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
    @IBOutlet var moodSelector: ImageSelector!
    @IBOutlet var temperature: UILabel!
    
    var store: WeatherStore!
 
    var currentLogItem: LogItem!
    var currentMood: Mood!
    
    @IBAction private func moodSelectionChanged(_ sender: ImageSelector) {
        let selectedIndex = sender.selectedIndex
        currentMood = moods[selectedIndex]
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
        // planTextView.text = currentLogItem.planNote
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let today = dateFormatter.string(from: Date())
        if currentLogItem.date == today {
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
        //store.fetchWeatherInfo()
        
        // if selected date == today
        
        moods = [.happy, .good, .soso, .bad, .sad]
        //selectMood.layer.cornerRadius = selectMood.bounds.height/2
        self.textView.addDoneButton(title: "Done", target: self, selector: #selector(tapDone(sender:)))
        self.planTextView.addDoneButton(title: "Done", target: self, selector: #selector(tapDone(sender:)))
        /*
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        */
    }
    /*
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }
    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
    */
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
        // if let vc = presentingViewController as? CalendarViewController
        if let vc = presentingViewController?.children[1] as? MoodListViewController {
            dismiss(animated: true, completion: {
                //print(self.getMood())
                vc.tableView.reloadData()
            })
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
    func textViewDidChange(_ textView: UITextView) {
        print("change")
    }
    
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
