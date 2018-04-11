//
//  AnalogueControl.swift
//  FloatingAnalogues
//
//  Created by James Addyman on 11/04/2018.
//  Copyright © 2018 James Addyman. All rights reserved.
//

import UIKit

protocol AnalogueControlDelegate: class {
	func analogueControl(_ analogControl: AnalogueControl, valueChanged value: CGPoint)
}

@IBDesignable
class AnalogueControl: UIView, UIGestureRecognizerDelegate {
	
	var invertYAxis = false
	var xValue: CGFloat = 0.0
	var yValue: CGFloat = 0.0

	var backgroundView: UIView!
	var handleView: UIView!
	
	var handleXConstraint: NSLayoutConstraint!
	var handleYConstraint: NSLayoutConstraint!
	
	weak var delegate: AnalogueControlDelegate?
	
	var radius: CGFloat {
		return max(bounds.width, bounds.height) / 2.0
	}
	
	var radius2: CGFloat {
		return max(bounds.width, bounds.height) / 4.0
	}
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		setup()
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		setup()
	}
	
	func setup() {
		backgroundColor = .clear
		isOpaque = false
		
		backgroundView = UIView(frame: .zero)
		backgroundView.translatesAutoresizingMaskIntoConstraints = false
		backgroundView.backgroundColor = UIColor(white: 1.0, alpha: 0.5)
		
		handleView = UIView(frame: .zero)
		handleView.translatesAutoresizingMaskIntoConstraints = false
		handleView.backgroundColor = .white
		
		addSubview(backgroundView)
		addSubview(handleView)
		
		var constraints = [NSLayoutConstraint]()
		constraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "H:|[backgroundView]|", options: [], metrics: nil, views: ["backgroundView": backgroundView]))
		constraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "V:|[backgroundView]|", options: [], metrics: nil, views: ["backgroundView": backgroundView]))
		constraints.append(NSLayoutConstraint(item: handleView, attribute: .width, relatedBy: .equal, toItem: self, attribute: .width, multiplier: 0.66, constant: 0.0))
		constraints.append(NSLayoutConstraint(item: handleView, attribute: .height, relatedBy: .equal, toItem: self, attribute: .height, multiplier: 0.66, constant: 0.0))
		
		handleXConstraint = NSLayoutConstraint(item: handleView, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1.0, constant: 0.0)
		handleYConstraint = NSLayoutConstraint(item: handleView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1.0, constant: 0.0)
		constraints.append(contentsOf: [handleXConstraint, handleYConstraint])
		NSLayoutConstraint.activate(constraints)
		
		let pan = UIPanGestureRecognizer(target: self, action: #selector(panRecognized(_:)))
		pan.delegate = self
		addGestureRecognizer(pan)
		
		let longPress = UILongPressGestureRecognizer(target: self, action: #selector(tapRecognized(_:)))
		longPress.minimumPressDuration = 0.01
		longPress.delegate = self
		addGestureRecognizer(longPress)
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		
		backgroundView.layer.cornerRadius = max(backgroundView.bounds.width, backgroundView.bounds.height) / 2.0
		handleView.layer.cornerRadius = max(handleView.bounds.width, handleView.bounds.height) / 2.0
	}
	
	func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
		return true
	}
	
	@objc func tapRecognized(_ recognizer: UITapGestureRecognizer) {
		switch recognizer.state {
		case .began:
			var location = recognizer.location(in: self)
			var normalisedX = (location.x / radius) - 1
			var normalisedY = ((location.y / radius) - 1) * -1
			
			// cap X to -1,1
			if normalisedX > 1.0 {
				location.x = bounds.width
				normalisedX = 1.0
			} else if normalisedX < -1.0 {
				location.x = 0.0
				normalisedX = -1.0
			}
			
			// cap Y to -1,1
			if normalisedY > 1.0 {
				location.y = bounds.height
				normalisedY = 1.0
			} else if normalisedY < -1.0 {
				location.y = 0.0
				normalisedY = -1.0
			}
			
			if invertYAxis {
				normalisedY *= 1
			}
			
			xValue = normalisedX
			yValue = normalisedY
			
			handleXConstraint.constant = location.x - radius
			handleYConstraint.constant = location.y - radius
			setNeedsLayout()
			layoutIfNeeded()
			
			delegate?.analogueControl(self, valueChanged: CGPoint(x: xValue, y: yValue))
		case .ended:
			xValue = 0.0
			yValue = 0.0
			UIView.animate(withDuration: 0.1) {
				self.handleXConstraint.constant = 0.0
				self.handleYConstraint.constant = 0.0
				self.setNeedsLayout()
				self.layoutIfNeeded()
			}
			

			delegate?.analogueControl(self, valueChanged: CGPoint(x: xValue, y: yValue))
		default:
			break
		}
	}
	
	@objc func panRecognized(_ recognizer: UIPanGestureRecognizer) {
		switch recognizer.state {
		case .began, .changed:
			var location = recognizer.location(in: self)
			var normalisedX = (location.x / radius) - 1
			var normalisedY = ((location.y / radius) - 1) * -1
			
			// cap X to -1,1
			if normalisedX > 1.0 {
				location.x = bounds.width
				normalisedX = 1.0
			} else if normalisedX < -1.0 {
				location.x = 0.0
				normalisedX = -1.0
			}
			
			// cap Y to -1,1
			if normalisedY > 1.0 {
				location.y = 0.0
				normalisedY = 1.0
			} else if normalisedY < -1.0 {
				location.y = bounds.height
				normalisedY = -1.0
			}
			
			if invertYAxis {
				normalisedY *= 1
			}
			
			xValue = normalisedX
			yValue = normalisedY
			
			handleXConstraint.constant = location.x - radius
			handleYConstraint.constant = location.y - radius
			setNeedsLayout()
			layoutIfNeeded()
			
			delegate?.analogueControl(self, valueChanged: CGPoint(x: xValue, y: yValue))
		default:
			xValue = 0.0
			yValue = 0.0
			UIView.animate(withDuration: 0.1) {
				self.handleXConstraint.constant = 0.0
				self.handleYConstraint.constant = 0.0
				self.setNeedsLayout()
				self.layoutIfNeeded()
			}
			
			delegate?.analogueControl(self, valueChanged: CGPoint(x: xValue, y: yValue))
		}
	}
}
