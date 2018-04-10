#import <Foundation/Foundation.h>
#import "DCM Framework/DCMObject.h"
#import "DCM Framework/DCMTransferSyntax.h"

#include "AYDcmPrintSCU.h"

int main(int argc, const char *argv[])
{
	NSAutoreleasePool	*pool	= [[NSAutoreleasePool alloc] init];
	int status = -1;
	
	//	argv[ 1] : logPath
	//	argv[ 2] : baseName
	//	argv[ 3] : xmlPath
	
	NSLog(@"DICOM Print Process Start");
	
	if( argv[ 1] && argv[ 2] && argv[ 3])
	{
		// send printjob
		AYDcmPrintSCU printSCU = AYDcmPrintSCU( argv[ 1], 0, argv[ 2]);
		
		status = printSCU.sendPrintjob( argv[ 3]);
	}

	NSLog(@"DICOM Print Process End");
	
	[pool release];
	
	return status;
}
