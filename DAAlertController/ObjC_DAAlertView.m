//
//  ObjC_DAAlertView.m
//  DAAlertController
//
//  Objective-C code Copyright (c) 2015 FactoralComplexity. By Daria Kopaliani. All rights reserved.
//  Swift adaptation Copyright (c) 2015 Nicolas Gomollon. All rights reserved.
//

#import "ObjC_DAAlertView.h"
#import "DAAlertController-Swift.h"

#define itemAt(array, index) ((array.count > index) ? array[index] : nil)

@implementation ObjC_DAAlertView

- (instancetype)initWithTitle:(NSString *)title message:(NSString *)message delegate:(id<UIAlertViewDelegate>)delegate cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSArray *)otherButtonTitles {
	/*
	 Okay, I usually do not write code that ugly but in this particular case there is а good reason - buggy `UIAlertView` and just that there is no other way. I myself reported this issue to the radar and know at least of 3 other guys, so may be `UIAlertController` actually happened because of us, you are welcome :)
	 
	 So the issue is that if you pass `nil` as `otherButtonTitles` in `initWithTitle:message:delegate:cancelButtonTitle:otherButtonTitles` method regardless wether you add other buttons later (using `addButtonWithTitle:` method) `firstOtherButtonIndex` will always be `-1`. And this results in `alertViewShouldEnableFirstOtherButton` never called which is something we can not afford if we want to disable buttons when there is no text in a textfiled.
	 
	 Unfortunately `initWithTitle:message:delegate:cancelButtonTitle:otherButtonTitles` method uses "nil terminated lists" for `otherButtonTitles` parameter. If you know of a non-crazy way to convert a `NSArray` into "nil terminated strings", please get in touch with me, I'll buy you a beer.
	 
	 So this is my way of converting a `NSArray` into a `nil-terminated list`:
	 */
	return [super initWithTitle:title message:message delegate:delegate cancelButtonTitle:cancelButtonTitle otherButtonTitles:itemAt(otherButtonTitles, 0), itemAt(otherButtonTitles, 1), itemAt(otherButtonTitles, 2), itemAt(otherButtonTitles, 3), itemAt(otherButtonTitles, 4), itemAt(otherButtonTitles, 5), itemAt(otherButtonTitles, 6), itemAt(otherButtonTitles, 7), itemAt(otherButtonTitles, 8), itemAt(otherButtonTitles, 9), itemAt(otherButtonTitles, 10), nil];
}

@end
