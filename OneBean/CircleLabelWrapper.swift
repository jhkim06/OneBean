//
//  CircleLabelWrapper.swift
//  OneBean
//
//  Created by Junho Kim on 2023/04/11.
//

import Foundation
import SwiftUI
import UIKit

class CircleLabelWrapper: UIView {
    
    private var hostingController: UIHostingController<CircleText>?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup("TEXT")
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup("TEXT")
    }
    
    init(frame: CGRect, _ text: String) {
        super.init(frame: frame)
        setup(text)
    }
    
    private func setup(_ text: String) {
        
        let swiftUIView = CircleText(radius: 30, text: text, kerning: 8)
        let hostingController = UIHostingController(rootView: swiftUIView)
        //hostingController.view.backgroundColor = .clear
        addSubview(hostingController.view)
        print("hostingController.view \(hostingController.view.frame.origin)")
        self.hostingController = hostingController
    }
    
}
