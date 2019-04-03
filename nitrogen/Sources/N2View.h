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

@class N2Layout;

extern NSString* N2ViewBoundsSizeDidChangeNotification;
extern NSString* N2ViewBoundsSizeDidChangeNotificationOldBoundsSize;

@interface N2View : NSView {
	NSControlSize _controlSize;
	NSSize _minSize, _maxSize;
	N2Layout* _n2layout;
	NSColor* _foreColor;
	NSColor* _backColor;
}

@property NSControlSize controlSize;
@property NSSize minSize, maxSize;
@property(retain) N2Layout* n2layout;
@property(nonatomic, retain) NSColor* foreColor;
@property(nonatomic, retain) NSColor* backColor;

-(void)formatSubview:(NSView*)view;
-(void)resizeSubviews;

@end

