//
//  ScanLoadingViewController.swift
//  Broomstick
//
//  Created by Patrick Cui on 9/12/20.
//  Copyright © 2020 KC App Dev. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class ScanLoadingViewController: UIViewController {
    
    var labelText = "Analyzing..."
    let loadingTextLabel = UILabel()
    let activityIndicator = NVActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 150 * screenRatio, height: 150 * screenRatio))
    
    func setUp() {
        //change background ccolor
        self.view.backgroundColor = mediumColor
        //the loading animation
        activityIndicator.type = .pacman
        activityIndicator.color = whiteColor
        activityIndicator.padding = 20 * screenRatio
        activityIndicator.center = CGPoint(x: self.view.center.x + 10 * screenRatio, y: self.view.center.y - 20 * screenRatio)
        activityIndicator.startAnimating()
        self.view.addSubview(activityIndicator)
        //the text label below the loading animation
        loadingTextLabel.frame = CGRect(x: self.view.center.x - 100 * screenRatio, y: self.view.center.y + 5 * screenRatio, width: 200 * screenRatio, height: 100 * screenRatio)
        loadingTextLabel.text = labelText
        loadingTextLabel.textAlignment = .center
        
        loadingTextLabel.font = headingSmall
        loadingTextLabel.textColor = .white
        self.view.addSubview(loadingTextLabel)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        processImages()
    }
    
    func processImages() {
        let analyzer = PhotoAnalyzer(debug_status: true)
        analyzer.setup()
        analyzer.complete_scan()
        let results = analyzer.scan_results()
        print(results)
        let vc = ScanResultViewController(scanDate: Date(), totalStorage: results.total_size, deleted: nil, kept: nil, screenshots: results.screenshots, incoherant: results.blurry, duplicates: results.duplicates, reviewFinished: false, analyzer: analyzer)
        self.navigationController?.pushViewController(vc, animated: true)
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
