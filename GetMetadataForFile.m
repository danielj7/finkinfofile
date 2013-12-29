//
//  GetMetadataForFile.m
//  FinkInfoFile
//
//  Created by Daniel Johnson on 3/29/05.
//  Copyright (c) 2006-2013 Daniel Johnson. All rights reserved.
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

#import <CoreFoundation/CoreFoundation.h>
#import <CoreServices/CoreServices.h> 
#import <Foundation/Foundation.h>
#import "DJInfoFile.h"

/* -----------------------------------------------------------------------------
   Step 1
   Set the UTI types the importer supports
  
   Modify the CFBundleDocumentTypes entry in Info.plist to contain
   an array of Uniform Type Identifiers (UTI) for the LSItemContentTypes 
   that your importer can handle
  
   ----------------------------------------------------------------------------- */

/* -----------------------------------------------------------------------------
   Step 2 
   Implement the GetMetadataForFile function
  
   Implement the GetMetadataForFile function below to scrape the relevant
   metadata from your document and return it as a CFDictionary using standard keys
   (defined in MDItem.h) whenever possible.
   ----------------------------------------------------------------------------- */

/* -----------------------------------------------------------------------------
   Step 3 (optional) 
   If you have defined new attributes, update the schema.xml file
  
   Edit the schema.xml file to include the metadata keys that your importer returns.
   Add them to the <allattrs> and <displayattrs> elements.
  
   Add any custom types that your importer requires to the <attributes> element
  
   <attribute name="com_mycompany_metadatakey" type="CFString" multivalued="true"/>
  
   ----------------------------------------------------------------------------- */



/* -----------------------------------------------------------------------------
    Get metadata attributes from file
   
   This function's job is to extract useful information your file format supports
   and return it as a dictionary
   ----------------------------------------------------------------------------- */

Boolean GetMetadataForFile(void* thisInterface, 
			   CFMutableDictionaryRef attributes, 
			   CFStringRef contentTypeUTI,
			   CFStringRef pathToFile)
{
    /* Pull any available metadata from the file at the specified path */
    /* Return the attribute keys and attribute values in the dict */
    /* Return TRUE if successful, FALSE if there was no data provided */
    
    Boolean success = NO;
    DJInfoFile *infoFile;
    NSDictionary *theFields;
    NSDictionary *infoBlock;
    NSString *fieldContent;
    
    // need to create an autorelease pool ourselves
    @autoreleasepool {
    
        NSStringEncoding enc;
        NSError *error;
        NSString *fileContents = [NSString stringWithContentsOfFile:(__bridge NSString *)pathToFile usedEncoding:&enc error:&error];
        
		if (fileContents == nil) {
			fileContents = [NSString stringWithContentsOfFile:(__bridge NSString *)pathToFile encoding:NSWindowsCP1252StringEncoding error:&error];
		}
		
		if (fileContents == nil) {
			NSLog(@"Unable to open file %@", (__bridge NSString *)pathToFile);
			return success;
		}
		
        // if the file begins with "This is ", it's probably a makeinfo generated file and can be ignored
        if (![fileContents hasPrefix:@"This is "]) {
	
			if ((infoFile = [[DJInfoFile alloc] initWithString:fileContents])) {
				
				if ((theFields = [infoFile fieldList])) {
				
				// if there's an Info2 block, access the inner dictionary
				if ((infoBlock = theFields[@"info2"]) || (infoBlock = theFields[@"info3"]) || (infoBlock = theFields[@"info4"])) {
					theFields = infoBlock;
				}
				
				// if there's no Package field, this isn't a valid info file and can be ignored
				// in which case this statement will fail and success will remain NO
				if ((fieldContent = theFields[@"package"])) {
					// set Title attribute to package name
					((__bridge NSMutableDictionary *)attributes)[(NSString *)kMDItemTitle] = fieldContent;
					success = YES;
				}
				
				if ((fieldContent = theFields[@"maintainer"])) {
					// set Authors and EmailAddresses attributes to maintainer field
					NSArray *tempArray = @[fieldContent];
					((__bridge NSMutableDictionary *)attributes)[(NSString *)kMDItemAuthors] = tempArray;
					((__bridge NSMutableDictionary *)attributes)[(NSString *)kMDItemEmailAddresses] = tempArray;
				} else {
					success = NO;
				}
				
				if ((fieldContent = theFields[@"description"])) {
					// set Description attribute to description field
					((__bridge NSMutableDictionary *)attributes)[(NSString *)kMDItemDescription] = fieldContent;
				} else {
					success = NO;
				}
				
				if ((fieldContent = theFields[@"descdetail"])) {
					// set Instructions attribute to descdetail field
					((__bridge NSMutableDictionary *)attributes)[(NSString *)kMDItemInstructions] = fieldContent;
				}
				
				if ((fieldContent = theFields[@"version"])) {
					// set Version attribute to epoch:version-revision
					
					NSString *epochString = theFields[@"epoch"];
					NSString *revisionString = theFields[@"revision"];
					
					if (epochString) {
					fieldContent = [epochString stringByAppendingFormat:@":%@", fieldContent];
					}
					
					if (revisionString) {
					fieldContent = [fieldContent stringByAppendingFormat:@"-%@", revisionString];
					} else {
					success = NO;
					}
					
					((__bridge NSMutableDictionary *)attributes)[(NSString *)kMDItemVersion] = fieldContent;
				} else {
					success = NO;
				}
				
				// set TextContent attribute to the full text of the file as a catch-all
				((__bridge NSMutableDictionary *)attributes)[(NSString *)kMDItemTextContent] = fileContents;
				}
			}
        }
        
        return success;
    }
}
