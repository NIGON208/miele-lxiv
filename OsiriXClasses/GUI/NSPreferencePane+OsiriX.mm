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

#import "NSPreferencePane+OsiriX.h"
#import "PreferencesWindowController.h"
#import <SecurityInterface/SFAuthorizationView.h>

@implementation NSPreferencePane (OsiriX)

-(BOOL)isUnlocked {
	return ![[NSUserDefaults standardUserDefaults] boolForKey:@"AUTHENTICATION"] ||
            [[(PreferencesWindowController*)[[[self mainView] window] windowController] authView] authorizationState] == SFAuthorizationViewUnlockedState;
}

-(NSNumber*)editable {
	return [NSNumber numberWithBool:[self isUnlocked]];
}

@end
