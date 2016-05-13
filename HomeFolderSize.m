//
//  AGHomeFolderSize.m
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

#import "HomeFolderSize.h"

@implementation HomeFolderSize

- (id)init
{	
	[super init];
	[self updateDiskSpaceInfo];
	return self;
}

-(void)dealloc 
{ 
	[super dealloc]; 
} 

- (NSNumber *)updateDiskSpaceInfo
{
	NSError *error = nil;
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSString *pathToHomeFolder = [@"~" stringByExpandingTildeInPath];
	NSDictionary *homeFolderFileSystemAttributes = 
	[fileManager attributesOfFileSystemForPath:pathToHomeFolder error:&error];
	
	homeFolderSize =[homeFolderFileSystemAttributes objectForKey:NSFileSystemSize];
	homeFolderFreeSize =[homeFolderFileSystemAttributes objectForKey:NSFileSystemFreeSize];
	
	
	
	percentOfUsedSpace = [self percentOfDiskSpaceUsed];
	[fileManager release];
	return percentOfUsedSpace;
}

- (NSString *)getHumanReadableFileSize:(NSNumber *)filesize
{
	int i, c = 7;
	double size = [filesize floatValue];
	
	for (i = 0; i < c && size >= 1024; i++)
	{
		size = size / 1024;
	}
	return [self getHumanReadableFileSize:filesize forScale:i includeSuffix:YES];
}

- (NSString *)getHumanReadableFileSize:(NSNumber *)filesize forScale:(int)scale includeSuffix:(BOOL)includeSuffix
{
	int unit = 1000;
	long bytes = [filesize longValue];
	
    if (bytes < unit) return @"0B";
    int exp = (int) (log(bytes) / log(unit));

	NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
	[numberFormatter setFormat:@"0.##"];
	NSString *formattedNumber = [numberFormatter stringFromNumber:[NSNumber numberWithDouble:bytes / pow(unit, exp)]];
	if (includeSuffix) {
		static NSString *suffix[] = {@"KB", @"MB", @"GB", @"TB", @"PB", @"EB" };
		return [NSString stringWithFormat:@"%@ %@",formattedNumber, suffix[exp-1]];
	}
	else {
		return formattedNumber;
	}
}


- (NSNumber *)percentOfDiskSpaceUsed
{
	double x = 100.0 - ([homeFolderFreeSize doubleValue] / [homeFolderSize doubleValue] * 100.0);
	x = round(x);
	return [NSNumber numberWithDouble:x];
}

- (BOOL)warnIfPercentIsOver:(int)warnLevel
{
	int percentOfUsedSpaceInt = [[self percentOfUsedSpace] intValue];
	if (percentOfUsedSpaceInt > warnLevel) {
		return YES;
	}
	return NO;
}

- (BOOL)warnIfGBFreeSpaceLessThan:(int)warnLevel
{
	if ([[self homeFolderSizeNumberAsGB] intValue] < warnLevel) {
		return YES;
	}
	return NO;
}

- (BOOL)warnOrAlertForLevel:(int)warnLevel type:(int)warnWhenType
{
	if (warnWhenType == kWarnAlertPercent) {
		int percentOfUsedSpaceInt = [[self percentOfUsedSpace] intValue];
		if (percentOfUsedSpaceInt > warnLevel) {
			return YES;
		}
	} else if (warnWhenType == kWarnAlertMB) {
		if ([[self homeFolderSizeNumberAsMB] intValue] < warnLevel) {
			return YES;
		}
	} else if (warnWhenType == kWarnAlertGB) {
		if ([[self homeFolderSizeNumberAsGB] intValue] < warnLevel) {
			return YES;
		}
	}
	return NO;
}

- (NSString *)percentOfUsedSpaceString {
    return [[[self percentOfUsedSpace] stringValue] stringByAppendingString:@"%"];
}

- (NSString *)homeFolderSizeString {
	return [self getHumanReadableFileSize:homeFolderSize];
}

- (NSNumber *)homeFolderSizeNumberAsGB {
	NSString *fileSizeString =  [self getHumanReadableFileSize:homeFolderFreeSize forScale:kSuffixGB includeSuffix:NO];
	return [NSNumber numberWithInt:[fileSizeString intValue]];
}

- (NSNumber *)homeFolderSizeNumberAsMB {
	NSString *fileSizeString =  [self getHumanReadableFileSize:homeFolderFreeSize forScale:kSuffixMB includeSuffix:NO];
	return [NSNumber numberWithInt:[fileSizeString intValue]];
}

- (NSString *)homeFolderFreeSizeString {
	[self updateDiskSpaceInfo];
    return [[[self getHumanReadableFileSize:homeFolderFreeSize] retain] autorelease];
}

- (NSNumber *)percentOfUsedSpace {
	[self updateDiskSpaceInfo];
    return [[percentOfUsedSpace retain] autorelease];
}

@end
