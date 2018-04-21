//
//  ViewController.swift
//  FloatingAnalogues
//
//  Created by James Addyman on 11/04/2018.
//  Copyright © 2018 James Addyman. All rights reserved.
//

import UIKit

class FloatingAnalogueViewController: UIViewController, AnalogueControlDelegate, UIGestureRecognizerDelegate {

	@IBOutlet var leftAnalogueControl: AnalogueControl!
	@IBOutlet weak var leftLabel: UILabel!
	@IBOutlet var rightAnalogueControl: AnalogueControl!
	@IBOutlet weak var rightLabel: UILabel!
	
	@IBOutlet weak var leftAnalogueXConstraint: NSLayoutConstraint!
	@IBOutlet weak var leftAnalogueYConstraint: NSLayoutConstraint!
	
	@IBOutlet weak var rightAnalogueXConstraint: NSLayoutConstraint!
	@IBOutlet weak var rightAnalogueYConstraint: NSLayoutConstraint!
	
	@IBOutlet weak var leftHalfView: UIView!
	@IBOutlet weak var rightHalfView: UIView!
	
	var hideLeftControlTimer: Timer?
	var hideRightControlTimer: Timer?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		leftAnalogueControl.delegate = self
		rightAnalogueControl.delegate = self
		
		let leftPanRecognizer = UIPanGestureRecognizer(target: self, action: #selector(leftPanRecognized(recognizer:)))
		leftPanRecognizer.maximumNumberOfTouches = 1
		leftPanRecognizer.delegate = self
		leftHalfView.addGestureRecognizer(leftPanRecognizer)
		
		let rightPanRecognizer = UIPanGestureRecognizer(target: self, action: #selector(rightPanRecognized(recognizer:)))
		rightPanRecognizer.maximumNumberOfTouches = 1
		rightPanRecognizer.delegate = self
		rightHalfView.addGestureRecognizer(rightPanRecognizer)
		
		leftAnalogueControl.alpha = 0.0
		rightAnalogueControl.alpha = 0.0
	}
	
	func analogueControl(_ analogControl: AnalogueControl, valueChanged value: CGPoint) {
		switch analogControl {
		case leftAnalogueControl:
			leftLabel.text = String(format: "%.1f, %.1f", value.x, value.y)
		case rightAnalogueControl:
			rightLabel.text = String(format: "%.1f, %.1f", value.x, value.y)
		default:
			break
		}
	}
	
	func show(_ analogueControl: AnalogueControl) {
		UIView.animate(withDuration: 0.2) {
			analogueControl.alpha = 1.0
		}
	}
	
	func hide(_ analogueControl: AnalogueControl) {
		UIView.animate(withDuration: 0.2) {
			analogueControl.alpha = 0.0
		}
	}
	
	@objc func leftPanRecognized(recognizer: UIPanGestureRecognizer) {
		let point = recognizer.location(in: view)
		switch recognizer.state {
		case .began:
			hideLeftControlTimer?.invalidate()
			hideLeftControlTimer = nil
			
			if leftAnalogueControl.alpha > 0 {
				return
			}
			
			show(leftAnalogueControl)
			
			leftAnalogueXConstraint.constant = point.x
			leftAnalogueYConstraint.constant = view.bounds.size.height - point.y
			view.setNeedsLayout()
			view.layoutIfNeeded()
			leftAnalogueControl.panRecognized(recognizer)
		case .ended, .cancelled:
			leftAnalogueControl.panRecognized(recognizer)
			hideLeftControlTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { [unowned self] timer in
				self.hide(self.leftAnalogueControl)
			}
		default:
			leftAnalogueControl.panRecognized(recognizer)
		}
	}

	@objc func rightPanRecognized(recognizer: UIPanGestureRecognizer) {
		let point = recognizer.location(in: view)
		switch recognizer.state {
		case .began:
			hideRightControlTimer?.invalidate()
			hideRightControlTimer = nil
			
			if rightAnalogueControl.alpha > 0 {
				return
			}
			
			show(rightAnalogueControl)
			
			rightAnalogueXConstraint.constant = view.bounds.size.width - point.x
			rightAnalogueYConstraint.constant = view.bounds.size.height - point.y
			view.setNeedsLayout()
			view.layoutIfNeeded()
			rightAnalogueControl.panRecognized(recognizer)
		case .ended, .cancelled:
			rightAnalogueControl.panRecognized(recognizer)
			hideRightControlTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { [unowned self] timer in
				self.hide(self.rightAnalogueControl)
			}
		default:
			rightAnalogueControl.panRecognized(recognizer)
		}
	}
	
	func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
		return true
	}
}
