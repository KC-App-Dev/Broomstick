//
//  PhotoAnalyzer.swift
//  Broomstick
//
//  Created by Jimmy Kang on 6/28/20.
//  Copyright © 2020 KC App Dev. All rights reserved.
//
//  The class containing all logic for loading/classifying files


import Foundation
import Photos
import UIKit
import Vision

struct ImageAnalysis {
    // var metadata: [String: Any]
    // var image: UIImage
    var creation_date: Date
    var featureprint: VNFeaturePrintObservation
    var size_mb: Double
    var screenshot: Bool
    var blurry: Bool
}

enum TypeOfWaste {
    case screenshot
    case blurry
    case similar
    case normal
}

struct ScanStats {
    var screenshots: Int
    var blurry: Int
    var duplicates: Int
    var total_size: Double
}

struct SavedClean {
    var screenshots: Int
    var blurry: Int
    var duplicates: Int
    var kept: Int
    var size_detected: Double
    var size_cleaned: Double
    var date_cleaned: Date
    var completed: Bool
}

class PhotoAnalyzer {
    // device info
    var num_pics: Int = -1
    var total_image_size: Double = 0.0
    var dyn_total_image_size: Double = 0.0
    
    // mid analysis
    var photoCollection: PHFetchResult<PHAsset> = PHFetchResult()
    var image_data: [ImageAnalysis] = []
    var final_categorization: [TypeOfWaste] = []
    
    // post analysis(cleanup)
    var debug = false
    var similar_groups: [[Int]] = []
    var images_to_delete: [Int] = []
    var images_flagged: [Int] = []
    var current_review_arr: [Int] = []
    var current_categories: [TypeOfWaste] = []
    var total_deleted: Int = 0
    var sized_deleted: Float = 0.0
    
    // saving
    var clean_save: SavedClean = SavedClean(screenshots: -1, blurry: -1, duplicates: -1, kept: -1, size_detected: 0.0, size_cleaned: 0.0, date_cleaned: Date(), completed: true)
    
    init(debug_status: Bool = false) {
        if debug_status {
            print("Debug mode is on.")
        }
        debug = debug_status
    }
    
    func setup() {
        /*
         Sets up some convenience values. 
         */
        let fetchResult: PHFetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions())
        photoCollection = fetchResult
        let limit = 50
        print("debug: ", debug)
        print("photoCollection.count: ", photoCollection.count)
        if debug && photoCollection.count >= limit {
            num_pics = limit
        } else {
            num_pics = photoCollection.count
        }
        
        print("PhotoAnalyzer initialized. printing variables.")
        print("num_pics: ", num_pics)
    }
    
    func load_total_size() -> Double {
        return load_sizes_imgs(pic_indices: Array(0 ... num_pics-1))
    }
    
    func load_sizes_imgs(pic_indices: [Int]) -> Double {
        var total_size: Double = 0.0
        for i in pic_indices {
            let resources = PHAssetResource.assetResources(for: photoCollection.object(at:i))
            var size: Int64 = 0
            if let resource = resources.first {
                let unsignedInt64 = resource.value(forKey: "fileSize") as? CLong
                size = Int64(bitPattern: UInt64(unsignedInt64!))
                total_size += Double(size) / (1024.0*1024.0)
            }
        }
        self.total_image_size = total_size
        print("total sized calculated: ", total_size)
        return total_size
    }

    private func loadImage(index: Int) throws -> UIImage? {
        let manager = PHImageManager.default()
        var image: UIImage? = nil
        print("Image unique id: ", photoCollection.object(at: index).localIdentifier)
        manager.requestImage(for: try photoCollection.object(at: index), targetSize: CGSize(), contentMode: .aspectFill, options: generateRequestOptions()) {
            result, info in
            image = result
        }
        return image
    }
    
    private func fetchOptions() -> PHFetchOptions {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        return fetchOptions
    }
    
    private func generateRequestOptions() -> PHImageRequestOptions{
        let requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = true
        requestOptions.deliveryMode = .highQualityFormat
        return requestOptions
    }

    func request_perms(completionHandler: (Bool) -> Void) {
        print("requesting permissions...")
        var request_status = false;
        PHPhotoLibrary.requestAuthorization{
            received_status in
            print(received_status)
            if received_status == .authorized {
                request_status = true
            }
        }
        completionHandler(request_status)
    }
    
    func retrievePhoto(index: Int) throws -> UIImage? {
        let status = PHPhotoLibrary.authorizationStatus()
        var imageToReturn: UIImage?
        switch status {
            case .authorized:
                print("Authorized.")
                imageToReturn = try loadImage(index:index)
            case .restricted, .denied:
                print("Photo Auth has been restricted or denied.")
                imageToReturn = nil
            case .notDetermined:
                print("Permission is not determined.")
                var status : PHAuthorizationStatus = PHAuthorizationStatus(rawValue: 0)!
                PHPhotoLibrary.requestAuthorization {received_status in
                    status = received_status
                    print("received permission status: ", received_status)
                }
                switch status {
                    case .authorized:
                        imageToReturn = try self.loadImage(index: index)
                        /*
                        DispatchQueue.main.async {
                            imageToReturn = self.loadImage().unsafelyUnwrapped
                        }
                        */
                    case .restricted, .denied:
                        print("Photo Auth has been restricted or denied.^2")
                        imageToReturn = nil
                    case .notDetermined:
                        print("Permission is not determined.^2")
                        imageToReturn = nil
                }
            }
        if imageToReturn != nil {
            print("imageToReturn is not nil.")
        } else {
            print("imageToReturn is nil. ")
        }
        return imageToReturn
    }
    
    private func exif_does_exist(image: UIImage) -> Bool{
        let jpg_data = image.jpegData(compressionQuality: 1.0)!
        let source = CGImageSourceCreateWithData(jpg_data as CFData, nil)!
        let properties = CGImageSourceCopyPropertiesAtIndex(source, 0, nil)!
        let dict = properties as! [String: Any]
        print("exif dict: ", dict)
        return dict.keys.contains("{Exif}")
    }
    
    private func image_is_screenshot(image: UIImage, metadata:[String: Any]) -> Bool {
        /*
         Detects if an image is a screenshot, based on its dimensions vs. device dimensions.
         Arguments:
            image - image in question.
            metadata - metadata generated by fetch_metadata
         */
        print("analyzing for screenshot. ")
        let width = metadata["width"] as! Int
        let height = metadata["height"] as! Int
        let device_width = Int(UIScreen.main.bounds.size.width)
        let device_height = Int(UIScreen.main.bounds.size.height)
        return (width % device_width == 0) && (height % device_height == 0)
    }
    
    private func fetch_metadata(index: Int) -> [String: Any]{
        let photo_asset = photoCollection.object(at: index)
        return [
            "sourceType": photo_asset.sourceType,
            "width": photo_asset.pixelWidth,
            "height": photo_asset.pixelHeight,
            "creationDate": photo_asset.creationDate!,
            "modificationDate": photo_asset.modificationDate!,
            "location": photo_asset.location,
            "isFavorite": photo_asset.isFavorite,
            "isHidden": photo_asset.isHidden
        ]
    }
    
    private func mobilenet_results(image: UIImage) -> [(String, Double)] {
        let mobilenet_model = MobileNetV2()
        guard let vision_model = try? VNCoreMLModel(for: mobilenet_model.model) else {
            fatalError("VN errored out. ")
        }
        var return_results: [(String, Double)] = []
        let request = VNCoreMLRequest(model: vision_model) { request, error in
          if let observations = request.results as? [VNClassificationObservation] {

            // The observations appear to be sorted by confidence already, so we
            // take the top 5 and map them to an array of (String, Double) tuples.
            let top5 = observations.prefix(through: 4)
                                   .map { ($0.identifier, Double($0.confidence)) }
            print(top5)
            return_results = top5
          }
        }

        request.imageCropAndScaleOption = .centerCrop

        let handler = VNImageRequestHandler(cgImage: image.cgImage!)
        try? handler.perform([request])
        return return_results
    }
    
    private func generate_features(image: UIImage) -> VNFeaturePrintObservation {
        let request_handler = VNImageRequestHandler(cgImage: image.cgImage!)
        var feature_print = VNFeaturePrintObservation()
        let featureprint_request = VNGenerateImageFeaturePrintRequest() {
            request, error in
            if let feature_print_received = request.results as? [VNFeaturePrintObservation] {
                feature_print = feature_print_received[0]
            }
        }
        print("sending feature print request through. ")
        try? request_handler.perform([featureprint_request])
        return feature_print
    }
    
    private func test_similarity(pic1: Int, pic2: Int) {
        var distance: Float = -1.0
        do {
            try image_data[pic1].featureprint.computeDistance(&distance, to: image_data[pic2].featureprint)
            print("distance calculated: ", distance)
        } catch {
            print("error computing distance.")
        }
    }
    
    private func days_btwn_pics(pic1: Date, pic2: Date) -> Int {
        return Calendar.current.dateComponents([.day], from: pic1, to: pic2).day!
    }
    
    // functions to scan / generate data
    
    func complete_scan() {
        /*
         A function to demonstrate loopthroughs of the entire camera roll
         Simply prints the results for now.
         */
        
        image_data = Array(repeating: ImageAnalysis(creation_date: Date(), featureprint: VNFeaturePrintObservation(), size_mb: 0.0, screenshot: false, blurry: false), count: num_pics)
        var queue_total = 0
        var timestamp = NSDate()
        
        // test async loading
        let queue = OperationQueue()
        queue.name = "com.KCAppDev.concurrent"
        queue.qualityOfService = .userInitiated
        queue.maxConcurrentOperationCount = 10
        for i in 0 ... num_pics-1 {
            queue.addOperation {
                do {
                    print("TRYING INDEX: ", i)

                    let image_retrieved = try self.retrievePhoto(index: i)
                    
                    // metadata processing
                    let metadata = self.fetch_metadata(index: i)
                    print("metadata: ", metadata)
                    
                    // ml model processing
                    let blurry = self.mobilenet_results(image: image_retrieved!)[0].1 < 0.1
                    
                    // feature print processing
                    let feature_print = self.generate_features(image: image_retrieved!)
                    print("size in bytes: ", image_retrieved!.jpegData(compressionQuality: 1.0)!.count)

                    // add analysis to total array
                    let analysis = ImageAnalysis (
                        creation_date: metadata["creationDate"] as! Date,
                        featureprint: feature_print,
                        size_mb: Double(image_retrieved!.jpegData(compressionQuality: 1.0)!.count) / Double(1024 * 1024),
                        screenshot: self.image_is_screenshot(image: image_retrieved!, metadata: metadata),
                        blurry: blurry
                    )
                    self.image_data[i] = analysis
                    queue_total += 1
                } catch {
                    print("image could not be loaded.")
                }
            }
        }
        while !(queue_total >= num_pics) {}
        print("Async took: ", NSDate().timeIntervalSince(timestamp as Date))
        /*
        timestamp = NSDate()
        // generate image analysis data for all of the pictures(before final categorization)
        for i in 0...num_pics-1 {
            do {
                print("TRYING INDEX: ", i)
                
                let timestamp = NSDate()
                
                let image_retrieved = try retrievePhoto(index: i)
                
                print("time 1 so far: ", NSDate().timeIntervalSince(timestamp as Date))
                
                // metadata processing
                let metadata = fetch_metadata(index: i)
                print("metadata: ", metadata)
                
                print("time 2 so far: ", NSDate().timeIntervalSince(timestamp as Date))
                
                // ml model processing
                let blurry = mobilenet_results(image: image_retrieved!)[0].1 < 0.1
                
                print("time 3 so far: ", NSDate().timeIntervalSince(timestamp as Date))
                
                // feature print processing
                let feature_print = generate_features(image: image_retrieved!)
                print("size in bytes: ", image_retrieved!.jpegData(compressionQuality: 1.0)!.count)
                
                print("time 4 so far: ", NSDate().timeIntervalSince(timestamp as Date))
                
                // add analysis to total array
                let analysis = ImageAnalysis (
                    creation_date: metadata["creationDate"] as! Date,
                    featureprint: feature_print,
                    size_mb: Double(image_retrieved!.jpegData(compressionQuality: 1.0)!.count) / Double(1024 * 1024),
                    screenshot: image_is_screenshot(image: image_retrieved!, metadata: metadata),
                    blurry: blurry
                )
                image_data.append(analysis)
                
                print("time 5 so far: ", NSDate().timeIntervalSince(timestamp as Date))
            } catch {
                print("An unknown error occured.  Breaking out of loop. ")
                break
            }
        }
        print("Normal took: ", NSDate().timeIntervalSince(timestamp as Date))
        print("Loop is finished. Printing final image_data array.")
        print(image_data)
        */
        
        // loopthrough and decide final categorizations
        var i = 0
        for analysis in image_data {
            if analysis.screenshot {
                final_categorization.append(.screenshot)
            } else if analysis.blurry && !analysis.screenshot{
                final_categorization.append(.blurry)
            } else {
                if similar_groups.count > 0 {
                    let last_potential_similar = image_data[similar_groups[similar_groups.count-1][similar_groups[similar_groups.count-1].count-1]]
                    var distance: Float = 0
                    do {
                        try analysis.featureprint.computeDistance(&distance, to: last_potential_similar.featureprint)
                    } catch {
                        print("there was an error analyzing similarity. ")
                    }
                    // check if two pics were on the same day
                    if (days_btwn_pics(pic1: analysis.creation_date, pic2: last_potential_similar.creation_date) == 0) && distance < 10 {
                        similar_groups[similar_groups.count-1].append(i)
                    } else {
                        similar_groups.append([i])
                    }
                } else {
                    print("appending i value: ", i)
                    similar_groups.append([i])
                }
                // keep in mind, at this point the normal is not confirmed.
                final_categorization.append(.normal)
            }
            i += 1
        }
        
        // remove single groups in similar
        i = 0
        var limit = similar_groups.count
        while i < limit {
            if similar_groups[i].count == 1 {
                similar_groups.remove(at: i)
                limit -= 1
            } else {
                for index in similar_groups[i] {
                    final_categorization[index] = .similar
                }
                i += 1
            }
        }
        
        // loopthrough categorizations and generate list of indices to display to user
        i = 0
        for category in final_categorization {
            if category != .normal {
                images_flagged.append(i)
            }
            i += 1
        }
        
        print("similarity analysis complete. ")
        print("final similarity vector: ", similar_groups)
        print("final categorization", final_categorization)
        
    }
    
    func delete_selected_images() -> Bool{
        /*
         Deletes the images with indices included in images_to_delete.
         You must select the images to delete in images_to_delete before running this function.
         */
        total_deleted = images_to_delete.count
        var i = 0
        var limit = images_to_delete.count
        var assets_to_delete:[PHAsset] = []
        let library = PHPhotoLibrary.shared()
        while i < limit {
            assets_to_delete.append(photoCollection.object(at:images_to_delete[i]))
            i += 1
        }
        do {
            try library.performChangesAndWait({PHAssetChangeRequest.deleteAssets(assets_to_delete as NSFastEnumeration)})
        } catch {
            print("something went wrong with deleting the images.")
        }
        
        return true
    }
    
    func scan_results() -> ScanStats {
        /*
         Returns results of scan in an easily displayable manner. Assumes
         scan is complete.
         */
        var screenshots = 0
        var blurry = 0
        var duplicates = 0
        var normal = 0
        var imgs_interest: [Int] = []
        var i = 0
        for img in final_categorization {
            switch img {
                case .blurry:
                    blurry += 1
                    imgs_interest.append(i)
                case .screenshot:
                    screenshots += 1
                    imgs_interest.append(i)
                case .similar:
                    duplicates += 1
                    imgs_interest.append(i)
                case .normal:
                    normal += 1
            }
            i += 1
        }
        return ScanStats (screenshots: screenshots, blurry: blurry, duplicates: duplicates, total_size: load_sizes_imgs(pic_indices: imgs_interest))
    }
    
    // functions to clean / display images to users
    func all_images_to_display() -> [UIImage] {
        var images_arr: [UIImage] = []
        for index in images_flagged {
            do {
                current_review_arr.append(index)
                images_arr.append(try loadImage(index: index)!)
                current_categories.append(final_categorization[index])
            } catch {
                print("something went wrong while converting index to image.")
            }
        }
        return images_arr
    }
    
    func update_self_save() {
        let scanresults = scan_results()
        clean_save = SavedClean(screenshots: scanresults.screenshots, blurry: scanresults.blurry, duplicates: scanresults.duplicates, kept: scanresults.screenshots+scanresults.blurry+scanresults.duplicates-images_to_delete.count, size_detected: scanresults.total_size, size_cleaned: 12.6, date_cleaned: Date(), completed: true)
    }
    
    func category_images_to_display(category: TypeOfWaste) -> [UIImage] {
        var images_arr: [UIImage] = []
        current_review_arr = []
        for index in images_flagged {
            do {
                if final_categorization[index] == category {
                    images_arr.append(try loadImage(index: index)!)
                    current_review_arr.append(index)
                    current_categories.append(final_categorization[index])
                }
            } catch {
                print("something went wrong while converting index to image.")
            }
        }
        return images_arr
    }
    
    func swiped(index: Int, delete: Bool) {
        /*
         Updates the images_to_delete array with index referring to current_review_arr.
         current_review_arr[index] returns index referring to the actual photocollection.
         */
        if delete{
            print("updating images_to_delete. adding: ", current_review_arr[index])
            images_to_delete.append(current_review_arr[index])
        }
    }
    
    func delete_categories() -> [TypeOfWaste] {
        /*
         Returns the categories of each image in current_categories
         */
        return current_categories
    }
    
    func update_images_to_delete(indices: [Int]) {
        /*
         Delete images. The indices passed in are applied to images_flagged.
         */
        for index in indices {
            images_to_delete.append(images_flagged[index])
        }
    }
    
    func save_clean(save: SavedClean) {
        let defaults = UserDefaults.standard
        var past_cleans: [SavedClean] = []
        var loaded_cleans = defaults.object(forKey: "pastCleans") as? [SavedClean]
        if loaded_cleans == nil {
            past_cleans = []
        } else {
            past_cleans = loaded_cleans!
        }
        past_cleans.append(clean_save)
        defaults.set(past_cleans, forKey: "pastCleans")
    }
}
