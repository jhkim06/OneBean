//
//  MoodSelectionViewController.swift
//  OneBean
//
//  Created by Junho Kim on 2023/03/20.
//

import UIKit

class MoodSelectionViewController: UIViewController {
 
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
        }
    }
    
    func getMood() -> Mood {
        return currentMood!
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
    lazy var blurredView: UIView = {
        // 1. create container view
        let containerView = UIView()
        // 2. create custom blur view
        let blurEffect = UIBlurEffect(style: .light)
        let customBlurEffectView = CustomVisualEffectView(effect: blurEffect, intensity: 0.2)
        customBlurEffectView.frame = self.view.bounds
        // 3. create semi-transparent black view
        let dimmedView = UIView()
        dimmedView.backgroundColor = .black.withAlphaComponent(0.6)
        dimmedView.frame = self.view.bounds
        
        // 4. add both as subviews
        containerView.addSubview(customBlurEffectView)
        containerView.addSubview(dimmedView)
        return containerView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        moods = [.happy, .sad, .angry, .goofy, .crying, .confused, .sleepy, .meh]
        addMoodButton.layer.cornerRadius = addMoodButton.bounds.height/2
        
        setupView()
    }
    
    func setupView() {
        // 6. add blur view and send it to back
        view.addSubview(blurredView)
        view.sendSubviewToBack(blurredView)
    }
    
    @IBAction func dismissAction(_ sender: Any) {
        
        if let vc = presentingViewController as? ViewController {
            dismiss(animated: true, completion: {
                vc.setMood(self.getMood())
            })
        }
    }
}
