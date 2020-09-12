//
//  Global.swift
//  Broomstick
//
//  Created by Patrick Cui on 9/11/20.
//  Copyright © 2020 KC App Dev. All rights reserved.
//

import Foundation
import UIKit

//Colors used in the application
let darkColor = UIColor(hex: "#15286fff")!
let mediumColor = UIColor(hex: "#377FCAFF")!
let lightColor = UIColor(hex: "#59BDF4ff")!
let whiteColor = UIColor.white
let blackColor = UIColor.black
let grayColor = UIColor(hex: "#C4C4C4ff")!


//UIColor hex extension
extension UIColor {
    public convenience init?(hex: String) {
        let r, g, b, a: CGFloat

        if hex.hasPrefix("#") {
            let start = hex.index(hex.startIndex, offsetBy: 1)
            let hexColor = String(hex[start...])

            if hexColor.count == 8 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0

                if scanner.scanHexInt64(&hexNumber) {
                    r = CGFloat((hexNumber & 0xff000000) >> 24) / 255
                    g = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
                    b = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
                    a = CGFloat(hexNumber & 0x000000ff) / 255

                    self.init(red: r, green: g, blue: b, alpha: a)
                    return
                }
            }
        }

        return nil
    }
}

//Fonts used in the application
var bigNumber = UIFont(name: "ProximaNova-SemiBold", size: 60)
var mediumNumber = UIFont(name: "ProximaNova-Bold", size: 50)
var number = UIFont(name: "ProximaNova-Bold", size: 36)
var heading = UIFont(name: "ProximaNova-Bold", size: 32)
var headingSmall = UIFont(name: "ProximaNova-Bold", size: 24)
var buttonText = UIFont(name: "ProximaNova-Bold", size: 24)
var boldLabel = UIFont(name: "ProximaNova-Bold", size: 18)
var label = UIFont(name: "ProximaNova-Regular", size: 18)
var smallLabel = UIFont(name: "ProximaNova-Regular", size: 18)

//Auto layout
var screenRatio = 1.0 as CGFloat

//button click animation
func animateButton(inputButton: UIButton) {
    //animates a UI button so it can be clicked
    UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseOut, animations: {
        inputButton.transform = CGAffineTransform(scaleX: 0.92, y: 0.92)
    }) { (_) in
        UIView.animate(withDuration: 0.1, delay: 0.05, options: .curveEaseOut, animations: {
            inputButton.transform = CGAffineTransform(scaleX: 1, y: 1)
        })
    }
}
