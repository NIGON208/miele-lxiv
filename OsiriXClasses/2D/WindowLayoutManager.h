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

/*
The WindowLayoutManager class manages the various placement of the Viewers
primarily by use of hanging proctols and Advanced hanging protocols
and keeps track of the Viewer Related Window Controllers
It is a shared class.
 */

#import <Cocoa/Cocoa.h>

@class OSIWindowController;
//@class LayoutWindowController;
@interface WindowLayoutManager : NSObject
{
	NSDictionary *_currentHangingProtocol;
}

@property( retain) NSDictionary *currentHangingProtocol;

+ (WindowLayoutManager*)sharedWindowLayoutManager;
+ (int) windowsRowsForHangingProtocol:(NSDictionary*) protocol;
+ (int) windowsColumnsForHangingProtocol:(NSDictionary*) protocol;
+ (int) imagesRowsForHangingProtocol:(NSDictionary*) protocol;
+ (int) imagesColumnsForHangingProtocol:(NSDictionary*) protocol;
- (int) windowsRows;
- (int) windowsColumns;
- (int) imagesRows;
- (int) imagesColumns;

#pragma mark - hanging protocol setters and getters

+ (NSArray*) hangingProtocolsForModality: (NSString*) modality;
+ (NSDictionary*) hangingProtocolForModality: (NSString*) modalities description: (NSString *) description;
- (void) setCurrentHangingProtocolForModality: (NSString*) modality description: (NSString*) description;
- (NSDictionary*) currentHangingProtocol;

@end
