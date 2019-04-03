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

/** \brief Cell that can contain text and and image */

#import <Cocoa/Cocoa.h>

@interface ImageAndTextCell : NSTextFieldCell {
@private
    NSImage	*image, *lastImage, *lastImageAlternate;
	BOOL clickedInLastImage;
}

- (void)setImage:(NSImage *)anImage;
- (void)setLastImage:(NSImage *)anImage;
- (void)setLastImageAlternate:(NSImage *)anImage;
- (NSImage *)image;

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView;
- (NSSize)cellSize;
- (BOOL) clickedInLastImage;

@end
