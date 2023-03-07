//
//  UIImage+OneBean.swift
//  OneBean
//
//  Created by Junho Kim on 2023/03/06.
//

import UIKit

enum ImageResource: String {
    case angry // angry = "angry"
    case confused
    case crying
    case goofy
    case happy
    case meh
    case sad
    case sleepy
}

extension UIImage {
    convenience init(resource: ImageResource) {
        self.init(named: resource.rawValue)!
    }
}
