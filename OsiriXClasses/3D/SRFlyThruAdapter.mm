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

#import "SRFlyThruAdapter.h"
#import "SRController.h"
#import "SRView.h"

@implementation SRFlyThruAdapter
- (id) initWithSRController: (SRController*) aSRController
{
	self = [super initWithWindow3DController: aSRController];
	return self;
}

- (Camera*) getCurrentCamera
{
	Camera *cam = [[controller view] camera];
	[cam setPreviewImage: [[controller view] nsimage:TRUE]];
	return cam;
}

- (void) setCurrentViewToCamera:(Camera*) cam
{
	[[(SRController*)controller view] setCamera: cam];
	[[(SRController*)controller view] setNeedsDisplay:YES];
}

- (NSImage*) getCurrentCameraImage: (BOOL) notUsed
{
	return [[controller view] nsimageQuicktime];
}

- (void) prepareMovieGenerating
{
	[[(SRController*)controller view] setViewSizeToMatrix3DExport];
}

- (void) endMovieGenerating
{
	[[(SRController*)controller view] restoreViewSizeAfterMatrix3DExport];
}

@end
