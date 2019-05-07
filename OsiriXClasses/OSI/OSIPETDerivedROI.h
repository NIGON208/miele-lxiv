//
//  OSIPETDerivedROI.h
//  Miele_LXIV

//
//  ©Alex Bettarini -- all rights reserved
//  License GPLv3.0 -- see License File
//
//  At the end of 2014 the project was forked from OsiriX to become Miele-LXIV
//  The original header follows:

//
//  Created by Joël Spaltenstein on 12/1/14.
//  Copyright (c) 2014 OsiriX Team. All rights reserved.
//

#import "OSIDerivedROI.h"

@interface OSIPETDerivedROI : OSIDerivedROI

- (instancetype)initWithBaseROI:(OSIROI *)roi floatVolumeData:(OSIFloatVolumeData *)floatVolumeData name:(NSString *)name;

@end
