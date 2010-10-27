# $Id: makefile,v 1.2 2001/01/26 00:43:56 build Exp $

# -------------------------------------------------------------------
# I/VDS
#
# File:	vds/smppl/makefile 
#
# Description:
#
# Dependencies:
#
# Revision History:
#	$Log: makefile,v $
#	Revision 1.2  2001/01/26 00:43:56  build
#	*** empty log message ***
#	
#	Revision 1.1.1.1  2001/01/04 21:07:36  cvs
#	Initial import to CVS
#	
# Revision 1.1  1997/05/08  14:49:50  pinnacle
# rep bin w/txt
#
# Revision 1.2  1995/11/16  05:10:10  pinnacle
# Replaced: smppl/makefile for:  by ksundar for vds.240
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
#	11/16/95	Sundar		mkmkppl is replaced by "ksh $VDS/etc/bin
#					/mkmkppl during Solaris port.
# -------------------------------------------------------------------

target: pplmkfile
#	grmake -r -k -f pplmkfile

pplmkfile: smppl.m
	ksh ${VDS}/etc/bin/mkmkppl smppl.m pplmkfile ${VDS}
