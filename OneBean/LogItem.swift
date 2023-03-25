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
    var note: String
    
    init(date: String, mood: Mood) {
        self.date = date
        self.mood = mood
        self.note = ""
    }
    
    // setMood
    func setMood(mood: Mood) {
        self.mood = mood
    }
    func setNote(note: String) {
        self.note = note
    }
    /*
    static func ==(lhs: LogItem, rhs: LogItem) -> Bool {
        return lhs.date == rhs.date
    }
    */
}
