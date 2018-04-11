//
//  ViewController.swift
//  FloatingAnalogues
//
//  Created by James Addyman on 11/04/2018.
//  Copyright © 2018 James Addyman. All rights reserved.
//

import UIKit

class ViewController: UIViewController, AnalogueControlDelegate {

	@IBOutlet var leftAnalogueControl: AnalogueControl!
	@IBOutlet weak var leftLabel: UILabel!
	@IBOutlet var rightAnalogueControl: AnalogueControl!
	@IBOutlet weak var rightLabel: UILabel!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		leftAnalogueControl.delegate = self
		rightAnalogueControl.delegate = self
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
	
}
