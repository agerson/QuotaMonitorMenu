//
//  PreferenceWindowController.m
//  QuotaMonitorMenu
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


#import "PreferenceWindowController.h"


@implementation PreferenceWindowController

@synthesize prefsEnabled, prefFontColor;

- (void)awakeFromNib 
{ 
    
	AuthorizationItem items = {kAuthorizationRightExecute, 0, NULL, 0};
    AuthorizationRights rights = {1, &items};
    [authView setAuthorizationRights:&rights];
    [authView updateStatus:nil];
	[authView setDelegate:self];
	self.prefsEnabled = NO;
	self.prefFontColor = [NSColor grayColor];
	 
}

- (BOOL)arePrfsValid 
{ 
	//LOG_ID(s);
	if ([[checkDiskUseageEveryTextField stringValue] isEqualToString:@""]) {
		[self showEmptyPrefAlertWithText:@"You must have a value for \"Check Disk Every\" "];
		return NO;
	} else if ([[warnWhenTextField stringValue] isEqualToString:@""]) {
		[self showEmptyPrefAlertWithText:@"You must have a value for \"Warn when\" "];
		return NO;	
	} else if ([[alertWhenTextField stringValue] isEqualToString:@""]) {
		[self showEmptyPrefAlertWithText:@"You must have a value for \"Alert when\" "];
		return NO;
	}
	
	return YES;
}

- (void)showEmptyPrefAlertWithText:(NSString *)text
{ 
	NSBeep();
	NSAlert *alert = [NSAlert alertWithMessageText:text  
									 defaultButton:@"OK" 
								   alternateButton:nil 
									   otherButton:nil 
						 informativeTextWithFormat:@""];
	[alert runModal]; 
}

#pragma mark -
#pragma mark NSWindow delegates
- (void)windowWillClose:(NSNotification *)notification
{
	[userDefaultsController save:nil];
	[statusItemController prefsHaveChanged:nil];
	[statusItemController setSuppressAlert:NO];
}

- (void)windowDidBecomeKey:(NSNotification *)notification
{
	[statusItemController setSuppressAlert:YES];
}

- (BOOL)windowShouldClose:(id)sender
{
	[statusItemController setSuppressAlert:YES];
	return [self arePrfsValid];
}


#pragma mark -
#pragma mark SFAuthorization delegates

- (void)authorizationViewDidAuthorize:(SFAuthorizationView *)view {
	self.prefsEnabled = YES;
	self.prefFontColor = [NSColor blackColor];
	[statusItemController performSelector:@selector(bringAppToFront) withObject:nil afterDelay:0.1];   
}

- (void)authorizationViewDidDeauthorize:(SFAuthorizationView *)view {
	self.prefsEnabled = NO;
	self.prefFontColor = [NSColor grayColor];
}

@end
