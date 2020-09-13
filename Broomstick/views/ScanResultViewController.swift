//
//  FinishedScanResultViewController.swift
//  Broomstick
//
//  Created by Patrick Cui on 9/12/20.
//  Copyright © 2020 KC App Dev. All rights reserved.
//

import UIKit
import PieCharts

class ScanResultViewController: UIViewController {
    
    var scanDate: Date = Date()
    var totalStorage: Double
    var deleted: Int?
    var kept: Int?
    var screenshots: Int
    var incoherent: Int
    var duplicates: Int
    var reviewFinished: Bool
    var analyzer: PhotoAnalyzer?
    var photosToDelete: [UIImage]?
    
    //chart view
    var chartView = PieChart()
    //button
    let button = UIButton()
    
    
    init (
        scanDate: Date, totalStorage: Double, deleted: Int?, kept: Int?, screenshots: Int, incoherent: Int, duplicates: Int, reviewFinished: Bool, analyzer: PhotoAnalyzer?, photosToDelete: [UIImage]?
    ) {
        self.scanDate = scanDate
        self.totalStorage = totalStorage
        self.deleted = deleted
        self.kept = kept
        self.screenshots = screenshots
        self.incoherent = incoherent
        self.duplicates = duplicates
        self.reviewFinished = reviewFinished
        self.analyzer = analyzer
        self.photosToDelete = photosToDelete
        super.init(nibName: nil, bundle: nil)
    }
    
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUp() {
        //sets background color
        self.view.backgroundColor = mediumColor
        //parent view
        let parent = self.view!
        //back button
        let backButtonImage = UIImage(named: "back")
        let backButton = UIButton()
        backButton.frame = CGRect(x: 30 * screenRatio, y: 63 * screenRatio, width: 30 * screenRatio, height: 30 * screenRatio)
        backButton.setImage(backButtonImage, for: .normal)
        backButton.addTarget(self, action: #selector(goBack), for: .touchUpInside)
        parent.addSubview(backButton)
        //header
        let scanResultLabel = UILabel()
        scanResultLabel.frame = CGRect(x: 0, y: 0, width: 170 * screenRatio, height: 32 * screenRatio)
        scanResultLabel.textColor = whiteColor
        scanResultLabel.font = heading
        scanResultLabel.text = "Scan Result"
        parent.addSubview(scanResultLabel)
        scanResultLabel.translatesAutoresizingMaskIntoConstraints = false
        scanResultLabel.widthAnchor.constraint(equalToConstant: 170 * screenRatio).isActive = true
        scanResultLabel.heightAnchor.constraint(equalToConstant: 32 * screenRatio).isActive = true
        scanResultLabel.leadingAnchor.constraint(equalTo: parent.leadingAnchor, constant: 31 * screenRatio).isActive = true
        scanResultLabel.topAnchor.constraint(equalTo: parent.topAnchor, constant: 102 * screenRatio).isActive = true

        if (reviewFinished) {
            //date label
            let formatter = DateFormatter()
            formatter.dateFormat = "M/dd/yy"
            let dateLabel = UILabel()
            dateLabel.frame = CGRect(x: 0, y: 0, width: 80 * screenRatio, height: 14 * screenRatio)
            dateLabel.textColor = whiteColor
            dateLabel.font = smallLabel
            dateLabel.text = formatter.string(from: scanDate)
            parent.addSubview(dateLabel)
            dateLabel.translatesAutoresizingMaskIntoConstraints = false
            dateLabel.widthAnchor.constraint(equalToConstant: 80 * screenRatio).isActive = true
            dateLabel.heightAnchor.constraint(equalToConstant: 14 * screenRatio).isActive = true
            dateLabel.leadingAnchor.constraint(equalTo: parent.leadingAnchor, constant: 33 * screenRatio).isActive = true
            dateLabel.topAnchor.constraint(equalTo: parent.topAnchor, constant: 139 * screenRatio).isActive = true
            //deleted
            parent.addSubview(labelCard(inputText: "Deleted", color: UIColor(hex: "#C13C3Cff")!, centerX: 110 * screenRatio, y: 400 * screenRatio))
            //deleted photos
            let deletedLabel = UILabel()
            deletedLabel.frame = CGRect(x: 0, y: 0, width: 60 * screenRatio, height: 14 * screenRatio)
            deletedLabel.center = CGPoint(x: 110 * screenRatio, y: 500 * screenRatio)
            deletedLabel.textColor = whiteColor
            deletedLabel.font = smallLabel
            deletedLabel.text = "Photos"
            deletedLabel.textAlignment = .center
            parent.addSubview(deletedLabel)
            let deletedNumLabel = UILabel()
            deletedNumLabel.frame = CGRect(x: 0, y: 0, width: 61 * screenRatio, height: 50 * screenRatio)
            deletedNumLabel.center = CGPoint(x: 110 * screenRatio, y: 465 * screenRatio)
            deletedNumLabel.textColor = whiteColor
            deletedNumLabel.font = mediumNumber
            deletedNumLabel.text = "\(deleted ?? 0)"
            deletedNumLabel.textAlignment = .center
            parent.addSubview(deletedNumLabel)
            //kept
            parent.addSubview(labelCard(inputText: "Kept", color: UIColor(hex: "#3BD092ff")!, centerX: 271 * screenRatio, y: 400 * screenRatio))
            let keptLabel = UILabel()
            keptLabel.frame = CGRect(x: 0, y: 0, width: 60 * screenRatio, height: 14 * screenRatio)
            keptLabel.center = CGPoint(x: 271 * screenRatio, y: 500 * screenRatio)
            keptLabel.textColor = whiteColor
            keptLabel.font = smallLabel
            keptLabel.text = "Photos"
            keptLabel.textAlignment = .center
            parent.addSubview(keptLabel)
            let keptNumLabel = UILabel()
            keptNumLabel.frame = CGRect(x: 0, y: 0, width: 90 * screenRatio, height: 50 * screenRatio)
            keptNumLabel.center = CGPoint(x: 271 * screenRatio, y: 465 * screenRatio)
            keptNumLabel.textColor = whiteColor
            keptNumLabel.font = mediumNumber
            keptNumLabel.text = "\((kept ?? 0))"
            keptNumLabel.textAlignment = .center
            parent.addSubview(keptNumLabel)
        }

        //chart view
        chartView.frame = CGRect(x: 0, y: 0, width: ((reviewFinished) ? 200 : 240) * screenRatio, height: ((reviewFinished) ? 200 : 240) * screenRatio)
        chartView.center = CGPoint(x: 185 * screenRatio, y: ((reviewFinished) ? 264 : 270) * screenRatio)
        chartView.outerRadius = ((reviewFinished) ? 100 : 120) * screenRatio
        chartView.innerRadius = ((reviewFinished) ? 75 : 90) * screenRatio
        chartView.models = [PieSliceModel(value: Double(incoherent), color: darkColor), PieSliceModel(value: Double(screenshots), color: lightColor), PieSliceModel(value: Double(duplicates), color: whiteColor)]
        parent.addSubview(chartView)
        //you clearned
        let youCleaned = UILabel()
        youCleaned.frame = CGRect(x: 0, y: 0, width: 120 * screenRatio, height: 14 * screenRatio)
        youCleaned.textColor = whiteColor
        youCleaned.font = smallLabel
        youCleaned.text = (reviewFinished) ?  "You Cleaned" : "We Found"
        parent.addSubview(youCleaned)
        youCleaned.translatesAutoresizingMaskIntoConstraints = false
        youCleaned.textAlignment = .center
        youCleaned.widthAnchor.constraint(equalToConstant: 120 * screenRatio).isActive = true
        youCleaned.heightAnchor.constraint(equalToConstant: 14 * screenRatio).isActive = true
        youCleaned.leadingAnchor.constraint(equalTo: parent.leadingAnchor, constant: 127 * screenRatio).isActive = true
        youCleaned.topAnchor.constraint(equalTo: parent.topAnchor, constant: 223 * screenRatio).isActive = true
        //number of Space clearned
        let numSpaceLabel = UILabel()
        numSpaceLabel.textAlignment = .center
        numSpaceLabel.frame = CGRect(x: 0, y: 0, width: 120 * screenRatio, height: 62 * screenRatio)
        numSpaceLabel.center = chartView.center
        numSpaceLabel.textColor = whiteColor
        numSpaceLabel.font = mediumNumber
        numSpaceLabel.text = "\(totalStorage.rounded())"
        parent.addSubview(numSpaceLabel)
        let spaceData = UILabel()
        spaceData.frame = CGRect(x: 0, y: 0, width: 120 * screenRatio, height: 14 * screenRatio)
        spaceData.textColor = whiteColor
        spaceData.font = smallLabel
        spaceData.text = (reviewFinished) ? "MB Data" : "MB Waste"
        parent.addSubview(spaceData)
        spaceData.translatesAutoresizingMaskIntoConstraints = false
        spaceData.textAlignment = .center
        spaceData.widthAnchor.constraint(equalToConstant: 120 * screenRatio).isActive = true
        spaceData.heightAnchor.constraint(equalToConstant: 14 * screenRatio).isActive = true
        spaceData.leadingAnchor.constraint(equalTo: parent.leadingAnchor, constant: 127 * screenRatio).isActive = true
        spaceData.topAnchor.constraint(equalTo: parent.topAnchor, constant: 295 * screenRatio).isActive = true

        //incoherent
        parent.addSubview(labelCard(inputText: "Incoherent", color: darkColor, centerX: 110 * screenRatio, y:  ((reviewFinished) ? 530 : 430) * screenRatio))
        let badLabel = UILabel()
        badLabel.frame = CGRect(x: 0, y: 0, width: 60 * screenRatio, height: 14 * screenRatio)
        badLabel.center = CGPoint(x: 110 * screenRatio, y:  ((reviewFinished) ? 630 : 530) * screenRatio)
        badLabel.textColor = whiteColor
        badLabel.font = smallLabel
        badLabel.text = "Photos"
        badLabel.textAlignment = .center
        parent.addSubview(badLabel)
        let badNumLabel = UILabel()
        badNumLabel.frame = CGRect(x: 0, y: 0, width: 90 * screenRatio, height: 50 * screenRatio)
        badNumLabel.center = CGPoint(x: 110 * screenRatio, y:  ((reviewFinished) ? 595 : 495) * screenRatio)
        badNumLabel.textColor = whiteColor
        badNumLabel.font = mediumNumber
        badNumLabel.adjustsFontSizeToFitWidth = true
        badNumLabel.text = "\(incoherent)"
        badNumLabel.textAlignment = .center
        parent.addSubview(badNumLabel)
        //screenshots
        parent.addSubview(labelCard(inputText: "Screenshots", color: lightColor, centerX: 271 * screenRatio, y:  ((reviewFinished) ? 530 : 430) * screenRatio))
        let ssLabel = UILabel()
        ssLabel.frame = CGRect(x: 0, y: 0, width: 60 * screenRatio, height: 14 * screenRatio)
        ssLabel.center = CGPoint(x: 271 * screenRatio, y:  ((reviewFinished) ? 630 : 530) * screenRatio)
        ssLabel.textColor = whiteColor
        ssLabel.font = smallLabel
        ssLabel.text = "Photos"
        ssLabel.textAlignment = .center
        parent.addSubview(ssLabel)
        let ssNumLabel = UILabel()
        ssNumLabel.frame = CGRect(x: 0, y: 0, width: 90 * screenRatio, height: 50 * screenRatio)
        ssNumLabel.center = CGPoint(x: 271 * screenRatio, y:  ((reviewFinished) ? 595 : 495) * screenRatio)
        ssNumLabel.textColor = whiteColor
        ssNumLabel.font = mediumNumber
        ssNumLabel.text = "\(screenshots)"
        ssNumLabel.textAlignment = .center
        parent.addSubview(ssNumLabel)
        //duplicates
        parent.addSubview(labelCard(inputText: "Duplicates", color: whiteColor, centerX: 187.5 * screenRatio, y:  ((reviewFinished) ? 660 : 560) * screenRatio))
        let duplicatesLabel = UILabel()
        duplicatesLabel.frame = CGRect(x: 0, y: 0, width: 60 * screenRatio, height: 14 * screenRatio)
        duplicatesLabel.center = CGPoint(x: 187.5 * screenRatio, y:  ((reviewFinished) ? 760 : 660) * screenRatio)
        duplicatesLabel.textColor = whiteColor
        duplicatesLabel.font = smallLabel
        duplicatesLabel.text = "Photos"
        duplicatesLabel.textAlignment = .center
        parent.addSubview(duplicatesLabel)
        let duplicateNumLabel = UILabel()
        duplicateNumLabel.frame = CGRect(x: 0, y: 0, width: 90 * screenRatio, height: 50 * screenRatio)
        duplicateNumLabel.center = CGPoint(x: 187.5 * screenRatio, y:  ((reviewFinished) ? 725 : 625) * screenRatio)
        duplicateNumLabel.textColor = whiteColor
        duplicateNumLabel.font = mediumNumber
        duplicateNumLabel.text = "\(duplicates)"
        duplicateNumLabel.textAlignment = .center
        parent.addSubview(duplicateNumLabel)
        
        if !reviewFinished {
            button.frame = CGRect(x: 82 * screenRatio, y: 704 * screenRatio, width: 210 * screenRatio, height: 48 * screenRatio)
            button.layer.cornerRadius = 24 * screenRatio
            button.backgroundColor = darkColor
            button.setTitle("Review", for: .normal)
            button.titleLabel?.font = buttonText
            parent.addSubview(button)
            button.layer.shadowColor = UIColor.black.withAlphaComponent(0.25).cgColor
            button.layer.shadowOffset = CGSize(width: 0, height: 10 * screenRatio)
            button.layer.shadowRadius = 15 * screenRatio
            button.layer.shadowOpacity = 1.0
            button.layer.masksToBounds = false
            button.addTarget(self, action: #selector(continueCleanUp), for: .touchUpInside)
        }
        
    }
    
    @objc func continueCleanUp() {
        animateButton(inputButton: button)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            let vc = PhotoReviewViewController(analyer: self.analyzer!, displayPhotos: self.photosToDelete!)
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    
    
    @objc func goBack() {
        if !reviewFinished {
            navigationController?.popToRootViewController(animated: true)
        } else {
             navigationController?.popViewController(animated: true)
        }
       
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()
        scans.append(Scan(totalStorage: totalStorage, deleted: nil, kept: nil, incoherent: incoherent, screenshots: screenshots, duplicates: duplicates, reviewComplete: false, date: Date()))
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
