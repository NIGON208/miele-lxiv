//
//  ROI3DSettingsWindow.h
//  Miele_LXIV
//
//  ©Alex Bettarini -- all rights reserved
//  License GPLv3.0 -- see License File
//  Created by Alex Bettarini on 4/6/15

#import <Cocoa/Cocoa.h>

@interface ROI3DSettingsWindow : NSWindowController //<NSPopoverDelegate>
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
    NSPopover *popover;
    NSButton *helpIso;
    NSButton *helpPeak;
}

@property (assign) IBOutlet NSPopover *popoverIso;
@property (assign) IBOutlet NSPopover *popoverPeak;
@property (assign) IBOutlet NSButton *helpIso;
@property (assign) IBOutlet NSButton *helpPeak;

-(void)computePeakValue:(id)sender;
-(void)computeIsoContour:(id)sender;
-(IBAction)togglePopover:(id)sender;
-(IBAction)peakDiameterSliderAction:(id) sender;

@end
