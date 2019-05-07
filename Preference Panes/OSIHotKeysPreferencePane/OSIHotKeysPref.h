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
  Distributed under GNU - GPL
  
  See http://www.osirix-viewer.com/copyright.html for details.

     This software is distributed WITHOUT ANY WARRANTY; without even
     the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
     PURPOSE.
=========================================================================*/

#import <PreferencePanes/PreferencePanes.h>
#import "HotKeyArrayController.h"

@interface OSIHotKeysPref : NSPreferencePane 
{
	NSArray *_actions;
	IBOutlet NSTextFieldCell *keyTextFieldCell;
	IBOutlet HotKeyArrayController *arrayController;
	IBOutlet NSWindow *mainWindow;
}

+ (OSIHotKeysPref*) currentKeysPref;
- (void) keyDown:(NSEvent *)theEvent;
- (void) mainViewDidLoad;
- (NSArray *)actions;
- (void)setActions:(NSArray *)actions;

@end
