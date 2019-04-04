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
  Distributed under GNU - GPL
  
  See http://www.osirix-viewer.com/copyright.html for details.

     This software is distributed WITHOUT ANY WARRANTY; without even
     the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
     PURPOSE.
=========================================================================*/

#import "ServerTableView.h"
#import <DNDArrayController.h>
#import "OSILocationsPreferencePanePref.h"

@implementation ServerTableView

- (NSDragOperation)draggingSession:(NSDraggingSession *)session sourceOperationMaskForDraggingContext:(NSDraggingContext)context
{
    if (context == NSDraggingContextOutsideApplication) {
        // link for external dragged URLs
        return NSDragOperationLink; // The data can be shared.
    }
    
    return [super draggingSession:session sourceOperationMaskForDraggingContext:context];
}

- (void) keyDown: (NSEvent *) event
{
    if ([[event characters] length] == 0)
        return;
    
	unichar c = [[event characters] characterAtIndex:0];
	
	if (( c == NSDeleteFunctionKey || c == NSDeleteCharacter || c == NSBackspaceCharacter || c == NSDeleteCharFunctionKey) &&
        [self selectedRow] >= 0 &&
        [self numberOfRows] > 0)
	{
		[(DNDArrayController*)[self delegate] deleteSelectedRow:self];
	}
	else
		[super keyDown:event];
}

@end
