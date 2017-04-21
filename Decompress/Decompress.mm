// WHY THIS EXTERNAL APPLICATION FOR COMPRESS OR DECOMPRESSION?
// Because if a file is corrupted, it will not crash the OsiriX application, but only this small task.

#import <Foundation/Foundation.h>

#include "options.h"
#include "url.h"
#import "tmp_locations.h"

#import "DefaultsOsiriX.h"
#import "AppController.h"
#import "DCMPix.h"
#import <WebKit/WebKit.h>
#include <mingpp.h>
#import "N2Debug.h"
#import <Quartz/Quartz.h>

#undef verify
#include "osconfig.h" /* make sure OS specific configuration is included first */
#include "djdecode.h"  /* for dcmjpeg decoders */
#include "djencode.h"  /* for dcmjpeg encoders */
#include "dcrledrg.h"  /* for DcmRLEDecoderRegistration */
#include "dcrleerg.h"  /* for DcmRLEEncoderRegistration */
#include "djrploss.h"
#include "djrplol.h"
#include "dcpixel.h"
#include "dcrlerp.h"
#include "dcdicdir.h"
#include "dcdatset.h"
#include "dcmetinf.h"
#include "dcfilefo.h"
#include "dcuid.h"
#include "dcdict.h"
#include "dcdeftag.h"
#include "dcmjpls/djdecode.h" //JPEG-LS
#include "dcmjpls/djencode.h" //JPEG-LS

#import <OsiriX/DCMTransferSyntax.h>
#import <OsiriX/DCMObject.h>
#import <OsiriX/DCMAbstractSyntaxUID.h>

// We don`t care: we are just a small app, our memory will be killed by the system. Don't loose time here !
//#define WASTE_TIME_CLEANING_UP

extern "C"
{
    void exitOsiriX(void)
    {
        [NSException raise: @"JPEG error exception raised" format: @"JPEG error exception raised - See Console.app for error message"];
    }
}

enum DCM_CompressionQuality {DCMLosslessQuality = 0, DCMHighQuality, DCMMediumQuality, DCMLowQuality};

NSLock					*PapyrusLock = 0L;
NSThread				*mainThread = 0L;
BOOL					NEEDTOREBUILD = NO;
NSMutableDictionary		*DATABASECOLUMNS = 0L;
short					Altivec = 0;
short					UseOpenJpeg = 1, Use_kdu_IfAvailable = 0;

static NSMutableDictionary *dict;
static NSInteger fileListFirstItemIndex = 3;

extern void dcmtkSetJPEGColorSpace( int);

/*
void myunlink(const char * path) {
    NSLog(@"Unlinking %s", path);
    unlink(path);
    NSLog(@"... Unlinked %s", path);
}
*/
#define myunlink unlink

// Always modify this function in sync with compressionForModality in Decompress.mm / BrowserController.m
int compressionForModality( NSArray *array, NSArray *arrayLow, int limit, NSString* mod, int* quality, int resolution)
{
	NSArray *s;
	if( resolution < limit)
		s = arrayLow;
	else
		s = array;
	
	if( [mod isEqualToString: @"SR"]) // No compression for DICOM SR
		return compression_none;
	
	for( NSDictionary *dict in s)
	{
		if( [mod rangeOfString: [dict valueForKey: @"modality"]].location != NSNotFound)
		{
			int compression = compression_none;
			if( [[dict valueForKey: @"compression"] intValue] == compression_sameAsDefault)
				dict = [s objectAtIndex: 0];
			
			compression = [[dict valueForKey: @"compression"] intValue];
			
			if( quality)
			{
				if( compression == compression_JPEG2000 || compression == compression_JPEGLS)
					*quality = [[dict valueForKey: @"quality"] intValue];
				else
					*quality = 0;
			}
			
			return compression;
		}
	}
	
	if( [s count] == 0)
		return compression_none;
	
	if( quality)
		*quality = [[[s objectAtIndex: 0] valueForKey: @"quality"] intValue];
	
	return [[[s objectAtIndex: 0] valueForKey: @"compression"] intValue];
}

void createSwfMovie(NSArray* inputFiles, NSString* path, float frameRate);

static void registerCodecs(void)
{
    // register global JPEG codecs
    DJDecoderRegistration::registerCodecs();
    DJEncoderRegistration::registerCodecs(ECC_lossyRGB,
                                          EUC_never,
                                          OFFalse,
                                          0,
                                          0,
                                          0,
                                          OFTrue,
                                          ESS_444,
                                          OFFalse,
                                          OFFalse,
                                          0,
                                          0,
                                          0.0,
                                          0.0,
                                          0,
                                          0,
                                          0,
                                          0,
                                          OFTrue,
                                          OFTrue,
                                          OFFalse,
                                          OFFalse,
                                          OFTrue);
    
    // register RLE codecs
    DcmRLEDecoderRegistration::registerCodecs();
    DcmRLEEncoderRegistration::registerCodecs();
    
    // register JPEG-LS codecs
    DJLSDecoderRegistration::registerCodecs();
    DJLSEncoderRegistration::registerCodecs();
}

#ifdef WASTE_TIME_CLEANING_UP
static void deregisterCodecs(void)
{
    // deregister JPEG codecs
    DJDecoderRegistration::cleanup();
    DJEncoderRegistration::cleanup();
    
    // deregister RLE codecs
    DcmRLEDecoderRegistration::cleanup();
    DcmRLEEncoderRegistration::cleanup();
}
#endif

static void action_Compress(int argc, const char *argv[], NSString *path)
{
    NSArray *compressionSettings = [dict valueForKey: @"CompressionSettings"];
    NSArray *compressionSettingsLowRes = [dict valueForKey: @"CompressionSettingsLowRes"];
    
    int limit = [[dict objectForKey: @"CompressionResolutionLimit"] intValue];
    
    NSString *destDirec;
    if( [path isEqualToString: @"sameAsDestination"])
        destDirec = nil;
    else
        destDirec = path;
    
    for (NSInteger i = fileListFirstItemIndex; i < argc; i++)
    {
        NSString *curFile = [NSString stringWithUTF8String:argv[ i]];
        OFBool status = YES;
        NSString *curFileDest;
        
        if( destDirec)
            curFileDest = [destDirec stringByAppendingPathComponent: [curFile lastPathComponent]];
        else
            curFileDest = [curFile stringByAppendingString: @" temp"];
        
        if ([[curFile pathExtension] isEqualToString: @"zip"] ||
            [[curFile pathExtension] isEqualToString: @"osirixzip"])
        {
            NSString *tempCurFileDest = [[curFileDest stringByDeletingLastPathComponent] stringByAppendingPathComponent: [NSString stringWithFormat: @".%@", [curFileDest lastPathComponent]]];
            
            myunlink([tempCurFileDest fileSystemRepresentation]);
            myunlink([curFileDest fileSystemRepresentation]);
            
            NSTask *t = [[[NSTask alloc] init] autorelease];
            
            @try
            {
                [t setLaunchPath: @"/usr/bin/unzip"];
                NSString *path = [@(SYSTEM_TMP) stringByAppendingPathComponent: @"/"];
                [t setCurrentDirectoryPath: path];
                NSArray *args = [NSArray arrayWithObjects: @"-o", @"-d", tempCurFileDest, curFile, nil];
                [t setArguments: args];
                [t launch];
                
                while( [t isRunning])
                    [NSThread sleepForTimeInterval: 0.1];
                
                //[t waitUntilExit];		// <- This is VERY DANGEROUS : the main runloop is continuing...
            }
            @catch ( NSException *e)
            {
                NSLog( @"***** unzipFile exception: %@", e);
            }
            
            [[NSFileManager defaultManager] moveItemAtPath: tempCurFileDest toPath: curFileDest error: nil];
            
            myunlink([curFile fileSystemRepresentation]);
            return;
        }

        DcmFileFormat fileformat;
        OFCondition cond = fileformat.loadFile( [curFile UTF8String]);
        // if we can't read it stop
        if( cond.good())
        {
            DcmDataset *dataset = fileformat.getDataset();
//			DcmItem *metaInfo = fileformat.getMetaInfo();
            DcmXfer original_xfer(dataset->getOriginalXfer());
            
            const char *string = NULL;
#if 0
//            NSString *sopClassUID = nil;
//            if (dataset->findAndGetString(DCM_SOPClassUID, string, OFFalse).good() && string != NULL)
//                sopClassUID = [NSString stringWithCString:string encoding: NSASCIIStringEncoding];
#endif
            delete dataset->remove( DcmTagKey( 0x0009, 0x1110)); // "GEIIS" The problematic private group, containing a *always* JPEG compressed PixelData
            
            NSString *modality;
            if (dataset->findAndGetString(DCM_Modality, string, OFFalse).good() && string != NULL)
                modality = [NSString stringWithCString:string encoding: NSASCIIStringEncoding];
            else
                modality = @"OT";
            
            int resolution = 0;
            unsigned short rows = 0;
            if (dataset->findAndGetUint16( DCM_Rows, rows, OFFalse).good())
            {
                if( resolution == 0 || resolution > rows)
                    resolution = rows;
            }
            unsigned short columns = 0;
            if (dataset->findAndGetUint16( DCM_Columns, columns, OFFalse).good())
            {
                if( resolution == 0 || resolution > columns)
                    resolution = columns;
            }
            
            int quality;
            int compression = compressionForModality( compressionSettings, compressionSettingsLowRes, limit, modality, &quality, resolution);
            
            BOOL alreadyCompressed = NO;
            
            if (original_xfer.isEncapsulated()) // DICOM file is already compressed
            {
                switch( compression)
                {
                    case compression_JPEGLS:
                        if (original_xfer.getXfer() == EXS_JPEGLSLossless ||
                            original_xfer.getXfer() == EXS_JPEGLSLossy)
                            alreadyCompressed = YES;
                        break;
                        
                    case compression_JPEG2000:
                        if (original_xfer.getXfer() == EXS_JPEG2000 ||
                            original_xfer.getXfer() == EXS_JPEG2000LosslessOnly)
                            alreadyCompressed = YES;
                        break;
                        
                    case compression_JPEG:
                        if( original_xfer.getXfer() == EXS_JPEGProcess14SV1)
                            alreadyCompressed = YES;
                        break;
                }
            }
            
            if( alreadyCompressed)
            {
                if( destDirec)
                {
                    myunlink([curFileDest fileSystemRepresentation]);
                    [[NSFileManager defaultManager] moveItemAtPath: curFile toPath: curFileDest error: nil];
                    myunlink([curFile fileSystemRepresentation]);
                }
                return;
            }
            
            if (compression == compression_JPEG2000)
            {
                // DCMTK doesn't support JPEG2000 yet. Use DCMFramework
                
                DCMTransferSyntax *tsx;
                
                if (quality == DCMLosslessQuality)
                    tsx = [DCMTransferSyntax JPEG2000LosslessTransferSyntax];
                else
                    tsx = [DCMTransferSyntax JPEG2000LossyTransferSyntax];
                
                DCMObject *dcmObject = [[DCMObject alloc] initWithContentsOfFile: curFile decodingPixelData: NO];
                
                BOOL succeed;
                if ([DCMAbstractSyntaxUID isImageStorage: [dcmObject attributeValueWithName:@"SOPClassUID"]] &&
                    [[dcmObject attributeValueWithName:@"SOPClassUID"] isEqualToString:[DCMAbstractSyntaxUID pdfStorageClassUID]] == NO &&
                    [DCMAbstractSyntaxUID isStructuredReport: [dcmObject attributeValueWithName:@"SOPClassUID"]] == NO)
                {
                    @try
                    {
                        succeed = [dcmObject writeToFile: curFileDest
                                      withTransferSyntax: tsx
                                                 quality: quality
                                                     AET: @OUR_AET
                                              atomically: YES];
                    }
                    @catch (NSException *e)
                    {
                        NSLog( @"dcmObject writeToFile failed: %@", e);
                    }
                }
                else
                {
                    succeed = [[NSData dataWithContentsOfFile: curFile] writeToFile: curFileDest atomically: YES];
                }

                [dcmObject release];
                
                if (succeed)
                {
                    myunlink([curFile fileSystemRepresentation]);
                    if( destDirec == nil)
                        [[NSFileManager defaultManager] moveItemAtPath: curFileDest toPath: curFile error: nil];
                }
                else
                {
                    myunlink([curFileDest fileSystemRepresentation]);
                    if ([[dict objectForKey: @"DecompressMoveIfFail"] boolValue])
                    {
                        [[NSFileManager defaultManager] moveItemAtPath: curFile toPath: curFileDest error: nil];
                    }
                    else if( destDirec)
                    {
                        myunlink([curFile fileSystemRepresentation]);
                        NSLog( @"failed to compress file: %@, the file is deleted", curFile);
                    }
                    else
                        NSLog( @"failed to compress file: %@", curFile);
                }
                return;
            }
            else if (compression == compression_JPEG ||
                     compression == compression_JPEGLS)
            {
                DcmRepresentationParameter *params = nil;
                E_TransferSyntax tSyntax;
                DJ_RPLossless losslessParams(6,0);
                DJ_RPLossy JP2KParams( quality);
                DJ_RPLossy JP2KParamsLossLess( DCMLosslessQuality);
                
                if (compression == compression_JPEG)
                {
                    params = &losslessParams;
                    tSyntax = EXS_JPEGProcess14SV1;
                }
                else //if (compression == compression_JPEGLS)
                {
                    if (quality == DCMLosslessQuality)
                    {
                        params = &JP2KParamsLossLess;
                        tSyntax = EXS_JPEGLSLossless;
                    }
                    else
                    {
                        params = &JP2KParams;
                        tSyntax = EXS_JPEGLSLossy;
                    }
                }
                
                // this causes the lossless JPEG version of the dataset to be created
                DcmXfer oxferSyn( tSyntax);
                OFCondition myError = dataset->chooseRepresentation(tSyntax, params);
                
                // check if everything went well
                if (dataset->canWriteXfer(tSyntax))
                {
                    // force the meta-header UIDs to be re-generated when storing the file
                    // since the UIDs in the data set may have changed
                    
                    //only need to do this for lossy
                    //delete metaInfo->remove(DCM_MediaStorageSOPClassUID);
                    //delete metaInfo->remove(DCM_MediaStorageSOPInstanceUID);
                    
                    // store in lossless JPEG format
                    fileformat.loadAllDataIntoMemory();
                    
                    {
                    
                    NSString *tempCurFileDest = [[curFileDest stringByDeletingLastPathComponent] stringByAppendingPathComponent: [NSString stringWithFormat: @".%@", [curFileDest lastPathComponent]]];
                    
                    myunlink([tempCurFileDest fileSystemRepresentation]);
                    myunlink([curFileDest fileSystemRepresentation]);
                    
                    cond = fileformat.saveFile( [tempCurFileDest UTF8String], tSyntax);
                    status = (cond.good()) ? YES : NO;
                    
                    [[NSFileManager defaultManager] moveItemAtPath: tempCurFileDest
                                                            toPath: curFileDest
                                                             error: nil];
                    }
                    
                    if( status == NO)
                    {
                        myunlink([curFileDest fileSystemRepresentation]);
                        if ([[dict objectForKey: @"DecompressMoveIfFail"] boolValue])
                        {
                            [[NSFileManager defaultManager] moveItemAtPath: curFile
                                                                    toPath: curFileDest
                                                                     error: nil];
                        }
                        else if( destDirec)
                        {
                            myunlink([curFile fileSystemRepresentation]);
                            NSLog( @"failed to compress file: %@, the file is deleted", curFile);
                        }
                        else
                            NSLog( @"failed to compress file: %@", curFile);
                    }
                    else
                    {
                        myunlink([curFile fileSystemRepresentation]);
                        if( destDirec == nil)
                            [[NSFileManager defaultManager] moveItemAtPath: curFileDest
                                                                    toPath: curFile
                                                                     error: nil];
                    }
                }
                else {
                    OFLOG_FATAL(DCM_dcmjpegLogger, "no conversion to transfer syntax " << oxferSyn.getXferName() << " possible!");
                }
            }
            else
            {
                if( destDirec)
                {
                    myunlink([curFileDest fileSystemRepresentation]);
                    [[NSFileManager defaultManager] moveItemAtPath: curFile toPath: curFileDest error: nil];
                    myunlink([curFile fileSystemRepresentation]);
                }
            }
        }
        else if ([[dict objectForKey: @"DecompressMoveIfFail"] boolValue])
        {
            myunlink([curFileDest fileSystemRepresentation]);
            [[NSFileManager defaultManager] moveItemAtPath: curFile toPath: curFileDest error: nil];
        }
        else
        {
            NSLog(@"compress : cannot read file: %@", curFile);
        }
    } // for
}

static void action_Decompress(int argc, const char *argv[], NSString *path)
{
    NSString *destDirec;
    if( [path isEqualToString: @"sameAsDestination"])
        destDirec = nil;
    else
        destDirec = path;
    
    for (NSInteger i = fileListFirstItemIndex; i < argc ; i++)
    {
        NSString *curFile = [NSString stringWithUTF8String:argv[ i]];
        NSString *curFileDest;
        
        if( destDirec)
            curFileDest = [destDirec stringByAppendingPathComponent: [curFile lastPathComponent]];
        else
            curFileDest = [curFile stringByAppendingString: @" temp"];
        
        OFBool status = NO;
        
        if ([[curFile pathExtension] isEqualToString: @"zip"] ||
            [[curFile pathExtension] isEqualToString: @"osirixzip"])
        {
            NSString *tempCurFileDest = [[curFileDest stringByDeletingLastPathComponent] stringByAppendingPathComponent: [NSString stringWithFormat: @".%@", [curFileDest lastPathComponent]]];
            
            myunlink([tempCurFileDest fileSystemRepresentation]);
            myunlink([curFileDest fileSystemRepresentation]);
            
            NSTask *t = [[[NSTask alloc] init] autorelease];
            
            @try
            {
                [t setLaunchPath: @"/usr/bin/unzip"];
                NSString *path = [@(SYSTEM_TMP) stringByAppendingPathComponent: @"/"];
                [t setCurrentDirectoryPath: path];
                NSArray *args = [NSArray arrayWithObjects: @"-o", @"-d", tempCurFileDest, curFile, nil];
                [t setArguments: args];
                [t launch];
                while( [t isRunning])
                    [NSThread sleepForTimeInterval: 0.1];
                
                //[t waitUntilExit];		// <- This is VERY DANGEROUS : the main runloop is continuing...
            }
            @catch ( NSException *e)
            {
                NSLog( @"***** unzipFile exception: %@", e);
            }
            
            [[NSFileManager defaultManager] moveItemAtPath: tempCurFileDest toPath: curFileDest error: nil];
            
            myunlink([curFile fileSystemRepresentation]);
        }
        else
        {
            OFCondition cond;
            
            const char *fname = (const char *)[curFile UTF8String];
            
            DcmFileFormat fileformat;
            cond = fileformat.loadFile(fname);
            
            if (cond.good())
            {
                DcmXfer filexfer(fileformat.getDataset()->getOriginalXfer());
                
                if (filexfer.getXfer() == EXS_JPEG2000LosslessOnly ||
                    filexfer.getXfer() == EXS_JPEG2000)
                {
                    // USe DCMFramework
                    DCMObject *dcmObject = [[DCMObject alloc] initWithContentsOfFile: curFile decodingPixelData: NO];
                    @try
                    {
                        status = [dcmObject writeToFile:curFileDest
                                     withTransferSyntax:[DCMTransferSyntax ImplicitVRLittleEndianTransferSyntax]
                                                quality:1
                                                    AET:@OUR_AET
                                             atomically:YES];
                    }
                    @catch (NSException *e)
                    {
                        NSLog( @"dcmObject writeToFile failed: %@", e);
                    }
                    
                    [dcmObject release];
                    
                    if( status == NO)
                    {
                        myunlink([curFileDest fileSystemRepresentation]);
                        
                        if( destDirec)
                        {
                            myunlink([curFile fileSystemRepresentation]);
                            NSLog( @"failed to decompress file: %@, the file is deleted", curFile);
                        }
                        else
                            NSLog( @"failed to decompress file: %@", curFile);
                    }
                }
                else if (filexfer.getXfer() != EXS_LittleEndianExplicit ||
                         filexfer.getXfer() != EXS_LittleEndianImplicit)
                {
                    DcmDataset *dataset = fileformat.getDataset();
                    
                    delete dataset->remove( DcmTagKey( 0x0009, 0x1110)); // "GEIIS" The problematic private group, containing a *always* JPEG compressed PixelData
                    
                    // decompress data set if compressed
                    dataset->chooseRepresentation(EXS_LittleEndianExplicit, NULL);
                    
                    // check if everything went well
                    if (dataset->canWriteXfer(EXS_LittleEndianExplicit))
                    {
                        fileformat.loadAllDataIntoMemory();
                        
                        NSString *tempCurFileDest = [[curFileDest stringByDeletingLastPathComponent] stringByAppendingPathComponent: [NSString stringWithFormat: @".%@", [curFileDest lastPathComponent]]];
                        
                        myunlink([tempCurFileDest fileSystemRepresentation]);
                        myunlink([curFileDest fileSystemRepresentation]);
                        
                        cond = fileformat.saveFile( [tempCurFileDest UTF8String], EXS_LittleEndianExplicit);
                        status =  (cond.good()) ? YES : NO;
                        
                        [[NSFileManager defaultManager] moveItemAtPath: tempCurFileDest toPath: curFileDest error: nil];
                    }
                    else
                        status = NO;

                    
                    if( status == NO)
                    {
                        myunlink([curFileDest fileSystemRepresentation]);
                        
                        if( destDirec)
                        {
                            myunlink([curFile fileSystemRepresentation]);
                            NSLog( @"failed to decompress file: %@, the file is deleted", curFile);
                        }
                        else
                            NSLog( @"failed to decompress file: %@", curFile);
                    }
                }
                else
                {
                    if( destDirec)
                    {
                        myunlink([curFileDest fileSystemRepresentation]);
                        [[NSFileManager defaultManager] moveItemAtPath: curFile toPath: curFileDest error: nil];
                        myunlink([curFile fileSystemRepresentation]);
                    }
                    status = NO;
                }
            }
        }
        
        if( status)
        {
            myunlink([curFile fileSystemRepresentation]);
            if( destDirec == nil)
                [[NSFileManager defaultManager] moveItemAtPath: curFileDest toPath: curFile error: nil];
        }
    }
}

int main(int argc, const char *argv[])
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
	// To avoid:
	// http://lists.apple.com/archives/quicktime-api/2007/Aug/msg00008.html
	// _NXCreateWindow: error setting window property (1002)
	// _NXTermWindow: error releasing window (1002)
	[NSApplication sharedApplication];
    
    if (argc < 3)
        return 0;
    
    registerCodecs();

    NSString *path = [NSString stringWithUTF8String:argv[1]];
    NSString *what = [NSString stringWithUTF8String:argv[2]];
    
    NSBundle *bundle = [NSBundle bundleForClass:NSClassFromString(@"DCMPix")];
    NSString *bundleId = [[bundle infoDictionary] objectForKey:@"CFBundleIdentifier"];
    dict = [DefaultsOsiriX getDefaults];
    [dict addEntriesFromDictionary: [[NSUserDefaults standardUserDefaults] persistentDomainForName:bundleId]];
    
#if 0 // TODO
    dcmtkSetJPEGColorSpace( [[dict objectForKey:@"UseJPEGColorSpace"] intValue]);
#endif
        
	//BOOL useDCMTKForJP2K = [[dict objectForKey:@"useDCMTKForJP2K"] intValue]; // deprecated
    
    UseOpenJpeg = [[dict objectForKey:@"UseOpenJpegForJPEG2000"] intValue];
    Use_kdu_IfAvailable = [[dict objectForKey:@"UseKDUForJPEG2000"] intValue];
    //[DCMPixelDataAttribute setUse_kdu_IfAvailable: [[dict objectForKey:@"UseKDUForJPEG2000"] intValue]];

#pragma mark SettingsPlist
    if ([what isEqualToString:@"SettingsPlist"])
    {
        @try
        {
            NSString* path2 = [NSString stringWithUTF8String:argv[fileListFirstItemIndex]];
            [dict addEntriesFromDictionary:[NSMutableDictionary dictionaryWithContentsOfFile:path2]];
            what = [NSString stringWithUTF8String:argv[4]];
            fileListFirstItemIndex += 2;
        }
        @catch (NSException* e)
        { // ignore evtl failures
            NSLog(@"Decompress failed reading settings plist at %s: %@", argv[fileListFirstItemIndex], e);
        }
    }
		
    if ([what isEqualToString:@"compress"])
    {
        action_Compress(argc, argv, path);
    }
		
#pragma mark testDICOMDIR
    else if( [what isEqualToString: @"testDICOMDIR"])
    {
        NSLog( @"-- Testing DICOMDIR: %@", [NSString stringWithUTF8String: argv[ 1]]);
        
        DcmDicomDir dcmdir( [[NSString stringWithUTF8String: argv[ 1]] fileSystemRepresentation]);
        DcmDirectoryRecord& record = dcmdir.getRootRecord();
        
        for (unsigned int i = 0; i < record.card();)
        {
            DcmElement* element = record.getElement(i);
            OFString ofstr;
            element->getOFStringArray(ofstr).good();
            
            i += 10;
        }
        
        NSLog( @"-- Testing DICOMDIR done");
              
//            *(long*) 0x00 = 0xDEADBEEF;
    }
        
# pragma mark testFiles
    else if( [what isEqualToString: @"testFiles"])
    {
        for (NSInteger i = fileListFirstItemIndex; i < argc ; i++)
        {
            NSString *curFile = [NSString stringWithUTF8String: argv[ i]];
            
            // Simply try to load and generate the image... will it crash?
            
            DCMPix *dcmPix = [[DCMPix alloc] initWithPath: curFile :0 :1 :nil :0 :0 isBonjour: NO imageObj: nil];
            
            if( dcmPix)
            {
                [dcmPix CheckLoad];
                //*(long*)0 = 0xDEADBEEF; // Dead Beef ? WTF ??? Will it unlock the matrix....
                [dcmPix release];
            }
            else
                NSLog( @"dcmPix == nil");
        }
    }
    else if( [what isEqualToString:@"decompressList"])
    {
        action_Decompress(argc, argv, path);
    }
		
# pragma mark writeMovie
    else if( [what isEqualToString: @"writeMovie"])
    {
        if( ![path hasSuffix:@".swf"])
        {
            NSLog( @"******** writeMovie Decompress - not available");
        }
        else
        { // SWF!!
            NSString* inputDir = [NSString stringWithUTF8String:argv[fileListFirstItemIndex++]];
            NSArray* inputFiles = [inputDir stringsByAppendingPaths:[[NSFileManager defaultManager] contentsOfDirectoryAtPath:inputDir error:NULL]];
            
            float frameRate = 0;
            
            if( fileListFirstItemIndex < argc)
                frameRate = [[NSString stringWithUTF8String: argv[ fileListFirstItemIndex]] floatValue];
            
            createSwfMovie(inputFiles, path, frameRate);
            
            [[NSFileManager defaultManager] removeItemAtPath: inputDir error: nil];
        }
    }
				
# pragma mark pdfFromURL
    else if( [what isEqualToString: @"pdfFromURL"])
    {
        @try
        {
            WebView *webView = [[[WebView alloc] initWithFrame: NSMakeRect(0,0,1,1) frameName: @"myFrame" groupName: @"myGroup"] autorelease];
            NSWindow *w = [[[NSWindow alloc] initWithContentRect:NSMakeRect(0,0,1,1)
                                                       styleMask:NSBorderlessWindowMask
                                                         backing:NSBackingStoreNonretained
                                                           defer:NO] autorelease];
            [w setContentView:webView];
            
            WebPreferences *webPrefs = [WebPreferences standardPreferences];
            
            [webPrefs setLoadsImagesAutomatically: YES];
            [webPrefs setAllowsAnimatedImages: YES];
            [webPrefs setAllowsAnimatedImageLooping: NO];
            [webPrefs setJavaEnabled: NO];
            [webPrefs setPlugInsEnabled: NO];
            [webPrefs setJavaScriptEnabled: YES];
            [webPrefs setJavaScriptCanOpenWindowsAutomatically: NO];
            [webPrefs setShouldPrintBackgrounds: YES];
            
            [webView setApplicationNameForUserAgent: @"OsiriX"];
            [webView setPreferences: webPrefs];
            [webView setMaintainsBackForwardList: NO];
            
            NSURL *theURL = [NSURL fileURLWithPath: path];
            if( theURL)
            {
                NSURLRequest *request = [NSURLRequest requestWithURL: theURL];
                
                [[webView mainFrame] loadRequest: request];
                
                NSTimeInterval timeout = [NSDate timeIntervalSinceReferenceDate] + 10;
                
                while ([[webView mainFrame] dataSource] == nil ||
                       [[[webView mainFrame] dataSource] isLoading] == YES ||
                       [[[webView mainFrame] provisionalDataSource] isLoading] == YES)
                {
                    [[NSRunLoop currentRunLoop] runUntilDate: [NSDate dateWithTimeIntervalSinceNow: 0.1]];
                    
                    if( [NSDate timeIntervalSinceReferenceDate] > timeout)
                        break;
                }
                
                NSPrintInfo *sharedInfo = [NSPrintInfo sharedPrintInfo];
                NSMutableDictionary *sharedDict = [sharedInfo dictionary];
                NSMutableDictionary *printInfoDict = [NSMutableDictionary dictionaryWithDictionary: sharedDict];
                
                [printInfoDict setObject: NSPrintSaveJob forKey: NSPrintJobDisposition];
                
                [[NSFileManager defaultManager] removeItemAtPath: [path stringByAppendingPathExtension: @"pdf"] error: nil];
                [printInfoDict setObject: [path stringByAppendingPathExtension: @"pdf"] forKey: NSPrintSavePath];
                
                NSPrintInfo *printInfo = [[NSPrintInfo alloc] initWithDictionary: printInfoDict];
                
                [printInfo setBottomMargin: 30];
                [printInfo setTopMargin: 30];
                [printInfo setLeftMargin: 24];
                [printInfo setRightMargin: 24];
                
                [printInfo setHorizontalPagination: NSAutoPagination];
                [printInfo setVerticalPagination: NSAutoPagination];
                [printInfo setVerticallyCentered:NO];
                
                NSView *viewToPrint = [[[webView mainFrame] frameView] documentView];
                NSPrintOperation *printOp = [NSPrintOperation printOperationWithView: viewToPrint printInfo: printInfo];
                [printOp setShowsPrintPanel: NO];
                [printOp setShowsProgressPanel: NO];
                [printOp runOperation];
                
                //jf remove empty last PDF page
                @try
                {
                    NSURL *pdfURL = [theURL URLByAppendingPathExtension:@"pdf"];
                    PDFDocument *pdf = [[[PDFDocument alloc]initWithURL:pdfURL]autorelease];
                    NSUInteger pdfPageCount = [pdf pageCount];
                    if (pdfPageCount > 1)
                    {
                        NSUInteger pdfLastPageIndex = pdfPageCount - 1;
                        PDFPage *pdfLastPage = [pdf pageAtIndex:pdfLastPageIndex];
                        NSUInteger pdfLastPageCharCount = [pdfLastPage numberOfCharacters];
                        if (pdfLastPageCharCount < 2)
                        {
                            [pdf removePageAtIndex:pdfLastPageIndex];
                            [pdf writeToURL:pdfURL];
                        }
                    }
                }
                @catch ( NSException *e) {
                    N2LogException( e);
                }
            }
        }
        @catch (NSException * e)
        {
            N2LogExceptionWithStackTrace(e);
        }
        return 0;
    }
    
#ifdef WASTE_TIME_CLEANING_UP
    deregisterCodecs();
	[pool release];
#endif

	return 0;
}

void createSwfMovie(NSArray* inputFiles, NSString* path, float frameRate)
{
	if (path)
		[[NSFileManager defaultManager] removeItemAtPath:path error:NULL];
	
	Ming_init();
	Ming_setSWFCompression(9); // 9 = maximum compression
	SWFMovie* swf = new SWFMovie(7);
	swf->setBackground(0x88, 0x88, 0x88);
    
    if( frameRate < 1)
        frameRate = 10;
	swf->setRate(frameRate);
	
	BOOL sizeSet = NO;
	NSSize swfSize;
	
	NSString* as = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"SWFInit" ofType:@"as"]
                                             encoding:NSUTF8StringEncoding
                                                error:NULL];
	//NSLog(@"AS:\n%@", as);
	SWFAction* action = new SWFAction([as cStringUsingEncoding:NSISOLatin1StringEncoding]);
	//		int len, res = action->compile(7, &len);
	//	NSLog(@"compile ret:%d len:%d", res, len);
	swf->add(action);
	
	const CGFloat ControllerHeight = 14, PlayPauseWidth = 0;
	const CGFloat ControllerPadTop = 1, ControllerPadBottom = 1;
	const CGFloat MarkHeight = ControllerHeight-ControllerPadTop-ControllerPadBottom,
                  MarkWidth = MarkHeight-2;
	const CGFloat ControllerPadLeft = MarkWidth/2,
                  ControllerPadRight = MarkWidth/2+PlayPauseWidth;
	NSRect ControllerRect;
	NSRect ControllerNavigationRect;
	const CGFloat ControllerBarThickness = 2,
                  ControllerBarPadLeft = -ControllerBarThickness/2,
                  ControllerBarPadRight = -ControllerBarThickness/2;
	
	// movie controller left of mark
	SWFShape* squareS = new SWFShape();
	squareS->setRightFillStyle(SWFFillStyle::SolidFillStyle(0,0,0,0));
	squareS->movePenTo(0,0);
	squareS->drawLine(1,0);
	squareS->drawLine(0,MarkHeight);
	squareS->drawLine(-1,0);
	squareS->drawLine(0,-MarkHeight);
	SWFButton* leftBarB = new SWFButton();
	leftBarB->addShape(squareS, SWFBUTTON_HIT|SWFBUTTON_UP|SWFBUTTON_DOWN|SWFBUTTON_OVER);
	leftBarB->addAction(new SWFAction("leftBarMouseDown();"), SWFBUTTON_MOUSEDOWN);
	SWFDisplayItem* leftBarDI = swf->add(leftBarB);
	leftBarDI->setName("leftBarDI");
	// movie controller right of mark
	squareS = new SWFShape();
	squareS->setRightFillStyle(SWFFillStyle::SolidFillStyle(0,0,0,0));
	squareS->movePenTo(0,0);
	squareS->drawLine(-1,0);
	squareS->drawLine(0,MarkHeight);
	squareS->drawLine(1,0);
	squareS->drawLine(0,-MarkHeight);
	SWFButton* rightBarB = new SWFButton();
	rightBarB->addShape(squareS, SWFBUTTON_HIT|SWFBUTTON_UP|SWFBUTTON_DOWN|SWFBUTTON_OVER);
	rightBarB->addAction(new SWFAction("rightBarMouseDown();"), SWFBUTTON_MOUSEDOWN);
	SWFDisplayItem* rightBarDI = swf->add(rightBarB);
	rightBarDI->setName("rightBarDI");
	
	// movie controller mark
	SWFShape* markS = new SWFShape();
	markS->setRightFillStyle(SWFFillStyle::SolidFillStyle(64,64,64,191));
	markS->movePenTo(-MarkWidth/2, -MarkHeight/2);
	markS->drawLine(MarkWidth,0);
	markS->drawLine(0,MarkHeight);
	markS->drawLine(-MarkWidth,0);
	markS->drawLine(0,-MarkHeight);
	SWFButton* markB = new SWFButton();
	markB->addShape(markS, SWFBUTTON_HIT|SWFBUTTON_UP|SWFBUTTON_DOWN|SWFBUTTON_OVER);
	markB->addAction(new SWFAction("markMouseDown();"), SWFBUTTON_MOUSEDOWN);
	SWFDisplayItem* markDI = swf->add(markB);
	markDI->setName("markDI");
	
	SWFBitmap* bitmap[inputFiles.count];
	SWFDisplayItem* displayItem[inputFiles.count];
//#pragma omp parallel for default(private)				
	for (int i = 0; i < inputFiles.count; ++i)
    {
		NSString* imgPath = [inputFiles objectAtIndex:i];
//		NSLog(@"%@", imgPath);
		
		bitmap[i] = new SWFBitmap(imgPath.UTF8String, NULL);
		if (!bitmap[i])
			NSLog(@"SWF creation FAILED: could not read %@", imgPath);
        
		NSSize bitmapSize = NSMakeSize(bitmap[i]->getWidth(),
                                       bitmap[i]->getHeight());
		
		if (!sizeSet) {
			swfSize = NSMakeSize(bitmapSize.width,
                                 bitmapSize.height+ControllerHeight);
			swf->setDimension(swfSize.width, swfSize.height);
			sizeSet = YES;
		}
		
		SWFShape* shape = new SWFShape();
		shape->setRightFillStyle(SWFFillStyle::BitmapFillStyle(bitmap[i], SWFFILL_CLIPPED_BITMAP));
		shape->drawLine(bitmapSize.width,0);
		shape->drawLine(0,bitmapSize.height);
		shape->drawLine(-bitmapSize.width,0);
		shape->drawLine(0,-bitmapSize.height);
		
		displayItem[i] = swf->add(shape);
		displayItem[i]->moveTo(0,0);
		displayItem[i]->scaleTo(0);
	}
	
	// controller
	
	ControllerRect = NSMakeRect(0, swfSize.height-ControllerHeight, swfSize.width, ControllerHeight);
	ControllerNavigationRect = NSMakeRect(ControllerRect.origin.x+ControllerPadLeft,
                                          ControllerRect.origin.y+ControllerPadTop,
                                          ControllerRect.size.width-ControllerPadLeft-ControllerPadRight,
                                          ControllerRect.size.height-ControllerPadTop-ControllerPadBottom);
	swf->add(new SWFAction([[NSString stringWithFormat:@"_root.ControllerOriginX = %f; _root.ControllerWidth = %f;", ControllerNavigationRect.origin.x, ControllerNavigationRect.size.width] cStringUsingEncoding:NSISOLatin1StringEncoding]));
	NSRect ControllerBarRect = NSMakeRect(ControllerNavigationRect.origin.x+ControllerBarPadLeft,
                                          (ControllerNavigationRect.origin.y*2+ControllerNavigationRect.size.height-ControllerBarThickness)/2,
                                          ControllerNavigationRect.size.width-ControllerBarPadLeft-ControllerBarPadRight,
                                          ControllerBarThickness);
	
	SWFShape* controllerBar = new SWFShape();
	controllerBar->setRightFillStyle(SWFFillStyle::SolidFillStyle(191,191,191,127));
	controllerBar->movePenTo(0, 0);
	controllerBar->drawLine(1,0);
	controllerBar->drawLine(0,1);
	controllerBar->drawLine(-1,0);
	controllerBar->drawLine(0,-1);
	controllerBar->setRightFillStyle(SWFFillStyle::SolidFillStyle(191,191,191,127));
	SWFDisplayItem* controllerBarDisplayItem = swf->add(controllerBar);
	controllerBarDisplayItem->moveTo(ControllerBarRect.origin.x, ControllerBarRect.origin.y);
	controllerBarDisplayItem->scaleTo(ControllerBarRect.size.width, ControllerBarRect.size.height);	

    // Click in image to play/stop
    SWFShape* button = new SWFShape();
    button->setRightFillStyle(SWFFillStyle::SolidFillStyle(0,50,0,0));
    button->drawLine(swfSize.width,0);
    button->drawLine(0,swfSize.height-ControllerHeight);
    button->drawLine(-swfSize.width,0);
    button->drawLine(0,-swfSize.height-ControllerHeight);
    
    SWFButton* playStop = new SWFButton();
	playStop->addShape( button, SWFBUTTON_HIT|SWFBUTTON_UP|SWFBUTTON_DOWN|SWFBUTTON_OVER);
	playStop->addAction(new SWFAction("if( playing == 1) playing = 0; else playing = 1; if( playing) play(); else stop();"), SWFBUTTON_MOUSEDOWN);
    SWFDisplayItem* playItemDI = swf->add(playStop);
    playItemDI->setName("playItemDI");
    playItemDI->moveTo(0, 0);
    
	// animation
	
	for (int i = 0; i < inputFiles.count; ++i)
    {
		markDI->moveTo(ControllerNavigationRect.origin.x+ControllerNavigationRect.size.width/((long)inputFiles.count-1)*i,
                       ControllerNavigationRect.origin.y+ControllerNavigationRect.size.height/2);
        
		leftBarDI->scaleTo(ControllerNavigationRect.size.width/((long)inputFiles.count-1)*i,
                           1);
        
		leftBarDI->moveTo(ControllerNavigationRect.origin.x,
                          ControllerNavigationRect.origin.y);
        
		rightBarDI->scaleTo(ControllerNavigationRect.size.width/((long)inputFiles.count-1)*((long)inputFiles.count-1-i),
                            1);
        
		rightBarDI->moveTo(ControllerNavigationRect.origin.x+ControllerNavigationRect.size.width,
                           ControllerNavigationRect.origin.y);
		
		for (int d = MAX(0,i-1); d < MIN(inputFiles.count,i+1); ++d)
			if (d == i)
				displayItem[d]->scaleTo(1);
			else
                displayItem[d]->scaleTo(0);
		
		swf->nextFrame();
	}
	
	swf->save(path.UTF8String);
	
	for (int i = 0; i < inputFiles.count; ++i)
		delete bitmap[i];
	
	delete swf;
	Ming_cleanup();	
}
