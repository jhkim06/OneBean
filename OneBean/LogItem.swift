//
//  LogItem.swift
//  OneBean
//
//  Created by Junho Kim on 2023/03/07.
//

import UIKit

class LogItem {
    
    var date: String
    var mood: Mood
    
    init(date: String, mood: Mood) {
        self.date = date
        self.mood = mood
    }
    
    /*
    static func ==(lhs: LogItem, rhs: LogItem) -> Bool {
        return lhs.date == rhs.date
    }
    */
}
