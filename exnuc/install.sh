#!/bin/ksh
# 
# File:   install.sh
# Author: impd
#
# Created on March 28, 2010, 12:04 PM
#
# this would lead to madness, have /opt/ingr point to the legacy data
mkdir -p $ISDP_INSTALL/exnuc
find config/english/forms | cpio -pmud $ISDP_INSTALL/exnuc
find config/english/forms | cpio -pmud $ISDP_INSTALL/exnucdp

# Add a cleanup or filter or or something to get rid of the .svn files
