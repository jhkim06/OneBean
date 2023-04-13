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
    
    var textOriginalText: String = ""
    var planOriginalText: String = ""
    
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
        
        hourTextView.layer.borderColor = CGColor(red: 97/255, green: 174/255, blue: 114/255, alpha: 0.7)
        hourTextView.layer.borderWidth = 2.0
        hourTextView.layer.cornerRadius = 5
        
        // planTextView.text = currentLogItem.planNote
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let today = dateFormatter.string(from: Date())
        let date = dateFormatter.date(from:currentLogItem.date)
        if (date! <= Date()) {
            titleLabel.text = "How was your day?"
        } else {
            titleLabel.text = "Plan for a day!"
            moodSelector.buttonEnabled = false
        }
        
        if currentLogItem.date == today {
            /*
            // show current temperature
            store.fetchWeatherInfo {
                (weatherResult) in

                switch weatherResult {
                case let .success(weather):
                    print("Successfully found \(weather.count) weather.")
                    // TODO convert Weather to dictionary with desired key
                    self.temperature.text = String(weather[3].obsrValue) + " °C"
                    //print("cat: \(weather[3].category) obs: \(weather[3].obsrValue)")
                    
                case let .failure(error):
                    print("Error fetching interesting photos: \(error)")
                }
            }
            */
        }  else {
            // update dateLabel
            let myFormat = Date.FormatStyle()
                .day()
                .month(.abbreviated)
                .year()
                .weekday(.wide)
            
            let weekday = date!.formatted(myFormat)
            dateLabel.text = weekday
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
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.setCursorToEnd()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textView.delegate = self
        planTextView.delegate = self
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
        // notificationCenter.post(name: UIResponder.keyboardWillShowNotification, object: self.hourTextView)
        
        /*
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(handleDayChangedNotification(_:)), name: NSNotification.Name.NSCalendarDayChanged, object: nil)
        
        nc.post(name: NSNotification.Name.NSCalendarDayChanged, object: nil)
        */
        
    }
    
    @objc func keyboardWillShow(_ notification: NSNotification) {
        print("keyboardWillShow called")
        if self.hourTextView.isFirstResponder {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= (keyboardSize.height + 100)
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
    
    @IBAction func backgroundTapped(_ sender: UITapGestureRecognizer) {
        
        if let parent = presentingViewController as? UITabBarController {
            if let vc = parent.selectedViewController as? MoodListViewController {
                dismiss(animated: true, completion: {
                    //print(self.getMood())
                    vc.tableView.reloadData()
                })
            }
            if let vc = parent.selectedViewController as? CalendarViewController {
                dismiss(animated: true, completion: {
                    //print(self.getMood())
                    if self.currentMood.selectedByUser == false && self.textView.text == "" && self.planTextView.text == "" {
                        vc.logItemStore.removeItem(date: self.currentLogItem.date)
                    }
                    
                    vc.calendarView.reloadData()
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
