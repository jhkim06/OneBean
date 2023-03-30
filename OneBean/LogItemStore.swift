//
//  LogItemStore.swift
//  OneBean
//
//  Created by Junho Kim on 2023/03/07.
//

import UIKit

class LogItemStore {
    
    var allLogItems = Dictionary<String, LogItem>() // data type...
    // var allLogItems_ = Dictionary<String, Dictionary<String, LogItem>>() // data type...
    var dates = [String]()
    
    let itemArchiveURL: URL = {
        let documentsDirectories =
            FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentDirectory = documentsDirectories.first! // in iOS only one URL returned
        return documentDirectory.appendingPathComponent("logitems.plist")
    }()
    
    let dateFormatter = DateFormatter()
    
    init() {
        
        do {
            let data = try Data(contentsOf: itemArchiveURL)
            let unarchiver = PropertyListDecoder()
            let logitems = try unarchiver.decode([String: LogItem].self, from: data)
            allLogItems = logitems
            
            for (date_, _) in allLogItems {
                dates.append(date_)
            }
            dates.sort()
            //print("saved item count: \(allLogItems.count)")
        } catch {
            print("Error reading in saved items: \(error)")
        }
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self,
                                       selector: #selector(saveChanges),
                                       name: UIScene.didEnterBackgroundNotification,
                                       object: nil)
        notificationCenter.addObserver(self,
                                       selector: #selector(saveChanges),
                                       name: UIScene.willDeactivateNotification,
                                       object: nil)

    }
    
    @discardableResult func createItem(date: String, mood: Mood) -> LogItem {
        
        let newItem = LogItem(date: date, mood: mood)
        
        if allLogItems.contains(where: {$0.key == date}) {
            newItem.setNote(note: allLogItems[date]!.note )
            allLogItems.removeValue(forKey: date)
            
            allLogItems[date] = newItem
        } else {
            // add new item
            allLogItems[date] = newItem
            dates.append(date)
            dates.sort()
        }
        return newItem
    }
    func removeItem(date: String) {
        allLogItems.removeValue(forKey: date)
        if let index = dates.firstIndex(of: date) {
            dates.remove(at: index)
        }
    }
    
    @objc func saveChanges() -> Bool {
        print("Saving items to: \(itemArchiveURL)")
        do {
            let encoder = PropertyListEncoder()
            let data = try encoder.encode(allLogItems)
            try data.write(to: itemArchiveURL, options: [.atomic])
            print("Saved all of the items")
            return true
        } catch let encodingError {
            print("Error encoding allLogItems: \(encodingError)")
            return false
        }
    }
}
