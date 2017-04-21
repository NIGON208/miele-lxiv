#!/bin/bash

SRCROOT=$(pwd)/../

cd "$SRCROOT/Binaries"
rm -Rf ITKLibs
rm -Rf VTKLibs
rm -Rf ITKHeaders
rm -Rf VTKHeaders
rm -Rf openjpeg

# Get them out of the way so that we can unzip the defaults
cd "$SRCROOT"
rm -Rf options.h
rm -Rf url.h

exit 0
