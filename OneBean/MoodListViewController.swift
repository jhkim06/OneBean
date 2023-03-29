//
//  MoodListViewController.swift
//  OneBean
//
//  Created by Junho Kim on 2023/03/24.
//

import UIKit

class MoodListViewController: UITableViewController {
    
    var logItemStore: LogItemStore!
    @IBOutlet weak var mothView: UIView!
    @IBOutlet var mothYear: UILabel!
    
    
    @IBAction func selectMonth(_ sender: Any) {
        
        if let monthSelectionViewController = storyboard?.instantiateViewController(identifier: "MonthSelectionViewController") {
            print("selectMonth")
            monthSelectionViewController.modalPresentationStyle = .overCurrentContext
            monthSelectionViewController.modalTransitionStyle = .crossDissolve
            present(monthSelectionViewController, animated: true)
        }
    }
    
    @IBAction func deleteLogItem(_ sender: UIButton) {
        
        // convert point to indexPath 
        let point = sender.convert(CGPoint.zero, to: tableView)
        guard let indexPath = tableView.indexPathForRow(at: point) else {return}
        
        let date = logItemStore.dates[indexPath.section]
        // TODO add warning message before deletion
        logItemStore.removeItem(date: date)
        //logItemStore.saveChanges()
        tableView.reloadData()
    }
    
    /*
    override init(style: UITableView.Style) {
        super.init(style: .insetGrouped)
    }
    */
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //print("viewWillAppear MoodListView")
        super.viewWillAppear(animated)
        
        
        let myFormat = Date.FormatStyle()
            .year()
            .month()
        
        let currentTime = Date().formatted(myFormat)
        
        // textView.replace(selectedRange, withText: "\n\(currentTime.formatted(date: .omitted, time: .shortened))")
        self.mothYear.text = currentTime
        
        if let vc = parent?.children[0] as? CalendarViewController {
            //print("set logItemstore")
            self.logItemStore = vc.logItemStore
        }
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(mothView)
        /*
        mothView.frame = CGRect(x: 0,
                                //y: self.view.bounds.size.height - mothView.bounds.size.height,
                                y: 20,
                                width: self.view.bounds.size.width,
                                height: 30.0)
        */
        
        mothView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            mothView.widthAnchor.constraint(equalToConstant: 300),
            mothView.heightAnchor.constraint(equalToConstant: 50),
            mothView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            mothView.centerYAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: 20)
        ])
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 70
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
        // TODO show only logs of the selected month
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

        let cell = tableView.dequeueReusableCell(withIdentifier: "LogItemCell",
                                                 for: indexPath) as! LogItemCell
        

        //imageView auto layout constraints
        cell.imageView?.translatesAutoresizingMaskIntoConstraints = false

        let marginguide = cell.contentView.layoutMarginsGuide

        //cell.imageView?.topAnchor.constraint(equalTo: marginguide.topAnchor).isActive = true
        cell.imageView?.leadingAnchor.constraint(equalTo: marginguide.leadingAnchor).isActive = true
        cell.imageView?.heightAnchor.constraint(equalToConstant: 40).isActive = true
        cell.imageView?.widthAnchor.constraint(equalToConstant: 40).isActive = true
        cell.imageView?.centerYAnchor.constraint(equalTo: marginguide.centerYAnchor).isActive = true
        //cell.imageView?.bottomAnchor.constraint(equalTo: marginguide.bottomAnchor).isActive = true
        cell.imageView?.contentMode = .scaleAspectFill
        cell.imageView?.layer.cornerRadius = 20 //half of your width or height
        cell.imageView?.image = moodItem?.mood.image
        //cell.textLabel?.text = "I was \(moodEntry.mood.name)"
        
        let dateString = date
        cell.dateLabel?.text = "on \(dateString)"
       
        cell.noteLabel?.text = moodItem?.note
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 2.0
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "showLog":
            if let section = tableView.indexPathForSelectedRow?.section {
                let date = logItemStore.dates[section]
                let logItem = logItemStore.allLogItems[date]
            
                let detailViewController = segue.destination as! DetailViewController
                detailViewController.currentLogItem = logItem
            }
        default:
            preconditionFailure("Unexpected segue identifier.")
        }
    }

}
