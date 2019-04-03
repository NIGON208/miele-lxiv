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
#import "DICOMFiles/dicomFile.h"

/** \brief  C++ calls for DicomFile 
*
*  Some C++ header from DCMTK and other C++ libs can conflict with Objective C during compilation.
*  Putting them in a separate category prevents compilation errors.
*/

@interface DicomFile (DicomFileDCMTKCategory)

+ (NSArray*) getEncodingArrayForFile: (NSString*) file;
+ (BOOL) isDICOMFileDCMTK:(NSString *) file; /**< Check for validity of DICOM using DCMTK */
+ (BOOL) isNRRDFile:(NSString *) file; /**< Test for NRRD file format */
+ (NSString*) getDicomField: (NSString*) field forFile: (NSString*) path;
+ (NSString*) getDicomFieldForGroup:(int) gr element: (int) el forDcmFileFormat: (void*) ff;

- (short) getDicomFileDCMTK; /**< Decode DICOM using DCMTK.  Returns 0 on success -1 on failure. */
- (short) getNRRDFile; /**< decode NRRD file format.  Returns 0 on success -1 on failure. */
@end
