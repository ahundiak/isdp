# $Id: makefile,v 1.2 2002/01/18 15:24:12 ylong Exp $
# -------------------------------------------------------------------
# I/VDS
#
# File:	vds/vdpocket/cmd/makefile 
#
# Description:
#
# Dependencies:
#
# Revision History:
#	$Log: makefile,v $
#	Revision 1.2  2002/01/18 15:24:12  ylong
#	*** empty log message ***
#	
#	
# History:
#	MM/DD/YY	AUTHOR		DESCRIPTION
# -------------------------------------------------------------------

target:
	if test ${ISDP_MAKE_SP} -eq 1; \
	then \
	        ksh grmake -r -k -f make_SP; \
	else \
	        ksh grmake -r -k -f make_PLOAD; \
	fi;

