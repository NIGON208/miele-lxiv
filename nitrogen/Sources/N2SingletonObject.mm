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

#import "N2SingletonObject.h"

@implementation N2SingletonObject

-(id)init {
	if (!_hasInited) {
		self = [super init];
		_hasInited = YES;
	}
	
	return self;
}

-(id)retain {
	return self;
}

-(oneway void)release {
}

-(id)autorelease {
	return self;
}

-(NSUInteger)retainCount {
	return UINT_MAX;
}

@end
