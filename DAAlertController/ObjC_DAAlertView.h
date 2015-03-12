//
//  ObjC_DAAlertView.h
//  DAAlertController
//
//  Objective-C code Copyright (c) 2015 FactoralComplexity. By Daria Kopaliani. All rights reserved.
//  Swift adaptation Copyright (c) 2015 Nicolas Gomollon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ObjC_DAAlertView: UIAlertView

- (instancetype)initWithTitle:(NSString *)title message:(NSString *)message delegate:(id<UIAlertViewDelegate>)delegate cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSArray *)otherButtonTitles;

@end
