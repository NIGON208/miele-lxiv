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

/** \brief VTK horn registration */


@interface HornRegistration : NSObject {
	NSMutableArray	*modelPoints, *sensorPoints;
	double *adRot, *adTrans;
}

- (void) addModelPointX: (double) x Y: (double) y Z: (double) z;
- (void) addSensorPointX: (double) x Y: (double) y Z: (double) z;
- (void) addModelPoint: (double*) point;
- (void) addSensorPoint: (double*) point;
- (short) numberOfPoint;
- (void) computeVTK:(double*) matrixResult;

- (double*) rotation;
- (double*) translation;

@end
