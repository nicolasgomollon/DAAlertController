//
//  ViewController.swift
//  DAAlertController
//
//  Created by Nicolas Gomollon on 3/11/15.
//  Copyright (c) 2015 Techno-Magic. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
	}
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		presentAlertController()
	}
	
	func presentAlertController(index: Int = 0) {
		if index >= 3 { return }
		
		let cancelAction = DAAlertAction(title: "Cancel", style: .Cancel) {
			print("\"Cancel\" button pressed.")
			self.presentAlertController(index + 1)
		}
		let signOutAction = DAAlertAction(title: "Sign out", style: .Destructive) {
			print("\"Sign out\" button pressed.")
			self.presentAlertController(index + 1)
		}
		let notNowAction = DAAlertAction(title: "Not now", style: .Default) {
			print("\"Not now\" button pressed.")
			self.presentAlertController(index + 1)
		}
		let signUpAction = DAAlertFieldAction(title: "Sign up", style: .Default) { (textFields: Array<UITextField>) -> Void in
			print("\"Sign up\" button pressed.")
			var i = 0
			for textField in textFields {
				print("\(i): \"\(textField.text)\"")
				i++
			}
			self.presentAlertController(index + 1)
		}
		
		switch index {
		case 0:
			DAAlertController.showAlert(.Alert,
				inViewController: self,
				title: "Are you sure you want to sign out?",
				message: "If you sign out of your account all photos will be removed from this iPhone.",
				actions: [cancelAction, signOutAction])
		case 1:
			DAAlertController.showAlert(.ActionSheet,
				inViewController: self,
				title: "Are you sure you want to sign out?",
				message: "If you sign out of your account all photos will be removed from this iPhone.",
				actions: [signOutAction, notNowAction, cancelAction])
		case 2:
			DAAlertController.showAlertView(self,
				title: "Sign up",
				message: "Please choose a nick name.",
				actions: [cancelAction, signUpAction],
				numberOfTextFields: 2,
				textFieldsConfigurationHandler: { (textFields: Array<UITextField>) -> Void in
					textFields.first?.placeholder = "Nick name"
					textFields.first?.enablesReturnKeyAutomatically = true
					textFields.last?.placeholder = "Full name"
					textFields.last?.enablesReturnKeyAutomatically = true
					textFields.last?.secureTextEntry = false
				},
				validationBlock: { (textFields: Array<UITextField>) -> Bool in
					return NSString(string: textFields.first?.text ?? "").length >= 5
				}
			)
		default:
			break
		}
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
}

