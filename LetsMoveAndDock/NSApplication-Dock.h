//
//  ©Alex Bettarini -- all rights reserved
//  License GPLv3.0 -- see License File
//
//  At the end of 2014 the project was forked from OsiriX to become Miele-LXIV
//  The original header follows:

////////////////////////////////////////////
//
//	Matt Brewer
//	December 1, 2009
//
//	matt@matt-brewer.com
//	http://www.matt-brewer.com
//
//
//	This code is released as is
//	with NO warranty, implied or otherwise.
//
////////////////////////////////////////////

#import <AppKit/AppKit.h>

@interface NSApplication (Dock)

- (BOOL)addApplicationToDock;
- (BOOL)applicationExistsInDock;

- (BOOL)addApplicationToDock:(NSString*)path;
- (BOOL)applicationExistsInDock:(NSString*)path;

@end
