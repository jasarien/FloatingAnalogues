//
//  ViewController.swift
//  FloatingAnalogs
//
//  Created by James Addyman on 11/04/2018.
//  Modified by Sev Gerk.
//  Copyright © 2018 James Addyman. All rights reserved.
//

import UIKit

class FloatingAnalogsViewController: UIViewController, AnalogControlDelegate, UIGestureRecognizerDelegate {
    
    @IBOutlet var leftAnalogControl: AnalogControl!
    @IBOutlet weak var leftLabel: UILabel!
    @IBOutlet weak var quickTapLeftGateLabel: UILabel!
    @IBOutlet var rightAnalogControl: AnalogControl!
    @IBOutlet weak var rightLabel: UILabel!
    @IBOutlet weak var quickTapRightGateLabel: UILabel!
    
    @IBOutlet weak var leftAnalogXConstraint: NSLayoutConstraint!
    @IBOutlet weak var leftAnalogYConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var rightAnalogXConstraint: NSLayoutConstraint!
    @IBOutlet weak var rightAnalogYConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var leftHalfView: UIView!
    @IBOutlet weak var rightHalfView: UIView!
    
    @IBOutlet weak var rightHUDLabel: UILabel!
    @IBOutlet weak var leftHUDLabel: UILabel!
    
    var hideLeftControlTimer: Timer?
    var hideRightControlTimer: Timer?
    
    var quickTapLeftGateTimer: Timer?
    var quickTapLeftGateIsOpen = false
    var quickTapRightGateTimer: Timer?
    var quickTapRightGateIsOpen = false
    let quickTapGateTimeLimit = 0.15
    var quickTapLeftGateTimeRemaining = 0.00
    var quickTapRightGateTimeRemaining = 0.00
    
    var rightAnalogIsActive = false
    var leftAnalogIsActive = false
    
    var leftAnalogOriginalPosition: CGPoint!
    var rightAnalogOriginalPosition: CGPoint!
    var leftAnalogCurrentPosition: CGPoint!
    var rightAnalogCurrentPosition: CGPoint!
    
    var orientation = "Unknown"
    
    var stick3DTouchIsEnabled: Bool!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        determineOrientation(size: UIScreen.main.bounds.size)
        
        leftAnalogControl.delegate = self
        rightAnalogControl.delegate = self
        
        let leftPanRecognizer = UIPanGestureRecognizer(target: self, action: #selector(leftPanRecognized(recognizer:)))
        leftPanRecognizer.maximumNumberOfTouches = 1
        leftPanRecognizer.delegate = self
        leftHalfView.addGestureRecognizer(leftPanRecognizer)
        
        let rightPanRecognizer = UIPanGestureRecognizer(target: self, action: #selector(rightPanRecognized(recognizer:)))
        rightPanRecognizer.maximumNumberOfTouches = 1
        rightPanRecognizer.delegate = self
        rightHalfView.addGestureRecognizer(rightPanRecognizer)
        
        leftAnalogControl.alpha = 0.0
        rightAnalogControl.alpha = 0.0
        
        // Check the trait collection to see if force (3D Touch) is available (for later experiments…)
        if self.traitCollection.forceTouchCapability == .available {
            stick3DTouchIsEnabled = true
        } else {
            // Fall back to other non 3D Touch features.
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        determineOrientation(size: size)
    }

    func determineOrientation(size: CGSize) {
        if (size.width > size.height) {
            orientation = "Landscape"
        } else {
            orientation = "Portrait"
        }
        NSLog("Orientation: \(orientation)")
    }
    
    func analogControl(_ analogControl: AnalogControl, valueChanged value: CGPoint) {
        switch analogControl {
        case leftAnalogControl:
            leftLabel.text = String(format: "(%.1f, %.1f) %.1f, %.1f", leftAnalogCurrentPosition.x, leftAnalogCurrentPosition.y, value.x, value.y)
        case rightAnalogControl:
            rightLabel.text = String(format: "(%.1f, %.1f) %.1f, %.1f", rightAnalogCurrentPosition.x, rightAnalogCurrentPosition.y, value.x, value.y)
        default:
            break
        }
    }
    
    func show(_ analogControl: AnalogControl) {
        analogControl.transform = CGAffineTransform(scaleX: 0, y: 0)
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
            analogControl.transform = .identity
            analogControl.alpha = 1.0
        }, completion: nil)
        switch analogControl {
        case leftAnalogControl:
            leftAnalogIsActive = true
        case rightAnalogControl:
            leftAnalogIsActive = true
        default:
            break
        }

    }
    
    func hide(_ analogControl: AnalogControl) {
        analogControl.transform = .identity
        UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
            analogControl.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
            analogControl.alpha = 0.0
            switch analogControl {
            case self.leftAnalogControl:
                self.leftLabel.text = String(format: "(0,0) 0, 0")
            case self.rightAnalogControl:
                self.rightLabel.text = String(format: "(0,0) 0, 0")
                default:
                    break
            }
        }, completion: nil)
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        super.touchesBegan(touches, with: event)
        
        if (touch.view == leftHalfView) {
            hideLeftControlTimer?.invalidate()
            hideLeftControlTimer = nil
            
            leftAnalogOriginalPosition = touch.location(in: leftHalfView)
  
            switch orientation {
            case "Landscape":
                leftAnalogOriginalPosition.x = (leftAnalogOriginalPosition.x + leftAnalogControl.radius)
            case "Portrait":
                leftAnalogOriginalPosition.y = (leftAnalogOriginalPosition.y + leftAnalogControl.radius)
            default:
                NSLog("Error: Can't Determine Stick Placement")
                break
            }
            
            leftAnalogCurrentPosition = leftAnalogOriginalPosition
            leftLabel.text = String(format: "(%.1f, %.1f) 0, 0", leftAnalogCurrentPosition.x, leftAnalogCurrentPosition.y)
            
            show(leftAnalogControl)
            
            leftAnalogXConstraint.constant = leftAnalogCurrentPosition.x
            leftAnalogYConstraint.constant = view.bounds.size.height - leftAnalogCurrentPosition.y
            
            checkForQuickTapLeft()
    
        } else if (touch.view == rightHalfView) {
            
            hideRightControlTimer?.invalidate()
            hideRightControlTimer = nil
            
            rightAnalogOriginalPosition = touch.location(in: rightHalfView)
            
            switch orientation {
            case "Landscape":
                rightAnalogOriginalPosition.x = (rightAnalogOriginalPosition.x - rightAnalogControl.radius)
            case "Portrait":
                rightAnalogOriginalPosition.y = (rightAnalogOriginalPosition.y + rightAnalogControl.radius)
            default:
                NSLog("Error: Can't Determine Stick Placement")
                break
            }

            rightAnalogCurrentPosition = rightAnalogOriginalPosition
            rightLabel.text = String(format: "(%.1f, %.1f) 0, 0", rightAnalogOriginalPosition.x, rightAnalogCurrentPosition.y)

            show(rightAnalogControl)
            
            rightAnalogXConstraint.constant = rightHalfView.bounds.size.width - rightAnalogCurrentPosition.x
            rightAnalogYConstraint.constant = view.bounds.size.height - rightAnalogCurrentPosition.y
            
            checkForQuickTapRight()
        }
        
        view.setNeedsLayout()
        view.layoutIfNeeded()
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        if (touch.view == leftHalfView) {
            leftAnalogIsActive = false
            if !quickTapLeftGateIsOpen { startQuickTapLeftTimer() }
            //hideLeftControlTimer = Timer.scheduledTimer(withTimeInterval: quickTapLeftGateTimeRemaining, repeats: false) { [unowned self] timer in
            if (self.leftAnalogCurrentPosition == self.leftAnalogOriginalPosition) && !self.leftAnalogIsActive{
                self.hide(self.leftAnalogControl)
            }
            //}
        } else if (touch.view == rightHalfView) {
            rightAnalogIsActive = false
            if !quickTapRightGateIsOpen { startQuickTapRightTimer() }
            //hideRightControlTimer = Timer.scheduledTimer(withTimeInterval: quickTapRightGateTimeRemaining, repeats: false) { [unowned self] timer in
            if (self.rightAnalogCurrentPosition == self.rightAnalogOriginalPosition) && !self.rightAnalogIsActive {
                self.hide(self.rightAnalogControl)
            }
        }
        //}
    }
 
    
   // 3D touch setup… for later… -sev
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
//        let touch = touches.first!
//        if stick3DTouchIsEnabled {
//            stick3DTouch(touch: touch, control: leftAnalogControl)
//        }
    }

    func stick3DTouch(touch: UITouch, control: AnalogControl) {
//        control.transform = CGAffineTransform(scaleX: touch.force * 1, y: 0)
        
//        view.setNeedsLayout()
//        view.layoutIfNeeded()
    }
    
    func checkForQuickTapLeft() {
        if quickTapLeftGateIsOpen {
            resetQuickTapLeftTime()
            leftHUDLabel.alpha = 1.0
            flashScreen()
            print("Left Stick: Quick Tap 💥")
            // trigger the left quick tap mapped button
        } else {
            print("Left Stick: Tap")
            stopQuickTapLeftTimer()
        }
    }
    
    func checkForQuickTapRight() {
        if quickTapRightGateIsOpen {
            resetQuickTapRightTime()
            rightHUDLabel.alpha = 1.0
            flashScreen()
            print("Right Stick: Quick Tap 💥")
            // trigger the right quick tap mapped button
        } else {
            print("Right Stick: Tap")
            stopQuickTapRightTimer()
        }
    }
    
    // FOR TESTING ONLY
    func flashScreen() {
        if let wnd = self.view{

            let v = UIView(frame: wnd.bounds)
            v.backgroundColor = UIColor.red
            v.alpha = 0.2
            wnd.addSubview(v)
            UIView.animate(withDuration: 0.1, animations: {
                v.alpha = 0.0
                self.leftHUDLabel.alpha = 0.0
                self.rightHUDLabel.alpha = 0.0
            }, completion: {(finished:Bool) in
                v.removeFromSuperview()
            })
        }
    }
    
    func startQuickTapLeftTimer() {
        quickTapLeftGateTimeRemaining = quickTapGateTimeLimit
        quickTapLeftGateIsOpen = true
        quickTapLeftGateLabel.textColor = UIColor.green
        quickTapLeftGateTimer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: (#selector(FloatingAnalogsViewController.updateQuickTapLeftTimer)), userInfo: nil, repeats: true)

    }

    func startQuickTapRightTimer() {
        quickTapRightGateTimeRemaining = quickTapGateTimeLimit
        quickTapRightGateIsOpen = true
        quickTapRightGateLabel.textColor = UIColor.green
        quickTapRightGateTimer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: (#selector(FloatingAnalogsViewController.updateQuickTapRightTimer)), userInfo: nil, repeats: true)

    }
    
    func resetQuickTapLeftTime() {
        quickTapLeftGateTimeRemaining = quickTapGateTimeLimit
    }
    
    func resetQuickTapRightTime() {
        quickTapRightGateTimeRemaining = quickTapGateTimeLimit
    }
    
    @objc func updateQuickTapLeftTimer() {
        if quickTapLeftGateTimeRemaining > 0.00 {
            quickTapLeftGateTimeRemaining -= 0.01
        } else {
            stopQuickTapLeftTimer()
        }
        let timeRemaining = Double(round(100 * quickTapLeftGateTimeRemaining) / 100)
        quickTapLeftGateLabel.text = "\(timeRemaining)"
    }
    
    @objc func updateQuickTapRightTimer() {
        if quickTapRightGateTimeRemaining > 0.00 {
            quickTapRightGateTimeRemaining -= 0.01
        } else {
            stopQuickTapRightTimer()
        }
        let timeRemaining = Double(round(100 * quickTapRightGateTimeRemaining) / 100)
        quickTapRightGateLabel.text = "\(timeRemaining)"
    }
    
    func stopQuickTapLeftTimer() {
        quickTapLeftGateTimeRemaining = 0
        quickTapLeftGateIsOpen = false
        quickTapLeftGateLabel.textColor = UIColor.orange
        //leftHUDLabel.alpha = 0.0
        quickTapLeftGateTimer?.invalidate()
        quickTapLeftGateTimer = nil
    }
    
    func stopQuickTapRightTimer() {
        quickTapRightGateTimeRemaining = 0
        quickTapRightGateIsOpen = false
        quickTapRightGateLabel.textColor = UIColor.orange
        //rightHUDLabel.alpha = 0.0
        quickTapRightGateTimer?.invalidate()
        quickTapRightGateTimer = nil

    }
    
    @objc func leftPanRecognized(recognizer: UIPanGestureRecognizer) {
        leftAnalogCurrentPosition = recognizer.location(in: view)
        switch recognizer.state {
        case .began:
            hideLeftControlTimer?.invalidate()
            hideLeftControlTimer = nil

            if leftAnalogControl.alpha > 0 {
                return
            }

            show(leftAnalogControl)

            leftAnalogXConstraint.constant = leftAnalogCurrentPosition.x
            leftAnalogYConstraint.constant = view.bounds.size.height - leftAnalogCurrentPosition.y
            view.setNeedsLayout()
            view.layoutIfNeeded()
            leftAnalogControl.panRecognized(recognizer)
            
            checkForQuickTapLeft()
        case .ended, .cancelled:
            leftAnalogControl.panRecognized(recognizer)
            leftAnalogIsActive = false
            if !quickTapLeftGateIsOpen { startQuickTapLeftTimer() }
            hideLeftControlTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { [unowned self] timer in
                self.hide(self.leftAnalogControl)
            }
        default:
            leftAnalogControl.panRecognized(recognizer)
        }
    }
    
    @objc func rightPanRecognized(recognizer: UIPanGestureRecognizer) {
        rightAnalogCurrentPosition = recognizer.location(in: view)
        switch recognizer.state {
        case .began:
            hideRightControlTimer?.invalidate()
            hideRightControlTimer = nil
            
            if rightAnalogControl.alpha > 0 {
                return
            }
            
            show(rightAnalogControl)
            
            rightAnalogXConstraint.constant = view.bounds.size.width - rightAnalogCurrentPosition.x
            rightAnalogYConstraint.constant = view.bounds.size.height - rightAnalogCurrentPosition.y
            view.setNeedsLayout()
            view.layoutIfNeeded()
            rightAnalogControl.panRecognized(recognizer)
            
            checkForQuickTapRight()
        case .ended, .cancelled:
            rightAnalogControl.panRecognized(recognizer)
            rightAnalogIsActive = false
            if !quickTapRightGateIsOpen { startQuickTapRightTimer() }
            hideRightControlTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { [unowned self] timer in
                self.hide(self.rightAnalogControl)
            }
        default:
            rightAnalogControl.panRecognized(recognizer)
        }
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    
    // Checking 3D Touch support (for later…) -sev
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        // Update the app's 3D Touch support.
        if self.traitCollection.forceTouchCapability == .available {
            // Enable 3D Touch features
            stick3DTouchIsEnabled = true
        } else {
            stick3DTouchIsEnabled = false
            // Fall back to other non 3D Touch features.
        }
    }
}

