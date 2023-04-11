//
//  MoodSelectionViewController.swift
//  OneBean
//
//  Created by Junho Kim on 2023/03/20.
//

import UIKit

class MoodSelectionViewController: UIViewController {
 
    @IBOutlet var stackView: UIStackView!
    var selectMood: UIButton!
   
    var currentMood: Mood? {
        didSet {
            guard let currentMood = currentMood else {
                selectMood?.setTitle(nil, for: .normal)
                selectMood?.backgroundColor = nil
                return
            }
            
            if let vc = presentingViewController?.children[0] as? CalendarViewController {
                dismiss(animated: true, completion: {
                    vc.setMood(currentMood)
                })
            }
            
            //selectMood?.setTitle("I'm \(currentMood.name)", for: .normal)
            //selectMood?.backgroundColor = currentMood.color
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
            //currentMood = moods.first
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
    // https://betterprogramming.pub/how-to-present-a-view-controller-with-blurred-background-in-ios-4350017e6073
    lazy var blurredView: UIView = {
        // 1. create container view
        let containerView = UIView()
        // 2. create custom blur view
        let blurEffect = UIBlurEffect(style: .light)
        let customBlurEffectView = CustomVisualEffectView(effect: blurEffect, intensity: 0.7)
        customBlurEffectView.frame = self.view.bounds
        // 3. create semi-transparent black view
        let dimmedView = UIView()
        dimmedView.backgroundColor = .black.withAlphaComponent(0.2)
        dimmedView.frame = self.view.bounds
        
        // 4. add both as subviews
        containerView.addSubview(customBlurEffectView)
        //containerView.addSubview(dimmedView)
        return containerView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        moods = [.happy, .good, .soso, .bad, .sad]
        //selectMood.layer.cornerRadius = selectMood.bounds.height/2
    }
    @IBAction func backgroundTapped(_ sender: UITapGestureRecognizer) {
            dismiss(animated: true)
    }
    
    func setupView() {
        // 6. add blur view and send it to back
        view.addSubview(blurredView)
        view.sendSubviewToBack(blurredView)
    }
   
    // https://betterprogramming.pub/5-ways-to-pass-data-between-view-controllers-18acb467f5ec
    @IBAction func dismissAction(_ sender: Any) {
        
        //if let vc = presentingViewController as? CalendarViewController {
        if let vc = presentingViewController?.children[0] as? CalendarViewController {
            dismiss(animated: true, completion: { [self] in
                //print(self.getMood())
                guard let mood = self.currentMood else {
                   return
                }
                vc.setMood(mood)
            })
        }
    }
}
