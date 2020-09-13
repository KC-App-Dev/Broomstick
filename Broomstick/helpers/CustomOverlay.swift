//
//  CustomOverlay.swift
//  Broomstick
//
//  Created by Patrick Cui on 9/13/20.
//  Copyright © 2020 KC App Dev. All rights reserved.
//

import Foundation
import Koloda

private let swipeRightImage = "swipeRight"
private let swipeLeftImage = "swipeLeft"


class CustomOverlayView: OverlayView {
    
   lazy var overlayImageView: UIImageView! = {
        [unowned self] in
        
        var imageView = UIImageView(frame: self.bounds)
        self.addSubview(imageView)
        
        return imageView
        }()

    override var overlayState: SwipeResultDirection? {
        didSet {
            switch overlayState {
            case .left? :
                overlayImageView.image = UIImage(named: swipeLeftImage)
            case .right? :
                overlayImageView.image = UIImage(named: swipeRightImage)
            default:
                overlayImageView.image = nil
            }
        }
    }

}
