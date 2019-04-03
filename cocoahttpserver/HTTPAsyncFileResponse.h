//
//  ©Alex Bettarini -- all rights reserved
//  License GPLv3.0 -- see License File
//
//  At the end of 2014 the project was forked from OsiriX to become Miele-LXIV
//  The original version of this file had no header

#import <Foundation/Foundation.h>
#import "HTTPResponse.h"

@class HTTPConnection;


@interface HTTPAsyncFileResponse : NSObject <HTTPResponse>
{
	HTTPConnection *connection;
	NSThread *connectionThread;
	NSArray *connectionRunLoopModes;
	
	NSString *filePath;
	NSFileHandle *fileHandle;
	
	UInt64 fileLength;
	
	UInt64 fileReadOffset;
	UInt64 connectionReadOffset;
	
	NSData *data;
	
	BOOL asyncReadInProgress;
}

- (id)initWithFilePath:(NSString *)filePath forConnection:(HTTPConnection *)connection runLoopModes:(NSArray *)modes;
- (NSString *)filePath;

@end
