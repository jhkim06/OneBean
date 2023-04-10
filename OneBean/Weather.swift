//
//  Weather.swift
//  OneBean
//
//  Created by Junho Kim on 2023/04/09.
//

import Foundation

class Weather: Codable {
    let baseDate: String
    let baseTime: String
    let category: String
    let obsrValue: String
    let nx: Int
    let ny: Int
}
