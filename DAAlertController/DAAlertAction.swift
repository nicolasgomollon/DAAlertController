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
	open var style: UIAlertActionStyle
	open var handler: (() -> Void)?
	
	public init(title: String?, style: UIAlertActionStyle, handler: (() -> Void)? = nil) {
		self.title = title
		self.style = style
		self.handler = handler
		super.init()
	}
	
}

extension DAAlertAction: NSCopying {
	
	public func copy(with zone: NSZone?) -> Any {
		return DAAlertAction(title: title, style: style, handler: handler)
	}
	
}

@objc(DAAlertFieldAction)
open class DAAlertFieldAction: DAAlertAction {
	
	open var textFieldHandler: ((Array<UITextField>) -> Void)?
	
	public init(title: String?, style: UIAlertActionStyle, textFieldHandler: ((Array<UITextField>) -> Void)? = nil) {
		self.textFieldHandler = textFieldHandler
		super.init(title: title, style: style)
	}
	
}
