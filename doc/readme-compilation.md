## Osiri-LXIV compilation

Alex Bettarini - 15 Mar 2015

Prebuilt binaries are no longer provided. It's more appropriate to rebuild the toolkits from the sources downloaded from the respective repositories.

A number of bash shell scripts are available in the `steps` directory.

The sources can be built "as is" resulting in a version of the application with the branding, logo and defaults inherited from the original OsiriX project, later forked to the Osiri-LXIV project.

Alternatively you can spend some time creating your on branding, which involves:

- creating your logo and icon
- customizing the strings in `options.h` and `url.h`
- setup your own web server hosting a home page and a page to allow checking for updates
- setup a server for bug reporting and management, for example [MantisBT](https://www.mantisbt.org), or you can use the system built into the GitHub if you forked your own project.

---
# Step 1
- First run (you need to do this only once)

		$ cd steps
		$ unzip-binaries-sh

---
# Step 2

Build the third-party open source toolkits

---
### VTK, ITK, OpenJPEG

- Either install these toolkits with a package manager like [Homebrew](https://brew.sh)
- or install them from sources

	- Download the sources from their respective repositories.
	- Build the toolkits with CMake (GUI) or cmake (CLI), as you prefer.
	- Install the toolkits anywhere you like, but keep in mind where you installed them, because next you will need to create symbolic links to those install locations.

---
### **DCMTK**:
			
- Proceed as above, then

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
# Step 3
- Create symbolic links from the `Binaries/` directory to the directories where you installed the toolkits

---
# Step 4
- Now you should be able to launch the Xcode project and build the application, or if you prefer and know how to do it, build it directly from the command line.

