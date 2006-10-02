//
//  LLScoutViewer.m
//  OsiriX
//
//  Created by Joris Heuberger on 18/05/06.
//  Copyright 2006 HUG. All rights reserved.
//

#import "LLScoutViewer.h"
#import "LLScoutView.h"
#import "LLScoutOrthogonalReslice.h"

#import "LLMPRViewer.h"

@implementation LLScoutViewer

+ (BOOL)haveSamePixelSpacing:(NSArray*)pixA :(NSArray*)pixB;
{
	float pixSpacingAx = [[pixA objectAtIndex:0] pixelSpacingX];
	float pixSpacingAy = [[pixA objectAtIndex:0] pixelSpacingY];
	float pixSpacingBx = [[pixB objectAtIndex:0] pixelSpacingX];
	float pixSpacingBy = [[pixB objectAtIndex:0] pixelSpacingY];
	
	return ((pixSpacingAx == pixSpacingBx) && (pixSpacingAy == pixSpacingBy));
}

+ (BOOL)haveSameImagesCount:(NSArray*)pixA :(NSArray*)pixB;
{
	int imageCountA = [pixA count];
	int imageCountB = [pixB count];
	
	return (imageCountA == imageCountB);
}

+ (BOOL)haveSameImagesLocations:(NSArray*)pixA :(NSArray*)pixB;
{
	BOOL sameLocations = YES;
	int i;
	
	for(i=0; i<[pixA count]; i++)
	{
		sameLocations = sameLocations && ([[pixA objectAtIndex:i] sliceLocation] == [[pixB objectAtIndex:i] sliceLocation]);
	}
	
	return sameLocations;
}

+ (BOOL)verifyRequiredConditions:(NSArray*)pixA :(NSArray*)pixB;
{
	NSMutableString *alertMessage = [NSMutableString stringWithString:@"The two series must have:"];
	
	BOOL samePixelSpacing, sameImagesCount, sameImagesLocations=NO;
	samePixelSpacing = [LLScoutViewer haveSamePixelSpacing:pixA :pixB];
	sameImagesCount = [LLScoutViewer haveSameImagesCount:pixA :pixB];
		
	if(!samePixelSpacing)
		[alertMessage appendString:@"\n - the same pixels spacing"];
	
	if(!sameImagesCount)
		[alertMessage appendString:@"\n - the same number of images"];
	else
	{
		sameImagesLocations = [LLScoutViewer haveSameImagesLocations:pixA :pixB];
		if(!sameImagesLocations)
			[alertMessage appendString:@"\n - the same location for each image"];
	}
		
	NSRunAlertPanel(NSLocalizedString(@"Error", nil), NSLocalizedString(alertMessage, nil), NSLocalizedString(@"OK", nil), nil, nil);
	
	return samePixelSpacing && sameImagesCount && sameImagesLocations;
}

- (id)initWithPixList: (NSMutableArray*) pix :(NSArray*) files :(NSData*) vData :(ViewerController*) vC :(ViewerController*) bC;
{
	[super initWithWindowNibName:@"LLScoutView"];
	[[self window] setDelegate:self];
	[[self window] setShowsResizeIndicator:NO];
		
	// initialisations
	dcmPixList = [pix retain];
	dcmFileList = [files retain];

	[mprController initWithPixList: pix : files : vData : vC : bC: self];
	
	//[[mprController xReslicedView] adjustWLWW:400 :1200];
//	[[NSNotificationCenter defaultCenter] removeObserver:mprController name: @"changeWLWW" object: nil];
//	[[NSNotificationCenter defaultCenter] removeObserver:[mprController originalView] name: @"changeWLWW" object: nil];
//	[[NSNotificationCenter defaultCenter] removeObserver:[mprController xReslicedView] name: @"changeWLWW" object: nil];
//	[[NSNotificationCenter defaultCenter] removeObserver:[mprController yReslicedView] name: @"changeWLWW" object: nil];
	
	LLScoutOrthogonalReslice *reslicer = [[LLScoutOrthogonalReslice alloc] initWithOriginalDCMPixList: pix];
	[mprController setReslicer:reslicer];
	[reslicer release];
	[(LLScoutView*)[mprController xReslicedView] setIsFlipped: [[vC imageView] flippedData]];

	viewer = vC;
	blendingViewer = bC;

	[[NSNotificationCenter defaultCenter] removeObserver:self name: @"UpdateWLWWMenu" object: nil];	
	[[NSNotificationCenter defaultCenter] removeObserver:mprController name: @"UpdateWLWWMenu" object: nil];
	[[NSNotificationCenter defaultCenter] removeObserver:[mprController originalView] name: @"UpdateWLWWMenu" object: nil];
	[[NSNotificationCenter defaultCenter] removeObserver:[mprController xReslicedView] name: @"UpdateWLWWMenu" object: nil];
	[[NSNotificationCenter defaultCenter] removeObserver:[mprController yReslicedView] name: @"UpdateWLWWMenu" object: nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(CloseViewerNotification:) name:@"CloseViewerNotification" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(CloseMPRViewerNotification:) name:@"NSWindowWillCloseNotification" object:nil];
	
	return self;
}

-(void)dealloc
{
	NSLog(@"Scout Viewer dealloc");
//	if(mprViewerTop)[mprViewerTop release];
//	if(mprVieweMiddle)[mprVieweMiddle release];
//	if(mprViewerBottom)[mprViewerBottom release];

	[dcmPixList release];
	[dcmFileList release];
	[super dealloc];
}

- (void)windowWillClose:(NSNotification *)aNotification
{
//	if(mprViewerTop)[[mprViewerTop window] close];
//	if(mprVieweMiddle)[[mprVieweMiddle window] close];
//	if(mprViewerBottom)[[mprViewerBottom window] close];

	NSWindow *w;
	if(mprViewerTop)
	{
		w = [mprViewerTop window];
		[mprViewerTop release];
		mprViewerTop = 0L;
		[w close];
	}
	if(mprVieweMiddle)
	{
		w = [mprVieweMiddle window];
		[mprVieweMiddle release];
		mprVieweMiddle = 0L;
		[w close];
	}
	if(mprViewerBottom)
	{
		w = [mprViewerBottom window];
		[mprViewerBottom release];
		mprViewerBottom = 0L;
		[w close];
	}

	[self release];
}

- (IBAction) showWindow:(id)sender
{
	NSRect screenRect = [[[self window] screen] frame];
	NSRect windowRect = [[self window] frame];
	windowRect.size.height = screenRect.size.height;
	windowRect.origin.x = 0;
	[[self window] setFrame:windowRect display:YES animate:NO];
	
	[super showWindow:sender];
	
	[mprController showViews:sender];
	[mprController setThickSlabMode:2];
	[mprController setThickSlab:[[[mprController originalDCMPixList] objectAtIndex:0] pheight]/8.0*([[[mprController originalDCMPixList] objectAtIndex:0] pixelSpacingY]/[[[mprController originalDCMPixList] objectAtIndex:0] sliceInterval])];
	[[mprController xReslicedView] setCurrentTool:tWL];
	[[mprController xReslicedView] scaleToFit];
	[mprController setWLWW:400 :1200];
	
	[[mprController originalView] setFusion:0 :1];
	[[mprController originalView] setThickSlabXY:0 :0];
	
	[self setTopLimit:(int)[dcmPixList count]*0.66 bottomLimit:(int)[dcmPixList count]*0.33];
}

- (BOOL)is2DViewer;
{
	return NO;
}

- (void)setTopLimit:(int)top bottomLimit:(int)bottom;
{
	NSLog(@"setTopLimit:%d bottomLimit:%d", top, bottom);
	
	int newTopLimit, newBottomLimit;
	
//	if([self isStackUpsideDown])
//	{
//		newTopLimit = [dcmPixList count] - top;
//		newBottomLimit = [dcmPixList count] - bottom;
//	}
//	else
//	{
		newTopLimit = top;
		newBottomLimit = bottom;
//	}
	
	BOOL topChanged = newTopLimit != topLimit;
	BOOL bottomChanged = newBottomLimit != bottomLimit;
	
	if(topChanged)
	{
		topLimit = newTopLimit;
		[(LLScoutView*)[mprController xReslicedView] setTopLimit:topLimit];
		[[mprController xReslicedView] setNeedsDisplay:YES];
	}
	if(bottomChanged)
	{
		bottomLimit = newBottomLimit;
		[(LLScoutView*)[mprController xReslicedView] setBottomLimit:bottomLimit];
		[[mprController xReslicedView] setNeedsDisplay:YES];
	}
	
	NSWindow *w;
	if(mprViewerTop && topChanged)
	{
		w = [mprViewerTop window];
		[mprViewerTop release];
		mprViewerTop = 0L;
		[w close];
	}
	if(mprVieweMiddle && (topChanged || bottomChanged))
	{
		w = [mprVieweMiddle window];
		[mprVieweMiddle release];
		mprVieweMiddle = 0L;
		[w close];
	}
	if(mprViewerBottom && bottomChanged)
	{
		w = [mprViewerBottom window];
		[mprViewerBottom release];
		mprViewerBottom = 0L;
		[w close];
	}
}

- (void)displayMPR:(int)index;
{
	NSRange pixRange;
	LLMPRViewer *llViewer;
	
	NSLog(@"topLimit: %d, bottomLimit: %d",topLimit, bottomLimit);
	NSLog(@"[[mprController originalDCMPixList] count]: %d",[[mprController originalDCMPixList] count]);
	NSLog(@"[dcmPixList count]: %d",[dcmPixList count]);
	NSLog(@"index: %d",index);

	if([self isStackUpsideDown])
		NSLog(@"isStackUpsideDown : YES");
	else
		NSLog(@"isStackUpsideDown : NO");

	if(index==0)
	{
		if([[viewer imageView] flippedData])
		{
			pixRange.location = topLimit;
			pixRange.length = [dcmPixList count] - topLimit;
		}
		else if([self isStackUpsideDown])
		{
//			pixRange.location = topLimit;
//			pixRange.length = [[mprController originalDCMPixList] count] - topLimit;
			pixRange.location = [dcmPixList count] - topLimit;
			pixRange.length = topLimit - bottomLimit;
		}
		else
		{
			pixRange.location = 0;
			pixRange.length = topLimit;
		}
		llViewer = mprViewerTop;
	}
	else if(index==1)
	{
		if([[viewer imageView] flippedData])
		{
			pixRange.location = bottomLimit;
			pixRange.length = topLimit - bottomLimit;
		}
		else if([self isStackUpsideDown])
		{
//			pixRange.location = bottomLimit;
//			pixRange.length = topLimit - bottomLimit;
			pixRange.location = [dcmPixList count] - bottomLimit; //topLimit;
			pixRange.length = bottomLimit; //[dcmPixList count] - topLimit;
		}
		else
		{
			pixRange.location = topLimit;
			pixRange.length = bottomLimit - topLimit;
		}
		llViewer = mprVieweMiddle;
	}
	else
	{
		if([[viewer imageView] flippedData])
		{
			pixRange.location = 0;
			pixRange.length = bottomLimit;
		}
		else if([self isStackUpsideDown])
		{
//			pixRange.location = 0;
//			pixRange.length = bottomLimit;
			pixRange.location = 0;
			pixRange.length = [dcmPixList count] - topLimit;
		}
		else
		{
			pixRange.location = bottomLimit;
			pixRange.length = [[mprController originalDCMPixList] count] - bottomLimit;
		}
		llViewer = mprViewerBottom;
	}

	NSArray *originalPix, *injectedPix, *originalFiles;
	NSLog(@"pixRange.location: %d, pixRange.length: %d",pixRange.location, pixRange.length);
	originalPix = [dcmPixList subarrayWithRange:pixRange];
	injectedPix = [[blendingViewer pixList:0] subarrayWithRange:pixRange];
	originalFiles = [dcmFileList subarrayWithRange:pixRange];

	if(llViewer)
	{	
		NSWindow *w = [llViewer window];
		//[llViewer release];
 		//llViewer = 0L;
		[w close];	
		llViewer = 0L;
	}
	
	if(mprViewerTop)
	{	
		NSWindow *w = [mprViewerTop window];
		[w close];	
		mprViewerTop = 0L;
	}
	if(mprVieweMiddle)
	{	
		NSWindow *w = [mprVieweMiddle window];
		[w close];	
		mprVieweMiddle = 0L;
	}
	if(mprViewerBottom)
	{	
		NSWindow *w = [mprViewerBottom window];
		[w close];	
		mprViewerBottom = 0L;
	}	
	
	if(index==0)
	{
		mprViewerTop = [[LLMPRViewer alloc] initWithPixList:originalPix :injectedPix :originalFiles :nil :viewer :blendingViewer :self];
		llViewer = mprViewerTop;
	}
	else if(index==1)
	{
		mprVieweMiddle = [[LLMPRViewer alloc] initWithPixList:originalPix :injectedPix :originalFiles :nil :viewer :blendingViewer :self];
		llViewer = mprVieweMiddle;
	}
	else
	{
		mprViewerBottom = [[LLMPRViewer alloc] initWithPixList:originalPix :injectedPix :originalFiles :nil :viewer :blendingViewer :self];
		llViewer = mprViewerBottom;
	}
	float wl, ww;
	[[mprController xReslicedView] getWLWW:&wl :&ww];

	//[llViewer retain];
	[llViewer setPixListRange:pixRange];
	[llViewer showWindow:self];
	[llViewer setWLWW:wl :ww];
}

- (void)toggleDisplayResliceAxes;{}
- (void)blendingPropagateOriginal:(OrthogonalMPRView*)sender;{}
- (void)blendingPropagateX:(OrthogonalMPRView*)sender;{}
- (void)blendingPropagateY:(OrthogonalMPRView*)sender;{}

- (void)CloseViewerNotification:(NSNotification*)note;
{
	ViewerController *v = [note object];
	
	if([v pixList] == [mprController originalDCMPixList])
	{
		[[self window] performClose: self];
		return;
	}
}

- (void)CloseMPRViewerNotification:(NSNotification*)note;
{
	//NSLog(@"CloseMPRViewerNotification");
	if(mprViewerTop)
	{
	//NSLog(@"mprViewerTop");
		if([[note object] isEqual:[mprViewerTop window]])
		{
		//NSLog(@"window");
			[mprViewerTop release];
			mprViewerTop = nil;
			return;
		}
	}
	if(mprVieweMiddle)
	{
	//NSLog(@"mprVieweMiddle");
		if([[note object] isEqual:[mprVieweMiddle window]])
		{
		//NSLog(@"window");
			[mprVieweMiddle release];
			mprVieweMiddle = nil;
			return;
		}
	}
	if(mprViewerBottom)
	{
	//NSLog(@"mprViewerBottom");
		if([[note object] isEqual:[mprViewerBottom window]])
		{
		//NSLog(@"window");
			[mprViewerBottom release];
			mprViewerBottom = nil;
			return;
		}
	}	
}

- (BOOL)isStackUpsideDown;
{
	NSLog(@"- (BOOL)isStackUpsideDown;");
	NSLog(@"[[dcmPixList objectAtIndex:0] sliceLocation] : %f", [[dcmPixList objectAtIndex:0] sliceLocation]);
	NSLog(@"[[dcmPixList objectAtIndex:1] sliceLocation] : %f", [[dcmPixList objectAtIndex:1] sliceLocation]);
	
	//if(![[viewer imageView] flippedData])
		return ([[dcmPixList objectAtIndex:0] sliceLocation] - [[dcmPixList objectAtIndex:1] sliceLocation] < 0);
	//else
	//	return ([[dcmPixList objectAtIndex:0] sliceLocation] - [[dcmPixList objectAtIndex:1] sliceLocation] > 0);
}

@end
