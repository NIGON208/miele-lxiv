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

@interface CustomIntervalPanel : NSWindowController
{
    NSDate *fromDate;
    NSDate *toDate;
    
    IBOutlet NSMatrix *matrix;
    IBOutlet NSDatePicker *fromPicker;
    IBOutlet NSDatePicker *toPicker;
    IBOutlet NSDatePicker *textualFromPicker;
    IBOutlet NSDatePicker *textualToPicker;
}

@property (nonatomic, retain) NSDate *fromDate, *toDate;

+ (CustomIntervalPanel*) sharedCustomIntervalPanel;
- (IBAction) nowFrom:(id)sender;
- (IBAction) nowTo:(id) sender;
- (void) sizeWindowAccordingToSettings;
- (void) setFormatAccordingToSettings;

@end
