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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let diameter: CGFloat = min(self.shapeLayer.frame.height, self.shapeLayer.frame.width)
        
        self.shapeLayer.path = UIBezierPath(roundedRect:
            CGRect(x: (self.contentView.frame.width-diameter)*0.8, // FIXME do not use hard coded numbers
                   y: -5.0, //(self.contentView.frame.height-diameter)*0.01,
                   width: diameter*0.65, height: diameter*0.3), cornerRadius: 10).cgPath
    }
}
