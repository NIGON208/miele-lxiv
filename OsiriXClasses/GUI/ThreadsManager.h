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

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

@interface ThreadsManager : NSObject {
	@private 
	NSArrayController* _threadsController;
    NSTimer* _timer;
}

@property(readonly) NSArrayController* threadsController;

+(ThreadsManager*)defaultManager;

-(NSArray*)threads;
-(NSUInteger)threadsCount;
-(NSThread*)threadAtIndex:(NSUInteger)index;
-(void)addThreadAndStart:(NSThread*)thread;
-(void)removeThread:(NSThread*)thread;

@end
