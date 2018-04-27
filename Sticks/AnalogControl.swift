//
//  AnalogControl.swift
//  FloatingAnalogs
//
//  Created by James Addyman on 11/04/2018.
//  Modified by Sev Gerk.
//  Copyright © 2018. All rights reserved.
//

import UIKit

protocol AnalogControlDelegate: class {
    func analogControl(_ analogControl: AnalogControl, valueChanged value: CGPoint)
}

@IBDesignable
class AnalogControl: UIView, UIGestureRecognizerDelegate {
    
    var invertYAxis = false
    var xValue: CGFloat = 0.0
    var yValue: CGFloat = 0.0
    
    var stickTrack: UIView!
    var stick: UIView!
    
    var blurEffect: UIBlurEffect!
    var blurEffectView: UIVisualEffectView!
    
    var handleXConstraint: NSLayoutConstraint!
    var handleYConstraint: NSLayoutConstraint!
    
    weak var delegate: AnalogControlDelegate?
    
    var radius: CGFloat {
        return max(bounds.width, bounds.height) / 2.0
    }
    
    var radius2: CGFloat {
        return max(bounds.width, bounds.height) / 4.0
    }
    
    var holdControlPositionTimer: Timer?
    
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
        
        stickTrack = UIView(frame: .zero)
        stickTrack.translatesAutoresizingMaskIntoConstraints = false
        
        // Add Blur Effect
        if !UIAccessibilityIsReduceTransparencyEnabled() {
            stickTrack.backgroundColor = .clear
            blurEffect = UIBlurEffect(style: .light)
            blurEffectView = UIVisualEffectView(effect: blurEffect)
            //Fill the view
            blurEffectView.frame = stickTrack.bounds
            blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            blurEffectView.clipsToBounds = true
            
            stickTrack.addSubview(blurEffectView) //if you have more UIViews, use an insertSubview API to place it where needed
        } else {
            stickTrack.backgroundColor = UIColor(white: 1.0, alpha: 0.5)
        }
        
        
        stick = UIView(frame: .zero)
        stick.translatesAutoresizingMaskIntoConstraints = false
        stick.backgroundColor = .white
        // style settings for later… -sev
//        stick.borderColor = .white
//        stick.borderWidth = 3
//        stick.shadowColor = .black
//        stick.shadowRadius = 3
//        stick.shadowOffset = CGSize(width: 0, height: 0)
//        stick.shadowOpacity = 0.5
        
        addSubview(stickTrack)
        addSubview(stick)
        
        var constraints = [NSLayoutConstraint]()
        constraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "H:|[stickTrack]|", options: [], metrics: nil, views: ["stickTrack": stickTrack]))
        constraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "V:|[stickTrack]|", options: [], metrics: nil, views: ["stickTrack": stickTrack]))
        constraints.append(NSLayoutConstraint(item: stick, attribute: .width, relatedBy: .equal, toItem: self, attribute: .width, multiplier: 0.66, constant: 0.0))
        constraints.append(NSLayoutConstraint(item: stick, attribute: .height, relatedBy: .equal, toItem: self, attribute: .height, multiplier: 0.66, constant: 0.0))
        
        handleXConstraint = NSLayoutConstraint(item: stick, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1.0, constant: 0.0)
        handleYConstraint = NSLayoutConstraint(item: stick, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1.0, constant: 0.0)
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
        
        stickTrack.layer.cornerRadius = max(stickTrack.bounds.width, stickTrack.bounds.height) / 2.0
        blurEffectView.layer.cornerRadius = max(stickTrack.bounds.width, stickTrack.bounds.height) / 2.0
        stick.layer.cornerRadius = max(stick.bounds.width, stick.bounds.height) / 2.0
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
            
            delegate?.analogControl(self, valueChanged: CGPoint(x: xValue, y: yValue))
        case .ended:
            self.xValue = 0.0
            self.yValue = 0.0
            UIView.animate(withDuration: 0.5) {
                self.handleXConstraint.constant = 0.0
                self.handleYConstraint.constant = 0.0
                self.setNeedsLayout()
                self.layoutIfNeeded()
                self.delegate?.analogControl(self, valueChanged: CGPoint(x: self.xValue, y: self.yValue))
            }
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
            
            delegate?.analogControl(self, valueChanged: CGPoint(x: xValue, y: yValue))
        default:
            // Holds control position after release to give player a chance to tap within timer (more on that later…)
            holdControlPositionTimer = Timer.scheduledTimer(withTimeInterval: 0.25, repeats: false) { [unowned self] timer in
                UIView.animate(withDuration: 0.15) {
                    self.handleXConstraint.constant = 0.0
                    self.handleYConstraint.constant = 0.0
                    self.setNeedsLayout()
                    self.layoutIfNeeded()
                }
                self.xValue = 0.0
                self.yValue = 0.0
            }
            delegate?.analogControl(self, valueChanged: CGPoint(x: xValue, y: yValue))
        }
    }
}
