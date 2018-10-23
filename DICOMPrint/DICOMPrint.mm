#define NEW_DICOM_PRINT_UTILITY

#import <Foundation/Foundation.h>

#ifndef NEW_DICOM_PRINT_UTILITY
#import <DCM/DCMObject.h>
#import <DCM/DCMTransferSyntax.h>
#include "AYDcmPrintSCU.h"
#endif

int main(int argc, const char *argv[])
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	int status = EXIT_SUCCESS;
	
	NSLog(@"DICOM Print Process Start");

#ifdef NEW_DICOM_PRINT_UTILITY
    //    argv[ 1] : logPath
    //    argv[ 2] : baseName
    //    argv[ 3] : jsonPath

    NSError *error = nil;
    NSString *jsonStr = [NSString stringWithContentsOfFile:@(argv[3])
                                                  encoding:NSUTF8StringEncoding
                                                     error:&error];
    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:[jsonStr dataUsingEncoding:NSUTF8StringEncoding]
                                                             options:NSJSONReadingMutableContainers
                                                               error:&error];
    //NSDictionary *filmboxDict = [jsonDict valueForKeyPath:@"association.filmsession.filmbox"];
    //NSLog(@"filmboxDict: %@", filmboxDict);

    NSString *image_file = [jsonDict valueForKeyPath:@"association.filmsession.filmbox.imagebox.image_file"];
    NSLog(@"TODO: print file: %@", image_file);
    
    // TODO: launch dcmprscu
#else
    //    argv[ 1] : logPath
    //    argv[ 2] : baseName
    //    argv[ 3] : xmlPath
	if( argv[ 1] && argv[ 2] && argv[ 3])
	{
		// send printjob
		AYDcmPrintSCU printSCU = AYDcmPrintSCU( argv[ 1], 0, argv[ 2]);
		
		status = printSCU.sendPrintjob( argv[ 3]);
	}
#endif

	NSLog(@"DICOM Print Process End");
	
	[pool release];
	return status;
}
