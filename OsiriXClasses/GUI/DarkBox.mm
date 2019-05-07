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

#import "DarkBox.h"

@implementation DarkBox

- (void)drawRect:(NSRect)rect{
	NSColor *backgroundColor = [NSColor  colorWithCalibratedRed:0.7 green:0.7 blue:0.7 alpha:0.25];
	[backgroundColor setFill];	
	[NSBezierPath fillRect:rect];
	[super drawRect:rect];
}

@end
