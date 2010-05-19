# $Id: makefile,v 1.2 2001/09/14 15:06:14 ylong Exp $

# -------------------------------------------------------------------
# I/VDS
#
# File:	vds/vdannot/cmd/makefile 
#
# Description:
#
# Dependencies:
#
# Revision History:
#	$Log: makefile,v $
#	Revision 1.2  2001/09/14 15:06:14  ylong
#	highlight selected table
#	
#	Revision 1.1.1.1  2001/01/04 21:07:40  cvs
#	Initial import to CVS
#	
# Revision 1.1  1997/05/08  15:21:14  pinnacle
# rep bin w/txt
#
# Revision 1.3  1995/07/14  14:05:48  pinnacle
# Replaced: vdannot/cmd/makefile for:  by yzhu for vds.240
#
# Revision 1.2  1995/01/05  18:36:26  pinnacle
# Replaced: vdannot/cmd/makefile by tdumbach r#
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

target:
	if test ${ISDP_MAKE_SP} -eq 1; \
	then \
		ksh grmake -r -k -f make_SP; \
	else \
		ksh grmake -r -k -f make_PLOAD; \
	fi;
