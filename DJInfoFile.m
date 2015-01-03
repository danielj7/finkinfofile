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

static NSCharacterSet	*newlineSet= nil;
static NSCharacterSet	*colonSet = nil;
static NSCharacterSet	*whitespaceSet = nil;

@implementation DJInfoFile

// Designated initializer
// Create infofile dictionary from string.

- (instancetype)initWithString:(NSString *)string {
    if ((self = [super init])) {
		if (string == nil) return self;
		
		// Create these NSCharacterSets once so that all instances can reuse them.
		static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            newlineSet = [NSCharacterSet newlineCharacterSet];
            colonSet = [NSCharacterSet characterSetWithCharactersInString:@":"];
            whitespaceSet = [NSCharacterSet whitespaceCharacterSet];
		});
        
		// If the file begins with "This is ", it's probably a makeinfo generated file and can be ignored.
		if ([string hasPrefix:@"This is "])
			return self;
		
		// Set to raw text content.
		_fileContents = string;
		
		// Split file in lines.
		NSArray		*lines;
		if (!(lines = [string componentsSeparatedByString:@"\n"])) return self;
		
		// Create a line enumerator to pass to the parser.
		NSEnumerator    *lineEnumerator;
		if (!(lineEnumerator = [lines objectEnumerator])) return self;
		
		// Parse the file into a dictionary.
		_fieldList = [[NSDictionary alloc] initWithDictionary:[self parseFields:lineEnumerator]];
		
    }
    return self;
}

// Create infofile dictionary from URL.

- (instancetype)initWithContentsOfURL:(NSURL *)url error:(NSError *__autoreleasing *)error {
	NSString *fileContents = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:error];
	if (fileContents == nil) {
		fileContents = [NSString stringWithContentsOfURL:url encoding:NSWindowsCP1251StringEncoding error:error];
	}
	return [self initWithString:fileContents];
}

// Create infofile dictionary from pathname.

- (instancetype)initWithContentsOfPath:(NSString *)path error:(NSError *__autoreleasing *)error {
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
			// Skip line if there's no colon otherwise puts everything up to colon in fieldString.
			// This is the field name. Also effectively skips blank lines.
			if (![scanner scanUpToCharactersFromSet:colonSet
										 intoString:&fieldString]) {
				continue;
			}
			// Skip line if it begins with # (comment).
			if ([fieldString hasPrefix:@"#"]) {
				continue;
			}
			// If line is just a << then it's the end of a multiline field.
			if ([fieldString isEqualToString:@"<<"]) {
				break;
			}
			
			// Remove any whitespace from beginning and end of field name and make all lowercase.
			fieldString = [[fieldString stringByTrimmingCharactersInSet:whitespaceSet] lowercaseString];
			
			// Remove colon.
			[scanner scanCharactersFromSet:colonSet
								intoString:nil];
			
			// Treat everything from the colon to EOL as field content after removing whitespace.
			if ([scanner scanUpToCharactersFromSet:newlineSet
										intoString:&contentString]) {
				contentString = [contentString stringByTrimmingCharactersInSet:whitespaceSet];
				// Field content of << indicates the beginning of a multiline field.
				if ([contentString isEqualToString:@"<<"]) {
					contentString = @"";
					if ([fieldString hasPrefix:@"splitoff"] ||
						([fieldString hasPrefix:@"info"] && ![fieldString isEqualToString:@"infodocs"])) {
						// These field names have to be parsed recursively since they can contain fields of their own.
						contentString = [self parseFields:lineEnumerator];
					} else {
						// Other multiline fields aren't recursive and all lines within them can be concatenated.
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
				// Looks like we have emtpy field content.
				contentString = @"";
			}
			// Add field to the dictionary.
			theFields[fieldString] = contentString;
		}
    }
	// Must return an immutable copy of the dictionary.
    return [theFields copy];
}


@end
