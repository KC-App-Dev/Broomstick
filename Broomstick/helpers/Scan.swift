//
//  Scan.swift
//  Broomstick
//
//  Created by Patrick Cui on 9/13/20.
//  Copyright © 2020 KC App Dev. All rights reserved.
//

import Foundation

class Scan: NSObject {
    var totalStorage: Double
    var deleted: Int
    var kept: Int
    var incoherent: Int
    var screenshots: Int
    var duplicates: Int
    var reviewComplete: Bool
    var date: Date
    
    init(totalStorage: Double, deleted: Int, kept: Int, incoherent: Int, screenshots: Int, duplicates: Int, reviewComplete: Bool, date: Date) {
        self.totalStorage = totalStorage
        self.deleted = deleted
        self.kept = kept
        self.incoherent = incoherent
        self.screenshots = screenshots
        self.duplicates = duplicates
        self.reviewComplete = reviewComplete
        self.date = date
    }
}
