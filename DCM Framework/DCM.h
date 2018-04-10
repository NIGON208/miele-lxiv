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


#import "DCM Framework/DCMValueRepresentation.h"
#import "DCM Framework/DCMAttributeTag.h"
#import "DCM Framework/DCMAttribute.h"
#import "DCM Framework/DCMSequenceAttribute.h"
#import "DCM Framework/DCMDataContainer.h"
#import "DCM Framework/DCMObject.h"
#import "DCM Framework/DCMTransferSyntax.h"
#import "DCM Framework/DCMTagDictionary.h"
#import "DCM Framework/DCMTagForNameDictionary.h"
#import "DCM Framework/DCMCharacterSet.h"
#import "DCM Framework/DCMPixelDataAttribute.h"
#import "DCM Framework/DCMCalendarDate.h"

#import "DCMLimitedObject.h"

#import "DCM Framework/DCMNetServiceDelegate.h"
#import "DCM Framework/DCMEncapsulatedPDF.h"


#define DCMDEBUG 0
#define DCMFramework_compile YES


#import <Accelerate/Accelerate.h>

enum DCM_CompressionQuality {DCMLosslessQuality = 0, DCMHighQuality, DCMMediumQuality, DCMLowQuality};



@protocol MoveStatusProtocol
	- (void)setStatus:(unsigned short)moveStatus  numberSent:(int)numberSent numberError:(int)numberErrors;
@end


