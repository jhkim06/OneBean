//
//  LogItemStore.swift
//  OneBean
//
//  Created by Junho Kim on 2023/03/07.
//

import UIKit

class LogItemStore {
    
    var allLogItems = Dictionary<String, Dictionary<String, LogItem>>()
    var dates = Dictionary<String, [String]>()
    
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
            let logitems = try unarchiver.decode([String: [String: LogItem]].self, from: data)
            allLogItems = logitems
            
            // set dates using allLogItems
            for (monthYear_, _) in allLogItems {
                //print(monthYear_)
                for (day_, _) in allLogItems[monthYear_]! {
                    //print("day \(day_)")
                    if dates[monthYear_]?.count == nil {
                        //print("first day")
                        dates[monthYear_] = [day_]
                    } else {
                        //print("not first day \(dates[monthYear_]?.count)")
                        dates[monthYear_]?.append(day_)
                    }
                    //print(day_)
                }
                dates[monthYear_]?.sort()
            }
            //print("check all logItems \(allLogItems.count)")
            //print("check dates \(dates.count)")
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
    
    @discardableResult func createItem(date: String, mood: Mood, setByUser: Bool=true) -> LogItem {
        let monthYear = date.components(separatedBy: "-")[..<2].joined(separator: "-")
        let day = date.components(separatedBy: "-")[2]
        
        let newItem = LogItem(date: date, mood: mood)
        if setByUser {
            newItem.setByUser()
        }
        
        if allLogItems.contains(where: {$0.key == monthYear}) {
            
            if ((allLogItems[monthYear]?.contains(where: {$0.key == day})) == true) {
            
                let str = allLogItems[monthYear]?[day]?.note
                newItem.setNote(note: str!)
                let planstr = allLogItems[monthYear]?[day]?.planNote
                newItem.setPlanNote(note: planstr!)
                let hourstr = allLogItems[monthYear]?[day]?.hourNote
                newItem.setHourNote(note: hourstr!)
                
                let firstLog = allLogItems[monthYear]?[day]?.firstLogInCurrentHour
                newItem.setFirstLog(first: firstLog!) // why ! needed here?
                let currentLogTime = allLogItems[monthYear]?[day]?.currentLogTime
                newItem.setCurrentLogTime(time: currentLogTime!)

                allLogItems[monthYear]?.removeValue(forKey: day)
                allLogItems[monthYear]?[day] = newItem
            }
            else {
                allLogItems[monthYear]?[day] = newItem
                
                if allLogItems[monthYear]?.count == 0 { // compare to line 38
                    dates[monthYear] = [day]
                } else {
                    dates[monthYear]?.append(day)
                }
                dates[monthYear]?.sort()
            }
        } else {
            // add new item
            allLogItems[monthYear] = [day:newItem]
            
            dates[monthYear] = [day]
            dates[monthYear]?.sort()
        }
        return newItem
    }
    func removeItem(date: String) {
        let monthYear = date.components(separatedBy: "-")[..<2].joined(separator: "-")
        let day = date.components(separatedBy: "-")[2]
        
        allLogItems[monthYear]?.removeValue(forKey: day)
        
        if let index = dates[monthYear]?.firstIndex(of: day) {
            dates[monthYear]?.remove(at: index)
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
