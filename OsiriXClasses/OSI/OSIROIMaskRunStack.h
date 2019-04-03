//
//  OISROIMaskStack.h
//  Miele_LXIV

//
//  ©Alex Bettarini -- all rights reserved
//  License GPLv3.0 -- see License File
//
//  At the end of 2014 the project was forked from OsiriX to become Miele-LXIV
//  The original header follows:

//
//  Created by Joël Spaltenstein on 9/25/12.
//  Copyright (c) 2012 OsiriX Team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OSIROIMask.h"

@interface OSIROIMaskRunStack : NSObject
{
    NSData *_maskRunData;
    NSUInteger maskRunCount;
    NSUInteger _maskRunIndex;
    
    NSMutableArray *_maskRunArray;
}

- (id)initWithMaskRunData:(NSData *)maskRunData;

- (OSIROIMaskRun)currentMaskRun;
- (void)pushMaskRun:(OSIROIMaskRun)maskRun;
- (OSIROIMaskRun)popMaskRun;

- (NSUInteger)count;

@end
