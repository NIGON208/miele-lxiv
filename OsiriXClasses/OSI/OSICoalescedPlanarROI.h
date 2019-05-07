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
#import "OSIROI.h"

@class OSIFloatVolumeData;

@interface OSICoalescedPlanarROI : OSIROI {
    NSArray *_sourceROIs;
    N3AffineTransform _volumeTransform;

    OSIFloatVolumeData *_coalescedROIMaskVolumeData;
    
    OSISlab _cachedSlab;
    N3AffineTransform _cachedDicomToPixTransform;
    N3Vector _cachedMinCorner;
    NSData *_cachedMaskRunsData;
}

- (id)initWithSourceROIs:(NSArray *)rois;

@property (readonly, copy) NSArray *sourceROIs;
@property (readonly, assign) N3AffineTransform volumeTransform;

@end
