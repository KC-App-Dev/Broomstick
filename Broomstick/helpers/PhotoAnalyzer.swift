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
    
}

class PhotoAnalyzer {
    
    var photoCollection: PHFetchResult<PHAsset> = PHFetchResult()
    var num_pics: Int = -1
    var image_data: [ImageAnalysis] = []
    var final_categorization: [TypeOfWaste] = []
    var similar_groups: [[Int]] = []
    var images_to_delete: [Int] = []
    var total_image_size: Double = 0.0
    
    init(debug: Bool = false) {
        if debug {
            print("Debug mode is on.")
        }
    }
    
    func setup() {
        /*
         Sets up some convenience values. 
         */
        let fetchResult: PHFetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions())
        photoCollection = fetchResult
        num_pics = photoCollection.count
        
        print("PhotoAnalyzer initialized. printing variables.")
        print("num_pics: ", num_pics)
    }
    
    func load_total_size() -> Double {
        var total_size: Double = 0.0
        for i in 0 ... num_pics-1 {
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

    func request_perms() {
    print("requesting permissions...")
    PHPhotoLibrary.requestAuthorization{
        received_status in
        print(received_status)
    }
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
        let width = metadata["width"] as! Int
        let height = metadata["height"] as! Int
        let device_width = Int(UIScreen.main.bounds.size.height)
        let device_height = Int(UIScreen.main.bounds.size.width)
        return (width == device_width) && (height == device_height)
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
    
    func complete_scan() {
        /*
         A function to demonstrate loopthroughs of the entire camera roll
         Simply prints the results for now.
         */
        
        // generate image analysis data for all of the pictures(before final categorization)
        for i in 0...num_pics-1 {
            do {
                print("TRYING INDEX: ", i)
                let image_retrieved = try retrievePhoto(index: i)
                
                // metadata processing
                let metadata = fetch_metadata(index: i)
                print("metadata: ", metadata)
                
                // ml model processing
                let blurry = mobilenet_results(image: image_retrieved!)[0].1 < 0.1
                
                // feature print processing
                let feature_print = generate_features(image: image_retrieved!)
                print("size in bytes: ", image_retrieved!.jpegData(compressionQuality: 1.0)!.count)
                
                // add analysis to total array
                let analysis = ImageAnalysis (
                    creation_date: metadata["creationDate"] as! Date,
                    featureprint: feature_print,
                    size_mb: Double(image_retrieved!.jpegData(compressionQuality: 1.0)!.count) / Double(1024 * 1024),
                    screenshot: image_is_screenshot(image: image_retrieved!, metadata: metadata),
                    blurry: blurry
                )
                image_data.append(analysis)
            } catch {
                print("An unknown error occured.  Breaking out of loop. ")
                break
            }
        }
        print("Loop is finished. Printing final image_data array.")
        print(image_data)
        
        // loopthrough and decide final categorizations
        var i = 0
        for analysis in image_data {
            if analysis.screenshot {
                final_categorization.append(.screenshot)
            } else if analysis.blurry {
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
        
        print("similarity analysis complete. ")
        print("final similarity vector: ", similar_groups)
        print("final categorization", final_categorization)
        
    }
    
    func delete_selected_images() {
        /*
         Deletes the images with indices included in images_to_delete.
         You must select the images to delete in images_to_delete before running this function.
         */
        var i = 0
        var limit = images_to_delete.count
        var assets_to_delete:[PHAsset] = []
        let library = PHPhotoLibrary.shared()
        while i < limit {
            assets_to_delete.append(photoCollection.object(at:images_to_delete[i]))
            i += 1
        }
        library.performChanges({PHAssetChangeRequest.deleteAssets(assets_to_delete as NSFastEnumeration)})
    }
}
