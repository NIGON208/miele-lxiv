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

/*
The idea is that as bugs are fixed the unit tests should be updated to exercise the fixed routine(s)
to prove that they stay fixed with future modifications.

Testable units are within OsiriX rather than its frameworks, eg DCMFramework.
This testing framework is linked with the Development product.
*/

#import "UnitTestingBase.h"

//#import "Point3D.h"
#import "dicomData.h"
#import "DicomStudy.h"
#import "AppController.h"
#import "BrowserController.h"

@implementation UnitTestingBase

#pragma mark -

- (void) testDicomData
{
	dicomData *aDicomData, *aParentData;
	NSMutableArray *aParentArray, *aChildArray;
	
    // Test initialisation of dicomData.
	
	aDicomData=[[[dicomData alloc] init] autorelease];
    XCTAssertNotNil(aDicomData);
	XCTAssertNil([aDicomData group]);
	XCTAssertNil([aDicomData tagName]);
	XCTAssertNil([aDicomData name]);
	XCTAssertNil([aDicomData content]);
	XCTAssertNil([aDicomData parent]);
	XCTAssertNil([aDicomData child]);
	XCTAssertNil([aDicomData parentData]);

    // Test setters and getters.
	
	[aDicomData setGroup: @"Test Group Name"];
    XCTAssertEqual([aDicomData group], @"Test Group Name");
    
	[aDicomData setTagName: @"Test Tag Name"];
    XCTAssertEqual([aDicomData tagName], @"Test Tag Name");
    
	[aDicomData setName: @"Test Name"];
    XCTAssertEqual([aDicomData name], @"Test Name");
    
	[aDicomData setContent: @"Test Content"];
    XCTAssertEqual([aDicomData content], @"Test Content");
	
	aParentArray=[NSMutableArray array];
    XCTAssertNotNil(aParentArray);
    
	[aDicomData setParent: aParentArray];
    XCTAssertEqualObjects([aDicomData parent], aParentArray);
    
	aChildArray=[NSMutableArray array];
    XCTAssertNotNil(aChildArray);
    
	[aDicomData setChild: aChildArray];
    XCTAssertEqualObjects([aDicomData child], aChildArray);
	
	aParentData=[[[dicomData alloc] init] autorelease];
	[aDicomData setParentData: aParentData];
	XCTAssertEqualObjects([aDicomData parentData], aParentData);
}

#pragma mark -

- (void) testEndoscopyViewerInitialisation
{
    // Check the app controller is valid.
	AppController *ac = [AppController sharedAppController];
	XCTAssertNotNil(ac);

    // Get the current browser and check it's valid.
	BrowserController *bc = [BrowserController currentBrowser];
	XCTAssertNotNil([BrowserController currentBrowser]);

    // Open selected series.
	[bc newViewerDICOM: Nil];

    // Open the endoscopy viewer.
	[self performSelector: @selector(openAViewer:) withObject: Nil afterDelay: 4];

    // Close all viewers.
	[ac closeAllViewers: Nil];
}

- (void) openAViewer: (id) i
{
    // Open the endoscopy viewer.
	NSWindow *win = [NSApp mainWindow];
	XCTAssertNotNil(win);
//	[NSApp sendAction: @selector(MPR2DViewer:) to: [win windowController] from: self];
	[NSApp sendAction: @selector(endoscopyViewer:) to: [win windowController] from: self];
}

#pragma mark -

- (void) testCLUTMenuLoaded
{
    NSMenu *mainMenu = [NSApp mainMenu];
    XCTAssertNotNil(mainMenu);
    
    NSMenu *viewerMenu = [[mainMenu itemWithTitle:NSLocalizedString(@"2D Viewer", nil)] submenu];
    XCTAssertNotNil(viewerMenu);
    
    NSMenu *clutMenu = [[viewerMenu itemWithTitle:NSLocalizedString(@"Color Look Up Table", nil)] submenu];
    XCTAssertNotNil(clutMenu, @"Check localized strings for 'color look up table' are correct");
}

@end
