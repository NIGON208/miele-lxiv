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

#import <PreferencePanes/PreferencePanes.h>

@interface OSIWebSharingPreferencePanePref : NSPreferencePane 
{
	IBOutlet NSArrayController *studiesArrayController, *userArrayController;
	
	NSString *TLSAuthenticationCertificate;
	IBOutlet NSButton *TLSChooseCertificateButton, *TLSCertificateButton;
	
	IBOutlet NSTextField* addressTextField;
	IBOutlet NSTextField* portTextField;
	
	IBOutlet NSPanel* usersPanel;
	
	IBOutlet NSWindow* mainWindow;
	
	IBOutlet NSTableView* usersTable;
}
@property (retain) NSString *TLSAuthenticationCertificate;

- (void) mainViewDidLoad;
- (IBAction) openKeyChainAccess:(id) sender;
- (IBAction) smartAlbumHelpButton: (id) sender;
- (IBAction) chooseTLSCertificate: (id) sender;
- (IBAction) viewTLSCertificate: (id) sender;
- (IBAction) copyMissingCustomizedFiles: (id) sender;
- (IBAction) editUsers: (id) sender;
- (IBAction) exitEditUsers: (id) sender;

@end
