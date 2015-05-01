//
//  ROI3DSettingsWindow.h
//  OsiriX_Lion
//
//  Created by Alex Bettarini on 4/6/15.
//  Copyright (c) 2015 OsiriX Team. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ROI3DSettingsWindow : NSWindowController <NSPopoverDelegate>
{
    NSString *minimumBallROIIsoContourPercentage,
    *maximumBallROIIsoContourPercentage;
    BOOL definedMaximumForBallROIIsoContour;
    
    BOOL definedMaximumForBallROIIsoContourPercentage;
    NSString *computeIsoContour;
    NSColor *peakValueColor;
    
    NSString *minimumBallROIIsoContour,
    *maximumBallROIIsoContour;
    float minValueOfSeries, maxValueOfSeries;
    
    int percentageIsoContour;
    
    float peakDiameterInMm;
    
    NSPopover *popoverIso;
    NSPopover *popoverPeak;    
}

@property (assign) IBOutlet NSPopover *popoverIso;
@property (assign) IBOutlet NSPopover *popoverPeak;

-(void)computePeakValue:(id)sender;
-(void)computeIsoContour:(id)sender;
-(IBAction)togglePopover:(id)sender;

@end
