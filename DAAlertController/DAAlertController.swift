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
		guard let alertWindow: UIWindow = alertWindow else { return }
		let rootViewController: UIViewController = .init()
		alertWindow.rootViewController = rootViewController
		alertWindow.windowLevel = UIWindow.Level.alert + 1
		alertWindow.makeKeyAndVisible()
		rootViewController.present(self, animated: animated, completion: nil)
	}
	
}

@objc(DAAlertController)
open class DAAlertController: NSObject {
	
	public static let `default`: DAAlertController = .init()
	
	open var current: EXAlertController?
	
	
	open class func showAlert(_ style: UIAlertController.Style, inViewController viewController: UIViewController, title: String?, message: String?, actions: Array<DAAlertAction>?) {
		switch style {
		case .alert:
			showAlertView(viewController, title: title, message: message, actions: actions)
		case .actionSheet:
			showActionSheet(viewController, title: title, message: message, actions: actions)
		@unknown default:
			break
		}
	}
	
	open class func showActionSheet(_ viewController: UIViewController, sourceView: UIView? = nil, barButtonItem: UIBarButtonItem? = nil, title: String?, message: String?, actions: Array<DAAlertAction>?, permittedArrowDirections: UIPopoverArrowDirection = .any) {
		DAAlertController.default.current = EXAlertController(title: title, message: message, preferredStyle: .actionSheet)
		guard let alertController: EXAlertController = DAAlertController.default.current else { return }
		if let actions: Array<DAAlertAction> = actions {
			for action in actions {
				let actualAction: UIAlertAction = UIAlertAction(title: action.title, style: UIAlertAction.Style(rawValue: action.style.rawValue)!) { (anAction: UIAlertAction) in
					if let action: DAAlertFieldAction = action as? DAAlertFieldAction {
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
		if let popoverPresentationController: UIPopoverPresentationController = alertController.popoverPresentationController {
			if let barButtonItem: UIBarButtonItem = barButtonItem {
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
		guard let alertController: EXAlertController = DAAlertController.default.current else { return }
		alertController.validationBlock = validationBlock
		var disableableActions: Set<UIAlertAction> = .init()
		let observers: NSMutableSet = .init()
		var textFields: Array<UITextField> = .init()
		if let actions: Array<DAAlertAction> = actions {
			for action in actions {
				let actualAction: UIAlertAction = UIAlertAction(title: action.title, style: UIAlertAction.Style(rawValue: action.style.rawValue)!) { (anAction: UIAlertAction) in
					if observers.count > 0 {
						for observer in observers {
							NotificationCenter.default.removeObserver(observer)
						}
						observers.removeAllObjects()
					}
					if let action: DAAlertFieldAction = action as? DAAlertFieldAction {
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
				alertController.addTextField { (aTextField: UITextField) in
					textFields.append(aTextField)
					let observer: NSObjectProtocol = NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: aTextField, queue: .main) { (notification: Notification) in
						guard let textFieldsFilledWithValidData: Bool = validationBlock?(textFields) else { return }
						for disableableAction in disableableActions {
							disableableAction.isEnabled = textFieldsFilledWithValidData
						}
					}
					observers.add(observer)
				}
			}
			configurationHandler?(textFields)
			textFields.last?.delegate = DAAlertController.default
			if let textFieldsFilledWithValidData: Bool = validationBlock?(textFields) {
				for disableableAction in disableableActions {
					disableableAction.isEnabled = textFieldsFilledWithValidData
				}
			}
		}
		if let viewController: UIViewController = viewController {
			viewController.present(alertController, animated: true, completion: nil)
		} else {
			alertController.show()
		}
	}
	
	open class func dismissAlertController(animated flag: Bool = true, completion: (() -> Void)? = nil) {
		if let currentAlertController: EXAlertController = DAAlertController.default.current {
			currentAlertController.dismiss(animated: flag, completion: completion)
			DAAlertController.default.current = nil
		} else {
			completion?()
		}
	}
	
}

extension DAAlertController: UITextFieldDelegate {
	
	public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		guard let currentAlertController: EXAlertController = current,
			let textFields: Array<UITextField> = currentAlertController.textFields,
			let validationBlock: (Array<UITextField>) -> Bool = currentAlertController.validationBlock else { return true }
		return validationBlock(textFields)
	}
	
}
