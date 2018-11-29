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

#import "Photos.h"
#import "NSAppleScript+N2.h"

// if you want check point log info, define CHECK to the next line, uncommented:
#define CHECK NSLog(@"Applescript result code = %d", ok);

//// This converts an AEDesc into a corresponding NSValue.
//
//static id aedesc_to_id(AEDesc *desc)
//{
//	OSErr ok;
//
//	if (desc->descriptorType == typeChar)
//	{
//		NSMutableData *outBytes;
//		NSString *txt;
//
//		outBytes = [[NSMutableData alloc] initWithLength:AEGetDescDataSize(desc)];
//		ok = AEGetDescData(desc, [outBytes mutableBytes], [outBytes length]);
//		CHECK;
//
//		txt = [[NSString alloc] initWithData:outBytes encoding: NSUTF8StringEncoding];
//		[outBytes release];
//		[txt autorelease];
//
//		return txt;
//	}
//
//	if (desc->descriptorType == typeSInt16)
//	{
//		SInt16 buf;
//		
//		AEGetDescData(desc, &buf, sizeof(buf));
//		
//		return [NSNumber numberWithShort:buf];
//	}
//
//	return [NSString stringWithFormat:@"[unconverted AEDesc, type=\"%c%c%c%c\"]", ((char *)&(desc->descriptorType))[0], ((char *)&(desc->descriptorType))[1], ((char *)&(desc->descriptorType))[2], ((char *)&(desc->descriptorType))[3]];
//}

@implementation Photos

- (NSString *) scriptBody:(NSArray*) files
{
	NSString *albumNameStr = [[NSUserDefaults standardUserDefaults] stringForKey: @"ALBUMNAME"];
	
    //NSLog(@"%s:%i albumNameStr:<%@>", __FILE__, __LINE__, albumNameStr);
    
	NSMutableString *s = [NSMutableString stringWithCapacity:1000];

    [s appendString:@"tell application \"Photos\"\n"];
    
    [s appendString:[NSString stringWithFormat:@"if not (exists album \"%@\") then \n", albumNameStr]];
    [s appendString:[NSString stringWithFormat:@"make new album named \"%@\" \n", albumNameStr]];
    [s appendString:@"end if \n"];
    [s appendString:[NSString stringWithFormat:@"set this_album to album \"%@\" \n", albumNameStr]];
    
    for (id loopItem in files)
        [s appendString:[NSString stringWithFormat:@"import (POSIX file \"%@\" as alias) into this_album skip check duplicates yes \n", loopItem]];
	
	[s appendString:@"end tell \n"];
	
    //NSLog(@"%s:%i %@", __FILE__, __LINE__, s);

    return s;
}

- (BOOL)importIniPhoto: (NSArray*) files
{
	[self runScript:[self scriptBody:files]];
	return YES;
}

// initialize it in your init method:

- (id)init
{
	self = [super init];
	if (self)
	{
	}
	
return self;
}

// do the grunge work -
// the sweetly wrapped method is all we need to know:

- (void)runScript:(NSString *)txt
{
    NSLog(@"%s:%i %@", __FILE__, __LINE__, txt);
    NSAppleScript* as = [[[NSAppleScript alloc] initWithSource:txt] autorelease];
    NSDictionary* errs = nil;
    [as runWithArguments:nil error:&errs];
    if ([errs count])
        NSLog(@"Error: AppleScript execution failed: %@", errs);
}

@end
