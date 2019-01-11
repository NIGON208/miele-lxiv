## Miele-LXIV compilation

Alex Bettarini - 15 Mar 2015

Some of the pre-built toolkits in the `Binaries` directory are no longer provided. It's more appropriate to rebuild the toolkits from the sources downloaded from the respective repositories.

A number of bash shell scripts are available in the `./build-steps` directory.

If you want to fork the project and create your on branding, you should:

- create your own logo and icon
- customize the strings in `options.h` and `url.h`
- setup your own web server hosting a home page, and a page to allow checking for updates
- setup a server for bug reporting and management, for example [MantisBT](https://www.mantisbt.org), or you can use the system of issue tracking built into the GitHub

---
## Step 1
- First time (you need to do this only once)

		$ cd $PROJECT_DIR/doc/build-steps
		$ ./unzip-binaries-sh

---
## Step 2
		$ cd $PROJECT_DIR/Binaries/Icons/
		$ ln Logo-GitHub.tif Logo.tif

---
## Step 3

- Download and build the third-party open-source toolkits. Tested versions are:

	- VTK 7.1.1
	- ITK 4.11.1
	- DCMTK 3.6.2
	- JASPER 2.0.12
	- OpenJPG 2.2.0
	- libjpg 9b
	- libtiff 4.0.8
	- libz 1.2.11
	- libpng 1.6.30

---
### VTK, ITK, OpenJPEG

- Either install these toolkits with a package manager like [Homebrew](https://brew.sh)
- or install them from sources

	- Download the sources from their respective repositories.
	- Build the toolkits with CMake (GUI) or cmake (CLI), as you prefer.
	- Install the toolkits anywhere you like, but keep in mind where you installed them, because next you will need to create symbolic links to those install locations.

---
### **DCMTK**:

- Download the sources, then edit them as follows (a patch will be provided here in the future):

- Add `#undef verify` at the top of file `dcmdata/dcobject.h` (line 24)

- Add two lines to `dcmjpeg/include/dcmtk/dcmjpeg/djutils.h` so that it looks like this

			enum EJ_Mode
			{
				...

				EJM_lossless,
			 	EJM_JP2K_lossy,
				EJM_JP2K_lossless
			};

- Edit the file `dcmjpls/libcharls/context.h`

	At the top insert the line
	
		#include <vector>

- Edit `dcmnet/libsrc/dimse.cc`
 
	Remove `static` from `OFCondition getTransferSyntax()`

- Edit `dcmqrdb/include/dcmtk/dcmqrdb/dcmqrcbg.h`
   	
   	- Near line 115 insert the line

	   	    friend class DcmQueryRetrieveGetOurContext;
	   	    
		before the line

    			OFCondition performGetSubOp(DIC_UI sopClass, DIC_UI sopInstance, char *fname);

   	- Near line 123 make `getNextImage()` public virtual
   	- Near line 133 make `DcmQueryRetrieveDatabaseHandle` protected
   	- Near line 176 make `nRemaining` protected
   	- Near line 194 make `getCancelled` protected

- Edit `dcmqrdb/include/dcmtk/dcmqrdb/dcmqrsrv.h`

	- Near line 116 make `handleAssociation` public
	- Near line 128
	
			public:
				virtual OFCondition getSCP(
				...
				);

			private:

	- Near line 137
	
			public:
				virtual OFCondition storeSCP(
				...
				);

			private:

	- Near line 195 make `DcmQueryRetrieveOptions & options_` public

- Edit `dcmqrdb/libsrc/dcmqrcbg.cc`

	- Near line 100 change `getNextImage(&dbStatus)`
	into `this->getNextImage(&dbStatus)`

- Edit `dcmqrdb/dcmqrsrv.cc`

	- Near line 100 insert:
	
			#include "dcmtk/dcmnet/dimse.h"
			
   		Line 168, in function dispatch() replace
   		the calls to `storeSCP()` and `getSCP()`
   		with `this->storeSCP()` and `this->getSCP()`

- Build and install DCMTK

- Optionally edit the installed file `include/dcmtk/config/osconfig.h` and put the build date in place of `DEV` in `#define PACKAGE_DATE "DEV"`. This is recommended if you are not using the official "versioned" sources, but just any intermediate commit of the repository.

- Copy the two header files `intrface.h` and `pubtypes.h` from the DCMTK source directory `dcmtk/dcmjpls/libcharls/` to the installed directory `/include/dcmtk/`
			
- Add the following `libijg*` headers (taken from the DCMTK downloaded sources) as subdirectories of the installed files in `include/dcmtk/dcmjpeg/`
		
			├── libijg12/
			│   ├── jconfig12.h
			│   ├── jerror12.h
			│   ├── jinclude12.h
			│   ├── jmorecfg12.h
			│   └── jpeglib12.h
			├── libijg16/
			│   ├── jconfig16.h
			│   ├── jerror16.h
			│   ├── jinclude16.h
			│   ├── jmorecfg16.h
			│   └── jpeglib16.h
			└── libijg8/
			    ├── jconfig8.h
			    ├── jerror8.h
			    ├── jinclude8.h
			    ├── jmorecfg8.h
			    └── jpeglib8.h
			    
---
## Step 4 - Prepare to build the application
- Create symbolic links from the `Binaries/` directory to the directories where you installed the toolkits, unless you installed the toolkits directly there.

---
## Step 5 - Build and run the application
- Now you should be able to launch the Xcode project and build the application, or if you prefer build it directly from the command line:

		$ xcodebuild -configuration Development -target "miele-lxiv"
		
- if you get some errors relating to missing localization files, go into the Xcode PROJECT settings, Info, Localizations, and remove all Languages except for "English".

- When you build the scheme `miele-lxiv` you should select the `Development` configuration, otherwise you might have issues with missing certificates for signing the app.
- before running the built application, make sure your system has JPEG, TIFF and PNG shared libraries installed in the system. You might have to install them like this

		$ brew install jpeg libtiff libpng

