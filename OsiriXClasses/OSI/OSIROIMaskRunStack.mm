//
//  OISROIMaskStack.m
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

#import "OSIROIMaskRunStack.h"

@implementation OSIROIMaskRunStack

- (id)initWithMaskRunData:(NSData *)maskRunData
{
    if ( (self = [super init])) {
        _maskRunData = [maskRunData retain];
        maskRunCount = [maskRunData length] / sizeof(OSIROIMaskRun);
        _maskRunArray = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)dealloc
{
    [_maskRunData release];
    [_maskRunArray release];
    
    [super dealloc];
}

- (OSIROIMaskRun)currentMaskRun
{
    if ([_maskRunArray count]) {
        return [[_maskRunArray lastObject] OSIROIMaskRunValue];
    }
    else if (_maskRunIndex < maskRunCount) {
        return ((OSIROIMaskRun *)[_maskRunData bytes])[_maskRunIndex];
    }
    else {
        assert(0);
        return OSIROIMaskRunZero;
    }
}

- (void)pushMaskRun:(OSIROIMaskRun)maskRun
{
    [_maskRunArray addObject:[NSValue valueWithOSIROIMaskRun:maskRun]];
}

- (OSIROIMaskRun)popMaskRun
{
    OSIROIMaskRun maskRun;
    
    if ([_maskRunArray count]) {
        maskRun = [[_maskRunArray lastObject] OSIROIMaskRunValue];
        [_maskRunArray removeLastObject];
    }
    else if (_maskRunIndex < maskRunCount) {
        maskRun = ((OSIROIMaskRun *)[_maskRunData bytes])[_maskRunIndex];
        _maskRunIndex++;
    }
    else {
        assert(0);
        maskRun = OSIROIMaskRunZero;
    }
    
    return maskRun;
}

- (NSUInteger)count
{
    return [_maskRunArray count] + (maskRunCount - _maskRunIndex);
}


@end
