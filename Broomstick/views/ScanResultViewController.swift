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
    var deleted: Int
    var kept: Int
    var screenshots: Int
    var incoherant: Int
    var duplicates: Int
    var scanFinished: Bool
    
    //chart view
    var chartView = PieChart()
    
    
    init (
        scanDate: Date, totalStorage: Double, deleted: Int, kept: Int, screenshots: Int, incoherant: Int, duplicates: Int, scanFinished: Bool
    ) {
        self.scanDate = scanDate
        self.totalStorage = totalStorage
        self.deleted = deleted
        self.kept = kept
        self.screenshots = screenshots
        self.incoherant = incoherant
        self.duplicates = duplicates
        self.scanFinished = scanFinished
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
        //chart view
        chartView.frame = CGRect(x: 85 * screenRatio, y: 164 * screenRatio, width: 200 * screenRatio, height: 200 * screenRatio)
        chartView.outerRadius = 100 * screenRatio
        chartView.innerRadius = 75 * screenRatio
        chartView.models = [PieSliceModel(value: Double(incoherant), color: darkColor), PieSliceModel(value: Double(screenshots), color: lightColor), PieSliceModel(value: Double(duplicates), color: whiteColor)]
        parent.addSubview(chartView)
        //you clearned
        let youCleaned = UILabel()
        youCleaned.frame = CGRect(x: 0, y: 0, width: 120 * screenRatio, height: 14 * screenRatio)
        youCleaned.textColor = whiteColor
        youCleaned.font = smallLabel
        youCleaned.text = "You Cleaned"
        parent.addSubview(youCleaned)
        youCleaned.translatesAutoresizingMaskIntoConstraints = false
        youCleaned.textAlignment = .center
        youCleaned.widthAnchor.constraint(equalToConstant: 120 * screenRatio).isActive = true
        youCleaned.heightAnchor.constraint(equalToConstant: 14 * screenRatio).isActive = true
        youCleaned.leadingAnchor.constraint(equalTo: parent.leadingAnchor, constant: 127 * screenRatio).isActive = true
        youCleaned.topAnchor.constraint(equalTo: parent.topAnchor, constant: 223 * screenRatio).isActive = true
        //number of GB clearned
        let numGBLabel = UILabel()
        numGBLabel.textAlignment = .center
        numGBLabel.frame = CGRect(x: 143 * screenRatio, y: 237 * screenRatio, width: 78 * screenRatio, height: 62 * screenRatio)
        numGBLabel.textColor = whiteColor
        numGBLabel.font = mediumNumber
        numGBLabel.text = "\(totalStorage)"
        parent.addSubview(numGBLabel)
        let gbData = UILabel()
        gbData.frame = CGRect(x: 0, y: 0, width: 120 * screenRatio, height: 14 * screenRatio)
        gbData.textColor = whiteColor
        gbData.font = smallLabel
        gbData.text = "GB Data"
        parent.addSubview(gbData)
        gbData.translatesAutoresizingMaskIntoConstraints = false
        gbData.textAlignment = .center
        gbData.widthAnchor.constraint(equalToConstant: 120 * screenRatio).isActive = true
        gbData.heightAnchor.constraint(equalToConstant: 14 * screenRatio).isActive = true
        gbData.leadingAnchor.constraint(equalTo: parent.leadingAnchor, constant: 127 * screenRatio).isActive = true
        gbData.topAnchor.constraint(equalTo: parent.topAnchor, constant: 295 * screenRatio).isActive = true
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
        deletedNumLabel.text = "\(deleted)"
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
        keptNumLabel.text = "\(kept * 3)"
        keptNumLabel.textAlignment = .center
        parent.addSubview(keptNumLabel)
        //incoherant
        parent.addSubview(labelCard(inputText: "Incoherant", color: darkColor, centerX: 110 * screenRatio, y: 530 * screenRatio))
        let badLabel = UILabel()
        badLabel.frame = CGRect(x: 0, y: 0, width: 60 * screenRatio, height: 14 * screenRatio)
        badLabel.center = CGPoint(x: 110 * screenRatio, y: 630 * screenRatio)
        badLabel.textColor = whiteColor
        badLabel.font = smallLabel
        badLabel.text = "Photos"
        badLabel.textAlignment = .center
        parent.addSubview(badLabel)
        let badNumLabel = UILabel()
        badNumLabel.frame = CGRect(x: 0, y: 0, width: 90 * screenRatio, height: 50 * screenRatio)
        badNumLabel.center = CGPoint(x: 110 * screenRatio, y: 595 * screenRatio)
        badNumLabel.textColor = whiteColor
        badNumLabel.font = mediumNumber
        badNumLabel.text = "\(incoherant)"
        badNumLabel.textAlignment = .center
        parent.addSubview(badNumLabel)
        //screenshots
        parent.addSubview(labelCard(inputText: "Screenshots", color: lightColor, centerX: 271 * screenRatio, y: 530 * screenRatio))
        let ssLabel = UILabel()
        ssLabel.frame = CGRect(x: 0, y: 0, width: 60 * screenRatio, height: 14 * screenRatio)
        ssLabel.center = CGPoint(x: 271 * screenRatio, y: 630 * screenRatio)
        ssLabel.textColor = whiteColor
        ssLabel.font = smallLabel
        ssLabel.text = "Photos"
        ssLabel.textAlignment = .center
        parent.addSubview(ssLabel)
        let ssNumLabel = UILabel()
        ssNumLabel.frame = CGRect(x: 0, y: 0, width: 90 * screenRatio, height: 50 * screenRatio)
        ssNumLabel.center = CGPoint(x: 271 * screenRatio, y: 595 * screenRatio)
        ssNumLabel.textColor = whiteColor
        ssNumLabel.font = mediumNumber
        ssNumLabel.text = "\(screenshots)"
        ssNumLabel.textAlignment = .center
        parent.addSubview(ssNumLabel)
        //duplicates
        parent.addSubview(labelCard(inputText: "Duplicates", color: whiteColor, centerX: 187.5 * screenRatio, y: 660 * screenRatio))
        let duplicatesLabel = UILabel()
        duplicatesLabel.frame = CGRect(x: 0, y: 0, width: 60 * screenRatio, height: 14 * screenRatio)
        duplicatesLabel.center = CGPoint(x: 187.5 * screenRatio, y: 760 * screenRatio)
        duplicatesLabel.textColor = whiteColor
        duplicatesLabel.font = smallLabel
        duplicatesLabel.text = "Photos"
        duplicatesLabel.textAlignment = .center
        parent.addSubview(duplicatesLabel)
        let duplicateNumLabel = UILabel()
        duplicateNumLabel.frame = CGRect(x: 0, y: 0, width: 90 * screenRatio, height: 50 * screenRatio)
        duplicateNumLabel.center = CGPoint(x: 187.5 * screenRatio, y: 725 * screenRatio)
        duplicateNumLabel.textColor = whiteColor
        duplicateNumLabel.font = mediumNumber
        duplicateNumLabel.text = "\(duplicates)"
        duplicateNumLabel.textAlignment = .center
        parent.addSubview(duplicateNumLabel)
        
        
        
    }
    
    
    
    @objc func goBack() {
        navigationController?.popViewController(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()
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
