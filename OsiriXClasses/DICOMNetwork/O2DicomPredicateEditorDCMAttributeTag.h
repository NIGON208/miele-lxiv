//
//  ©Alex Bettarini -- all rights reserved
//  License GPLv3.0 -- see License File
//
//  At the end of 2014 the project was forked from OsiriX to become Miele-LXIV
//  The original header follows:
/*=========================================================================
 Program:   OsiriX
 
 Copyright (c) OsiriX Team
 All rights reserved.
 Distributed under GNU - LGPL
 
 See http://www.osirix-viewer.com/copyright.html for details.
 
 This software is distributed WITHOUT ANY WARRANTY; without even
 the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
 PURPOSE.
 =========================================================================*/

#import <DCM/DCMAttributeTag.h>

@interface O2DicomPredicateEditorDCMAttributeTag : DCMAttributeTag {
    NSString* _description;
    NSString* _cskey;
}

+ (id)tagWithGroup:(int)group element:(int)element vr:(NSString*)vr name:(NSString*)name description:(NSString*)description cskey:(NSString*)cskey;
+ (id)tagWithGroup:(int)group element:(int)element vr:(NSString*)vr name:(NSString*)name description:(NSString*)description;

- (NSString*)cskey;

@end
