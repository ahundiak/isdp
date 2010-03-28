#!/bin/ksh
# 
# File:   deltools.sh
# Author: impd
#
# Created on March 24, 2010, 3:21 PM
#
# Installs the various ISDP products

# These need to be set in the env file
# export ISDP_SOURCE=$HOME/isdp
# export ISDP_INSTALL=$HOME/ingr
# export ISDP_LEGACY=$HOME/save/ingr

# File containg info about each installed product
mkdir -p $ISDP_INSTALL
cp -p -f $ISDP_SOURCE/build/install/ingrconfig $ISDP_INSTALL

# proddata uses ingrconfig
# cp -p $ISDP_LEGACY/deltools/proddata $ISDP_INSTALL/bin
#chmod +x $ISDP_INSTALL/bin/proddata
cd $ISDP_SOURCE/deltools; make -e install; cd

# UMS Message compiler and library
