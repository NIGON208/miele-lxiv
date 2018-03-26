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

#import "DCMTKFileFormat.h"

#include "dcmtk/config/osconfig.h"
#include "dcmtk/dcmdata/dcfilefo.h"
#include "dcmtk/dcmdata/dcdeftag.h"
#include "dcmtk/ofstd/ofstd.h"

#include "dcmtk/dcmdata/dctk.h"
#include "dcmtk/dcmdata/cmdlnarg.h"
#include "dcmtk/ofstd/ofconapp.h"
#include "dcmtk/dcmdata/dcuid.h"       /* for dcmtk version name */
#include "dcmtk/dcmjpeg/djdecode.h"    /* for dcmjpeg decoders */
#include "dcmtk/dcmjpeg/dipijpeg.h"    /* for dcmimage JPEG plugin */

@implementation DCMTKFileFormat

@synthesize dcmtkDcmFileFormat;

- (id) initWithFile: (NSString*) file
{
    self = [super init];
    
    DcmFileFormat *fileformat = new DcmFileFormat();
    
    fileformat->loadFile( file.UTF8String, EXS_Unknown, EGL_noChange, DCM_MaxReadLength, ERM_autoDetect);
    self.dcmtkDcmFileFormat = fileformat;
    
    return self;
}

- (void) dealloc
{
    if( self.dcmtkDcmFileFormat)
    {
        delete (DcmFileFormat*) self.dcmtkDcmFileFormat;
        self.dcmtkDcmFileFormat = nil;
    }
    
    [super dealloc];
}
@end
