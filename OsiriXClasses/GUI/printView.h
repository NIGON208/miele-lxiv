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

#import "ViewerController.h"
#import <Cocoa/Cocoa.h>

/** \brief View used for printing from ViewerController */
@interface printView : NSView
{
	id						viewer;
	NSDictionary			*settings;
	NSArray					*filesToPrint;
	int						columns;
	int						rows;
	int						ipp;
	float					headerHeight;
}

- (id)initWithViewer:(id) v
			settings:(NSDictionary*) s
			   files:(NSArray*) f
		   printInfo:(NSPrintInfo*) pi;
- (int)columns;
- (int)rows;
- (int)ipp;

@end
