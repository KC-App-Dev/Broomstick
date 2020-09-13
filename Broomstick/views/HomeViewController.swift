//
//  HomeViewController.swift
//  Broomstick
//
//  Created by Patrick Cui on 9/11/20.
//  Copyright © 2020 KC App Dev. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {
    
    //***(TEMP)*** number of recent scans variable
    let scans = [[30, 25, true], [45, 12, true]]
    
    
    //button as class var
    let button = UIButton()
    let detailButton1 = UIButton()
    let detailButton2 = UIButton()
    
    //menu
    let containerView = UIView()
    var slideUpView = UIView()
    let slideUpViewHeight = CGFloat(500)
    let slideUpTableView = UITableView()
    let menuDataSource: [Int: (UIImage?, String)] = [
        0: (UIImage(named: "info"), "About"),
        1: (UIImage(named: "lock"), "Privacy"),
        2: (UIImage(named: "alert"), "Report a Bug"),
        3: (UIImage(named: "user"), "Contact"),
        4: (UIImage(named: "settings"), "Preferences")
    ]
    
    
    func initializeRatio() {
        //sets the screen ratio of the current device
        let width = self.view.frame.width
        screenRatio = width / 375 as CGFloat
        assert(screenRatio != 0)
        //adjusts the fonts based on the current ratio
        bigNumber = UIFont(name: "ProximaNova-SemiBold", size: 60 * screenRatio)
        mediumNumber = UIFont(name: "ProximaNova-Bold", size: 50 * screenRatio)
        number = UIFont(name: "ProximaNova-Bold", size: 36 * screenRatio)
        heading = UIFont(name: "ProximaNova-Bold", size: 32 * screenRatio)
        headingSmall = UIFont(name: "ProximaNova-Bold", size: 24 * screenRatio)
        buttonText = UIFont(name: "ProximaNova-Bold", size: 24 * screenRatio)
        boldLabel = UIFont(name: "ProximaNova-Bold", size: 18 * screenRatio)
        label = UIFont(name: "ProximaNova-Regular", size: 18 * screenRatio)
        smallLabel = UIFont(name: "ProximaNova-Regular", size: 14 * screenRatio)
    }
    
    func setUp() {
        //background color
        self.view.backgroundColor = mediumColor
        //parent variable
        let parent = self.view!
        //menu bar image
        let menuButtonImage = UIImage(named: "menu")
        //menu bar
        let menuButton = UIButton()
        menuButton.frame = CGRect(x: 40 * screenRatio, y: 70 * screenRatio, width: 30 * screenRatio, height: 30 * screenRatio)
        menuButton.setImage(menuButtonImage, for: .normal)
        menuButton.addTarget(self, action: #selector(showMenu), for: .touchUpInside)
        parent.addSubview(menuButton)
        //Your Photos
        let yourPhotosView = UILabel()
        yourPhotosView.frame = CGRect(x: 0, y: 0, width: 175 * screenRatio, height: 32 * screenRatio)
        yourPhotosView.textColor = whiteColor
        yourPhotosView.font = UIFont(name: "ProximaNova-Bold", size: 32 * screenRatio)
        yourPhotosView.text = "Your Photos"
        self.view.addSubview(yourPhotosView)
        yourPhotosView.translatesAutoresizingMaskIntoConstraints = false
        yourPhotosView.widthAnchor.constraint(equalToConstant: 175 * screenRatio).isActive = true
        yourPhotosView.heightAnchor.constraint(equalToConstant: 32 * screenRatio).isActive = true
        yourPhotosView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 40 * screenRatio).isActive = true
        yourPhotosView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 130 * screenRatio).isActive = true
        //Number of photos
        let numPhotosView = UILabel()
        numPhotosView.frame = CGRect(x: 0, y: 0, width: 145 * screenRatio, height: 60 * screenRatio)
        numPhotosView.textColor = whiteColor
        numPhotosView.font = bigNumber
        numPhotosView.textAlignment = .center
        let numFormat = NumberFormatter()
        numFormat.numberStyle = .decimal
        numPhotosView.text = numFormat.string(from: NSNumber(value: numPhotos()))
        parent.addSubview(numPhotosView)
        numPhotosView.translatesAutoresizingMaskIntoConstraints = false
        numPhotosView.widthAnchor.constraint(equalToConstant: 200 * screenRatio).isActive = true
        numPhotosView.heightAnchor.constraint(equalToConstant: 60 * screenRatio).isActive = true
        numPhotosView.leadingAnchor.constraint(equalTo: parent.leadingAnchor, constant: 87.5 * screenRatio).isActive = true
        numPhotosView.topAnchor.constraint(equalTo: parent.topAnchor, constant: 198 * screenRatio).isActive = true
        //Number of Photos Label
        let totalPhotosLael = UILabel()
        totalPhotosLael.frame = CGRect(x: 0, y: 0, width: 97 * screenRatio, height: 18 * screenRatio)
        totalPhotosLael.textColor = whiteColor
        totalPhotosLael.font = label
        totalPhotosLael.textAlignment = .center
        totalPhotosLael.text = "Total Photos"
        parent.addSubview(totalPhotosLael)
        totalPhotosLael.translatesAutoresizingMaskIntoConstraints = false
        totalPhotosLael.widthAnchor.constraint(equalToConstant: 97 * screenRatio).isActive = true
        totalPhotosLael.heightAnchor.constraint(equalToConstant: 18 * screenRatio).isActive = true
        totalPhotosLael.leadingAnchor.constraint(equalTo: parent.leadingAnchor, constant: 139 * screenRatio).isActive = true
        totalPhotosLael.topAnchor.constraint(equalTo: parent.topAnchor, constant: 256 * screenRatio).isActive = true
        //Total Storage
        let numSpace = UILabel()
        numSpace.frame = CGRect(x: 0, y: 0, width: 122 * screenRatio, height: 60 * screenRatio)
        numSpace.textColor = whiteColor
        numSpace.font = bigNumber
        numSpace.textAlignment = .center
        numSpace.text = "\(numStorage())"
        parent.addSubview(numSpace)
        numSpace.translatesAutoresizingMaskIntoConstraints = false
        numSpace.widthAnchor.constraint(equalToConstant: 122 * screenRatio).isActive = true
        numSpace.heightAnchor.constraint(equalToConstant: 60 * screenRatio).isActive = true
        numSpace.leadingAnchor.constraint(equalTo: parent.leadingAnchor, constant: 131 * screenRatio).isActive = true
        numSpace.topAnchor.constraint(equalTo: parent.topAnchor, constant: 311 * screenRatio).isActive = true
        //Total Storage Label
        let storageLabel = UILabel()
        storageLabel.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 18 * screenRatio)
        storageLabel.textColor = whiteColor
        storageLabel.font = label
        storageLabel.textAlignment = .center
        storageLabel.text = "MB Storage Used"
        parent.addSubview(storageLabel)
        storageLabel.translatesAutoresizingMaskIntoConstraints = false
        storageLabel.widthAnchor.constraint(equalToConstant: self.view.frame.width).isActive = true
        storageLabel.heightAnchor.constraint(equalToConstant: 18 * screenRatio).isActive = true
        storageLabel.topAnchor.constraint(equalTo: parent.topAnchor, constant: 368 * screenRatio).isActive = true
        //Recent Clean Ups
        let recentCleanUpsView = UILabel()
        recentCleanUpsView.frame = CGRect(x: 0, y: 0, width: 195 * screenRatio, height: 24 * screenRatio)
        recentCleanUpsView.textColor = whiteColor
        recentCleanUpsView.font = headingSmall
        recentCleanUpsView.text = "Recent Clean-Ups"
        parent.addSubview(recentCleanUpsView)
        recentCleanUpsView.translatesAutoresizingMaskIntoConstraints = false
        recentCleanUpsView.widthAnchor.constraint(equalToConstant: 195 * screenRatio).isActive = true
        recentCleanUpsView.heightAnchor.constraint(equalToConstant: 24 * screenRatio).isActive = true
        recentCleanUpsView.leadingAnchor.constraint(equalTo: parent.leadingAnchor, constant: 37 * screenRatio).isActive = true
        recentCleanUpsView.topAnchor.constraint(equalTo: parent.topAnchor, constant: 428 * screenRatio).isActive = true
        
        if scans.count == 0 {
            //Image for no scans
            let noScanImageView = UIImageView()
            noScanImageView.frame = CGRect(x: 107 * screenRatio, y: 494 * screenRatio, width: 160 * screenRatio, height: 126 * screenRatio)
            noScanImageView.image = UIImage(named: "noRecentScans")
            parent.addSubview(noScanImageView)
            //No scans label
            let noScanLabel = UILabel()
            noScanLabel.frame = CGRect(x: 0, y: 0, width: 135 * screenRatio, height: 18 * screenRatio)
            noScanLabel.textColor = whiteColor
            noScanLabel.font = label
            noScanLabel.text = "No Recent Scans"
            parent.addSubview(noScanLabel)
            noScanLabel.translatesAutoresizingMaskIntoConstraints = false
            noScanLabel.widthAnchor.constraint(equalToConstant: 135 * screenRatio).isActive = true
            noScanLabel.heightAnchor.constraint(equalToConstant: 18 * screenRatio).isActive = true
            noScanLabel.leadingAnchor.constraint(equalTo: parent.leadingAnchor, constant: 120 * screenRatio).isActive = true
            noScanLabel.topAnchor.constraint(equalTo: parent.topAnchor, constant: 634 * screenRatio).isActive = true
        } else if scans.count == 1 {
            parent.addSubview(recentScan(totalPhotos: 0, deletedPhotos: 0, reviewComplete: false, upper: true, action: #selector(showDetail)))
        } else {
            parent.addSubview(recentScan(totalPhotos: 30, deletedPhotos: 20, reviewComplete: true, upper: true, action: #selector(showDetail)))
            parent.addSubview(recentScan(totalPhotos: 45, deletedPhotos: 12, reviewComplete: true, upper: false, action: #selector(showDetail)))
        }
  
        //button
        button.frame = CGRect(x: 82 * screenRatio, y: 704 * screenRatio, width: 210 * screenRatio, height: 48 * screenRatio)
        button.layer.cornerRadius = 24 * screenRatio
        button.backgroundColor = darkColor
        button.setTitle("Clean Up", for: .normal)
        button.titleLabel?.font = buttonText
        parent.addSubview(button)
        button.layer.shadowColor = UIColor.black.withAlphaComponent(0.25).cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 10 * screenRatio)
        button.layer.shadowRadius = 15 * screenRatio
        button.layer.shadowOpacity = 1.0
        button.layer.masksToBounds = false
        button.addTarget(self, action: #selector(cleanUp), for: .touchUpInside)
        
        //menu table view
        slideUpTableView.isScrollEnabled = false
        slideUpTableView.delegate = self
        slideUpTableView.dataSource = self
        slideUpTableView.register(SlideUpViewCell.self, forCellReuseIdentifier: "SlideUpViewCell")
    }
    
    func numPhotos() -> Int {
        //returns the total number of photos in the user's photo library
        let analyzer = PhotoAnalyzer()
        analyzer.setup()
        let num_pics = analyzer.num_pics
        return num_pics
    }
    
    func numStorage() -> Double {
        //returns the total Space of storage taken up by photos
        let cutoff = 0.01
        let analyzer = PhotoAnalyzer()
        analyzer.setup()
        let size = analyzer.load_total_size()
        return (size - size.truncatingRemainder(dividingBy: cutoff)).rounded()
    }
    
    func loadPastCleans() -> [SavedClean]? {
        let defaults = UserDefaults.standard
        let past_cleans = defaults.object(forKey: "pastCleans") as? [SavedClean]
        return past_cleans
    }
    
    func recentScan(totalPhotos: Int, deletedPhotos: Int, reviewComplete: Bool, upper: Bool, action: Selector) -> UIView {
        //background white tab
        let view = UIView()
        view.frame = CGRect(x: 37 * screenRatio, y: (upper ? 468 : 568) * screenRatio, width: 301 * screenRatio, height: 76 * screenRatio)
        view.backgroundColor = .white
        view.layer.cornerRadius = 30 * screenRatio
        view.layer.shadowOpacity = 1.0
        view.layer.shadowColor = blackColor.withAlphaComponent(0.5).cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 10 * screenRatio)
        view.layer.shadowRadius = 10 * screenRatio
        //content stack view & assocaited var
        //total photos
        let totalPhotosLabel = UILabel()
        totalPhotosLabel.frame = CGRect(x: 0, y: 0, width: 44 * screenRatio, height: 36 * screenRatio)
        totalPhotosLabel.text = "\(totalPhotos)"
        totalPhotosLabel.textColor = darkColor
        totalPhotosLabel.font = number
        let totalPhotosDesc = UILabel()
        totalPhotosDesc.frame = CGRect(x: 0, y: 0, width: 50 * screenRatio, height: 14 * screenRatio)
        totalPhotosDesc.text = "Photos"
        totalPhotosDesc.textColor = darkColor
        totalPhotosDesc.font = smallLabel
        let totalPhotosView = UIStackView(arrangedSubviews: [totalPhotosLabel, totalPhotosDesc])
        totalPhotosView.frame = CGRect(x: 16 * screenRatio, y: view.frame.height / 2 - 23 * screenRatio, width: 70 * screenRatio, height: 50 * screenRatio)
        totalPhotosView.axis = .vertical
        totalPhotosView.alignment = .center
        //total deleted
        let totalDeletedLabel = UILabel()
        totalDeletedLabel.frame = CGRect(x: 0, y: 0, width: 44 * screenRatio, height: 36 * screenRatio)
        totalDeletedLabel.text = "\(deletedPhotos)"
        totalDeletedLabel.textColor = darkColor
        totalDeletedLabel.font = number
        let deletedPhotoDesc = UILabel()
        deletedPhotoDesc.frame = CGRect(x: 0, y: 0, width: 50 * screenRatio, height: 14 * screenRatio)
        deletedPhotoDesc.text = "Photos"
        deletedPhotoDesc.textColor = darkColor
        deletedPhotoDesc.font = smallLabel
        let deletedPhotosView = UIStackView(arrangedSubviews: [totalDeletedLabel, deletedPhotoDesc])
        deletedPhotosView.frame = CGRect(x: 86 * screenRatio, y: view.frame.height / 2 - 23 * screenRatio, width: 70 * screenRatio, height: 50 * screenRatio)
        deletedPhotosView.axis = .vertical
        deletedPhotosView.alignment = .center
        if (upper) {
            detailButton1.frame = CGRect(x: 170 * screenRatio, y: view.frame.height / 2 - 24 * screenRatio * screenRatio, width: 115 * screenRatio, height: 48 * screenRatio)
            detailButton1.backgroundColor = (reviewComplete) ? darkColor : lightColor
            detailButton1.setTitle(reviewComplete ? "View" : "Continue", for: .normal)
            detailButton1.titleLabel?.font = boldLabel
            detailButton1.layer.cornerRadius = 24 * screenRatio
            detailButton1.layer.shadowOpacity = 1.0
            detailButton1.layer.shadowColor = blackColor.withAlphaComponent(0.25).cgColor
            detailButton1.layer.shadowRadius = 10 * screenRatio
            detailButton1.layer.shadowOffset = CGSize(width: 0, height: 10 * screenRatio)
            detailButton1.layer.masksToBounds = false
            detailButton1.tag = upper ? 0 : 1
            detailButton1.addTarget(self, action: action, for: .touchUpInside)
            view.addSubview(detailButton1)
        } else {
            detailButton2.frame = CGRect(x: 170 * screenRatio, y: view.frame.height / 2 - 24 * screenRatio * screenRatio, width: 115 * screenRatio, height: 48 * screenRatio)
            detailButton2.backgroundColor = (reviewComplete) ? darkColor : lightColor
            detailButton2.setTitle(reviewComplete ? "View" : "Continue", for: .normal)
            detailButton2.titleLabel?.font = boldLabel
            detailButton2.layer.cornerRadius = 24 * screenRatio
            detailButton2.layer.shadowOpacity = 1.0
            detailButton2.layer.shadowColor = blackColor.withAlphaComponent(0.25).cgColor
            detailButton2.layer.shadowRadius = 10 * screenRatio
            detailButton2.layer.shadowOffset = CGSize(width: 0, height: 10 * screenRatio)
            detailButton2.layer.masksToBounds = false
            detailButton2.tag = upper ? 0 : 1
            detailButton2.addTarget(self, action: action, for: .touchUpInside)
            view.addSubview(detailButton2)
        }
        
        view.addSubview(totalPhotosView)
        view.addSubview(deletedPhotosView)
        
        return view
    }
    
    
    @objc func showMenu() {
        //shows the hamburger menu
        let window = UIApplication.shared.connectedScenes        .filter({$0.activationState == .foregroundActive})
            .map({$0 as? UIWindowScene})
            .compactMap({$0})
            .first?.windows
            .filter({$0.isKeyWindow}).first
        let screenSize = UIScreen.main.bounds.size
        containerView.backgroundColor = blackColor.withAlphaComponent(0.95)
        containerView.frame = self.view.frame
        window?.addSubview(containerView)
        let _recognizer = UITapGestureRecognizer(target: self, action: #selector(slideUpTapped))
        containerView.addGestureRecognizer(_recognizer)
        containerView.alpha = 0
        slideUpView.frame = CGRect(x: 0, y: screenSize.height, width: screenSize.width, height: slideUpViewHeight * screenRatio)
        slideUpView.backgroundColor = darkColor
        slideUpView.layer.cornerRadius = 30 * screenRatio
        slideUpView.clipsToBounds = true
        window?.addSubview(slideUpView)
        //settings label
        let settingsLabel = UILabel()
        settingsLabel.frame = CGRect(x: 0, y: 20 * screenRatio, width: slideUpView.frame.width, height: 20 * screenRatio)
        settingsLabel.textAlignment = .center
        settingsLabel.textColor = whiteColor
        settingsLabel.font = boldLabel
        settingsLabel.text = "Settings"
        slideUpView.addSubview(settingsLabel)
        //close icon for settings
        let closeButtonImage = UIImage(named: "close")
        let closeButton = UIButton()
        closeButton.frame = CGRect(x: slideUpView.frame.width * 0.88, y: 25 * screenRatio, width: 15 * screenRatio, height: 15 * screenRatio)
        closeButton.setImage(closeButtonImage, for: .normal)
        closeButton.addTarget(self, action: #selector(slideUpTapped), for: .touchUpInside)
        slideUpView.addSubview(closeButton)
        //table view for the settings menu
        slideUpTableView.frame = CGRect(x: 0, y: 60 * screenRatio, width: slideUpView.frame.width, height: slideUpView.frame.height - 50 * screenRatio)
        slideUpTableView.separatorStyle = .none
        slideUpTableView.backgroundColor = darkColor
        slideUpView.addSubview(slideUpTableView)
        
        //animate the menu to the correct position
        UIView.animate(withDuration: 0.5,
                       delay: 0, usingSpringWithDamping: 1.0,
                       initialSpringVelocity: 1.0,
                       options: .curveEaseInOut, animations: {
                        self.containerView.alpha = 0.8
                        self.slideUpView.frame = CGRect(x: 0, y: screenSize.height - self.slideUpViewHeight * screenRatio, width: screenSize.width, height: self.slideUpViewHeight)
        }, completion: nil)
        
    }
    
    @objc func slideUpTapped() {
        let screenSize = UIScreen.main.bounds.size
        UIView.animate(withDuration: 0.5,
                       delay: 0, usingSpringWithDamping: 1.0,
                       initialSpringVelocity: 1.0,
                       options: .curveEaseInOut, animations: {
                        self.containerView.alpha = 0
                        self.slideUpView.frame = CGRect(x: 0, y: screenSize.height, width: screenSize.width, height: self.slideUpViewHeight * screenRatio)
        }, completion: nil)
    }
    
    func itemTapped(completion: ((Bool)->(Void))?) {
        let screenSize = UIScreen.main.bounds.size
        UIView.animate(withDuration: 0.5,
                       delay: 0, usingSpringWithDamping: 1.0,
                       initialSpringVelocity: 1.0,
                       options: .curveEaseInOut, animations: {
                        self.containerView.alpha = 0
                        self.slideUpView.frame = CGRect(x: 0, y: screenSize.height, width: screenSize.width, height: self.slideUpViewHeight * screenRatio)
        }, completion: completion)
    }
    
    
    @objc func showDetail(sender: UIButton)
    {
        if (sender.tag == 0) {
            //the first item is tapped
            animateButton(inputButton: detailButton1)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                let vc = ScanResultViewController(scanDate: Date(), totalStorage: 0.5, deleted: 25, kept: 5, screenshots: 30, incoherent: 12, duplicates: 10, reviewFinished: true, analyzer: nil, photosToDelete: nil)
                self.navigationController?.pushViewController(vc, animated: true)
            }
            
        } else if (sender.tag == 1) {
            //the second item is tapped
            animateButton(inputButton: detailButton2)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                let vc = ScanResultViewController(scanDate: Date(), totalStorage: 0.5, deleted: 25, kept: 5, screenshots: 30, incoherent: 12, duplicates: 10, reviewFinished: true, analyzer: nil, photosToDelete: nil)
                self.navigationController?.pushViewController(vc, animated: true)
            }
            
        }
    }
    @objc func cleanUp() {
        animateButton(inputButton: button)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            let vc = ScanLoadingViewController()
            self.navigationController?.pushViewController(vc, animated: true)
        }
        //executes the clean up method
    }
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let analyzer = PhotoAnalyzer()
        analyzer.request_perms { (completed) in
            initializeRatio()
            setUp()
        }
    }
    
    
}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuDataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SlideUpViewCell", for: indexPath) as? SlideUpViewCell
            else {fatalError("cannot load cells")}
        cell.iconView.image = menuDataSource[indexPath.row]?.0
        cell.labelView.text = menuDataSource[indexPath.row]?.1
        cell.labelView.font = boldLabel
        cell.labelView.textColor = whiteColor
        let _image = UIImage(named: "back")!
        cell.arrowView.image = _image
        cell.arrowView.transform = CGAffineTransform(scaleX: -1, y: 1)
        cell.selectionStyle = .none
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70 * screenRatio
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        itemTapped { (_) -> () in
            switch indexPath.row {
                case 4:
                    let vc = PreferencesViewController()
                    self.present(vc, animated: true)
                    break
                default: break
            }

        }
    }
    
    
}


