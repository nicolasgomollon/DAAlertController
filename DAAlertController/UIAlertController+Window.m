//
//  UIAlertController+Window.m
//  DAAlertController
//
//  Objective-C code Copyright (c) 2015 FactoralComplexity. By Daria Kopaliani. All rights reserved.
//  Swift adaptation Copyright (c) 2015 Nicolas Gomollon. All rights reserved.
//

#import <objc/runtime.h>
#import "UIAlertController+Window.h"

@interface UIAlertController (Private)

@property (nonatomic, strong) UIWindow *alertWindow;

@end

@implementation UIAlertController (Private)

@dynamic alertWindow;

- (void)setAlertWindow:(UIWindow *)alertWindow {
	objc_setAssociatedObject(self, @selector(alertWindow), alertWindow, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIWindow *)alertWindow {
	return objc_getAssociatedObject(self, @selector(alertWindow));
}

@end

@implementation UIAlertController (Window)

- (void)show {
	[self show:YES];
}

- (void)show:(BOOL)animated {
	self.alertWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
	self.alertWindow.rootViewController = [[UIViewController alloc] init];
	self.alertWindow.windowLevel = UIWindowLevelAlert + 1;
	[self.alertWindow makeKeyAndVisible];
	[self.alertWindow.rootViewController presentViewController:self animated:animated completion:nil];
}

@end