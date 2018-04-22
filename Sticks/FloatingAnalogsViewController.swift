//
//  ViewController.swift
//  FloatingAnalogs
//
//  Created by James Addyman on 11/04/2018.
//  Copyright © 2018 James Addyman. All rights reserved.
//

import UIKit

class FloatingAnalogsViewController: UIViewController, AnalogControlDelegate, UIGestureRecognizerDelegate {
    
    @IBOutlet var leftAnalogControl: AnalogControl!
    @IBOutlet weak var leftLabel: UILabel!
    @IBOutlet var rightAnalogControl: AnalogControl!
    @IBOutlet weak var rightLabel: UILabel!
    
    @IBOutlet weak var leftAnalogXConstraint: NSLayoutConstraint!
    @IBOutlet weak var leftAnalogYConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var rightAnalogXConstraint: NSLayoutConstraint!
    @IBOutlet weak var rightAnalogYConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var leftHalfView: UIView!
    @IBOutlet weak var rightHalfView: UIView!
    
    var hideLeftControlTimer: Timer?
    var hideRightControlTimer: Timer?
    
    var leftAnalogOriginalPosition: CGPoint!
    var rightAnalogOriginalPosition: CGPoint!
    var leftAnalogCurrentPosition: CGPoint!
    var rightAnalogCurrentPosition: CGPoint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        // Check the trait collection to see if force (3D Touch) is available.
        if self.traitCollection.forceTouchCapability == .available {
            // Enable 3D Touch features
        } else {
            // Fall back to other non 3D Touch features.
        }
    
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
        if (touch.view == leftHalfView) {
            print("Left Stick")
            
            leftAnalogOriginalPosition = touch.location(in: leftHalfView)
            leftAnalogOriginalPosition.x = (leftAnalogOriginalPosition.x + leftAnalogControl.radius)
            if !UIDevice.current.orientation.isLandscape {
                leftAnalogOriginalPosition.x = (leftAnalogOriginalPosition.x - rightAnalogControl.radius)
                leftAnalogOriginalPosition.y = (leftAnalogOriginalPosition.y + rightAnalogControl.radius)
            }
            leftAnalogCurrentPosition = leftAnalogOriginalPosition
            leftLabel.text = String(format: "(%.1f, %.1f) 0, 0", leftAnalogCurrentPosition.x, leftAnalogCurrentPosition.y)
            
            hideLeftControlTimer?.invalidate()
            hideLeftControlTimer = nil

            show(leftAnalogControl)
            leftAnalogXConstraint.constant = leftAnalogCurrentPosition.x
            leftAnalogYConstraint.constant = view.bounds.size.height - leftAnalogCurrentPosition.y
        } else if (touch.view == rightHalfView) {
            print("Right Stick")
            
            rightAnalogOriginalPosition = touch.location(in: rightHalfView)
            rightAnalogOriginalPosition.x = (rightAnalogOriginalPosition.x - rightAnalogControl.radius)
            if !UIDevice.current.orientation.isLandscape {
                rightAnalogOriginalPosition.x = (rightAnalogOriginalPosition.x + rightAnalogControl.radius)
                rightAnalogOriginalPosition.y = (rightAnalogOriginalPosition.y + rightAnalogControl.radius)
            }
            rightAnalogCurrentPosition = rightAnalogOriginalPosition
            rightLabel.text = String(format: "(%.1f, %.1f) 0, 0", rightAnalogOriginalPosition.x, rightAnalogCurrentPosition.y)
            
            hideRightControlTimer?.invalidate()
            hideRightControlTimer = nil

            show(rightAnalogControl)
            rightAnalogXConstraint.constant = rightHalfView.bounds.size.width - rightAnalogCurrentPosition.x
            rightAnalogYConstraint.constant = view.bounds.size.height - rightAnalogCurrentPosition.y
        }
        view.setNeedsLayout()
        view.layoutIfNeeded()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        if (touch.view == leftHalfView) && (leftAnalogCurrentPosition == leftAnalogOriginalPosition) {
            hide(leftAnalogControl)
        } else if (touch.view == rightHalfView) && (rightAnalogCurrentPosition == rightAnalogOriginalPosition) {
            hide(rightAnalogControl)
        }
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
        case .ended, .cancelled:
            leftAnalogControl.panRecognized(recognizer)
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
        case .ended, .cancelled:
            rightAnalogControl.panRecognized(recognizer)
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
    
    // Checking 3D Touch support
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        // Update the app's 3D Touch support.
        if self.traitCollection.forceTouchCapability == .available {
            // Enable 3D Touch features
        } else {
            // Fall back to other non 3D Touch features.
        }
    }
}

