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

#import "NSManagedObject+N2.h"


@implementation NSManagedObject (N2)

static const NSString* const CoredataURLPrefix = @"x-coredata://";

+(NSString*)UidForXid:(NSString*)xid {
	return [CoredataURLPrefix stringByAppendingString:xid];
}

+(NSURL*)UrlForXid:(NSString*)xid {
	return [NSURL URLWithString:[self UidForXid:xid]];
}

-(NSString*)XID {
	return [[[[(NSManagedObject*)self objectID] URIRepresentation] absoluteString] substringFromIndex:CoredataURLPrefix.length];
}

-(NSString*)XIDFilename {
	return [[self XID] stringByReplacingOccurrencesOfString: @"/" withString: @"-"];
}

@end
