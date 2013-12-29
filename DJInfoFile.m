//
//  DJInfoFile.m
//  test
//
//  Created by Daniel Johnson on 11/24/04.
//  Copyright 2004-2013 Daniel Johnson. All rights reserved.
//  daniel@daniel-johnson.org

/*
 This file is part of FinkInfoFile.
 
 FinkInfoFile is free software; you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation; either version 2 of the License, or
 (at your option) any later version.
 
 FinkInfoFile is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with FinkInfoFile; if not, write to the Free Software
 Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */

#import "DJInfoFile.h"

static NSCharacterSet	*newlineSet;
static NSCharacterSet	*colonSet;
static NSCharacterSet	*whitespaceSet;

@implementation DJInfoFile

// Designated initializer
// Create infofile dictionary from string.

- (id)initWithString:(NSString *)string {
    if (self = [super init]) {
		if (string == nil) return self;
		
		// create these NSCharacterSets once so that all instances can reuse them
		if (newlineSet == nil)
			newlineSet = [NSCharacterSet characterSetWithCharactersInString:@"\n"];
		if (colonSet == nil)
			colonSet = [NSCharacterSet characterSetWithCharactersInString:@":"];
		if (whitespaceSet == nil)
			whitespaceSet = [NSCharacterSet whitespaceCharacterSet];
		
		// if the file begins with "This is ", it's probably a makeinfo generated file and can be ignored
		if ([string hasPrefix:@"This is "])
			return self;
		
		// Set to raw text content
		_fileContents = string;
		
		// split file in lines
		NSArray		*lines;
		if (!(lines = [string componentsSeparatedByString:@"\n"])) return self;
		
		// create a line enumerator to pass to the parser
		NSEnumerator    *lineEnumerator;
		if (!(lineEnumerator = [lines objectEnumerator])) return self;
		
		// parse the file into a dictionary
		_fieldList = [[NSDictionary alloc] initWithDictionary:[self parseFields:lineEnumerator]];
		
    }
    return self;
}

// Create infofile dictionary from URL.

- (id)initWithContentsOfURL:(NSURL *)url error:(NSError **)error {
	NSString *fileContents = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:error];
	if (fileContents == nil) {
		fileContents = [NSString stringWithContentsOfURL:url encoding:NSWindowsCP1251StringEncoding error:error];
	}
	return [self initWithString:fileContents];
}

// Create infofile dictionary from pathname.

- (id)initWithContentsOfPath:(NSString *)path error:(NSError **)error {
	return [self initWithContentsOfURL:[NSURL fileURLWithPath:path] error:error];
}

// Private method
// Parse contents of infofile into a dictionary.

- (NSDictionary *)parseFields:(NSEnumerator *)lineEnumerator {
    id		    line;
    
    NSMutableDictionary    *theFields = [NSMutableDictionary dictionary];
    
    while (line = [lineEnumerator nextObject]) {
		NSString    *fieldString;
		id			contentString;
		NSScanner   *scanner = [NSScanner scannerWithString:line];
		
		if ([scanner isAtEnd] == NO) {
			if (![scanner scanUpToCharactersFromSet:colonSet
										 intoString:&fieldString]) {
				continue;
			}
			if ([fieldString hasPrefix:@"#"]) {
				continue;
			}
			if ([fieldString isEqualToString:@"<<"]) {
				break;
			}
			
			fieldString = [[fieldString stringByTrimmingCharactersInSet:whitespaceSet] lowercaseString];
			
			[scanner scanCharactersFromSet:colonSet
								intoString:nil];
			
			if ([scanner scanUpToCharactersFromSet:newlineSet
										intoString:&contentString]) {
				contentString = [contentString stringByTrimmingCharactersInSet:whitespaceSet];
				if ([contentString isEqualToString:@"<<"]) {
					contentString = @"";
					if ([fieldString hasPrefix:@"splitoff"] ||
						([fieldString hasPrefix:@"info"] && ![fieldString isEqualToString:@"infodocs"] && ![fieldString isEqualToString:@"infotest"])) {
						contentString = [self parseFields:lineEnumerator];
					} else {
						while (line = [lineEnumerator nextObject]) {
							NSString *trimmedLine = [line stringByTrimmingCharactersInSet:whitespaceSet];
							if ([trimmedLine isEqualToString:@""]) {
								contentString = [contentString stringByAppendingString:@"\n"];
								continue;
							}
							if ([trimmedLine isEqualToString:@"<<"]) {
								break;
							}
							contentString = [contentString stringByAppendingFormat:@"%@\n", line];
						}
					}
				}
			} else {
				contentString = @"";
			}
			
			theFields[fieldString] = contentString;
		}
    }
	
    return [theFields copy];
}


@end
