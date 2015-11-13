//
//  AGTrashStatusItemController.m
//  AGTrashStatusMenu
//
//	Copyright (C) 2010 Adam Gerson
//
//	This program is free software; you can redistribute it and/or
//	modify it under the terms of the GNU General Public License
//	as published by the Free Software Foundation; either version 2
//	of the License, or (at your option) any later version.
//
//	This program is distributed in the hope that it will be useful,
//	but WITHOUT ANY WARRANTY; without even the implied warranty of
//	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//	GNU General Public License for more details.
//
//	You should have received a copy of the GNU General Public License
//	along with this program; if not, write to the Free Software
//	Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

//@TODO: revalidate when pref drop downs change
//@TODO: Font issue in icon mode
//@TODO: Update localized strings and nib

#include <Security/Security.h>
#import "StatusItemController.h"
#import "SCEvents.h"
#import "SCEvent.h"

@implementation StatusItemController

@synthesize suppressAlert, allowEmptyTrashUpdate;

-(void)dealloc 
{ 
	[statusItem release];
	[menuIcon release];
	[checkDiskTimer release];
	[allowEmptyTrashTimer release];
	[super dealloc]; 
} 

- (void)awakeFromNib 
{ 
	[[NSNotificationCenter defaultCenter] addObserver:self
		 selector:@selector(applicationDidFinishLaunching:)
         name:@"NSApplicationDidFinishLaunchingNotification" object:nil];
	
	homeFolderSize = [[HomeFolderSize alloc] init]; 
	
	suppressAlertChecked = NO;
	suppressAlert = NO;

}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	[self prefsHaveChanged:nil];
	[self createStatusItem];
	[self setupEventListener];
	[self setAllowEmptyTrashUpdate:YES];	
}

- (IBAction)warnWhenTypeChanged:(id)sender
{
	[warnWhenTextField setStringValue:@""];
	[warnWhenTextField becomeFirstResponder];
	[self prefsHaveChanged:sender];
}


- (IBAction)alertWhenTypeChanged:(id)sender
{
	[alertWhenTextField setStringValue:@""];
	[alertWhenTextField becomeFirstResponder];
	[self prefsHaveChanged:sender];
}

- (IBAction)prefsHaveChanged:(id)sender
{
	checkDiskUseageEvery = [[[NSUserDefaults standardUserDefaults] objectForKey:@"checkDiskUseageEvery"] doubleValue] * 60;
	alertWhen = [[[NSUserDefaults standardUserDefaults] objectForKey:@"alertWhen"] intValue];
	warnWhen = [[[NSUserDefaults standardUserDefaults] objectForKey:@"warnWhen"] intValue];
	allowSuppressAlert = [[[NSUserDefaults standardUserDefaults] objectForKey:@"allowSuppressAlert"] boolValue];
	showInMenuBarAs = [[[NSUserDefaults standardUserDefaults] objectForKey:@"showInMenuBarAs"] intValue];
	requireAdminToQuit = [[[NSUserDefaults standardUserDefaults] objectForKey:@"requireAdminToQuit"] boolValue];
	warnWhenType = [[[NSUserDefaults standardUserDefaults] objectForKey:@"warnWhenType"] intValue];
	alertWhenType = [[[NSUserDefaults standardUserDefaults] objectForKey:@"alertWhenType"] intValue];
	
	if (warnWhenType == kWarnAlertPercent) {
		[warnWhenTypeFormatter setMinimum:[NSNumber numberWithInt:1]];
		[warnWhenTypeFormatter setMaximum:[NSNumber numberWithInt:100]];
	} else if (warnWhenType == kWarnAlertMB) {
		[warnWhenTypeFormatter setMinimum:[NSNumber numberWithInt:1]];
		[warnWhenTypeFormatter setMaximum:[NSNumber numberWithInt:999]];
	} else if (warnWhenType == kWarnAlertGB) {
		[warnWhenTypeFormatter setMinimum:[NSNumber numberWithInt:1]];
		[warnWhenTypeFormatter setMaximum:[NSNumber numberWithInt:9999]];
	}
	
	if (alertWhenType == kWarnAlertPercent) {
		[alertWhenTypeFormatter setMinimum:[NSNumber numberWithInt:1]];
		[alertWhenTypeFormatter setMaximum:[NSNumber numberWithInt:100]];
	} else if (alertWhenType == kWarnAlertMB) {
		[alertWhenTypeFormatter setMinimum:[NSNumber numberWithInt:1]];
		[alertWhenTypeFormatter setMaximum:[NSNumber numberWithInt:999]];
	} else if (alertWhenType == kWarnAlertGB) {
		[alertWhenTypeFormatter setMinimum:[NSNumber numberWithInt:1]];
		[alertWhenTypeFormatter setMaximum:[NSNumber numberWithInt:9999]];
	}
	
	[self setTimer];
}


- (void)setTimer
{
	if ([checkDiskTimer isValid]) {
		[checkDiskTimer invalidate];
	}
	checkDiskTimer = [NSTimer 
					   scheduledTimerWithTimeInterval:checkDiskUseageEvery
					   target:self 
					   selector:@selector(updateMenu:) 
					   userInfo:nil 
					   repeats:YES];
	
	[checkDiskTimer fire]; 
	
}

- (void)createStatusItem 
	{
	NSString *toolTipText = NSLocalizedString(@"Home Directory Disk Space Monitor", @"Standards");
	statusItem = [[[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength] retain];
	
	[statusItem setHighlightMode:YES]; 
	[statusItem setEnabled:YES]; 
	[statusItem setToolTip:toolTipText];
	[statusItem setMenu:statusMenu]; 

	[self updateMenu:nil];
}

- (void)setMenuIcon
{ 
	NSBundle *bundle = [NSBundle bundleForClass:[self class]]; 
	NSString *path = [bundle pathForResource:@"TrashCanIcon" ofType:@"tif"]; 
	menuIcon= [[NSImage alloc] initWithContentsOfFile:path]; 
	[statusItem setImage:menuIcon];
}

- (void)updateMenu:(NSTimer *)timer
{ 
	NSColor *fontColor;
	NSString *statusItemText;
	NSImage *statusItemIcon;
	BOOL warn = NO;
	BOOL alert = NO;
	
	if ([homeFolderSize warnOrAlertForLevel:warnWhen type:warnWhenType]) {
		warn = YES;
	}
	if ([homeFolderSize warnOrAlertForLevel:alertWhen type:alertWhenType]) {
		alert = YES;
	}
	
	if (alert && !suppressAlertChecked && timer != nil) {
		[self alertUser];
	}
	
	if (showInMenuBarAs == kShowInMenuBarAsText) {
		[statusItem setImage:nil];
		if (warn) {
			fontColor = [NSColor redColor];
			NSString *warnMenuText = NSLocalizedString(@"Warn Menu Text", @"Standards");
			statusItemText = [warnMenuText stringByAppendingString:@" "];
		}
		else {
			fontColor = [NSColor blackColor];
			NSString *normalMenuText = NSLocalizedString(@"Normal Menu Text", @"Standards");
			statusItemText = [normalMenuText stringByAppendingString:@" "];
		}
		
		NSDictionary *attrsDictionary =
			[NSDictionary dictionaryWithObject:fontColor 
			forKey:NSForegroundColorAttributeName];
			
		NSString *statusItemTitle = [statusItemText stringByAppendingString:
			[homeFolderSize percentOfUsedSpaceString]];

		NSAttributedString *statusItemTitleWithColor = [[NSAttributedString alloc] 
			initWithString:statusItemTitle
			attributes:attrsDictionary];
		
		[statusItem setAttributedTitle:statusItemTitleWithColor];
	} else if (showInMenuBarAs == kShowInMenuBarAsIcon) {
		[statusItem setAttributedTitle:nil];
		fontColor = [NSColor whiteColor];
		NSString *iconText = [[homeFolderSize percentOfUsedSpace] stringValue];
		
		if ([homeFolderSize warnIfPercentIsOver:warnWhen]) {
			statusItemIcon = [NSImage imageNamed:@"homeQuotaRed"];
		}
		else {
			statusItemIcon = [NSImage imageNamed:@"homeQuota"];
		}
		[statusItemIcon lockFocus];
		if ([iconText length] > 2) {
			fontColor = [NSColor blackColor];
			NSDictionary *iconAttrs =
		    [NSDictionary dictionaryWithObject:fontColor
										forKey:NSForegroundColorAttributeName];
			
			[iconText drawAtPoint:NSMakePoint(-1,-2) withAttributes:iconAttrs];
		} else if ([iconText length] == 1) {
			NSDictionary *iconAttrs =
		    [NSDictionary dictionaryWithObject:fontColor
										forKey:NSForegroundColorAttributeName];
			
			[iconText drawAtPoint:NSMakePoint(7,-2) withAttributes:iconAttrs];
		} else {  //2 digit
			NSDictionary *iconAttrs =
		    [NSDictionary dictionaryWithObject:fontColor
										forKey:NSForegroundColorAttributeName];
			
			[iconText drawAtPoint:NSMakePoint(3,-2) withAttributes:iconAttrs];
		}
		[statusItemIcon unlockFocus];
		[statusItem setImage:statusItemIcon];
		
	}
	
	NSString *diskCapacityText = NSLocalizedString(@"Total disk space", @"Standards");
	NSString *remainingText = NSLocalizedString(@"Remaining disk space", @"Standards");
	[homeFolderSizeMenuItem setTitle:[diskCapacityText 
		stringByAppendingString:[homeFolderSize homeFolderSizeString]]];
	[homeFolderFreeSizeMenuItem setTitle:[remainingText 
		stringByAppendingString:[homeFolderSize homeFolderFreeSizeString]]];
}

- (void)alertUser
{
	if (suppressAlert) {
		return;
	}
	[self bringAppToFront];
	suppressAlert = YES;
	NSBeep();
	NSString *alarmText = NSLocalizedString(@"alarm Text", @"Standards");
	alertUserAlert = [[NSAlert alloc] init];
	NSString *okText = NSLocalizedString(@"Ok", @"Standards");
	NSString *outOfSpaceText = NSLocalizedString(@"Almost out of space", @"Standards");
	NSString *emptyTrashText = NSLocalizedString(@"Empty Trash", @"Standards");
	[alertUserAlert addButtonWithTitle:okText];
	[alertUserAlert addButtonWithTitle:emptyTrashText];
	[alertUserAlert setMessageText:outOfSpaceText];
	[alertUserAlert setInformativeText:alarmText];
	[alertUserAlert setAlertStyle:NSCriticalAlertStyle];

	if (allowSuppressAlert) {
		[alertUserAlert setShowsSuppressionButton:YES];
	}

	int userClickedoOnButton = [alertUserAlert runModal];
	if (userClickedoOnButton == NSAlertSecondButtonReturn) {
		[self emptyTrash:nil];
	}
	if (allowSuppressAlert && [[alertUserAlert suppressionButton] state] == NSOnState) {
		suppressAlertChecked = YES;
	}
	[alertUserAlert release];
	suppressAlert = NO;
} 

-(IBAction)explainToUser:(id)sender 
{
	[self bringAppToFront];
	NSString *whatsIsThisText = NSLocalizedString(@"whats Is This Text", @"Standards");
	NSAlert *alert = [[NSAlert alloc] init];
	NSString *okText = NSLocalizedString(@"Ok", @"Standards");
	NSString *diskSpaceMonitorText = NSLocalizedString(@"Disk Space Monitor", @"Standards");
	[alert addButtonWithTitle:okText];
	[alert setMessageText:diskSpaceMonitorText];
	[alert setInformativeText:whatsIsThisText];
	[alert setAlertStyle:NSWarningAlertStyle];
	[alert runModal];
	[alert release];
} 

-(void)invalidPref 
{
	[self bringAppToFront];
	NSString *alertText = NSLocalizedString(@"Invalid Pref", @"Standards");
	NSAlert *alert = [[NSAlert alloc] init];
	NSString *okText = NSLocalizedString(@"Ok", @"Standards");
	[alert addButtonWithTitle:okText];
	[alert setMessageText:alertText];
	[alert setAlertStyle:NSWarningAlertStyle];
	[alert runModal];
	[alert release];
} 


-(IBAction)emptyTrash:(id)sender 
{ 
	NSDictionary* errorDict;
    NSAppleEventDescriptor* returnDescriptor = NULL;
	NSAppleScript* scriptObject = [[NSAppleScript alloc] initWithSource:
		@"\
		tell app \"Finder\"\n\
		empty the trash\n\
		end tell\n\
	"];
	[self bringAppToFront];
	NSAlert *alert = [[NSAlert alloc] init];
	NSString *okText = NSLocalizedString(@"Ok", @"Standards");
	NSString *cancelText = NSLocalizedString(@"Cancel", @"Standards");
	NSString *areYouSureText = NSLocalizedString(@"Permanently delete", @"Standards");
	NSString *noUndoText = NSLocalizedString(@"You cannot undo", @"Standards");
	NSBundle *bundle = [NSBundle bundleForClass:[self class]]; 
	NSString *path = [bundle pathForResource:@"FinderIcon" ofType:@"tif"];
	NSImage *finderIcon = [[NSImage alloc] initWithContentsOfFile:path];
	[alert addButtonWithTitle:okText];
	[alert addButtonWithTitle:cancelText];
	[alert setMessageText:areYouSureText];
	[alert setInformativeText:noUndoText];
	[alert setIcon:finderIcon];
	[alert setAlertStyle:NSWarningAlertStyle];
	if ([alert runModal] == NSAlertFirstButtonReturn) {
		returnDescriptor = [scriptObject executeAndReturnError: &errorDict];
	}
	[alert release];
	
    [scriptObject release];
	[self updateMenu:nil];
} 

-(void)bringAppToFront
{ 
	[NSApp activateIgnoringOtherApps:YES];
} 

-(IBAction)quit:(id)sender 
{ 
	if (requireAdminToQuit) {
		if (![self askForAdminPassword]) {
			[self bringAppToFront];
			NSAlert *alert = [[NSAlert alloc] init];
			NSString *okText = NSLocalizedString(@"Ok", @"Standards");
			NSString *cannotQuitText = NSLocalizedString(@"Can not quit", @"Standards");
			NSString *beAdminText = NSLocalizedString(@"Be an admin to quit", @"Standards");			
			[alert addButtonWithTitle:okText];
			[alert setMessageText:cannotQuitText];
			[alert setInformativeText:beAdminText];
			[alert setAlertStyle:NSWarningAlertStyle];
			[alert runModal];
			[alert release];
		}
		else {
			[NSApp terminate:self];
		}
	}
	else {
		[NSApp terminate:self];
	}
} 

-(BOOL)askForAdminPassword
{
	OSStatus err;
    static AuthorizationRef gAuthorization = NULL;
	AuthorizationCreate(NULL, NULL, 0, &gAuthorization);

	static const AuthorizationFlags  kFlags = 
                  kAuthorizationFlagInteractionAllowed 
                | kAuthorizationFlagExtendRights;
    AuthorizationItem   kActionRight = { "a", 0, 0, 0 };
    AuthorizationRights kRights      = { 1, &kActionRight };

    assert(gAuthorization != NULL);


    // Request the application-specific right.

        err = AuthorizationCopyRights(
            gAuthorization,         // authorization
            &kRights,               // rights
            NULL,                   // environment
            kFlags,                 // flags
            NULL                    // authorizedRights
        );
    

    if (err == noErr) {
       return YES;
    }
	else {
		return NO;
    }
	return NO;
}

#pragma mark -
#pragma mark SCEvents

- (void)setAllowEmptyTrashUpdateYes
{
	[self setAllowEmptyTrashUpdate:YES];
}

/**
 * Sets up the event listener using SCEvents and sets its delegate to this controller.
 * The event stream is started by calling startWatchingPaths: while passing the paths
 * to be watched.
 */
- (void)setupEventListener
{
    SCEvents *events = [SCEvents sharedPathWatcher];
    
    [events setDelegate:self];
    
	NSString *pathToTrash = @"";
	pathToTrash= [pathToTrash stringByAppendingFormat:@"%@/%@", NSHomeDirectory(),@".Trash"];
	
	//NSLog(@"%@",pathToTrash);
    NSMutableArray *paths = [NSMutableArray arrayWithObject:pathToTrash];

	//Start receiving events
	[events startWatchingPaths:paths];
	
	//Display a description of the stream
	//NSLog(@"%@", [events streamDescription]);	
}

- (void)pathWatcher:(SCEvents *)pathWatcher eventOccurred:(SCEvent *)event
{	
	if ([self allowEmptyTrashUpdate]) {
		//NSLog(@"%@", event);
		[self setAllowEmptyTrashUpdate:NO];
		allowEmptyTrashTimer = [NSTimer 
						   scheduledTimerWithTimeInterval:5.0
						   target:self 
						   selector:@selector(setAllowEmptyTrashUpdateYes) 
						   userInfo:nil 
						   repeats:NO];
		[self updateMenu:nil];
		
	}
}


@end
