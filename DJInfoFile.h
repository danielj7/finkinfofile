//
//  DJInfoFile.h
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

#import <Foundation/Foundation.h>


@interface DJInfoFile : NSObject

@property (nonatomic, readonly) NSDictionary *fieldList;
@property (nonatomic, readonly) NSString *fileContents;

- (instancetype)initWithString:(NSString *)string NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithContentsOfURL:(NSURL *)url error:(NSError *__autoreleasing *)error;
- (instancetype)initWithContentsOfPath:(NSString *)path error:(NSError *__autoreleasing *)error;

@end
