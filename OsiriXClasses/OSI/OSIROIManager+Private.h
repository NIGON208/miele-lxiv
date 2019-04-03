//
//  OSIROIManager_Private.h
//  Miele_LXIV

//
//  ©Alex Bettarini -- all rights reserved
//  License GPLv3.0 -- see License File
//
//  At the end of 2014 the project was forked from OsiriX to become Miele-LXIV
//  The original header follows:

//
//  Created by Joël Spaltenstein on 10/21/12.
//  Copyright (c) 2012 OsiriX Team. All rights reserved.
//

#import "OSIROIManager.h"

@class DCMView;

@interface OSIROIManager (Private)

- (void)drawInDCMView:(DCMView *)dcmView;

@end
