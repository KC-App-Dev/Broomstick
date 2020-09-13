//
//  SlideUpViewCell.swift
//  Broomstick
//
//  Created by Patrick Cui on 9/12/20.
//  Copyright © 2020 KC App Dev. All rights reserved.
//

import UIKit

class SlideUpViewCell: UITableViewCell {
    
    lazy var view: UIView = {
        let _view = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 75 * screenRatio))
        _view.backgroundColor = darkColor
        return _view
    }()
    
    lazy var iconView: UIImageView = {
        let _view = UIImageView(frame: CGRect(x: 20 * screenRatio, y: 15 * screenRatio, width: 30 * screenRatio, height: 30 * screenRatio))
        return _view
    }()
    
    lazy var labelView: UILabel = {
        let _view = UILabel(frame: CGRect(x: 75 * screenRatio, y: 18 * screenRatio, width: 175 * screenRatio, height: 24 * screenRatio))
        return _view
    }()
    
    lazy var arrowView: UIImageView =  {
        let _view = UIImageView(frame: CGRect(x: 320 * screenRatio, y: 15 * screenRatio, width: 30 * screenRatio, height: 30 * screenRatio))
        return _view
    }()

    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        addSubview(view)

        view.addSubview(iconView)
        view.addSubview(labelView)
        view.addSubview(arrowView)
        
    }

}
