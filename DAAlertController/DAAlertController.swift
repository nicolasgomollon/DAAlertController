//
//  DAAlertController.swift
//  DAAlertController
//
//  Objective-C code Copyright (c) 2015 FactoralComplexity. By Daria Kopaliani. All rights reserved.
//  Swift adaptation Copyright (c) 2015 Nicolas Gomollon. All rights reserved.
//

import Foundation
import UIKit

public enum DAAlertControllerStyle: Int {
	case ActionSheet
	case Alert
}

@objc(EXAlertController)
public class EXAlertController: UIAlertController {
	var validationBlock: ((Array<UITextField>) -> Bool)?
}

@objc(EXAlertView)
public class EXAlertView: ObjC_EXAlertView {
	var cancelAction: DAAlertAction?
	var otherActions: Array<DAAlertAction>?
	var validationBlock: ((Array<UITextField>) -> Bool)?
}

@objc(EXActionSheet)
public class EXActionSheet: UIActionSheet {
	var cancelAction: DAAlertAction? {
		didSet {
			if let cancelAction = cancelAction {
				cancelButtonIndex = addButtonWithTitle(cancelAction.title)
			}
		}
	}
	var destructiveAction: DAAlertAction? {
		didSet {
			if let destructiveAction = destructiveAction {
				destructiveButtonIndex = addButtonWithTitle(destructiveAction.title)
			}
		}
	}
	var otherActions: Array<DAAlertAction>? {
		didSet {
			if let otherActions = otherActions {
				for otherAction in otherActions {
					addButtonWithTitle(otherAction.title)
				}
			}
		}
	}
}

@objc(DAAlertController)
public class DAAlertController: NSObject {
	
	public class var defaultAlertController: DAAlertController {
		struct Singleton {
			static let sharedInstance = DAAlertController()
		}
		return Singleton.sharedInstance
	}
	
	private var currentAlertController: EXAlertController?
	private var currentAlertView: EXAlertView?
	
	
	public class func showAlert(style: DAAlertControllerStyle, inViewController viewController: UIViewController, title: String?, message: String?, actions: Array<DAAlertAction>?) {
		switch style {
		case .Alert:
			showAlertView(viewController, title: title, message: message, actions: actions)
		case .ActionSheet:
			showActionSheet(viewController, title: title, message: message, actions: actions)
		}
	}
	
	public class func showActionSheet(viewController: UIViewController, sourceView: UIView? = nil, barButtonItem: UIBarButtonItem? = nil, title: String?, message: String?, actions: Array<DAAlertAction>?, permittedArrowDirections: UIPopoverArrowDirection = .Any) {
		if NSClassFromString("UIAlertController") != nil {
			var alertController = UIAlertController(title: title, message: message, preferredStyle: .ActionSheet)
			if let actions = actions {
				for action in actions {
					var actualAction = UIAlertAction(title: action.title, style: UIAlertActionStyle(rawValue: action.style.rawValue)!) { (anAction: UIAlertAction!) -> Void in
						if var action = action as? DAAlertFieldAction {
							action.textFieldHandler?(Array<UITextField>())
						} else {
							action.handler?()
						}
					}
					alertController.addAction(actualAction)
				}
			}
			alertController.modalPresentationStyle = .Popover
			if var popoverPresentationController = alertController.popoverPresentationController {
				if let barButtonItem = barButtonItem {
					popoverPresentationController.barButtonItem = barButtonItem
				} else {
					popoverPresentationController.sourceView = sourceView ?? viewController.view
					popoverPresentationController.sourceRect = sourceView?.bounds ?? viewController.view.bounds
				}
				popoverPresentationController.permittedArrowDirections = permittedArrowDirections
			}
			viewController.presentViewController(alertController, animated: true, completion: nil)
		} else {
			assert(!(title ?? "").isEmpty || !(message ?? "").isEmpty || !(actions ?? Array<DAAlertAction>()).isEmpty, "DAAlertController must have a title, a message or an action to display")
			validate(actions)
			var actionSheet = self.actionSheet(title: title, message: message, actions: actions)
			if let barButtonItem = barButtonItem {
				actionSheet.showFromBarButtonItem(barButtonItem, animated: true)
			} else if let sourceView = sourceView {
				actionSheet.showFromRect(sourceView.bounds, inView: sourceView, animated: true)
			} else {
				actionSheet.showInView(viewController.view)
			}
		}
	}
	
	public class func showAlertView(viewController: UIViewController, title: String?, message: String?, actions: Array<DAAlertAction>?, numberOfTextFields: Int = 0, textFieldsConfigurationHandler configurationHandler: ((Array<UITextField>) -> Void)? = nil, validationBlock: ((Array<UITextField>) -> Bool)? = nil) {
		if NSClassFromString("UIAlertController") != nil {
			DAAlertController.defaultAlertController.currentAlertController = EXAlertController(title: title, message: message, preferredStyle: .Alert)
			if var alertController = DAAlertController.defaultAlertController.currentAlertController {
				alertController.validationBlock = validationBlock
				var disableableActions = NSMutableSet()
				var observers = NSMutableSet()
				var textFields = Array<UITextField>()
				if let actions = actions {
					for action in actions {
						var actualAction = UIAlertAction(title: action.title, style: UIAlertActionStyle(rawValue: action.style.rawValue)!) { (anAction: UIAlertAction!) -> Void in
							if observers.count > 0 {
								for observer in observers {
									NSNotificationCenter.defaultCenter().removeObserver(observer)
								}
								observers.removeAllObjects()
							}
							if var action = action as? DAAlertFieldAction {
								action.textFieldHandler?(textFields)
							} else {
								action.handler?()
							}
							DAAlertController.defaultAlertController.currentAlertController = nil
						}
						if (validationBlock != nil) && (action.style != .Cancel) {
							disableableActions.addObject(actualAction)
						}
						alertController.addAction(actualAction)
					}
				}
				if numberOfTextFields > 0 {
					for i in 0..<numberOfTextFields {
						alertController.addTextFieldWithConfigurationHandler { (aTextField: UITextField!) -> Void in
							textFields.append(aTextField)
							var observer = NSNotificationCenter.defaultCenter().addObserverForName(UITextFieldTextDidChangeNotification, object: aTextField, queue: NSOperationQueue.mainQueue()) { (notification: NSNotification!) -> Void in
								if let textFieldsFilledWithValidData = validationBlock?(textFields) {
									for disableableAction in disableableActions {
										if let disableableAction = disableableAction as? UIAlertAction {
											disableableAction.enabled = textFieldsFilledWithValidData
										}
									}
								}
							}
							observers.addObject(observer)
						}
					}
					configurationHandler?(textFields)
					textFields.last?.delegate = DAAlertController.defaultAlertController
					if let textFieldsFilledWithValidData = validationBlock?(textFields) {
						for disableableAction in disableableActions {
							if let disableableAction = disableableAction as? UIAlertAction {
								disableableAction.enabled = textFieldsFilledWithValidData
							}
						}
					}
				}
				viewController.presentViewController(alertController, animated: true, completion: nil)
			}
		} else {
			assert(numberOfTextFields <= 2, "DAAlertController can only have up to 2 UITextFields on iOS 7")
			DAAlertController.defaultAlertController.currentAlertView = self.alertView(title: title, message: message, actions: actions)
			if var alertView = DAAlertController.defaultAlertController.currentAlertView {
				alertView.validationBlock = validationBlock
				if numberOfTextFields > 0 {
					var textFields = Array<UITextField>()
					switch numberOfTextFields {
					case 1:
						alertView.alertViewStyle = .PlainTextInput
						if let textField = alertView.textFieldAtIndex(0) {
							textFields.append(textField)
						}
					case 2:
						alertView.alertViewStyle = .LoginAndPasswordInput
						if let textField = alertView.textFieldAtIndex(0) {
							textFields.append(textField)
						}
						if let textField = alertView.textFieldAtIndex(1) {
							textFields.append(textField)
						}
					default:
						break
					}
					configurationHandler?(textFields)
					textFields.last?.delegate = DAAlertController.defaultAlertController
				}
				alertView.show()
			}
		}
	}
	
}

extension DAAlertController {
	
	public class func validate(actions: Array<DAAlertAction>?) {
		var cancelActionsCount = 0
		var destructiveActionsCount = 0
		var defaultActionsCount = 0
		if let actions = actions {
			for action in actions {
				switch action.style {
				case .Default:
					defaultActionsCount++
				case .Cancel:
					cancelActionsCount++
				case .Destructive:
					destructiveActionsCount++
				}
			}
		}
		assert(defaultActionsCount <= 10, "DAAlertController can have up to 10 actions with a style of DAAlertActionStyle.Default; if you need to have more, please, consider using another control")
		assert(cancelActionsCount <= 1, "DAAlertController can only have one action with a style of DAAlertActionStyle.Cancel")
		if cancelActionsCount == 0 {
			println("UIActionSheet might not be rendered properly for iOS 7.* if you do not specify an action with a style of DAAlertActionStyle.Cancel");
		}
		if destructiveActionsCount > 1 {
			var destructiveActionsString = "";
			var firstDestructiveAction: DAAlertAction?
			for action in actions! {
				if action.style == .Destructive {
					if firstDestructiveAction == nil {
						firstDestructiveAction = action
					} else {
						if destructiveActionsString.isEmpty {
							destructiveActionsString = "\"\(action.title)\""
						} else {
							destructiveActionsString += ", \"\(action.title)\""
						}
						action.style = .Default
					}
				}
			}
			println("DAAlertController can only render one action of a style of DAAlertActionStyle.Destructive on iOS 7, \(destructiveActionsString) will be rendered as actions with a style of DAAlertActionStyle.Default")
		}
	}
	
	private class func actionSheet(#title: String?, message: String?, actions: Array<DAAlertAction>?) -> EXActionSheet! {
		var cancelAction: DAAlertAction?
		var destructiveAction: DAAlertAction?
		var otherActions = Array<DAAlertAction>()
		if let actions = actions {
			for action in actions {
				switch action.style {
				case .Cancel:
					if cancelAction == nil {
						cancelAction = action
					}
				case .Destructive:
					if destructiveAction == nil {
						destructiveAction = action
					}
				case .Default:
					otherActions.append(action)
				}
			}
		}
		
		/*
		Add the buttons manually, in order of appearance, to ensure consistency accross versions of iOS.
		*/
		var actionSheet = EXActionSheet(title: title, delegate: defaultAlertController, cancelButtonTitle: nil, destructiveButtonTitle: nil)
		actionSheet.destructiveAction = destructiveAction
		actionSheet.otherActions = otherActions
		actionSheet.cancelAction = cancelAction
		
		return actionSheet
	}
	
	private class func alertView(#title: String?, message: String?, actions: Array<DAAlertAction>?) -> EXAlertView! {
		var cancelAction: DAAlertAction?
		var otherActions = Array<DAAlertAction>()
		if let actions = actions {
			for action in actions {
				if action.style == .Cancel {
					if cancelAction == nil {
						cancelAction = action
					}
				} else {
					otherActions.append(action)
				}
			}
		}
		var otherButtonTitles = otherActions.map({$0.title})
		
		var alertView = EXAlertView(title: title ?? "", message: message ?? "", delegate: defaultAlertController, cancelButtonTitle: cancelAction?.title, otherButtonTitles: otherButtonTitles)
		alertView.otherActions = otherActions
		alertView.cancelAction = cancelAction
		
		return alertView
	}
	
}

extension DAAlertController: UITextFieldDelegate {
	
	public func textFieldShouldReturn(textField: UITextField) -> Bool {
		if NSClassFromString("UIAlertController") != nil {
			if let currentAlertController = currentAlertController {
				if let textFields = currentAlertController.textFields as? Array<UITextField> {
					if let validationBlock = currentAlertController.validationBlock {
						return validationBlock(textFields)
					}
				}
			}
			return true
		} else if let currentAlertView = currentAlertView {
			if alertViewShouldEnableFirstOtherButton(currentAlertView) {
				if ((currentAlertView.numberOfButtons == 2) && (currentAlertView.cancelButtonIndex != -1)) ||
					((currentAlertView.numberOfButtons == 1) && (currentAlertView.cancelButtonIndex == -1)) {
						currentAlertView.dismissWithClickedButtonIndex(Int(currentAlertView.cancelButtonIndex != -1), animated: true)
				}
				return true
			}
		}
		return false
	}
	
}

extension DAAlertController: UIAlertViewDelegate {
	
	public func alertView(alertView: UIAlertView, willDismissWithButtonIndex buttonIndex: Int) {
		NSNotificationCenter.defaultCenter().removeObserver(self, name: UITextFieldTextDidChangeNotification, object: nil)
		if let alertView = alertView as? EXAlertView {
			var textFields = Array<UITextField>()
			if (alertView.alertViewStyle == .PlainTextInput) || (alertView.alertViewStyle == .LoginAndPasswordInput) {
				if let textField = alertView.textFieldAtIndex(0) {
					textFields.append(textField)
				}
			}
			if (alertView.alertViewStyle == .LoginAndPasswordInput) {
				if let textField = alertView.textFieldAtIndex(1) {
					textFields.append(textField)
				}
			}
			if buttonIndex == alertView.cancelButtonIndex {
				if var action = alertView.cancelAction as? DAAlertFieldAction {
					action.textFieldHandler?(textFields)
				} else if var action = alertView.cancelAction {
					action.handler?()
				}
			} else if alertView.firstOtherButtonIndex != -1 {
				var otherAction = alertView.otherActions?[buttonIndex - alertView.firstOtherButtonIndex]
				if var action = otherAction as? DAAlertFieldAction {
					action.textFieldHandler?(textFields)
				} else if var action = otherAction {
					action.handler?()
				}
			} else {
				var otherAction = alertView.otherActions?[buttonIndex - Int(alertView.cancelButtonIndex != -1)]
				if var action = otherAction as? DAAlertFieldAction {
					action.textFieldHandler?(textFields)
				} else if var action = otherAction {
					action.handler?()
				}
			}
		}
		currentAlertView = nil
	}
	
	public func alertViewShouldEnableFirstOtherButton(alertView: UIAlertView) -> Bool {
		var shouldEnableFirstOtherButton = true
		if alertView.alertViewStyle != .Default {
			var textFields = Array<UITextField>()
			if (alertView.alertViewStyle == .PlainTextInput) || (alertView.alertViewStyle == .LoginAndPasswordInput) {
				if let textField = alertView.textFieldAtIndex(0) {
					textFields.append(textField)
				}
			}
			if (alertView.alertViewStyle == .LoginAndPasswordInput) {
				if let textField = alertView.textFieldAtIndex(1) {
					textFields.append(textField)
				}
			}
			if let alertView = alertView as? EXAlertView {
				if let validationBlock = alertView.validationBlock {
					shouldEnableFirstOtherButton = validationBlock(textFields)
				}
			}
		}
		return shouldEnableFirstOtherButton
	}
	
}

extension DAAlertController: UIActionSheetDelegate {
	
	public func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
		if let actionSheet = actionSheet as? EXActionSheet {
			if buttonIndex == actionSheet.cancelButtonIndex {
				if var action = actionSheet.cancelAction as? DAAlertFieldAction {
					action.textFieldHandler?(Array<UITextField>())
				} else if var action = actionSheet.cancelAction {
					action.handler?()
				}
			} else if buttonIndex == actionSheet.destructiveButtonIndex {
				if var action = actionSheet.destructiveAction as? DAAlertFieldAction {
					action.textFieldHandler?(Array<UITextField>())
				} else if var action = actionSheet.destructiveAction {
					action.handler?()
				}
			} else {
				var otherAction = actionSheet.otherActions?[buttonIndex - Int(actionSheet.destructiveButtonIndex != -1)]
				if var action = otherAction as? DAAlertFieldAction {
					action.textFieldHandler?(Array<UITextField>())
				} else if var action = otherAction {
					action.handler?()
				}
			}
		}
	}
	
}
