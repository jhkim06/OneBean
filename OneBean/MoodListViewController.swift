//
//  MoodListViewController.swift
//  OneBean
//
//  Created by Junho Kim on 2023/03/24.
//

import UIKit

class MoodListViewController: UITableViewController {
    
    var logItemStore: LogItemStore!
    
    /*
    override init(style: UITableView.Style) {

        super.init(style: .insetGrouped)
     
     }
     */
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let vc = parent?.children[0] as? CalendarViewController {
            print("set logItemstore")
            self.logItemStore = vc.logItemStore
        }
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //tableView.rowHeight = 100.0
    }
   
    //  to add space between the cells create sections for each item
    // https://stackoverflow.com/questions/6216839/how-to-add-spacing-between-uitableviewcell/33931591#33931591
    override func numberOfSections(in tableView: UITableView) -> Int {
        if let vc = parent?.children[0] as? CalendarViewController {
            //print("set logItemstore in number of sections")
            self.logItemStore = vc.logItemStore
        }
        //print(self.logItemStore)
        return self.logItemStore.allLogItems.count
    }
    
    override func tableView(_ tableView: UITableView,
                            numberOfRowsInSection section: Int) -> Int {
        //return self.logItemStore.allLogItems.count
        return 1
    }
    
    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let date = logItemStore.dates[indexPath.section]
        let moodItem = logItemStore.allLogItems[date]

        let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell",
                                                 for: indexPath)

        cell.imageView?.image = moodItem?.mood.image
        //cell.textLabel?.text = "I was \(moodEntry.mood.name)"

        let dateString = date
        cell.detailTextLabel?.text = "on \(dateString)"
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60 // set the height of each row
    }
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        // Add spacing between cells
        cell.separatorInset = UIEdgeInsets(top: 100, left: 0, bottom: 100, right: 0)
    }
}
