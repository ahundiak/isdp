# $Id: makefile,v 1.2 2001/11/07 14:23:15 ylong Exp $
# -------------------------------------------------------------------
# I/VDS
#
# File:	vds/smcomp/cmd/makefile 
#
# Description:
#
# Dependencies:
#
# Revision History:
#	$Log: makefile,v $
#	Revision 1.2  2001/11/07 14:23:15  ylong
#	SP14 for TR3064
#	
#	
# History:
#	MM/DD/YY	AUTHOR	DESCRIPTION
#	01/15/98	ylong	Created for SP14
# -------------------------------------------------------------------

target:
	if test ${ISDP_MAKE_SP} -eq 1; \
	then \
		ksh grmake -r -k -f make_SP; \
	else \
		ksh grmake -r -k -f make_PLOAD; \
	fi;

