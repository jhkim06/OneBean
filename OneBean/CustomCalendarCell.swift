//
//  CustomCalendarCell.swift
//  OneBean
//
//  Created by Junho Kim on 2023/03/17.
//

import Foundation
import UIKit
import FSCalendar


class CustomCalendarCell: FSCalendarCell {
    
    required init!(coder aDecoder: NSCoder!) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        // to prevent unwanted view addition
        self.subviews.filter({ $0 is CircleLabelWrapper }).forEach({ $0.removeFromSuperview() })
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
       
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let diameter: CGFloat = min(self.shapeLayer.frame.height, self.shapeLayer.frame.width)
        
        self.shapeLayer.path = UIBezierPath(roundedRect:
                                                CGRect(x: 11.0, // FIXME do not use hard-coded numbers
                   y: -7.0, //(self.contentView.frame.height-diameter)*0.01,
                   width: diameter*0.5, height: diameter*0.3), cornerRadius: 10).cgPath
    }
    override func configureAppearance() {
         super.configureAppearance()
         // Override the build-in appearance configuration
    }
}
