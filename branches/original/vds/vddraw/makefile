# $Id: makefile,v 1.2 2002/03/30 16:27:57 ad Exp $

# -------------------------------------------------------------------
# I/VDS
#
# File:		vddraw/makefile 
#
# Description:
#
# Dependencies:
#
# Revision History:
#	$Log: makefile,v $
#	Revision 1.2  2002/03/30 16:27:57  ad
#	*** empty log message ***
#	
#	Revision 1.1.1.1  2001/01/04 21:08:36  cvs
#	Initial import to CVS
#	
# Revision 1.1  1997/05/08  14:50:34  pinnacle
# rep bin w/txt
#
# Revision 1.8  1995/12/21  17:25:42  pinnacle
# Replaced: vddraw/makefile for:  by v240_int for vds.240
#
# Revision 1.7  1995/11/22  23:59:22  pinnacle
# Replaced: vddraw/makefile for:  by azuurhou for vds.240
#
# Revision 1.6  1995/11/22  23:57:52  pinnacle
# Replaced: vddraw/makefile for:  by azuurhou for vds.240
#
# Revision 1.5  1995/11/22  23:56:46  pinnacle
# Replaced: vddraw/makefile for:  by azuurhou for vds.240
#
# Revision 1.4  1995/06/27  18:33:18  pinnacle
# Replaced: vddraw/makefile for:  by azuurhou for vds.240
#
#
# History:
#	MM/DD/YY	AUTHOR		DESCRIPTION
#	01/01/95	adz		creation date
#	10/14/98	ah		Changed make to grmake for Sol 2.6
# -------------------------------------------------------------------

target:
	cd cmd ;	grmake
	cd imp ;	grmake
	cd drw ;	ksh ${VDS}/vddraw/drw/grmake
	cd ve  ;	grmake
	cd func ;	grmake
	cd prod ;	grmake
	cd struct ; 	grmake

