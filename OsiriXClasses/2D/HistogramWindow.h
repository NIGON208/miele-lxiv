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

#import <AppKit/AppKit.h>
#import "ROI.h"
#import "HistoView.h"

#define HISTOSIZE 512

/** \brief Window Controller for histogram display */

@interface HistoWindow : NSWindowController {
	
	ROI						*curROI;
	
	float					*data, histoData[ HISTOSIZE], maxValue, minValue;
	long					dataSize;
	
	IBOutlet HistoView		*histo;
	IBOutlet NSSlider		*binSlider;
	IBOutlet NSTextField	*binText, *maxText;
}

- (id) initWithROI: (ROI*) iroi;
- (ROI*) curROI;
- (IBAction) changeBin: (id) sender;
@end
