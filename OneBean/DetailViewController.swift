//
//  DetailViewController.swift
//  OneBean
//
//  Created by Junho Kim on 2023/03/25.
//

import UIKit

class DetailViewController: UIViewController, UITextViewDelegate {
    
    @IBOutlet var textView: UITextView!
    @IBOutlet var moodSelector: ImageSelector!
 
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
        
        textView.layer.borderColor = CGColor(red: 97/255, green: 174/255, blue: 114/255, alpha: 0.7)
        textView.layer.borderWidth = 2.0
        textView.layer.cornerRadius = 5
        textView.text = currentLogItem.note
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        currentLogItem.setMood(mood: currentMood)
        currentLogItem.setNote(note: textView.text)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        moods = [.happy, .good, .soso, .bad, .sad]
        //selectMood.layer.cornerRadius = selectMood.bounds.height/2
        self.textView.addDoneButton(title: "Done", target: self, selector: #selector(tapDone(sender:)))
       
        /*
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        */
    }
    @objc func tapDone(sender: Any) {
        self.view.endEditing(true)
    }
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
}
