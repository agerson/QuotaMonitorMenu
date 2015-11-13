//
//  AGHomeFolderSize.h
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

@interface HomeFolderSize : NSObject {
	NSNumber *homeFolderSize;
	NSNumber *homeFolderFreeSize;
	NSNumber *percentOfUsedSpace;
}

- (id)init;
- (void)dealloc;
- (NSNumber *)updateDiskSpaceInfo;
- (NSString *)getHumanReadableFileSize:(NSNumber *)filesize;
- (NSNumber *)percentOfDiskSpaceUsed;
- (BOOL)warnIfPercentIsOver:(int)warnLevel;
- (NSString *)percentOfUsedSpaceString;
- (NSString *)homeFolderSizeString;
- (NSString *)homeFolderFreeSizeString;
- (NSNumber *)percentOfUsedSpace;
- (BOOL)warnOrAlertForLevel:(int)warnLevel type:(int)warnWhenType;
- (NSString *)getHumanReadableFileSize:(NSNumber *)filesize forScale:(int)scale includeSuffix:(BOOL)includeSuffix;
- (NSNumber *)homeFolderSizeNumberAsGB;
- (NSNumber *)homeFolderSizeNumberAsMB;

@end
