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

@class ROI;

/** \brief Filters brush ROIs
*
*   Filters brush ROI
*   Erode, dilate, open, close
*/

@interface ITKBrushROIFilter : NSObject {

unsigned char *kernelDilate, *kernelErode;
}

// filters
- (void) erode:(ROI*)aROI withStructuringElementRadius:(int)structuringElementRadius;
- (void) dilate:(ROI*)aROI withStructuringElementRadius:(int)structuringElementRadius;
- (void) close:(ROI*)aROI withStructuringElementRadius:(int)structuringElementRadius;
- (void) open:(ROI*)aROI withStructuringElementRadius:(int)structuringElementRadius;

@end
