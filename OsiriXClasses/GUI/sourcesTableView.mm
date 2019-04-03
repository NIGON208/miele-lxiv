//
//  ©Alex Bettarini -- all rights reserved
//  License GPLv3.0 -- see License File
//
//  At the end of 2014 the project was forked from OsiriX to become Miele-LXIV
//  The original version of this file had no header

#import "sourcesTableView.h"


@implementation sourcesTableView


- (NSDragOperation)draggingSourceOperationMaskForLocal:(BOOL)flag
{
	if (!flag) {
		// link for external dragged URLs
		return NSDragOperationLink;
	}
	return [super draggingSourceOperationMaskForLocal:flag];
}

@end
