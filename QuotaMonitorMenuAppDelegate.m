//
//  QuotaMonitorMenuAppDelegate.m
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

#import "QuotaMonitorMenuAppDelegate.h"

@implementation QuotaMonitorMenuAppDelegate

@synthesize prefWindow;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	
	NSMutableDictionary *defaults = [NSMutableDictionary dictionary];
    
	[defaults setObject:[NSNumber numberWithInt:80] forKey:@"warnWhen"];
	[defaults setObject:[NSNumber numberWithInt:0] forKey:@"warnWhenType"];
	[defaults setObject:[NSNumber numberWithInt:90] forKey:@"alertWhen"];
	[defaults setObject:[NSNumber numberWithInt:0] forKey:@"alertWhenType"];
	[defaults setObject:[NSNumber numberWithInt:5] forKey:@"checkDiskUseageEvery"];
	[defaults setObject:[NSNumber numberWithBool:YES] forKey:@"allowSuppressAlert"];
	[defaults setObject:[NSNumber numberWithBool:YES] forKey:@"requireAdminToQuit"];
	[defaults setObject:[NSNumber numberWithInt:0] forKey:@"showInMenuBarAs"];
	
	[[NSUserDefaults standardUserDefaults] registerDefaults:defaults];
	 
}

@end
