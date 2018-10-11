#!/bin/bash

#DOXYGEN=doxygen  # /usr/local/bin/doxygen
DOXYGEN=/Applications/Doxygen.app/Contents/Resources/doxygen

mkdir -p Doxygen/Miele-LXIV
$DOXYGEN Doxyfile-miele-lxiv

mkdir -p Doxygen/DCM-Framework
$DOXYGEN Doxyfile-dcmframework

