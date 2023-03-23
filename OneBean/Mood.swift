//
//  Mood.swift
//  OneBean
//
//  Created by Junho Kim on 2023/03/06.
//

import UIKit

struct Mood {
    var name: String
    var image: UIImage
    var color: UIColor
}

extension Mood {
    static let good = Mood(name: "good",
                            image: UIImage(resource: .good),
                            color: UIColor.good)

    static let bad = Mood(name: "bad",
                             image: UIImage(resource: .bad),
                             color: UIColor.bad)

    static let happy = Mood(name: "happy",
                            image: UIImage(resource: .happy),
                            color: UIColor.happy)
    
    static let soso = Mood(name: "soso",
                          image: UIImage(resource: .soso),
                          color: UIColor.soso)

    static let sad = Mood(name: "sad",
                          image: UIImage(resource: .sad),
                          color: UIColor.sad)
}
