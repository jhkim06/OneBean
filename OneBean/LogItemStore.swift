//
//  LogItemStore.swift
//  OneBean
//
//  Created by Junho Kim on 2023/03/07.
//

import UIKit


class LogItemStore {
    
    var allLogItems = Dictionary<String, LogItem>() // data type...
    var dates = [String]()
    
    let dateFormatter = DateFormatter()
    
    
    @discardableResult func createItem(date: String, mood: Mood) -> LogItem {
        
        let newItem = LogItem(date: date, mood: mood)
        
        if allLogItems.contains(where: {$0.key == date}) {
            allLogItems.removeValue(forKey: date)
            allLogItems[date] = newItem
        } else {
            // add new item
            allLogItems[date] = newItem
            dates.append(date)
            dates.sort()
            print("\(date) added")
        }
        return newItem
    }
}
