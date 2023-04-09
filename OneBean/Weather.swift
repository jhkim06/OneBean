//
//  Weather.swift
//  OneBean
//
//  Created by Junho Kim on 2023/04/09.
//

import Foundation

// {"baseDate":"20230409","baseTime":"1100","category":"TMP","fcstDate":"20230409","fcstTime":"1200","fcstValue":"15","nx":55,"ny":127

class Weather: Codable {
    let baseDate: String
    let baseTime: String
    let category: String
    let obsrValue: String
    let nx: Int
    let ny: Int
}
