//
//  AppDelegate.m
//  Can Haz Address
//
//  Created by Jason Harris on 2/2/10.
//  Copyright 2010 Geekspiff. All rights reserved.
//

#import "AppDelegate.h"


static NSString * const kFirstNameKey = @"firstName";
static NSString * const kLastNameKey = @"lastName";
static NSString * const kCompanyKey = @"company";
static NSString * const kDisplayNameKey = @"displayName";
static NSString * const kURLsKey = @"urls";
static NSString * const kEmailsKey = @"emails";
static NSString * const kPhonesKey = @"phones";
static NSString * const kImageDataKey = @"imageData";

static NSString * const kSelectionIndexesDidChange = @"kSelectionIndexesDidChange";


@implementation AppDelegate

@synthesize window = _window;
@synthesize webView = _webView;
@synthesize personController = _personController;
@synthesize hudWindow = _hudWindow;
@synthesize people = _people;
@synthesize dstDirectory = _dstDirectory;
@synthesize hudText = _hudText;


- (void)awakeFromNib
{
	// - Load all people from our shared Address Book and save the values we care about in a dictionary.
	
	[self loadAddresses];
	
	// - Watch for the user to change the selected person(s).
	
	[self.personController addObserver: self forKeyPath: @"selectionIndexes" options: NSKeyValueObservingOptionInitial context: kSelectionIndexesDidChange];
	
	// - Set ourselves up as the UI delegate for our webview.
	
	[self.webView setFrameLoadDelegate: self];
}


- (void)applicationWillTerminate: (NSNotification *)notification
{
	// - Delete our tmp directory.
	
	if (_dstDirectory)
	{
		NSError *dummyError;
		[[NSFileManager defaultManager] removeItemAtPath: _dstDirectory error: &dummyError];
	}
}


- (void)observeValueForKeyPath: (NSString *)keyPath ofObject: (id)object change: (NSDictionary *)change context: (void *)context
{
	// - Watch for the user to change the selected person.
	
	if (context == kSelectionIndexesDidChange)
		[self selectedPersonDidChange];
	else
		[super observeValueForKeyPath: keyPath ofObject: object change: change context: context];
}


- (void)loadAddresses
{
	// - Load all Address Book addresses. This is neither efficient nor elegant. In the real world, one
	//   would do this in a much lazier and nicer way.
	
	ABAddressBook *addressBook = [ABAddressBook sharedAddressBook];
	NSArray *people = [addressBook people];
	
	NSMutableArray *sortedPeople = [NSMutableArray arrayWithCapacity: [people count]];
	for (ABPerson *person in people)
	{
		NSMutableDictionary *personRecord = [NSMutableDictionary dictionary];
		
		NSString *displayName = [self displayNameForPerson: person];
		if (!displayName)
			continue;
		[personRecord setValue: displayName forKey: kDisplayNameKey];
		
		NSString *firstName = [person valueForProperty: kABFirstNameProperty];
		if ([firstName length])
			[personRecord setValue: firstName forKey: kFirstNameKey];
		
		NSString *lastName = [person valueForProperty: kABLastNameProperty];
		if ([lastName length])
			[personRecord setValue: lastName forKey: kLastNameKey];
		
		NSString *company = [person valueForProperty: kABOrganizationProperty];
		if ([company length])
			[personRecord setValue: company forKey: kCompanyKey];
		
		ABMultiValue *urls = [person valueForProperty: kABURLsProperty];
		NSUInteger i, count = [urls count];
		NSMutableArray *displayURLs = [NSMutableArray arrayWithCapacity: count];
		for (i = 0; i < count; ++i)
			[displayURLs addObject: [urls valueAtIndex: i]];
		if ([displayURLs count])
			[personRecord setValue: displayURLs forKey: kURLsKey];
		
		ABMultiValue *emails = [person valueForProperty: kABEmailProperty];
		count = [emails count];
		NSMutableArray *displayEmails = [NSMutableArray arrayWithCapacity: count];
		for (i = 0; i < count; ++i)
			[displayEmails addObject: [emails valueAtIndex: i]];
		if ([displayEmails count])
			[personRecord setValue: displayEmails forKey: kEmailsKey];
		
		ABMultiValue *phones = [person valueForProperty: kABPhoneProperty];
		count = [phones count];
		NSMutableArray *displayPhones = [NSMutableArray arrayWithCapacity: count];
		for (i = 0; i < count; ++i)
			[displayPhones addObject: [phones valueAtIndex: i]];
		if ([displayPhones count])
			[personRecord setValue: displayPhones forKey: kPhonesKey];
		
		NSData *imageData = [person imageData];
		if (imageData)
			[personRecord setValue: imageData forKey: kImageDataKey];
		
		[sortedPeople addObject: personRecord];
	}
	
	NSSortDescriptor *sd = [[[NSSortDescriptor alloc] initWithKey: kDisplayNameKey ascending: YES] autorelease];
	[sortedPeople sortUsingDescriptors: [NSArray arrayWithObject: sd]];
	
	[self setValue: sortedPeople forKey: @"people"];
}


- (NSString *)displayNameForPerson: (ABPerson *)person
{
	NSString *firstName = [person valueForProperty: kABFirstNameProperty];
	NSString *lastName = [person valueForProperty: kABLastNameProperty];
	NSString *company = [person valueForProperty: kABOrganizationProperty];
	
	if ([firstName length] && [lastName length])
		return [NSString stringWithFormat: @"%@ %@", firstName, lastName];
	else if ([firstName length])
		return firstName;
	else if ([lastName length])
		return lastName;
	else if ([company length])
		return company;
	
	return nil;
}


- (void)presentError: (NSError *)error
{
	[[NSApplication sharedApplication] presentError: error];
	[NSException raise: NSGenericException format: @"A thrilling error has occurred (%@)", error];
}


- (void)selectedPersonDidChange
{
	// - Figure out for what the user would like to see in the detail view.
	
	NSArray *selectedObjects = [self.personController selectedObjects];
	NSXMLElement *rootElement = [NSXMLElement elementWithName: @"root"];
	
	// - Generate XML representing the detail view.
	
	[self addXMLForObjects: selectedObjects toRootElement: rootElement];
		
	// - Find the XSLT that transforms this XML into XHTML.
	
	NSBundle *bundle = [NSBundle mainBundle];
	NSString *xsltPath = [bundle pathForResource: @"Person" ofType: @"xslt"];
	NSParameterAssert( nil != xsltPath );
	NSURL *xsltURL = [NSURL fileURLWithPath: xsltPath];
	
	NSError *error;
	NSString *dstDirectory = self.dstDirectory;
	NSXMLDocument *xmlDocument = [[[NSXMLDocument alloc] initWithRootElement: rootElement] autorelease];
	NSXMLDocument *xhtmlDocument = [xmlDocument objectByApplyingXSLTAtURL: xsltURL arguments: nil error: &error];
	if (!xhtmlDocument)
		[self presentError: error];
	
	NSString *indexPath = [dstDirectory stringByAppendingPathComponent: @"index.html"];
	
	NSFileManager *fm = [NSFileManager defaultManager];
	if ([fm fileExistsAtPath: indexPath])
		[fm removeItemAtPath: indexPath error: &error];
	
	NSString *xhtmlString = [xhtmlDocument XMLString];
	BOOL didWrite = [xhtmlString writeToFile: indexPath atomically: NO encoding: NSUTF8StringEncoding error: &error];
	if (!didWrite)
		[self presentError: error];
	
	[[self.webView mainFrame] loadRequest: [NSURLRequest requestWithURL: [NSURL fileURLWithPath: indexPath]]];
}


- (void)addXMLForObjects: (NSArray *)objects toRootElement: (NSXMLElement *)rootElement
{
	// - Store the stuff we're going to display in an XML tree.
	
	[self addXMLForKey: kFirstNameKey fromObjects: objects toRootElement: rootElement];
	[self addXMLForKey: kLastNameKey fromObjects: objects toRootElement: rootElement];
	[self addXMLForKey: kCompanyKey fromObjects: objects toRootElement: rootElement];
	[self addXMLForKey: kEmailsKey fromObjects: objects toRootElement: rootElement];
	[self addXMLForKey: kURLsKey fromObjects: objects toRootElement: rootElement];
	[self addXMLForKey: kPhonesKey fromObjects: objects toRootElement: rootElement];

	// - Store the image (if there is one).
	
	NSString *dstDirectory = self.dstDirectory;
	NSError *error;
	NSArray *imageDatas = [objects valueForKey: kImageDataKey];
	if (1 == [imageDatas count] && [NSNull null] != [imageDatas lastObject])
	{
		NSData *imageData = [imageDatas lastObject];
		NSString *dstPath = [dstDirectory stringByAppendingPathComponent: @"face"];
		BOOL didSaveImageData = [imageData writeToFile: dstPath options: 0 error: &error];
		if (!didSaveImageData)
			[self presentError: error];
		
		NSXMLNode *faceAttribute = [NSXMLNode attributeWithName: @"face" stringValue: @"face"];
		[rootElement addAttribute: faceAttribute];
	}
}


- (void)addXMLForKey: (NSString *)key fromObjects: (id)objects toRootElement: (NSXMLElement *)rootElement
{
	// - This isn't very nice. In the real world, one would do this quite a bit more elegantly.
	
	NSArray *values = [objects valueForKey: key];
	id value = nil;
	BOOL isControllerMarker = NO;
	
	if ([values count] > 1)
	{
		isControllerMarker = YES;
		value = NSLocalizedString(@"MultipleValues", nil);
	}
	else if ([values count] == 0)
	{
		isControllerMarker = YES;
		value = NSLocalizedString(@"NoSelection", nil);
	}
	else
		value = [values lastObject];
	
	if (value == [NSNull null])
		return;
	
	if ([value isKindOfClass: [NSArray class]])
		[self addXMLForStrings: (NSArray *)value isControllerMarker: isControllerMarker tag: key toRootElement: rootElement];
	else if ([value isKindOfClass: [NSString class]])
		[self addXMLForString: (NSString *)value isControllerMarker: isControllerMarker tag: key toRootElement: rootElement];
	else
		[NSException raise: NSInternalInconsistencyException format: @"Exactly what were you thinking there, champ?"];
}


- (void)addXMLForStrings: (NSArray *)strings isControllerMarker: (BOOL)flag tag: (NSString *)tag toRootElement: (NSXMLElement *)rootElement
{
	NSXMLElement *childElement = [NSXMLElement elementWithName: tag];
	
	NSParameterAssert( [tag hasSuffix: @"s"] );
	NSString *subtag = [tag substringToIndex: [tag length] - 1];
	
	for (NSString *string in strings)
		[self addXMLForString: string isControllerMarker: flag tag: subtag toRootElement: childElement];
	
	if ([childElement childCount])
		[rootElement addChild: childElement];
}

		 
- (void)addXMLForString: (NSString *)string isControllerMarker: (BOOL)flag tag: (NSString *)tag toRootElement: (NSXMLElement *)rootElement
{
	if (0 == [string length])
		return;
	
	NSXMLElement *stringElement = [NSXMLElement elementWithName: tag stringValue: string];
	if (flag)
	{
		NSXMLNode *controllerAttribute = [NSXMLNode attributeWithName: @"displayDisabled" stringValue: @"YES"];
		[stringElement addAttribute: controllerAttribute];
	}
	
	[rootElement addChild: stringElement];
}


- (NSString *)dstDirectory
{
	// - Lazily create a temporary directory and populate it with our css, javascript and images. We'll
	//   just change the index.html file and reload it as needed.
	
	if (!_dstDirectory)
	{
		NSString *processName = [[NSProcessInfo processInfo] processName];
		
		NSString *uuid = nil;
		CFUUIDRef cfUUID = CFUUIDCreate(kCFAllocatorDefault);
		if (cfUUID)
		{
			uuid = [(NSString *)CFUUIDCreateString(kCFAllocatorDefault, cfUUID) autorelease];
			CFRelease(cfUUID);
		}
		
		_dstDirectory = [[NSTemporaryDirectory() stringByAppendingFormat: @"%@_%@", processName, uuid] retain];
		
		NSError *error;
		NSFileManager *fm = [NSFileManager defaultManager];
		NSBundle *bundle = [NSBundle mainBundle];
		
		BOOL didCreateDstDirectory = [fm createDirectoryAtPath: _dstDirectory withIntermediateDirectories: YES attributes: nil error: &error];
		if (!didCreateDstDirectory)
			[self presentError: error];

		NSString *cssSrcPath = [[bundle resourcePath] stringByAppendingPathComponent: @"css"];
		NSString *cssDstPath = [_dstDirectory stringByAppendingPathComponent: @"css"];
		BOOL didWriteCSS = [fm copyItemAtPath: cssSrcPath toPath: cssDstPath error: &error];
		if (!didWriteCSS)
			[self presentError: error];
		
		NSString *jsSrcPath = [[bundle resourcePath] stringByAppendingPathComponent: @"js"];
		NSString *jsDstPath = [_dstDirectory stringByAppendingPathComponent: @"js"];
		BOOL didWriteJS = [fm copyItemAtPath: jsSrcPath toPath: jsDstPath error: &error];
		if (!didWriteJS)
			[self presentError: error];
		
		NSString *imagesSrcPath = [[bundle resourcePath] stringByAppendingPathComponent: @"images"];
		NSString *imagesDstPath = [_dstDirectory stringByAppendingPathComponent: @"images"];
		BOOL didWriteImages = [fm copyItemAtPath: imagesSrcPath toPath: imagesDstPath error: &error];
		if (!didWriteImages)
			[self presentError: error];
		NSLog(@"If you'd like to examine the generated XHTML, take a look at \"%@/index.html\"", _dstDirectory);
	}
	
	return _dstDirectory;
}

@end
