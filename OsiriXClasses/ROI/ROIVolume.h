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

#import "DCMView.h"
#import <Cocoa/Cocoa.h>
#import "DCMPix.h"
#import "ROI.h"

#define id Id

#include "vtkTransform.h"

#if 1
#include "vtkActor.h"
#else
#include "vtkActor2D.h"
#endif

#undef id

/** \brief  creates volume from stack of Brush ROIs */

@class ViewerController;

@interface ROIVolume : NSObject {
	NSMutableArray		*roiList;
	vtkActor			*roiVolumeActor;
	vtkTexture			*textureImage;
	float				volume, red, green, blue, opacity, factor;
	NSColor				*color;
	BOOL				visible, textured;
	NSString			*name;
    ViewerController    *viewer;
	
	NSMutableDictionary		*properties;
}

@property float factor;

- (void) setTexture: (BOOL) o;
- (BOOL) texture;

- (void) setROIList: (NSArray*) newRoiList;
- (void) prepareVTKActor;

- (BOOL) isVolume;
- (NSValue*) roiVolumeActor;
- (BOOL) isRoiVolumeActorComputed;

- (float) volume;

- (NSColor*) color;
- (void) setColor: (NSColor*) c;

- (float) red;
- (void) setRed: (float) r;
- (float) green;
- (void) setGreen: (float) g;
- (float) blue;
- (void) setBlue: (float) b;
- (float) opacity;
- (void) setOpacity: (float) o;

- (float) factor;
- (void) setFactor: (float) f;

- (BOOL) visible;
- (void) setVisible: (BOOL) d;

- (NSString*) name;

- (NSDictionary*) properties;

- (NSMutableDictionary*)displayProperties;
- (void)setDisplayProperties:(NSDictionary*)newProperties;
- (id) initWithViewer: (ViewerController*) v;
@end
