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
#import "Camera.h"
#import "Window3DController.h"

/** \brief Adapter for FlyThru
*
*  Adaptor FlyThru
*  Subclassed for SR, VR, VRPro
*/

@interface FlyThruAdapter : NSObject {
	
	Window3DController	*controller;

}

- (id) initWithWindow3DController: (Window3DController*) aWindow3DController;
- (Camera*) getCurrentCamera;
- (void) setCurrentViewToCamera:(Camera*)aCamera;
- (NSImage*) getCurrentCameraImage:(BOOL) highQuality;
- (void) prepareMovieGenerating;
- (void) endMovieGenerating;
- (void) setCurrentViewToLowResolutionCamera:(Camera*)aCamera;

@end
