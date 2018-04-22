//
//  File.swift
//  Sticks
//
//  Created by Sev Gerk on 4/21/18.
//  Copyright © 2018 Provenance-Emu. All rights reserved.
//

import UIKit

@IBDesignable
class DesignableView: UIView {
}

@IBDesignable
class DesignableButton: UIButton {
}

@IBDesignable
class DesignableLabel: UILabel {
}

extension UIView {
    
    @IBInspectable
    var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
        }
    }
    
    @IBInspectable
    var roundButton: Bool {
        get {
            return false
        } set {
            if newValue {
            layer.cornerRadius = bounds.size.width/2
            }
        }
    }
    
    @IBInspectable
    var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable
    var borderColor: UIColor? {
        get {
            if let color = layer.borderColor {
                return UIColor(cgColor: color)
            }
            return nil
        }
        set {
            if let color = newValue {
                layer.borderColor = color.cgColor
            } else {
                layer.borderColor = nil
            }
        }
    }
    
    @IBInspectable
    var shadowRadius: CGFloat {
        get {
            return layer.shadowRadius
        }
        set {
            layer.shadowRadius = newValue
        }
    }
    
    @IBInspectable
    var shadowOpacity: Float {
        get {
            return layer.shadowOpacity
        }
        set {
            layer.shadowOpacity = newValue
        }
    }
    
    @IBInspectable
    var shadowOffset: CGSize {
        get {
            return layer.shadowOffset
        }
        set {
            layer.shadowOffset = newValue
        }
    }
    
    @IBInspectable
    var shadowColor: UIColor? {
        get {
            if let color = layer.shadowColor {
                return UIColor(cgColor: color)
            }
            return nil
        }
        set {
            if let color = newValue {
                layer.shadowColor = color.cgColor
            } else {
                layer.shadowColor = nil
            }
        }
    }
    
    // Trying to hook up something to add blurs to anything UIView with just writing it once, but it needs more work/research…
    
//    @IBInspectable
//    var blurEffect: Bool {
//        get {
//            return false
//        } set {
////            if newValue {
////                // Add Blur Effect
////                if !UIAccessibilityIsReduceTransparencyEnabled() {
////                    layer.backgroundColor =  CGColor
////                    var blurFX = UIBlurEffect(style: .light)
////                    var blurEffectView = UIVisualEffectView(effect: blurFX)
////                //Fill the view
////                    blurEffectView.frame = layer.bounds
////                    blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
////                    super.view = true
////
////                    view.addSubview(blurEffectView) //if you have more UIViews, use an insertSubview API to place it where needed
////                } else {
////                    view.backgroundColor = UIColor(white: 1.0, alpha: 0.5)
////                }
////
//
//        }
//
//        }
    
}

