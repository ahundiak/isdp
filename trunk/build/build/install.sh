#!/bin/ksh
#
# Run this after sourcing isdp.env and making a new install directory
mkdir -p $ISDP_INSTALL/bin
mkdir -p $ISDP_INSTALL/lib
cp $ISDP_SOURCE/grnuc/bin/echopath $ISDP_INSTALL/bin
cp $ISDP_SOURCE/exnuc/bin/slic     $ISDP_INSTALL/bin

# copied grmake for building grnuc
# link gpipe from missing and tools.h grnuc

