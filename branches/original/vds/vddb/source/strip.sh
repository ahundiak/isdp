#!/bin/ksh
# $Id: strip.sh,v 1.1.1.1 2001/01/04 21:08:33 cvs Exp $

# -------------------------------------------------------------------
# I/VDS
#
# File:	vds/vddb/source/strip.sh 
#
# Description:
#
# Dependencies:
#
# Revision History:
#	$Log: strip.sh,v $
#	Revision 1.1.1.1  2001/01/04 21:08:33  cvs
#	Initial import to CVS
#	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.2  1995/11/21  21:22:18  pinnacle
# Replaced: ./vddb/source/strip.sh for:  by azuurhou for vds.240
#
# Revision 1.1  1994/11/14  22:42:32  pinnacle
# Create vds.240 from vds.232
#
# Revision 1.1  1994/11/08  16:07:00  pinnacle
# create vds.232
#
#
# History:
#	MM/DD/YY	AUTHOR		DESCRIPTION
#
# -------------------------------------------------------------------

if [ -f ${VDS}/vddb/bin/VDSloaddata ] 
then
	echo "Stripping the VDSloaddata file."
	mcs -d ${VDS}/vddb/bin/VDSloaddata
	strip ${VDS}/vddb/bin/VDSloaddata
fi

