//
//  ViewController.swift
//  OneBean
//
//  Created by Junho Kim on 2023/03/05.
//

import UIKit
import FSCalendar

class ViewController: UIViewController {

    @IBOutlet var calendarView: FSCalendar!
    
    @IBOutlet var stackView: UIStackView!
    @IBOutlet var addMoodButton: UIButton!
    
    var currentMood: Mood? {
        didSet {
            guard let currentMood = currentMood else {
                addMoodButton?.setTitle(nil, for: .normal)
                addMoodButton?.backgroundColor = nil
                return
            }

            addMoodButton?.setTitle("I'm \(currentMood.name)", for: .normal)
            addMoodButton?.backgroundColor = currentMood.color
            
            // TODO if date selected update Log array
            logItemStore.createItem(date: selectedDate, mood: currentMood)
            calendarView.reloadData()
        }
    }

    @objc func moodSelectionChanged(_ sender: UIButton) {
        //
        guard let selectedIndex = moodButtons.firstIndex(of: sender) else {
            preconditionFailure(
                    "Unable to find the tapped button in the buttons array.")
        }
        //
        currentMood = moods[selectedIndex]
        
    }
    
    var moodButtons: [UIButton] = [] {
        didSet {
            oldValue.forEach { $0.removeFromSuperview() }
            moodButtons.forEach { stackView.addArrangedSubview($0)}
        }
    }

    //
    var moods: [Mood] = [] {
        didSet {
            currentMood = moods.first
            moodButtons = moods.map { mood in
                let moodButton = UIButton()
                moodButton.setImage(mood.image, for: .normal)
                moodButton.imageView?.contentMode = .scaleAspectFit
                //moodButton.adjustsImageWhenHighlighted = false
                moodButton.addTarget(self,
                                     action: #selector(moodSelectionChanged(_:)),
                                     for: .touchUpInside)
                return moodButton
            }
        }
    }
    
    let dateFormatter = DateFormatter()
    var selectedDate = Date() // default to today
    
    var logItemStore: LogItemStore!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        moods = [.happy, .sad, .angry, .goofy, .crying, .confused, .sleepy, .meh]
        addMoodButton.layer.cornerRadius = addMoodButton.bounds.height / 2
        
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        calendarView.delegate = self
        calendarView.dataSource = self
        
        calendarView.scrollEnabled = true
        calendarView.scrollDirection = .vertical
        
        calendarView.register(CustomCalendarCell.self, forCellReuseIdentifier: "cell")
        
        calendarView.backgroundColor = UIColor(red: 241/255, green: 244/255, blue: 237/255, alpha: 1)
        calendarView.appearance.selectionColor = UIColor(red: 38/255, green: 153/255, blue: 251/255, alpha: 0.5)
        calendarView.appearance.todayColor = UIColor(red: 38/255, green: 153/255, blue: 251/255, alpha: 0.2)
        
        // 
        calendarView.appearance.headerTitleFont = UIFont(name: "Avenir-Light", size: 20.0)
        calendarView.appearance.headerTitleColor = .gray
        
        calendarView.appearance.titleFont = UIFont(name: "Avenir-Light", size: 10.0)
        
        calendarView.appearance.weekdayTextColor = .gray
        calendarView.appearance.weekdayFont = UIFont(name: "Avenir-Light", size: 18.0)
        
        calendarView.appearance.subtitleSelectionColor = .red
    }
}

extension ViewController : FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance {

    func calendar(_ calendar: FSCalendar, cellFor date: Date, at position: FSCalendarMonthPosition) -> FSCalendarCell {
        let cell = calendar.dequeueReusableCell(withIdentifier: "cell", for: date, at: position)
        
        return cell
    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, isSelected date: Date) -> Bool {
        return true // Return true to indicate that the date is selected
    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, titleSelectionColorFor date: Date) -> UIColor? {
        
        return UIColor.white // Set the title selection color to clear to remove the default selection text color
    }
    /*
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, fillSelectionColorFor date: Date) -> UIColor? {
        return UIColor.clear // Set the fill selection color to clear to remove the default selection background color
    }
    */
    
    //
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, imageOffsetFor date: Date) -> CGPoint {
        if logItemStore.allLogItems.contains(where: {$0.key == date}) {
            return CGPoint(x:0.0, y:10.0)
        }
        return CGPoint(x:0.0, y:0.0)
    }
    
    // selection condition
    func calendar(_ calendar: FSCalendar, shouldSelect date: Date, at monthPosition: FSCalendarMonthPosition) -> Bool {
        
        // block to select future date
        if date > Date() {
                return false
        } else {
            return true
        }
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        selectedDate = date
        print(calendar.frame.origin)
        print(dateFormatter.string(from: selectedDate) + " 선택됨")
    }
    //
    public func calendar(_ calendar: FSCalendar, didDeselect date: Date, at monthPosition: FSCalendarMonthPosition) {
        print(dateFormatter.string(from: date) + " 해제됨")
        selectedDate = Date()
    }
    
    func calendar(_ calendar: FSCalendar, subtitleFor date: Date) -> String? {
            
        //selectedDate = date
        /*
        switch dateFormatter.string(from: date) {
            case dateFormatter.string(from: Date()):
                return "Today"
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
        
        if logItemStore.allLogItems.contains(where: {$0.key == date}) {
            let tempImage = logItemStore.allLogItems[date]!.mood.image
            
            // resize image
            let scaledImageSize = CGSize(
                width: (tempImage.size.width ) * 0.15,
                height: (tempImage.size.height ) * 0.15)
            
            let renderer = UIGraphicsImageRenderer(size: scaledImageSize)
            let scaledImage = renderer.image { _ in
                tempImage.draw(in: CGRect(origin: .zero, size: scaledImageSize))
            }
            return scaledImage
        }
        
        return nil
    }
}

