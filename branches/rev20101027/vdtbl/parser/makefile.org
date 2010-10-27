# $Id: makefile,v 1.4 2001/07/27 22:29:39 ylong Exp $

# -------------------------------------------------------------------
# I/VDS
#
# File:	vds/vdtbl/parser/makefile 
#
# Description:
#
# Dependencies:
#
# Revision History:
#
# History:
#	MM/DD/YY	AUTHOR		DESCRIPTION
#	07/28/01	ylong		Creation
#
# -------------------------------------------------------------------

target:
	if test ${ISDP_MAKE_SP} -eq 1; \
	then \
		ksh grmake -r -k -f make_SP; \
	else \
		ksh grmake -r -k -f make_PLOAD; \
	fi;
