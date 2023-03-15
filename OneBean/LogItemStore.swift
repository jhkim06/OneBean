//
//  LogItemStore.swift
//  OneBean
//
//  Created by Junho Kim on 2023/03/07.
//

import UIKit

class LogItemStore {
    
    //var allLogItems = [LogItem]() // FIXME use dictionary
    var allLogItems = Dictionary<Date, LogItem>()

    @discardableResult func createItem(date: Date, mood: Mood) -> LogItem {
        let newItem = LogItem(date: date, mood: mood)
        
        //allLogItems.append(newItem)
        allLogItems[date] = newItem
        
        return newItem
    }
}
