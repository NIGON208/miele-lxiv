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

#import "CPRGeneratorOperation.h"

@implementation CPRGeneratorOperation

@synthesize request = _request;
@synthesize volumeData = _volumeData;
@synthesize generatedVolume = _generatedVolume;

- (id)initWithRequest:(CPRGeneratorRequest *)request volumeData:(CPRVolumeData *)volumeData;
{
    if ( (self = [super init]) ) {
        _request = [request retain];
        _volumeData = [volumeData retain];
    }
    return self;
}

- (void)dealloc
{
    [_volumeData release];
    _volumeData = nil;
    [_request release];
    _request = nil;
    [_generatedVolume release];
    _generatedVolume = nil;
    [super dealloc];
}

- (BOOL)didFail
{
    return NO;
}

@end
