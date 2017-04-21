//
//  tmp_locations.h
//  OsiriX_Lion
//
//  Created by Alex Bettarini on 1 May 2014.
//  Copyright (c) 2015 Osiri-LXIV Team. All rights reserved.
//

#ifndef TMP_LOCATIONS_H_INCLUDED
#define TMP_LOCATIONS_H_INCLUDED

#define USER_TMP                    "tmp"
#define SYSTEM_TMP                  "/tmp"
#define AT_TLS_TMP                  @"/tmp"
#define TLS_TMP                     "/tmp"

#define PRIVATE_TMP                 @"/private/tmp/"
#define PRIVATE_VAR_TMP             @"/private/var/tmp/"

#ifdef MAC_APP_STORE
#define TMP_DIR                     "tmp"
#else
#define TMP_DIR                     "/tmp"
#endif

#endif
