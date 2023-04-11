//
//  ViewController.swift
//  OneBean
//
//  Created by Junho Kim on 2023/03/05.
//

import UIKit
import FSCalendar

class CalendarViewController: UIViewController {

    @IBOutlet var calendarView: FSCalendar!
    var locationProvider: LocationProvider?
    var store: WeatherStore!
    var currentTMP: String?

    @IBAction func selectMood(_ sender: UIButton) {
        if let moodSelectionViewController = storyboard?.instantiateViewController(identifier: "MoodSelectionViewController") {
            moodSelectionViewController.modalPresentationStyle = .overCurrentContext
            moodSelectionViewController.modalTransitionStyle = .crossDissolve
            present(moodSelectionViewController, animated: true)
        }
    }

    //
    let dateFormatter = DateFormatter()
    var selectedDate = String() // default to today
    
    var logItemStore: LogItemStore!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        selectedDate = dateFormatter.string(from:Date())
        calendarView.reloadData()
        
        locationProvider?.start() // track location
        
        OperationQueue.main.addOperation {
                self.store.fetchWeatherInfo {
                (weatherResult) in

                switch weatherResult {
                case let .success(weather):
                    // TODO convert Weather to dictionary with desired key
                    self.currentTMP = "today " + String(weather[3].obsrValue) + "°C"
                    
                    DispatchQueue.main.async {
                        self.calendarView.reloadData() // wait and reload
                    }
                     
                    //print("cat: \(weather[3].category) obs: \(weather[3].obsrValue)")
                case let .failure(error):
                    print("Error fetching interesting photos: \(error)")
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        calendarView.delegate = self
        calendarView.dataSource = self
        
        calendarView.scrollEnabled = true
        calendarView.scrollDirection = .vertical
        
        // to use custom cell
        calendarView.register(CustomCalendarCell.self, forCellReuseIdentifier: "cellCustom")
        
        calendarView.backgroundColor = UIColor(red: 241/255, green: 244/255, blue: 237/255, alpha: 1)
        calendarView.appearance.selectionColor = UIColor(red: 97/255, green: 174/255, blue: 114/255, alpha: 0.7)
        calendarView.appearance.todayColor = UIColor(red: 97/255, green: 174/255, blue: 114/255, alpha: 0.2)
        //calendarView.appearance.borderRadius = 0.7
        calendarView.appearance.titleTodayColor = .black
        calendarView.appearance.titleOffset = CGPoint(x:0.0, y:-20.0)
        //
        calendarView.appearance.headerTitleFont = UIFont(name: "Avenir-Light", size: 20.0)
        calendarView.appearance.headerTitleColor = .gray
        
        calendarView.appearance.titleFont = UIFont(name: "Avenir-Light", size: 10.0)
        
        calendarView.appearance.weekdayTextColor = .gray
        calendarView.appearance.weekdayFont = UIFont(name: "Avenir-Light", size: 18.0)
        
        calendarView.appearance.subtitleSelectionColor = .black
        calendarView.appearance.subtitleOffset = CGPoint(x:0.0, y:-12.0)
        calendarView.appearance.subtitleFont = UIFont(name: "Avenir-Light", size: 7.0)
        calendarView.appearance.subtitleTodayColor = .black
        
        calendarView.placeholderType = .none // show only the days of the current month
        
        locationProvider = LocationProvider()
        

        
        NotificationCenter.default.addObserver(self, selector: #selector(handleDayChangedNotification(_:)), name: NSNotification.Name.NSCalendarDayChanged, object: nil)
    }
    
    func setMood(_ mood: Mood) {
        logItemStore.createItem(date: selectedDate, mood: mood)
        calendarView.reloadData()
    }
    
    @objc func handleDayChangedNotification(_ notification: Notification) {
        // Handle date change here
        //print("The calendar day has changed.")
        OperationQueue.main.addOperation { [self] in
            
            self.calendarView.register(CustomCalendarCell.self, forCellReuseIdentifier: "cellCustom")
            
            self.calendarView.backgroundColor = UIColor(red: 241/255, green: 244/255, blue: 237/255, alpha: 1)
            self.calendarView.appearance.selectionColor = UIColor(red: 97/255, green: 174/255, blue: 114/255, alpha: 0.7)
            self.calendarView.appearance.todayColor = UIColor(red: 97/255, green: 174/255, blue: 114/255, alpha: 0.2)
            self.calendarView.appearance.titleTodayColor = .black
            self.calendarView.appearance.titleOffset = CGPoint(x:0.0, y:-20.0)
        
            calendarView.appearance.headerTitleFont = UIFont(name: "Avenir-Light", size: 20.0)
            calendarView.appearance.headerTitleColor = .gray
            
            calendarView.appearance.titleFont = UIFont(name: "Avenir-Light", size: 10.0)
            
            calendarView.appearance.weekdayTextColor = .gray
            calendarView.appearance.weekdayFont = UIFont(name: "Avenir-Light", size: 18.0)
            
            calendarView.appearance.subtitleSelectionColor = .black
            calendarView.appearance.subtitleOffset = CGPoint(x:0.0, y:-12.0)
            calendarView.appearance.subtitleFont = UIFont(name: "Avenir-Light", size: 7.0)
            calendarView.appearance.subtitleTodayColor = .black
            
            calendarView.placeholderType = .none // show only the days of the current month
            
            calendarView.today = Date()
        }
    }
}

extension CalendarViewController : FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance {
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, titleOffsetFor date: Date) -> CGPoint {
        switch dateFormatter.string(from: date) {
            case dateFormatter.string(from: Date()):
                return CGPoint(x:0.0, y:-20.0)
            default:
                return CGPoint(x:0.0, y:-20.0)
        }
    }
    /*
    func calendar(_ calendar: FSCalendar, willDisplay cell: FSCalendarCell, for date: Date, at position: FSCalendarMonthPosition) {
        // Remove your custom view from the cell's subviews
        cell.subviews.filter({ $0 is CircleLabelWrapper }).forEach({ $0.removeFromSuperview() })
    }
    */
    func calendar(_ calendar: FSCalendar, cellFor date: Date, at position: FSCalendarMonthPosition) -> FSCalendarCell {
        let cell = calendar.dequeueReusableCell(withIdentifier: "cellCustom", for: date, at: position)
        
        if dateFormatter.string(from: date) == dateFormatter.string(from: Date()) {
            let circleSize = CGSize(width: 5, height: 5)
            let circleOrigin = CGPoint(x: 25, y: 45)
            let circleLabelWrapper = CircleLabelWrapper(frame: CGRect(origin: circleOrigin, size: circleSize), self.currentTMP ?? "")
            //let circleLabelWrapper = CircleLabelWrapper(frame: CGRect(origin: circleOrigin))
            // add the custom view to the cell
            cell.addSubview(circleLabelWrapper)
            //circleLabelWrapper.frame = CGRect(origin: circleOrigin, size: circleSize)
        }
        
        //cell.backgroundColor = .red
        return cell
    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, isSelected date: Date) -> Bool {
        return true // Return true to indicate that the date is selected
    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, titleSelectionColorFor date: Date) -> UIColor? {
        
        return UIColor.black
    }
    /*
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, fillSelectionColorFor date: Date) -> UIColor? {
        return UIColor.clear // Set the fill selection color to clear to remove the default selection background color
    }
    */
    
    //
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, imageOffsetFor date: Date) -> CGPoint {
        let date = dateFormatter.string(from:date)
        let monthYear = date.components(separatedBy: "-")[..<2].joined(separator: "-")
        let day = date.components(separatedBy: "-")[2]
        
        if logItemStore.allLogItems.contains(where: {$0.key == monthYear}) {
            if ((logItemStore.allLogItems[monthYear]?.contains(where: {$0.key == day})) == true) {
                return CGPoint(x:0.0, y:0.0)
            }
        }
        return CGPoint(x:0.0, y:0.0)
    }
    
    // selection condition
    func calendar(_ calendar: FSCalendar, shouldSelect date: Date, at monthPosition: FSCalendarMonthPosition) -> Bool {
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let destinationVC = segue.destination as? DetailViewController, let _ = sender as? Date {
                // Pass any data to the destination view controller here
                let monthYear = self.selectedDate.components(separatedBy: "-")[..<2].joined(separator: "-")
                let day = self.selectedDate.components(separatedBy: "-")[2]
                
                let logItem = logItemStore.allLogItems[monthYear]![day]
                
                destinationVC.currentLogItem = logItem
                destinationVC.store = WeatherStore()
            }
        }
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        selectedDate = dateFormatter.string(from:date)
        
        let monthYear = selectedDate.components(separatedBy: "-")[..<2].joined(separator: "-")
        let day = selectedDate.components(separatedBy: "-")[2]
       
        if let nestedDict = logItemStore.allLogItems[monthYear], let _ = nestedDict[day] {
            performSegue(withIdentifier: "showDetail", sender: date)
        }
        else {
            let mood = Mood.soso
            logItemStore.createItem(date: selectedDate, mood: mood, setByUser: false)
            performSegue(withIdentifier: "showDetail", sender: date)
        }
        /*
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(handleDayChangedNotification(_:)), name: NSNotification.Name.NSCalendarDayChanged, object: nil)
        
        nc.post(name: NSNotification.Name.NSCalendarDayChanged, object: nil)
        */
        print(selectedDate  + " 선택됨")
    }
    //
    public func calendar(_ calendar: FSCalendar, didDeselect date: Date, at monthPosition: FSCalendarMonthPosition) {
        print(dateFormatter.string(from: date) + " 해제됨")
        selectedDate = dateFormatter.string(from:Date())
    }
    
    func calendar(_ calendar: FSCalendar, subtitleFor date: Date) -> String? {
            
        //selectedDate = date
        /*
        switch dateFormatter.string(from: date) {
            case dateFormatter.string(from: Date()):
                return self.currentTMP
            default:
                return nil
        }
         */
        return nil
        
    }
    
    func calendar(_ calendar: FSCalendar!, hasEventForDate date: Date) -> Bool {
        return true
    }
    
    // show image in the calendar
    func calendar(_ calendar: FSCalendar, imageFor date: Date) -> UIImage? {
        
        let date = dateFormatter.string(from:date)
        //print(date)
        // FIXME following lines are repeated fix this
        let monthYear = date.components(separatedBy: "-")[..<2].joined(separator: "-")
        let day = date.components(separatedBy: "-")[2]
        //print("mothYear \(monthYear)")
        if logItemStore.allLogItems.contains(where: {$0.key == monthYear}) {
            //print("month year exitst")
            if ((logItemStore.allLogItems[monthYear]?.contains(where: {$0.key == day})) == true) {
            
                
                let tempImage = logItemStore.allLogItems[monthYear]?[day]!.mood.image
                if let setByUser = logItemStore.allLogItems[monthYear]?[day]!.mood.selectedByUser {
                    if setByUser == false {
                        let tempImage = UIImage(resource: .bg)
                        
                        // resize image
                        let scaledImageSize = CGSize(
                            width: (tempImage.size.width ) * 0.3,
                            height: (tempImage.size.height ) * 0.3)
                        
                        let renderer = UIGraphicsImageRenderer(size: scaledImageSize)
                        let scaledImage = renderer.image { _ in
                            tempImage.draw(in: CGRect(origin: .zero, size: scaledImageSize))
                        }
                        return scaledImage
                    }
                }
                //print("image width: \(tempImage.size.width)")
                
                //if dateFormatter.string(from: date) == dateFormatter.string(from: Date()) {
                //    print("TODAY")
                //}
                
                // resize image
                let scaledImageSize = CGSize(
                    width: (tempImage!.size.width ) * 0.25,
                    height: (tempImage!.size.height ) * 0.25)
                
                let renderer = UIGraphicsImageRenderer(size: scaledImageSize)
                let scaledImage = renderer.image { _ in
                    tempImage!.draw(in: CGRect(origin: .zero, size: scaledImageSize))
                }
                return scaledImage
            }
        }
        // default image for each cell
            
        // default image
        /*
        let startAngle = CGFloat(0.0)
        let endAngle = CGFloat(360.0)
        
        let path = UIBezierPath(arcCenter: CGPoint(x: 25, y: 25), radius: 20, startAngle: startAngle.toRadians(), endAngle: endAngle.toRadians(), clockwise: true)
        
        let size = CGSize(width: 50, height: 50)
        let circle = UIGraphicsImageRenderer(size: size).image { _ in
            UIColor(red: 97/255, green: 174/255, blue: 114/255, alpha: 0.7).setStroke()
            path.lineWidth = 1
            path.stroke()
        }
        return circle
        */
        
        let tempImage = UIImage(resource: .bg)
        
        // resize image
        let scaledImageSize = CGSize(
            width: (tempImage.size.width ) * 0.3,
            height: (tempImage.size.height ) * 0.3)
        
        let renderer = UIGraphicsImageRenderer(size: scaledImageSize)
        let scaledImage = renderer.image { _ in
            tempImage.draw(in: CGRect(origin: .zero, size: scaledImageSize))
        }
        return scaledImage
    }
}

extension CGFloat {
    func toRadians() -> CGFloat {
        return self * CGFloat(Double.pi) / 180.0
    }
}
