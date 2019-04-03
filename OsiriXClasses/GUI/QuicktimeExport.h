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

#import <Foundation/Foundation.h>
#import <CoreMedia/CoreMedia.h>
#import <AVFoundation/AVFoundation.h>
#import <AppKit/AppKit.h>

/** \brief QuickTime export */
@interface QuicktimeExport : NSObject
{
	id						object;
	SEL						selector;
	long					numberOfFrames;
	unsigned long			codec;
	long					quality;
	
	NSSavePanel				*panel;
	NSArray					*exportTypes;
	
	IBOutlet NSView			*view;
	IBOutlet NSPopUpButton	*type;
}

+ (CVPixelBufferRef) CVPixelBufferFromNSImage:(NSImage *)image;
- (id) initWithSelector:(id) o :(SEL) s :(long) f;
- (NSString*) createMovieQTKit:(BOOL) openIt :(BOOL) produceFiles :(NSString*) name;
- (NSString*) createMovieQTKit:(BOOL) openIt :(BOOL) produceFiles :(NSString*) name :(NSInteger)framesPerSecond;
@end

