//
//  PreferencesViewController.swift
//  Broomstick
//
//  Created by Patrick Cui on 9/12/20.
//  Copyright © 2020 KC App Dev. All rights reserved.
//

import UIKit

class PreferencesViewController: UIViewController {
    
    func setUp() {
        self.view.backgroundColor = darkColor
        let parent = self.view!
        //back button
        let backButtonImage = UIImage(named: "back")
        let backButton = UIButton()
        backButton.frame = CGRect(x: 30 * screenRatio, y: 63 * screenRatio, width: 30 * screenRatio, height: 30 * screenRatio)
        backButton.setImage(backButtonImage, for: .normal)
        backButton.addTarget(self, action: #selector(goBack), for: .touchUpInside)
        parent.addSubview(backButton)
    }
    
    @objc func goBack() {
        dismiss(animated: true, completion: nil)
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
