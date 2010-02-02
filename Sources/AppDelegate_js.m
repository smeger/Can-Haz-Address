//
//  AppDelegate_1.m
//  Can Haz Address
//
//  Created by Jason Harris on 2/2/10.
//  Copyright 2010 Geekspiff. All rights reserved.
//

#import "AppDelegate.h"


// - Include this file to activate javascript interaction.


@implementation AppDelegate (js)

- (void)webView:(WebView *)webView didClearWindowObject:(WebScriptObject *)windowObject forFrame:(WebFrame *)frame
{
	// - Make this object available to javascript. The javascript environment can now access
	//   it using "window.viewController".
	
	[windowObject setValue: self forKey: @"viewController"];
}


+ (NSString *)webScriptNameForSelector:(SEL)selector
{
	// - Let the javascript environment know the mapping between its function name of ShowPhoneNumber 
	//   and our selector of showPhoneNumber:.
	
	if (selector == @selector(showPhoneNumber:))
		return @"ShowPhoneNumber";
	return nil;
}


+ (BOOL)isSelectorExcludedFromWebScript:(SEL)selector
{
	// - Let the javascript environment know that it is allowed to access the showPhoneNumber:
	//   selector.
	
	if (selector == @selector(showPhoneNumber:))
		return NO;
	return YES;
}


- (void)showPhoneNumber: (NSString *)phoneNumber
{
	// - Called by javascript when the user clicks a phone number.
	
	self.hudText = phoneNumber;
	[self.hudWindow makeKeyAndOrderFront: nil];
}

@end
