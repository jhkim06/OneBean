//
//  Mood.swift
//  OneBean
//
//  Created by Junho Kim on 2023/03/06.
//

import UIKit

struct Color : Codable {
    var red : CGFloat = 0.0, green: CGFloat = 0.0, blue: CGFloat = 0.0, alpha: CGFloat = 0.0
    
    var uiColor : UIColor {
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    init(uiColor : UIColor) {
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
    }
}

struct Mood: Equatable, Codable {
    var name: String
    var image: UIImage
    var color: UIColor
    
    enum CodingKeys: String, CodingKey {
        case name
        case image
        case color
    }
    init(name: String, image: UIImage, color: UIColor) {
        self.name = name
        self.image = image
        self.color = color
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        let imageData = try? container.decode(Data.self, forKey: .image)
        image = UIImage(data: imageData!, scale: 2.0)!
        //print("in decode \(image.size.width)")
        color = try container.decode(Color.self, forKey: .color).uiColor
    }
    
    func encode(to encoder: Encoder) throws {
        //print("in encode \(image.size.width)")
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(name, forKey: .name)
        try container.encode(image.pngData(), forKey: .image)
        try container.encode(Color(uiColor: color), forKey: .color)
    }
    
    static func ==(lhs: Mood, rhs: Mood) -> Bool {
        return lhs.name == rhs.name
    }
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
