//
//  DAAlertAction.swift
//  DAAlertController
//
//  Objective-C code Copyright (c) 2015 FactoralComplexity. By Daria Kopaliani. All rights reserved.
//  Swift adaptation Copyright (c) 2015 Nicolas Gomollon. All rights reserved.
//

import Foundation

public enum DAAlertActionStyle: Int {
	case Default
	case Cancel
	case Destructive
}

@objc(DAAlertAction)
public class DAAlertAction: NSObject {
	
	public var title: String
	public var style: DAAlertActionStyle
	public var handler: (() -> Void)?
	
	public init(title: String, style: DAAlertActionStyle, handler: (() -> Void)? = nil) {
		self.title = title
		self.style = style
		self.handler = handler
		super.init()
	}
	
}

extension DAAlertAction: NSCopying {
	
	public func copyWithZone(zone: NSZone) -> AnyObject {
		return DAAlertAction(title: title, style: style, handler: handler)
	}
	
}

@objc(DAAlertFieldAction)
public class DAAlertFieldAction: DAAlertAction {
	
	public var textFieldHandler: ((Array<UITextField>) -> Void)?
	
	public init(title: String, style: DAAlertActionStyle, textFieldHandler: ((Array<UITextField>) -> Void)? = nil) {
		self.textFieldHandler = textFieldHandler
		super.init(title: title, style: style)
	}
	
}

extension DAAlertFieldAction: NSCopying {
	
	public override func copyWithZone(zone: NSZone) -> AnyObject {
		return DAAlertFieldAction(title: title, style: style, textFieldHandler: textFieldHandler)
	}
	
}
