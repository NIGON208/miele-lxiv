## Osiri-LXIV compilation

Alex Bettarini - 15 Mar 2015

### Binaries

---

- **DCMTK**:

	A prebuilt binary is not provided, because in my view it is not suitable for an open source project: it would be a black box that the user cannot verify. It is more appropriate if the library is built from the sources. You can proceed like this:
	
	1. Download the latest sources
	
			$ git clone git://git.dcmtk.org/dcmtk
			$ cd dcmtk
			$ export DCMTK_SRC=`pwd`
			$ git checkout 1e5785f
	
	* Customize the sources for usage in the Osiri-LXIV project
		* Either
			- Make sure none of the class names conflict with the Osiri-LXIV Objective-C class names (hint: rename `DicomImage` to `dcmImage` in all DCMTK files).
			- Exclude `dimget.cc` from the library (then add it manually in the DCMTK Xcode project only for the target `dcmqrscp`)
		* Or
			- apply the DCMTK patch. First do a dry run

					$ patch --dry-run -p1 -i dcmtk-before.patch
					
			- apply patch

					$ cd $DCMTK_SRC/dcmqrdb/libsrc
					$ patch --dry-run -p1 -i dcmqrdb.cc.patch

	* Run CMake with the following parameters:
			
			CMAKE_OSX_DEPLOYMENT_TARGET=10.8
			CMAKE_OSX_SYSROOT=macosx10.8
			CMAKE_OSX_ARCHITECTURES=x86_64
			CMAKE_INSTALL_PREFIX=<your choice>
			
		Configure (twice) and generate either a makefile or an Xcode project. 
			
	* Build and install the DCMTK library.
	* Copy the installation tree into the `Binaries/` directory

	<p>In the future a patch will be provided for the following steps, but for the time being you'll have to do them manually:

	* Add `#undef verify` at the top of file `dcmdata/dcobject.h` (line 24)
	* Edit the file `include/dcmtk/oflog/config.h` line 118 to comment out

			#define DCMTK_LOG4CPLUS_HAVE_RVALUE_REFS
			
	* copy the two header files `intrface.h` and `pubtypes.h` from the DCMTK source directories
	
			dcmtk/dcmjpls/libcharls/
			
		to the project directory

			Binaries/DCMTK/include/dcmtk/
			
	* Add the following `libijg*` headers (taken from the DCMTK downloaded sources) as subdirectories of `Binaries/DCMTK/include/dcmtk/dcmjpeg/`
		
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

   	* Edit `dcmqrdb/dcmqrsrv.h`

   		Line 128
	
			public:
				virtual OFCondition getSCP(
				...
				);

			private:
						
   		Line 137
	
			public:
				virtual OFCondition storeSCP(
				...
				);

			private:

		Line 190, declare `options_` as public

   	* Edit `dcmqrdb/dcmqrsrv.cc`

   		Line 168, in function dispath() replace
   		the calls to `storeSCP()` and `getSCP()`
   		with `this->storeSCP()` and `this->getSCP()`
   		
   	* Edit `dcmqrdb/dcmqrcbg.h`
   	
   		- make getNextImage() public virtual

   	* Edit `dimse.cc`
   		- remove `static` from getTransferSyntax()

 	* Add two lines to `dcmjpeg/djutils.h` so that it looks like this

			enum EJ_Mode
			{
				...

				EJM_lossless,
			 	EJM_JP2K_lossy,
				EJM_JP2K_lossless
			};
			
 	* Optionally edit `include/dcmtk/config/osconfig.h` and put the build date in place of "DEV" in `#define PACKAGE_DATE "DEV"`

---
- Now you should be able to launch the Osiri-LXIV Xcode project and build it as usual:
	* (The first time only) build the target "Unzip Binaries" 
	* Build the target OsiriX

		