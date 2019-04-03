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

#import <Cocoa/Cocoa.h>

@class DCMAttributeTag;

@interface AnonymizationCustomTagPanelController : NSWindowController {
	IBOutlet NSTextField* groupField;
	IBOutlet NSTextField* elementField;
}

-(IBAction)cancelButtonAction:(id)sender;
-(IBAction)okButtonAction:(id)sender;

@property(assign) DCMAttributeTag* attributeTag;

@end
