//
//  FinishedScanViewController.swift
//  Broomstick
//
//  Created by Patrick Cui on 9/13/20.
//  Copyright © 2020 KC App Dev. All rights reserved.
//

import UIKit

class FinishedScanViewController: UIViewController {
    
    let totalDeleted: Int
    
    init(totalDeleted: Int) {
        self.totalDeleted = totalDeleted
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    let button = UIButton()
    
    func setUp() {
        self.view.backgroundColor = mediumColor
        //image
        let imageView = UIImageView()
        imageView.frame = CGRect(x: 0, y: 0, width: 270 * screenRatio, height: 180 * screenRatio)
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "trophy")
        imageView.center = CGPoint(x: self.view.center.x, y: self.view.center.y - 60 * screenRatio)
        self.view.addSubview(imageView)
        //label
        let _label = UILabel()
        _label.frame = CGRect(x: 0, y: 0, width: 280 * screenRatio, height: 100 * screenRatio)
        _label.textAlignment = .center
        _label.text = "Congrats! You cleaned \(totalDeleted) bad photos from your photo library!"
        _label.font = boldLabel
        _label.textColor = whiteColor
        _label.numberOfLines = 3
        _label.center = CGPoint(x: self.view.center.x, y: self.view.center.y + 60 * screenRatio)
        self.view.addSubview(_label)
        //button
        button.frame = CGRect(x: 82 * screenRatio, y: 704 * screenRatio, width: 210 * screenRatio, height: 48 * screenRatio)
        button.layer.cornerRadius = 24 * screenRatio
        button.backgroundColor = lightColor
        button.setTitle("Back to Home", for: .normal)
        button.titleLabel?.font = buttonText
        self.view.addSubview(button)
        button.layer.shadowColor = UIColor.black.withAlphaComponent(0.25).cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 10 * screenRatio)
        button.layer.shadowRadius = 15 * screenRatio
        button.layer.shadowOpacity = 1.0
        button.layer.masksToBounds = false
        button.addTarget(self, action: #selector(backToHome), for: .touchUpInside)
    }
    
    @objc func backToHome() {
        animateButton(inputButton: button)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            self.navigationController?.popToRootViewController(animated: true)
        }
        
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
