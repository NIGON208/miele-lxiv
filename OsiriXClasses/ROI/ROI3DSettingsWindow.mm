//
//  ROI3DSettingsWindow.m
//  OsiriX_Lion
//
//  Created by Alex Bettarini on 4/6/15.
//  Copyright (c) 2015 OsiriX Team. All rights reserved.
//

#import "ROI3DSettingsWindow.h"

@interface ROI3DSettingsWindow ()

@end

@implementation ROI3DSettingsWindow

@synthesize popoverIso, popoverPeak;
@synthesize helpIso, helpPeak;

- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    popover = nil;
}

// sender class is NSButton
-(IBAction)togglePopover:(id)sender
{
    if (popover) {
        [popover performClose:sender];
        popover = nil;
        return;
    }
    
    if (sender == helpIso)
        popover = popoverIso;
    else if (sender == helpPeak)
        popover = popoverPeak;
    else
        return;

    [popover showRelativeToRect:[sender bounds]
                         ofView:sender
                  preferredEdge:NSMaxYEdge];
}

-(void)computePeakValue:(id)sender
{
    
}

-(void)computeIsoContour:(id)sender
{
    
}

// sender class is NSSlider
-(IBAction)peakDiameterSliderAction:(id) sender
{
    [[NSUserDefaults standardUserDefaults] setFloat:[sender floatValue] forKey:@"peakDiameterInMm"];
}

@end
