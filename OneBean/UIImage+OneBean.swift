//
//  UIImage+OneBean.swift
//  OneBean
//
//  Created by Junho Kim on 2023/03/06.
//

import UIKit

enum ImageResource: String {
    case bad // angry = "angry"
    case happy
    case good
    case sad
    case soso
    case bg
}

extension UIImage {
    convenience init(resource: ImageResource) {
        self.init(named: resource.rawValue)!
    }
}
