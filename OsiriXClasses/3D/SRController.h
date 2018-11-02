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
#import "DCMPix.h"
#import "ColorTransferView.h"
#import "ViewerController.h"
#import "Window3DController.h"

// Fly Thru
#import "FlyThruController.h"
#import "FlyThru.h"
#import "SRFlyThruAdapter.h"

// ROIs Volumes
#define roi3Dvolume

@class SRView;
@class ROIVolume;


/** \brief Window Controller for Surface Rendering */
@interface SRController : Window3DController <NSWindowDelegate, NSToolbarDelegate>
{
    IBOutlet NSView         *toolsView;
    IBOutlet NSView         *LODView;
    IBOutlet NSView         *BlendingView;
    IBOutlet NSView         *export3DView;
    IBOutlet NSView         *perspectiveView;
    IBOutlet NSView         *OrientationsView;
    IBOutlet NSView         *BackgroundColorView;
	IBOutlet SRView			*view;
	IBOutlet NSWindow       *SRSettingsWindow;
    
    BOOL                    fusionSettingsWindow;
    
    NSToolbar				*toolbar;
    NSMutableArray			*pixList;
	NSArray					*fileList;
	
	BOOL					blending;
	NSData					*blendingVolumeData;
    NSMutableArray			*blendingPixList;
	ViewerController		*blendingController;

    IBOutlet NSTextField    *blendingPercentage;
    IBOutlet NSSlider       *blendingSlider;
    IBOutlet NSSlider       *LODSlider;
    IBOutlet NSButton       *checkFirst;
    IBOutlet NSButton       *checkSecond;
    IBOutlet NSPopUpButton  *firstPopup;
    IBOutlet NSSlider       *firstTrans;
    IBOutlet NSTextField    *firstValue;
    IBOutlet NSMatrix       *preprocessMatrix;
    IBOutlet NSSlider       *resolSlide;
    IBOutlet NSPopUpButton  *secondPopup;
    IBOutlet NSSlider       *secondTrans;
    IBOutlet NSTextField    *secondValue;
    IBOutlet NSTextField    *decimate;
    IBOutlet NSTextField    *smooth;
	
	NSData					*volumeData;
	
	// Fly Thru
	SRFlyThruAdapter		*FTAdapter;
	
	// 3D Points
	ViewerController		*viewer2D;
	NSMutableArray			*roi2DPointsArray, *sliceNumber2DPointsArray, *x2DPointsArray, *y2DPointsArray, *z2DPointsArray;
	
	// ROIs Volumes
	NSMutableArray			*roiVolumes;
	
	float					_firstSurface,  _secondSurface, _resolution, _firstTransparency, _secondTransparency, _decimate;
	int						_smooth;
	NSColor					*_firstColor, *_secondColor;
	BOOL					_shouldDecimate, _shouldSmooth, _useFirstSurface, _useSecondSurface, _shouldRenderFusion;
	
    NSMutableDictionary     *settings, *blendingSettings;
	NSTimeInterval			flyThruRecordingTimeFrame;
    
    // TODO: Backward compatibility for older xibs, to be delete in next release : not used !
    float                   fusionFirstSurface,  fusionSecondSurface, fusionResolution, fusionFirstTransparency, fusionSecondTransparency, fusionDecimate;
    int                     fusionSmooth;
    NSColor                 *fusionFirstColor, *fusionSecondColor;
    BOOL                    fusionShouldDecimate, fusionShouldSmooth, fusionUseFirstSurface, fusionUseSecondSurface;
    
#if 1 //def _STEREO_VISION_
	IBOutlet NSWindow       *SRGeometrieSettingsWindow;
	double _screenDistance;
	double _screenHeight;
	double _dolly;
	double _camFocal;
	IBOutlet NSTextField    *distanceValue;
	IBOutlet NSTextField	*heightValue;
	IBOutlet NSTextField    *eyeDistance;
	//IBOutlet NSTextField	*camFocalValue;
	//IBOutlet NSButton		*parallelFlag;
	IBOutlet NSView         *stereoIconView;
#endif
}

@property float firstSurface, secondSurface, resolution, firstTransparency, secondTransparency, decimate;
@property int smooth;
@property (retain) NSColor *firstColor, *secondColor;
@property BOOL shouldDecimate, shouldSmooth, useFirstSurface, useSecondSurface, shouldRenderFusion;

// Backward compatibility for older xibs, to be delete in next release : not used !
@property float               fusionFirstSurface,  fusionSecondSurface, fusionResolution, fusionFirstTransparency, fusionSecondTransparency, fusionDecimate;
@property int                 fusionSmooth;
@property (retain) NSColor    *fusionFirstColor, *fusionSecondColor;
@property BOOL                fusionShouldDecimate, fusionShouldSmooth, fusionUseFirstSurface, fusionUseSecondSurface;

- (IBAction) setOrientation:(id) sender;
- (IBAction) setDefaultTool:(id) sender;
- (IBAction) ApplySettings:(id) sender;
- (IBAction) SettingsPopup:(id) sender;
- (IBAction) flyThruButtonMenu:(id)sender;
- (IBAction) flyThruControllerInit:(id)sender;
- (IBAction) customizeViewerToolBar:(id)sender;
- (IBAction) roiDeleteAll:(id) sender;

- (ViewerController*) blendingController;
- (id) initWithPix:(NSMutableArray*) pix :(NSArray*) f :(NSData*) vData :(ViewerController*) bC :(ViewerController*) vC;
- (void) setupToolbar;
- (void) ChangeSettings:(id) sender;
- (NSArray*) fileList;

- (void)recordFlyThru;

// 3D Points
- (BOOL) add2DPoint: (float) x : (float) y : (float) z;
- (void) remove2DPoint: (float) x : (float) y : (float) z;
- (void) add3DPoint: (NSNotification*) note;
- (void) remove3DPointROI: (ROI*) removedROI;
- (void) remove3DPoint: (NSNotification*) note;

- (void) createContextualMenu;

- (ViewerController *) viewer2D;
- (void)renderSurfaces;
- (void)renderFusionSurfaces;

#ifdef roi3Dvolume
- (void) computeROIVolumes;
- (NSMutableArray*) roiVolumes;
- (void) displayROIVolume: (ROIVolume*) v;
- (void) hideROIVolume: (ROIVolume*) v;
- (void) displayROIVolumes;
- (IBAction) roiGetManager:(id) sender;
#endif

- (BOOL) shouldRenderFusion;

@end





	
