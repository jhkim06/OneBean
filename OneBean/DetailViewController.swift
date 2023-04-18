//
//  DetailViewController.swift
//  OneBean
//
//  Created by Junho Kim on 2023/03/25.
//

import UIKit

class DetailViewController: UIViewController, UITextViewDelegate {
    
    @IBOutlet var textView: UITextView!
    @IBOutlet var planTextView: UITextView!
    @IBOutlet var hourTextView: UITextView!
    @IBOutlet var moodSelector: ImageSelector!
    @IBOutlet var temperature: UILabel!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var currentHourLabel: UILabel!
    @IBOutlet var currentHourView: UIView!
    @IBOutlet var logTitleLable: UILabel!
    
    var textOriginalText: String = ""
    var planOriginalText: String = ""
    var firstLog: Bool = true
    var currentLogTime: String = ""
    
    var store: WeatherStore!
 
    var currentLogItem: LogItem!
    var currentMood: Mood!
    
    @IBAction private func moodSelectionChanged(_ sender: ImageSelector) {
        let selectedIndex = sender.selectedIndex
        currentMood = moods[selectedIndex]
        currentMood.selectedByUser = true
    }
    
    var moods: [Mood] = [] {
        didSet {
            //currentMood = moods.first
            moodSelector.images = moods.map { $0.image }
        }
    }
   
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        currentMood = currentLogItem.mood
        moodSelector.selectedIndex = moods.firstIndex(where: {$0 == currentMood})!
        moodSelector.layer.cornerRadius = 5
        
        textView.layer.borderColor = CGColor(red: 97/255, green: 174/255, blue: 114/255, alpha: 0.7)
        textView.layer.borderWidth = 2.0
        textView.layer.cornerRadius = 5
        textView.text = currentLogItem.note
        
        planTextView.layer.borderColor = CGColor(red: 97/255, green: 174/255, blue: 114/255, alpha: 0.7)
        planTextView.layer.borderWidth = 2.0
        planTextView.layer.cornerRadius = 5
        if let planNote = currentLogItem.planNote {
            planTextView.text = planNote
        }
        if let hourNote = currentLogItem.hourNote {
            hourTextView.text = hourNote
        }
        if let firstLog = currentLogItem.firstLogInCurrentHour {
            self.firstLog = firstLog
        }
        if let currentLogTime = currentLogItem.currentLogTime {
            self.currentLogTime = currentLogTime
        }
        
        hourTextView.layer.borderColor = CGColor(red: 97/255, green: 174/255, blue: 114/255, alpha: 0.7)
        hourTextView.layer.borderWidth = 2.0
        hourTextView.layer.cornerRadius = 5
        
        // planTextView.text = currentLogItem.planNote
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        let calendar = Calendar.current
        let selectedYear = currentLogItem.date.components(separatedBy: "-")[0]
        let selectedMonth = currentLogItem.date.components(separatedBy: "-")[1]
        let selectedDay = currentLogItem.date.components(separatedBy: "-")[2]
        var dateComponents = DateComponents()
        dateComponents.year = Int(selectedYear)
        dateComponents.month = Int(selectedMonth)
        dateComponents.day = Int(selectedDay)
        let selectedDate = calendar.date(from: dateComponents)
        
        let year = calendar.component(.year, from: Date())
        let month = calendar.component(.month, from: Date())
        let day = calendar.component(.day, from: Date())

        dateComponents.year = year
        dateComponents.month = month
        dateComponents.day = day
        let today = calendar.date(from: dateComponents)
        
        if (selectedDate! <= today!) {
            if (selectedDate! < today!) {
                titleLabel.text = "How was your day?"
                logTitleLable.text = "You can't changed the past"
            }
            if (selectedDate! == today) {
                titleLabel.text = "How is your day?"
                logTitleLable.text = "How is your current hour?"
            }
        } else {
            titleLabel.text = "Plan for a day!"
            logTitleLable.text = "You can't log the future yet"
            moodSelector.buttonEnabled = false
        }
        
        if selectedDate == today {
            
            let currentTime = Date()
            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = "HH:mm"
            let timeString = timeFormatter.string(from: currentTime)
            
            self.currentHourLabel.text = timeString
            
        }  else {
            // update dateLabel
            let myFormat = Date.FormatStyle()
                .day()
                .month(.abbreviated)
                .year()
                .weekday(.wide)
            
            let weekday = selectedDate!.formatted(myFormat)
            dateLabel.text = weekday
            
            self.currentHourLabel.text = ""
        }
        
    }
    
    func setCursorToEnd() {
        let endPosition = textView.endOfDocument
        textView.selectedTextRange = textView.textRange(from: endPosition, to: endPosition)
        textView.scrollRangeToVisible(textView.selectedRange)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        currentLogItem.setMood(mood: currentMood)
        currentLogItem.setNote(note: textView.text)
        currentLogItem.setPlanNote(note: planTextView.text)
        currentLogItem.setHourNote(note: hourTextView.text)
        currentLogItem.setFirstLog(first: firstLog)
        currentLogItem.setCurrentLogTime(time: currentLogTime)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.setCursorToEnd()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.layer.cornerRadius = self.view.frame.width / 50
        textView.delegate = self
        planTextView.delegate = self
        hourTextView.delegate = self
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let today = dateFormatter.string(from: Date())
        
        if currentLogItem.date == today {
            
        var colonColor = UIColor.black
            _ = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { timer in
            
            let currentTime = Date()
            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = "HH:mm"
            let timeString = timeFormatter.string(from: currentTime)
            
            self.currentHourLabel.text = timeString
            // Create a mutable attributed string from the label's text
            let attributedString = NSMutableAttributedString(string: self.currentHourLabel.text!)
            
            // Find the range of the colon in the attributed string
            if let colonRange = self.currentHourLabel.text?.range(of: ":")?.lowerBound.utf16Offset(in: self.currentHourLabel.text!) {
                // Toggle the colon's visibility by setting its color to the background color
                // when hidden, and to the specified color when visible
                if self.currentHourLabel.textColor == colonColor {
                    attributedString.addAttribute(.foregroundColor, value: UIColor.clear, range: NSRange(location: colonRange, length: 1))
                    colonColor = UIColor.clear
                } else {
                    attributedString.addAttribute(.foregroundColor, value: UIColor.black, range: NSRange(location: colonRange, length: 1))
                    colonColor = UIColor.black
                }
            }
            
            // Set the modified attributed string back to the label
            self.currentHourLabel.attributedText = attributedString
        }
        }
        /*
        currentMood = currentLogItem.mood
        moodSelector.selectedIndex = moods.firstIndex(where: {$0 == currentMood})!
        moodSelector.layer.cornerRadius = 5
        */
        //store.fetchWeatherInfo()
        
        // if selected date == today
        
        moods = [.happy, .good, .soso, .bad, .sad]
        //selectMood.layer.cornerRadius = selectMood.bounds.height/2
        self.textView.addDoneButton(title: "Done", target: self, selector: #selector(tapDone(sender:)))
        self.planTextView.addDoneButton(title: "Done", target: self, selector: #selector(tapDone(sender:)))
        self.hourTextView.addDoneButton(title: "Done", target: self, selector: #selector(tapDone(sender:)))
        
        self.planOriginalText = planTextView.text
        self.textOriginalText = textView.text
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        // use notification to mote text of hourTextView to the textView every hour.
        /*
        NotificationCenter.default.addObserver(self, selector: #selector(handleHourChange), name: .NSCalendarDayChanged, object: nil)
        */
        /*
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(handleDayChangedNotification(_:)), name: NSNotification.Name.NSCalendarDayChanged, object: nil)
        
        nc.post(name: NSNotification.Name.NSCalendarDayChanged, object: nil)
        */
        
    }
    
    /*
    @objc func handleHourChange() {
        let currentMinute = NSCalendar.current.component(.minute, from: Date())
        if currentMinute == 0 {
            // Hour has changed, perform action
            self.textView.text = "\nhour log,"
            let trimmedString = hourTextView.text.trimmingCharacters(in: .whitespacesAndNewlines)
            if !trimmedString.isEmpty {
                self.textView.text += self.hourTextView.text
            }
            self.hourTextView.text = ""
        }
    }
    */
    @objc func keyboardWillShow(_ notification: NSNotification) {
        if self.hourTextView.isFirstResponder {
            if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
                if self.view.frame.origin.y == 0 {
                    self.view.frame.origin.y -= (keyboardSize.height )
                }
            }
            
        }
    }
    @objc func keyboardWillHide(_ notification: NSNotification) {
        if self.hourTextView.isFirstResponder {
            if self.view.frame.origin.y != 0 {
                self.view.frame.origin.y = 0
            }
        }
    }
    
    @objc func tapDone(sender: Any) {
        // writeTime()
        if self.hourTextView.isFirstResponder {
            self.updateLog()
        }
        self.setCursorToEnd()
        self.view.endEditing(true)
    }
    @IBAction func addTime(sender: UIButton) {
       
        let currentTime = Date()
        //currentTime.formatted(date: .complete, time: .complete)
        
        if let selectedRange = textView.selectedTextRange {
            //self.currentLogItem
            let dateString = "\n\(currentTime.formatted(date: .omitted, time: .shortened))"
            textView.replace(selectedRange, withText: dateString)
        }
    }
    func writeTime() {
        let currentTime = Date()
        //currentTime.formatted(date: .complete, time: .complete)
        
        if let selectedRange = textView.selectedTextRange {
            
           /*
             let selectedNSRange = textView.selectedRange
             textView.replace(selectedRange, withText: " (\(currentTime.formatted(date: .abbreviated, time: .shortened)))")
             textView.textStorage.addAttribute(.font, value: UIFont.boldSystemFont(ofSize: 5), range: selectedNSRange)
             //print("current position \(selectedRange)")
             */
            
           let selectedNSRange = textView.selectedRange
           textView.replace(selectedRange, withText: " (\(currentTime.formatted(date: .abbreviated, time: .shortened)))")
           let lengthOfInsertedText = " (\(currentTime.formatted(date: .abbreviated, time: .shortened)))".count
           let font = UIFont.boldSystemFont(ofSize: 7)
           textView.textStorage.addAttribute(.font, value: font, range: NSRange(location: selectedNSRange.location, length: lengthOfInsertedText))
           let newSelectedRange = NSRange(location: selectedNSRange.location + lengthOfInsertedText, length: 0)
           textView.selectedRange = newSelectedRange
        }
    }
    func updateLog() {
        // TODO make a function for below
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let today = dateFormatter.string(from: Date())
        
        if self.currentLogItem.date == today {
            
            let trimmedString = self.hourTextView.text.trimmingCharacters(in: .whitespacesAndNewlines)
            if !trimmedString.isEmpty {
                
                let currentTime = Date()
                let timeFormatter = DateFormatter()
                timeFormatter.dateFormat = "HH:mm"
                let timeString = timeFormatter.string(from: currentTime)
                
                if self.firstLog == false && timeString.components(separatedBy: ":")[0] != self.currentLogTime.components(separatedBy: ":")[0] {
                    self.firstLog = true
                }
                
                // if this is the first log of the current hour, put time
                // else just add the text
                if self.firstLog {
                    //self.hourTextView.text = "\n\(timeString.components(separatedBy: ":")[0]):00 one hour log...\n" + timeString + " " + self.hourTextView.text
                    self.hourTextView.text = "\n" + timeString + " " + self.hourTextView.text
                    self.textView.text += self.hourTextView.text
                    
                    self.firstLog = false
                } else {
                    self.hourTextView.text = "\n" + timeString + " " + self.hourTextView.text
                    self.textView.text += self.hourTextView.text
                }
                self.currentLogTime = timeString
                
            }
        }
        // always clear hourTextView
        self.hourTextView.text = ""
    }
    @IBAction func backgroundTapped(_ sender: UITapGestureRecognizer) {
        
        if let parent = presentingViewController as? UITabBarController {
            
            self.updateLog()
            if let vc = parent.selectedViewController as? MoodListViewController {
                dismiss(animated: true, completion: {
                    //print(self.getMood())
                    vc.tableView.reloadData()
                })
            }
            if let vc = parent.selectedViewController as? CalendarViewController {
                
                dismiss(animated: true, completion: {
                    //print(self.getMood())
                    print("dismiss, CalendarViewController")
                    if self.currentMood.selectedByUser == false && self.textView.text == "" && self.planTextView.text == "" {
                        vc.logItemStore.removeItem(date: self.currentLogItem.date)
                    }
                    
                    vc.calendarView.reloadData()
                    vc.beginAppearanceTransition(true, animated: true)
                })
            }
        }
        
        //dismiss(animated: true)
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        //let endPosition = textView.endOfDocument
        //print(endPosition)
        //textView.selectedTextRange = textView.textRange(from: endPosition, to: endPosition)
        //textView.scrollRangeToVisible(textView.selectedRange)
    }
    
     /*
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        
        if let selectedRange = textView.selectedTextRange {
            //self.currentLogItem
            print("before \(selectedRange)")
        }
        
        let endPosition = textView.endOfDocument
        textView.selectedTextRange = textView.textRange(from: endPosition, to: endPosition)
        textView.scrollRangeToVisible(textView.selectedRange)
        
        if let selectedRange = textView.selectedTextRange {
            //self.currentLogItem
            print("after \(selectedRange)")
        }
        
        return true
    }
    */
    
}
