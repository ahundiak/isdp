# $Id: makefile,v 1.1.1.1 2001/01/04 21:08:03 cvs Exp $

# -------------------------------------------------------------------
# I/VDS
#
# File:	vds/vddb/makefile 
#
# Description:
#
# Dependencies:
#
# Revision History:
#	$Log: makefile,v $
#	Revision 1.1.1.1  2001/01/04 21:08:03  cvs
#	Initial import to CVS
#	
# Revision 1.1  1997/05/08  14:50:26  pinnacle
# rep bin w/txt
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
#	10/14/98	ah		Changed make to grmake for Sol2.6
# -------------------------------------------------------------------

# func must be made before source
target : 
	cd ${VDS}/vdris; grmake;
	cd source; grmake;
	cd source; strip.sh

