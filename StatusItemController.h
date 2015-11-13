//
//  AGTrashStatusItemController.h
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


#import <Cocoa/Cocoa.h>
#import "HomeFolderSize.h"
#import "SCEventListenerProtocol.h"

@interface StatusItemController : NSObject <SCEventListenerProtocol> {
	IBOutlet NSMenu *statusMenu; 
	IBOutlet NSMenuItem *homeFolderSizeMenuItem;
	IBOutlet NSMenuItem *homeFolderFreeSizeMenuItem;
	IBOutlet NSNumberFormatter *warnWhenTypeFormatter;
	IBOutlet NSNumberFormatter *alertWhenTypeFormatter;
	IBOutlet NSTextField *warnWhenTextField;
	IBOutlet NSTextField *alertWhenTextField;
	
	NSStatusItem *statusItem;
	NSImage *menuIcon;
	NSTimer *checkDiskTimer;
	NSTimer *allowEmptyTrashTimer;
	NSDictionary *settings;
	NSAlert *alertUserAlert;
	
	HomeFolderSize *homeFolderSize;
	
	int warnWhen;
	int warnWhenType;
	int alertWhen;
	int alertWhenType;
	int showInMenuBarAs;
	double checkDiskUseageEvery;
	BOOL suppressAlertChecked;
	BOOL allowSuppressAlert;
	BOOL requireAdminToQuit;
	BOOL suppressAlert;
	BOOL allowEmptyTrashUpdate;
}

@property (readwrite) BOOL suppressAlert;
@property (readwrite) BOOL allowEmptyTrashUpdate;

- (void)dealloc;
- (void)awakeFromNib;
- (void)setMenuIcon;
- (void)updateMenu:(NSTimer *)timer;
- (void)alertUser;
- (IBAction)explainToUser:(id)sender;
- (IBAction)emptyTrash:(id)sender;
- (IBAction)quit:(id)sender;
- (void)createStatusItem;
- (BOOL)askForAdminPassword;
- (void)bringAppToFront;
- (IBAction)prefsHaveChanged:(id)sender;
- (IBAction)warnWhenTypeChanged:(id)sender;
- (IBAction)alertWhenTypeChanged:(id)sender;
- (void)setTimer;
- (void)setupEventListener;
- (void)pathWatcher:(SCEvents *)pathWatcher eventOccurred:(SCEvent *)event;

@end
