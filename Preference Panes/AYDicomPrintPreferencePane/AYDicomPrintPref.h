//
//  ©Alex Bettarini -- all rights reserved
//  License GPLv3.0 -- see License File
//
//  At the end of 2014 the project was forked from OsiriX to become Miele-LXIV
//  The original header follows:

//
//  AYDicomPrintPref.h
//  AYDicomPrint
//
//  Created by Tobias Hoehmann on 12.06.06.
//  Copyright (c) 2006 aycan digitalsysteme gmbh. All rights reserved.
//

#import <PreferencePanes/PreferencePanes.h>

@interface AYDicomPrintPref : NSPreferencePane 
{
	NSArray *m_PrinterDefaults;
	IBOutlet NSArrayController *m_PrinterController;
	IBOutlet NSWindow *mainWindow;
}

- (IBAction) addPrinter: (id) sender;
- (IBAction) setDefaultPrinter: (id) sender;

- (IBAction) loadList: (id) sender;
- (IBAction) saveList: (id) sender;

@end
