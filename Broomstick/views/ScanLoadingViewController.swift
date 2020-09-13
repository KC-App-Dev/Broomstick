//
//  ScanLoadingViewController.swift
//  Broomstick
//
//  Created by Patrick Cui on 9/12/20.
//  Copyright © 2020 KC App Dev. All rights reserved.
//

import UIKit

class ScanLoadingViewController: UIViewController {
    
    func setUp() {
        self.view.backgroundColor = mediumColor
        let tempLoadingLabel = UILabel()
        tempLoadingLabel.frame = CGRect(x: 0, y: 0, width: 200, height: 100)
        tempLoadingLabel.center = self.view.center
        tempLoadingLabel.text = "Loading..."
        tempLoadingLabel.textAlignment = .center
        
        tempLoadingLabel.font = headingSmall
        tempLoadingLabel.textColor = .white
        self.view.addSubview(tempLoadingLabel)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()
  
    }
    
    func processImages() {
        let analyzer = PhotoAnalyzer()
        analyzer.setup()
        analyzer.complete_scan()
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
