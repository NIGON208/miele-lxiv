//
//  OSIPathExtrusionROI.h
//  Miele_LXIV

//
//  ©Alex Bettarini -- all rights reserved
//  License GPLv3.0 -- see License File
//
//  At the end of 2014 the project was forked from OsiriX to become Miele-LXIV
//  The original header follows:

//
//  Created by Joël Spaltenstein on 10/4/12.
//  Copyright (c) 2012 OsiriX Team. All rights reserved.
//

#import "OSIROI.h"
#import "N3BezierPath.h"
#import "OSIGeometry.h"

@interface OSIPathExtrusionROI : OSIROI
{
    N3BezierPath *_path;
    OSISlab _slab;
    NSString *_name;
    
    NSColor *_fillColor;
    NSColor *_strokeColor;
    CGFloat _strokeThickness;
    
    OSISlab _cachedSlab;
    N3AffineTransform _cachedDicomToPixTransform;
    N3Vector _cachedMinCorner;
    NSData *_cachedMaskRunsData;
}

- (id)initWith:(N3BezierPath *)path slab:(OSISlab)slab name:(NSString *)name;

@property (nonatomic, readonly, retain) N3BezierPath *bezierPath;

@end
