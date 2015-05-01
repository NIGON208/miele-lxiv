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

- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

-(IBAction)togglePopover:(id)sender
{
    NSPopover * popover = (NSPopover *)sender;
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

@end
