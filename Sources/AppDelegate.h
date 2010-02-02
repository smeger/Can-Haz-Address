//
//  AppDelegate.h
//  Can Haz Address
//
//  Created by Jason Harris on 2/2/10.
//  Copyright 2010 Geekspiff. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <AddressBook/AddressBook.h>

@interface AppDelegate : NSObject <NSApplicationDelegate> {
    NSWindow			* _window;
    WebView				* _webView;
	NSArrayController	* _personController;
	NSWindow			* _hudWindow;

@private
	NSArray				* _people;
	NSString			* _dstDirectory;
	NSString			* _hudText;
}

@property (assign) IBOutlet NSWindow			* window;
@property (assign) IBOutlet WebView				* webView;
@property (assign) IBOutlet NSArrayController	* personController;
@property (assign) IBOutlet NSWindow			* hudWindow;

@property (retain)			NSArray				* people;
@property (readonly)		NSString			* dstDirectory;
@property (retain)			NSString			* hudText;

- (void)loadAddresses;
- (NSString *)displayNameForPerson: (ABPerson *)person;
- (void)selectedPersonDidChange;
- (void)addXMLForObjects: (NSArray *)objects toRootElement: (NSXMLElement *)rootElement;
- (void)addXMLForKey: (NSString *)key fromObjects: (id)objects toRootElement: (NSXMLElement *)rootElement;
- (void)addXMLForStrings: (NSArray *)strings isControllerMarker: (BOOL)flag tag: (NSString *)tag toRootElement: (NSXMLElement *)rootElement;
- (void)addXMLForString: (NSString *)string isControllerMarker: (BOOL)flag tag: (NSString *)tag toRootElement: (NSXMLElement *)rootElement;

@end
