//
//  LogItem.swift
//  OneBean
//
//  Created by Junho Kim on 2023/03/07.
//

import UIKit

class LogItem: Codable {
    
    var date: String
    var mood: Mood
    var note: String
    var planNote: String?
    var hourNote: String?
    var firstLogInCurrentHour: Bool?
    var currentLogTime: String?
    
    init(date: String, mood: Mood) {
        self.date = date
        self.mood = mood
        self.note = ""
        self.planNote = ""
        self.hourNote = ""
        self.firstLogInCurrentHour = true
        self.currentLogTime = ""
    }
    
    // setMood
    func setMood(mood: Mood) {
        self.mood = mood
    }
    func setByUser(){
        self.mood.selectedByUser = true
    }
    func setNote(note: String) {
        self.note = note
    }
    func setPlanNote(note: String) {
        self.planNote = note
    }
    func setHourNote(note: String) {
        self.hourNote = note
    }
    func setFirstLog(first: Bool) {
        self.firstLogInCurrentHour = first
    }
    func setCurrentLogTime(time: String) {
        self.currentLogTime = time
    }
    /*
    static func ==(lhs: LogItem, rhs: LogItem) -> Bool {
        return lhs.date == rhs.date
    }
    */
}
