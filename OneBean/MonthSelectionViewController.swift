//
//  MonthSelectionViewController.swift
//  OneBean
//
//  Created by Junho Kim on 2023/03/29.
//

import UIKit

class MonthSelectionViewController: UIViewController {
    
    @IBOutlet var monthView: UIView!
    
    @IBAction func selectJan(_ sender: Any) {
        if let vc = presentingViewController?.children[1] as? MoodListViewController {
            dismiss(animated: true, completion: {
                vc.setMonthYear("Jan", "2023")
            })
        }
    }
    @IBAction func selectFeb(_ sender: Any) {
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
        monthView.layer.cornerRadius = 5
        
    }
    @IBAction func backgroundTapped(_ sender: UITapGestureRecognizer) {
            dismiss(animated: true)
    }
    
    func setupView() {
        // 6. add blur view and send it to back
        view.addSubview(blurredView)
        view.sendSubviewToBack(blurredView)
    }
}
