//
//  DAAlertController.swift
//  DAAlertController
//
//  Objective-C code Copyright (c) 2015 FactoralComplexity. By Daria Kopaliani. All rights reserved.
//  Swift adaptation Copyright (c) 2015 Nicolas Gomollon. All rights reserved.
//

import Foundation
import UIKit

@objc(EXAlertController)
public class EXAlertController: UIAlertController {
	
	open var alertWindow: UIWindow?
	open var validationBlock: ((Array<UITextField>) -> Bool)?
	
	open func show(_ animated: Bool = true) {
		alertWindow = UIWindow(frame: UIScreen.main.bounds)
		guard let alertWindow = alertWindow else { return }
		let rootViewController = UIViewController()
		alertWindow.rootViewController = rootViewController
		alertWindow.windowLevel = UIWindowLevelAlert + 1
		alertWindow.makeKeyAndVisible()
		rootViewController.present(self, animated: animated, completion: nil)
	}
	
}

@objc(DAAlertController)
open class DAAlertController: NSObject {
	
	open class var `default`: DAAlertController {
		struct Singleton {
			static let sharedInstance = DAAlertController()
		}
		return Singleton.sharedInstance
	}
	
	open var current: EXAlertController?
	
	
	open class func showAlert(_ style: UIAlertControllerStyle, inViewController viewController: UIViewController, title: String?, message: String?, actions: Array<DAAlertAction>?) {
		switch style {
		case .alert:
			showAlertView(viewController, title: title, message: message, actions: actions)
		case .actionSheet:
			showActionSheet(viewController, title: title, message: message, actions: actions)
		}
	}
	
	open class func showActionSheet(_ viewController: UIViewController, sourceView: UIView? = nil, barButtonItem: UIBarButtonItem? = nil, title: String?, message: String?, actions: Array<DAAlertAction>?, permittedArrowDirections: UIPopoverArrowDirection = .any) {
		DAAlertController.default.current = EXAlertController(title: title, message: message, preferredStyle: .actionSheet)
		guard let alertController = DAAlertController.default.current else { return }
		if let actions = actions {
			for action in actions {
				let actualAction = UIAlertAction(title: action.title, style: UIAlertActionStyle(rawValue: action.style.rawValue)!) { (anAction: UIAlertAction) -> Void in
					if let action = action as? DAAlertFieldAction {
						action.textFieldHandler?(Array<UITextField>())
					} else {
						action.handler?()
					}
					DAAlertController.default.current = nil
				}
				alertController.addAction(actualAction)
			}
		}
		alertController.modalPresentationStyle = .popover
		if let popoverPresentationController = alertController.popoverPresentationController {
			if let barButtonItem = barButtonItem {
				popoverPresentationController.barButtonItem = barButtonItem
			} else {
				popoverPresentationController.sourceView = sourceView ?? viewController.view
				popoverPresentationController.sourceRect = sourceView?.bounds ?? viewController.view.bounds
			}
			popoverPresentationController.permittedArrowDirections = permittedArrowDirections
		}
		viewController.present(alertController, animated: true, completion: nil)
	}
	
	open class func showAlertView(_ viewController: UIViewController? = nil, title: String?, message: String?, actions: Array<DAAlertAction>?, numberOfTextFields: Int = 0, textFieldsConfigurationHandler configurationHandler: ((Array<UITextField>) -> Void)? = nil, validationBlock: ((Array<UITextField>) -> Bool)? = nil) {
		DAAlertController.default.current = EXAlertController(title: title, message: message, preferredStyle: .alert)
		guard let alertController = DAAlertController.default.current else { return }
		alertController.validationBlock = validationBlock
		var disableableActions = Set<UIAlertAction>()
		let observers = NSMutableSet()
		var textFields = Array<UITextField>()
		if let actions = actions {
			for action in actions {
				let actualAction = UIAlertAction(title: action.title, style: UIAlertActionStyle(rawValue: action.style.rawValue)!) { (anAction: UIAlertAction) -> Void in
					if observers.count > 0 {
						for observer in observers {
							NotificationCenter.default.removeObserver(observer)
						}
						observers.removeAllObjects()
					}
					if let action = action as? DAAlertFieldAction {
						action.textFieldHandler?(textFields)
					} else {
						action.handler?()
					}
					DAAlertController.default.current = nil
				}
				if (validationBlock != nil) && (action.style != .cancel) {
					disableableActions.insert(actualAction)
				}
				alertController.addAction(actualAction)
			}
		}
		if numberOfTextFields > 0 {
			for _ in 0..<numberOfTextFields {
				alertController.addTextField { (aTextField: UITextField!) -> Void in
					textFields.append(aTextField)
					let observer = NotificationCenter.default.addObserver(forName: .UITextFieldTextDidChange, object: aTextField, queue: OperationQueue.main) { (notification: Notification) -> Void in
						if let textFieldsFilledWithValidData = validationBlock?(textFields) {
							for disableableAction in disableableActions {
								disableableAction.isEnabled = textFieldsFilledWithValidData
							}
						}
					}
					observers.add(observer)
				}
			}
			configurationHandler?(textFields)
			textFields.last?.delegate = DAAlertController.default
			if let textFieldsFilledWithValidData = validationBlock?(textFields) {
				for disableableAction in disableableActions {
					disableableAction.isEnabled = textFieldsFilledWithValidData
				}
			}
		}
		if let viewController = viewController {
			viewController.present(alertController, animated: true, completion: nil)
		} else {
			alertController.show()
		}
	}
	
	open class func dismissAlertController(animated flag: Bool = true, completion: (() -> Void)? = nil) {
		if let currentAlertController = DAAlertController.default.current {
			currentAlertController.dismiss(animated: flag, completion: completion)
			DAAlertController.default.current = nil
		} else {
			completion?()
		}
	}
	
}

extension DAAlertController: UITextFieldDelegate {
	
	public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		if let currentAlertController = current {
			if let textFields = currentAlertController.textFields {
				if let validationBlock = currentAlertController.validationBlock {
					return validationBlock(textFields)
				}
			}
		}
		return true
	}
	
}
