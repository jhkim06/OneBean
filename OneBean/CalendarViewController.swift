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
    var tomorrowTMX: String?
    var tomorrowTMN: String?
    var selectedDateUpdated: Bool = false
    var isSegueInProgress = false
    
    var vilageFcst = [String: [String:String]]()
    
    // views for forecast weather
    @IBOutlet var SKY1: UIImageView?
    @IBOutlet var SKY1Time: UILabel?
    @IBOutlet var SKY2: UIImageView?
    @IBOutlet var SKY2Time: UILabel?
    @IBOutlet var temperature: UILabel?
    
    @IBOutlet var addressLabel: UILabel!
    @IBOutlet var showDetailButton: UIButton!
    @IBOutlet var daateLabel: UILabel!

    @IBAction func showDetail(_ sender: UIButton) {
        // no need to add here for segue
    }

    //
    let dateFormatter = DateFormatter()
    var selectedDate = String() // default to today
    
    var logItemStore: LogItemStore!
    
    override func viewWillAppear(_ animated: Bool) {
        print("viewWillAppear")
        super.viewWillAppear(animated)
        
        if selectedDateUpdated == false {
            selectedDate = dateFormatter.string(from:Date())
        }
        calendarView.reloadData()
        
        //
        let myFormat = Date.FormatStyle()
            .day()
            .weekday(.abbreviated)
            .month(.abbreviated)
        
        let calendar = Calendar.current
        let selectedYear = self.selectedDate.components(separatedBy: "-")[0]
        let selectedMonth = self.selectedDate.components(separatedBy: "-")[1]
        let selectedDay = self.selectedDate.components(separatedBy: "-")[2]
        var dateComponents = DateComponents()
        dateComponents.year = Int(selectedYear)
        dateComponents.month = Int(selectedMonth)
        dateComponents.day = Int(selectedDay)
        let selectedDate = calendar.date(from: dateComponents)
        
        let weekday = selectedDate!.formatted(myFormat)
        self.daateLabel.text = weekday
        
        // set image for button to show detail
        let monthYear = self.selectedDate.components(separatedBy: "-")[..<2].joined(separator: "-")
        let day = self.selectedDate.components(separatedBy: "-")[2]
        
        if logItemStore.allLogItems.contains(where: {$0.key == monthYear}) && ((logItemStore.allLogItems[monthYear]?.contains(where: {$0.key == day})) == true){
            let tempImage = logItemStore.allLogItems[monthYear]?[day]!.mood.image
            if let setByUser = logItemStore.allLogItems[monthYear]?[day]!.mood.selectedByUser {
                // mood is not set by user
                if setByUser == false {
                    // show background image
                    let scaledImage = self.rescaleImage(rawImage: UIImage(resource: .bg))
                    self.showDetailButton.setImage(scaledImage, for: .normal)
                    
                } else {
                    let scaledImage = self.rescaleImage(rawImage: tempImage!)
                    self.showDetailButton.setImage(scaledImage, for: .normal)
                }
                
            } else { // selectedByUser may not exist since recentrly added
                let scaledImage = self.rescaleImage(rawImage: tempImage!)
                self.showDetailButton.setImage(scaledImage, for: .normal)
            }
        } else {
            // show background image
            let scaledImage = self.rescaleImage(rawImage: UIImage(resource: .bg))
            self.showDetailButton.setImage(scaledImage, for: .normal)
        }
        
        //self.locationProvider?.start() // track location
        self.locationProvider?.getAddress() {
            (addressStr) in
            self.addressLabel.text = "현위치 " + addressStr
        }
        
        // get current temperature of current location
        OperationQueue.main.addOperation {
           
            // current temperature
            self.store.fetchWeatherInfo() { [self] // selecte endpoint
            (weatherResult) in
                switch weatherResult {
                case let .success(weather):
                    self.currentTMP = weather["T1H"] as! String + "°C"
                    if self.selectedDate == dateFormatter.string(from: Date()) {
                        self.temperature!.text = self.currentTMP
                    } else {
                        self.temperature!.text = "No data"
                    }
                    
                    DispatchQueue.main.async {
                        self.calendarView.reloadData() // wait and reload
                    }
                     
                case let .failure(error):
                    print("Error fetching interesting photos: \(error)")
                }
            }
            
            // 단기예보
            self.store.fetchWeatherInfo(endpoint: EndPoint.getVilageFcst) { // select endpoint
            (weatherResult) in
                switch weatherResult {
                case let .success(weather):
                    //print(weather["TMP"])
                    
                    if let dict = weather as? [String:[String:String]] {
                        self.vilageFcst = dict
                        let calendar = Calendar.current
                        let currentDate = Date()
                        let tomorrowDate = calendar.date(bySettingHour: 5, minute: 0, second: 0, of: calendar.date(byAdding: .day, value: 1, to: currentDate)!)
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "yyyyMMdd:HHmm"
                        let tomorrow = dateFormatter.string(from: tomorrowDate!)
                        //print(dict["SKY"])
                        
                        for (dateTime, value) in dict["TMX"]! {
                            if dateTime.components(separatedBy: ":")[0] == tomorrow.components(separatedBy: ":")[0] {
                                self.tomorrowTMX = value
                            }
                        }
                        for (dateTime, value) in dict["TMN"]! {
                            if dateTime.components(separatedBy: ":")[0] == tomorrow.components(separatedBy: ":")[0] {
                                self.tomorrowTMN = value
                            }
                        }
                        
                        DispatchQueue.main.async {
                            self.calendarView.reloadData() // wait and reload
                        }
                        
                        self.showFcstWeather()
                        
                        if dateFormatter.string(from: selectedDate!) == dateFormatter.string(from: tomorrowDate!) {
                            self.temperature!.text = "H/L" + (self.tomorrowTMX ?? "") + "/" + (self.tomorrowTMN ?? "") + "°C"
                        }
                        
                    }
                     
                case let .failure(error):
                    print("Error fetching interesting photos: \(error)")
                }
            }
        }
    }
    
    func showFcstWeather() {
        
        let myFormat = Date.FormatStyle()
            .day()
            .weekday(.abbreviated)
            .month(.abbreviated)
        
        let calendar = Calendar.current
        let selectedYear = self.selectedDate.components(separatedBy: "-")[0]
        let selectedMonth = self.selectedDate.components(separatedBy: "-")[1]
        let selectedDay = self.selectedDate.components(separatedBy: "-")[2]
        var dateComponents = DateComponents()
        dateComponents.year = Int(selectedYear)
        dateComponents.month = Int(selectedMonth)
        dateComponents.day = Int(selectedDay)
        let selectedDate = calendar.date(from: dateComponents)
        
        let weekday = selectedDate!.formatted(myFormat)
        self.daateLabel.text = weekday
        
        let currentTime = Date()
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "yyyyMMdd:HH"
        
        let currentString = timeFormatter.string(from: currentTime) + "00"
        let selectedString = timeFormatter.string(from: selectedDate!) + "00"
        
        // for today
        if currentString.components(separatedBy: ":")[0] == selectedString.components(separatedBy: ":")[0] {
            // show current SKY
            let sky = self.vilageFcst["SKY"]![currentString] // can raise error?
        
            switch sky {
            case "1":
                self.SKY1?.image = UIImage(systemName: "sun.max.fill")
                self.SKY1Time!.text = "Now"
            case "3":
                self.SKY1?.image = UIImage(systemName: "cloud")
                self.SKY1Time!.text = "Now"
            case "4":
                self.SKY1?.image = UIImage(systemName: "cloud.fill")
                self.SKY1Time!.text = "Now"
            default:
                print("something wrong")
            }
           
            let secondTime = calendar.date(byAdding: .hour, value: 6, to: currentTime)
            let secondString = timeFormatter.string(from: secondTime!) + "00"
            
            let sky2 = self.vilageFcst["SKY"]![secondString]
            switch sky2 {
            case "1":
                self.SKY2?.image = UIImage(systemName: "sun.max.fill")
                self.SKY2Time!.text = secondString.components(separatedBy: ":")[1]
            case "3":
                self.SKY2?.image = UIImage(systemName: "cloud")
                self.SKY2Time!.text = secondString.components(separatedBy: ":")[1]
            case "4":
                self.SKY2?.image = UIImage(systemName: "cloud.fill")
                self.SKY2Time!.text = secondString.components(separatedBy: ":")[1]
            default:
                print("something wrong")
            }
            
        } else {
            
            // fcstTime, button
            // self.SKY1
            if var _ = self.vilageFcst["SKY"]![selectedString], (self.vilageFcst["SKY"]?.contains(where: {$0.key == selectedString.components(separatedBy: ":")[0] + ":0600"})) == true {
                let sky = self.vilageFcst["SKY"]![selectedString.components(separatedBy: ":")[0] + ":0600"]!
                let pty = self.vilageFcst["PTY"]![selectedString.components(separatedBy: ":")[0] + ":0600"]!
                
                switch sky {
                case "1":
                    self.SKY1?.image = UIImage(systemName: "sun.max.fill")
                    self.SKY1Time!.text = "0600"
                case "3":
                    self.SKY1?.image = UIImage(systemName: "cloud")
                    if pty == "1" {
                        self.SKY1?.image = UIImage(systemName: "cloud.rain")
                    }
                    self.SKY1Time!.text = "0600"
                case "4":
                    self.SKY1?.image = UIImage(systemName: "cloud.fill")
                    if pty == "1" {
                        self.SKY1?.image = UIImage(systemName: "cloud.rain.fill")
                    }
                    self.SKY1Time!.text = "0600"
                default:
                    print("something wrong")
                    self.SKY1?.image = nil
                    self.SKY1Time!.text = nil
                }
                
            } else {
                print("not exist")
                self.SKY1?.image = nil
                self.SKY1Time!.text = nil
            }
            
            if var _ = self.vilageFcst["SKY"]![selectedString], (self.vilageFcst["SKY"]?.contains(where: {$0.key == selectedString.components(separatedBy: ":")[0] + ":1200"})) == true {
                let sky = self.vilageFcst["SKY"]![selectedString.components(separatedBy: ":")[0] + ":1200"]!
                let pty = self.vilageFcst["PTY"]![selectedString.components(separatedBy: ":")[0] + ":1200"]!
                
                switch sky {
                case "1":
                    self.SKY2?.image = UIImage(systemName: "sun.max.fill")
                    self.SKY2Time!.text = "1200"
                case "3":
                    self.SKY2?.image = UIImage(systemName: "cloud")
                    if pty == "1" {
                        self.SKY2?.image = UIImage(systemName: "cloud.rain")
                    }
                    self.SKY2Time!.text = "1200"
                case "4":
                    self.SKY2?.image = UIImage(systemName: "cloud.fill")
                    if pty == "1" {
                        self.SKY2?.image = UIImage(systemName: "cloud.rain.fill")
                    }
                    self.SKY2Time!.text = "1200"
                default:
                    print("something wrong")
                    self.SKY2?.image = nil
                    self.SKY2Time!.text = nil
                }
                
            } else {
                print("not exist")
                self.SKY2?.image = nil
                self.SKY2Time!.text = nil
            }
        }
    }
    
    override func viewDidLoad() {
        print("viewDidLoad")
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
        calendarView.appearance.selectionColor = UIColor(red: 97/255, green: 174/255, blue: 114/255, alpha: 0.2)
        calendarView.appearance.todayColor = UIColor(red: 255/255, green: 105/255, blue: 97/255, alpha: 0.3)
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
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleDayChangedNotification(_:)), name: NSNotification.Name.NSCalendarDayChanged, object: nil)
        
    }
    
    func rescaleImage(rawImage: UIImage, scale: CGFloat = 0.4) -> UIImage {
        // resize image
        let scaledImageSize = CGSize(
            width: (rawImage.size.width ) * scale,
            height: (rawImage.size.height ) * scale)
        
        let renderer = UIGraphicsImageRenderer(size: scaledImageSize)
        let scaledImage = renderer.image { _ in
            rawImage.draw(in: CGRect(origin: .zero, size: scaledImageSize))
        }
        return scaledImage
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
        return CGPoint(x:0.0, y:-20.0)
    }
    /*
    func calendar(_ calendar: FSCalendar, willDisplay cell: FSCalendarCell, for date: Date, at position: FSCalendarMonthPosition) {
        // Remove your custom view from the cell's subviews
        cell.subviews.filter({ $0 is CircleLabelWrapper }).forEach({ $0.removeFromSuperview() })
    }
    */
    func calendar(_ calendar: FSCalendar, cellFor date: Date, at position: FSCalendarMonthPosition) -> FSCalendarCell {
        let cell = calendar.dequeueReusableCell(withIdentifier: "cellCustom", for: date, at: position)
        
        /*
         // example of CircleLabelWrapper
        let calendar = Calendar.current
        let currentDate = Date()
        
        if dateFormatter.string(from: date) == dateFormatter.string(from: Date()) {
            let circleSize = CGSize(width: 5, height: 5)
            let circleOrigin = CGPoint(x: 25, y: 38)
            let circleLabelWrapper = CircleLabelWrapper(frame: CGRect(origin: circleOrigin, size: circleSize), self.currentTMP ?? "")
            // add the custom view to the cell
            cell.addSubview(circleLabelWrapper)
            //circleLabelWrapper.frame = CGRect(origin: circleOrigin, size: circleSize)
        }
       
        if dateFormatter.string(from: date) == dateFormatter.string(from: tomorrowDate!) {
            let circleSize = CGSize(width: 5, height: 5)
            let circleOrigin = CGPoint(x: 25, y: 38)
            let circleLabelWrapper = CircleLabelWrapper(frame: CGRect(origin: circleOrigin, size: circleSize), "H/L" + (self.tomorrowTMX ?? "") + "/" + (self.tomorrowTMN ?? "") + "°C")
            // add the custom view to the cell
            cell.addSubview(circleLabelWrapper)
            //circleLabelWrapper.frame = CGRect(origin: circleOrigin, size: circleSize)
        }
         */
       
       
        
        
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
        return CGPoint(x:0.0, y:-7.0)
    }
    
    // selection condition
    func calendar(_ calendar: FSCalendar, shouldSelect date: Date, at monthPosition: FSCalendarMonthPosition) -> Bool {
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "showDetailButton" {
            //if let destinationVC = segue.destination as? DetailViewController, let _ = sender as? Date {
            if let destinationVC = segue.destination as? DetailViewController {
                // Pass any data to the destination view controller here
                let monthYear = self.selectedDate.components(separatedBy: "-")[..<2].joined(separator: "-")
                let day = self.selectedDate.components(separatedBy: "-")[2]
                
                if let nestedDict = self.logItemStore.allLogItems[monthYear], let _ = nestedDict[day] {
                    print("item exist")
                }
                else {
                    // if item not exist, create with setByUser is false
                    let mood = Mood.soso
                    self.logItemStore.createItem(date: self.selectedDate, mood: mood, setByUser: false)
                }
                
                let logItem = self.logItemStore.allLogItems[monthYear]![day]
                destinationVC.currentLogItem = logItem
                destinationVC.store = WeatherStore()
            }
            segue.destination.modalPresentationStyle = .fullScreen
        }
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        self.selectedDate = dateFormatter.string(from:date)
        self.selectedDateUpdated = true
        
        let monthYear = self.selectedDate.components(separatedBy: "-")[..<2].joined(separator: "-")
        let day = self.selectedDate.components(separatedBy: "-")[2]
        
        if logItemStore.allLogItems.contains(where: {$0.key == monthYear}) && ((logItemStore.allLogItems[monthYear]?.contains(where: {$0.key == day})) == true){
            let tempImage = logItemStore.allLogItems[monthYear]?[day]!.mood.image
            if let setByUser = logItemStore.allLogItems[monthYear]?[day]!.mood.selectedByUser {
                // mood is not set by user
                if setByUser == false {
                    // show background image
                    let scaledImage = self.rescaleImage(rawImage: UIImage(resource: .bg))
                    self.showDetailButton.setImage(scaledImage, for: .normal)
                    
                } else {
                    let scaledImage = self.rescaleImage(rawImage: tempImage!)
                    self.showDetailButton.setImage(scaledImage, for: .normal)
                }
                
            } else { // selectedByUser may not exist since recentrly added
                let scaledImage = self.rescaleImage(rawImage: tempImage!)
                self.showDetailButton.setImage(scaledImage, for: .normal)
            }
        } else {
            // show background image
            let scaledImage = self.rescaleImage(rawImage: UIImage(resource: .bg))
            self.showDetailButton.setImage(scaledImage, for: .normal)
        }
        
        self.showFcstWeather()
        
        let calendar = Calendar.current
        let currentDate = Date()
        let tomorrowDate = calendar.date(bySettingHour: 5, minute: 0, second: 0, of: calendar.date(byAdding: .day, value: 1, to: currentDate)!)
        
        if dateFormatter.string(from: date) == dateFormatter.string(from: Date()) {
            self.temperature!.text = self.currentTMP
        } else if dateFormatter.string(from: date) == dateFormatter.string(from: tomorrowDate!) {
            self.temperature!.text = "H/L " + (self.tomorrowTMX ?? "") + "/" + (self.tomorrowTMN ?? "") + "°C"
        } else {
            self.temperature!.text = "No data"
        }
        
        
        print(self.selectedDate  + " 선택됨")
    }
    //
    public func calendar(_ calendar: FSCalendar, didDeselect date: Date, at monthPosition: FSCalendarMonthPosition) {
        print(dateFormatter.string(from: date) + " 해제됨")
        selectedDate = dateFormatter.string(from:Date())
    }
    
    func calendar(_ calendar: FSCalendar, subtitleFor date: Date) -> String? {
        return nil
    }
    
    func calendar(_ calendar: FSCalendar!, hasEventForDate date: Date) -> Bool {
        return true
    }
    
    // show image in the calendar
    func calendar(_ calendar: FSCalendar, imageFor date: Date) -> UIImage? {
        
        let date = dateFormatter.string(from:date)
        // FIXME following lines are repeated fix this
        let monthYear = date.components(separatedBy: "-")[..<2].joined(separator: "-")
        let day = date.components(separatedBy: "-")[2]
        //print("mothYear \(monthYear)")
        if logItemStore.allLogItems.contains(where: {$0.key == monthYear}) {
            //print("month year exitst")
            if ((logItemStore.allLogItems[monthYear]?.contains(where: {$0.key == day})) == true) {
                
                let tempImage = logItemStore.allLogItems[monthYear]?[day]!.mood.image
                if let setByUser = logItemStore.allLogItems[monthYear]?[day]!.mood.selectedByUser {
                    // mood is not set by user
                    if setByUser == false {
                        let tempImage = UIImage(resource: .bg)
                        
                        // resize image
                        let scaledImageSize = CGSize(
                            width: (tempImage.size.width ) * 0.25,
                            height: (tempImage.size.height ) * 0.25)
                        
                        let renderer = UIGraphicsImageRenderer(size: scaledImageSize)
                        let scaledImage = renderer.image { _ in
                            tempImage.draw(in: CGRect(origin: .zero, size: scaledImageSize))
                        }
                        return scaledImage
                    } else {
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
        let tempImage = UIImage(resource: .bg)
        
        // resize image
        let scaledImageSize = CGSize(
            width: (tempImage.size.width ) * 0.25,
            height: (tempImage.size.height ) * 0.25)
        
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
