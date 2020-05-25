//
//  DAAlertAction.swift
//  DAAlertController
//
//  Objective-C code Copyright (c) 2015 FactoralComplexity. By Daria Kopaliani. All rights reserved.
//  Swift adaptation Copyright (c) 2015 Nicolas Gomollon. All rights reserved.
//

import Foundation
import UIKit

@objc(DAAlertAction)
open class DAAlertAction: NSObject {
	
	open var title: String?
	open var style: UIAlertAction.Style
	open var configurationHandler: ((UIAlertAction) -> Void)?
	open var handler: (() -> Void)?
	
	public init(title: String?, style: UIAlertAction.Style, configurationHandler: ((UIAlertAction) -> Void)? = nil, handler: (() -> Void)? = nil) {
		self.title = title
		self.style = style
		self.configurationHandler = configurationHandler
		self.handler = handler
		super.init()
	}
	
	open func generateAlertAction(preHandler: (() -> Void)?, postHandler: (() -> Void)?) -> UIAlertAction {
		let alertAction: UIAlertAction = UIAlertAction(title: title, style: style) { (alertAction: UIAlertAction) in
			preHandler?()
			self.handler?()
			postHandler?()
		}
		configurationHandler?(alertAction)
		return alertAction
	}
	
}

extension DAAlertAction: NSCopying {
	
	public func copy(with zone: NSZone?) -> Any {
		return DAAlertAction(title: title, style: style, handler: handler)
	}
	
}

@objc(DAAlertFieldAction)
open class DAAlertFieldAction: DAAlertAction {
	
	open var textFieldHandler: (([UITextField]) -> Void)?
	
	public init(title: String?, style: UIAlertAction.Style, textFieldHandler: (([UITextField]) -> Void)? = nil) {
		self.textFieldHandler = textFieldHandler
		super.init(title: title, style: style)
	}
	
	@available(*, unavailable, renamed: "generateAlertAction(textFields:preHandler:postHandler:)")
	open override func generateAlertAction(preHandler: (() -> Void)?, postHandler: (() -> Void)?) -> UIAlertAction {
		fatalError()
	}
	
	open func generateAlertAction(textFields: @escaping () -> [UITextField], preHandler: (() -> Void)?, postHandler: (() -> Void)?) -> UIAlertAction {
		let alertAction: UIAlertAction = UIAlertAction(title: title, style: style) { (alertAction: UIAlertAction) in
			preHandler?()
			self.textFieldHandler?(textFields())
			postHandler?()
		}
		configurationHandler?(alertAction)
		return alertAction
	}
	
}
