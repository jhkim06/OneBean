//
//  MonthSelectionViewController.swift
//  OneBean
//
//  Created by Junho Kim on 2023/03/29.
//

import UIKit

class MonthSelectionViewController: UIViewController {
    
    @IBOutlet var monthView: UIView!
    
    @IBOutlet var monthStackView: UIStackView!
    
    @IBOutlet var marButton: UIButton!
    
    @IBAction func moveLeft(_ sender: Any) {
        self.monthStackView.slideToLeft()
        // update year
        // update month button
    }
    @IBAction func moveRight(_ sender: Any) {
        self.monthStackView.slideToRight()
        // update year
        // update month button
    }
    
    @IBAction func selectJan(_ sender: Any) {
        if let vc = presentingViewController?.children[1] as? MoodListViewController {
            dismiss(animated: true, completion: {
                vc.setMonthYear("01", "2023")
                vc.tableView.reloadData()
            })
        }
    }
    @IBAction func selectFeb(_ sender: Any) {
        if let vc = presentingViewController?.children[1] as? MoodListViewController {
            dismiss(animated: true, completion: {
                vc.setMonthYear("02", "2023")
                vc.tableView.reloadData()
            })
        }
    }
    @IBAction func selectMar(_ sender: Any) {
        if let vc = presentingViewController?.children[1] as? MoodListViewController {
            dismiss(animated: true, completion: {
                vc.setMonthYear("03", "2023")
                vc.tableView.reloadData()
            })
        }
    }
    @IBAction func selectApr(_ sender: Any) {
    }
    @IBAction func selectMay(_ sender: Any) {
    }
    @IBAction func selectJun(_ sender: Any) {
    }
    @IBAction func selectJul(_ sender: Any) {
    }
    @IBAction func selectAug(_ sender: Any) {
    }
    @IBAction func selectSep(_ sender: Any) {
    }
    @IBAction func selectOct(_ sender: Any) {
    }
    @IBAction func selectNov(_ sender: Any) {
    }
    @IBAction func selectDec(_ sender: Any) {
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

extension UIView {
    // Name this function in a way that makes sense to you...
    // slideFromLeft, slideRight, slideLeftToRight, etc. are great alternative names
    func slideToLeft(duration: TimeInterval = 1.0, completionDelegate: AnyObject? = nil) {
        // Create a CATransition animation
        let slideToLeftTransition = CATransition()

        // Set its callback delegate to the completionDelegate that was provided (if any)
        if let delegate: AnyObject = completionDelegate {
            slideToLeftTransition.delegate = delegate as! CAAnimationDelegate
        }

        // Customize the animation's properties
        slideToLeftTransition.type = CATransitionType.push
        slideToLeftTransition.subtype = CATransitionSubtype.fromRight
        slideToLeftTransition.duration = duration
        slideToLeftTransition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        slideToLeftTransition.fillMode = CAMediaTimingFillMode.removed

        // Add the animation to the View's layer
        self.layer.add(slideToLeftTransition, forKey: "slideToLeftTransition")
    }
    func slideToRight(duration: TimeInterval = 1.0, completionDelegate: AnyObject? = nil) {
        // Create a CATransition animation
        let slideToRightTransition = CATransition()

        // Set its callback delegate to the completionDelegate that was provided (if any)
        if let delegate: AnyObject = completionDelegate {
            slideToRightTransition.delegate = delegate as! CAAnimationDelegate
        }

        // Customize the animation's properties
        slideToRightTransition.type = CATransitionType.push
        slideToRightTransition.subtype = CATransitionSubtype.fromLeft
        slideToRightTransition.duration = duration
        slideToRightTransition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        slideToRightTransition.fillMode = CAMediaTimingFillMode.removed

        // Add the animation to the View's layer
        self.layer.add(slideToRightTransition, forKey: "slideToRightTransition")
    }
}
