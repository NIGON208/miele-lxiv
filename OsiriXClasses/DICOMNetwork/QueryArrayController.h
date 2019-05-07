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

#import <Cocoa/Cocoa.h>

@class DCMTKRootQueryNode;

/** \brief Controller for performing query */
@interface QueryArrayController : NSObject
{
	DCMTKRootQueryNode *rootNode;
	NSMutableDictionary *filters;
	NSString *callingAET;
	NSString *calledAET;
	NSString *hostname;
	NSString *port;
	NSArray *queries;
	NSDictionary *distantServer;
	NSLock *queryLock;
	int retrieveMode;
}

- (id)initWithCallingAET:(NSString *) myAET distantServer: (NSDictionary*) ds;

- (id)rootNode;
- (NSArray *)queries;
- (NSMutableDictionary*) filters;
- (void)addFilter:(id)filter forDescription:(NSString *)description;
- (void)sortArray:(NSArray *)sortDesc;
- (void)performQuery;
- (NSDictionary *)parameters;
- (void)performQuery: (BOOL) showError;

@end
