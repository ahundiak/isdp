# $Id: makefile,v 1.13 2002/05/15 17:47:50 ylong Exp $

# -------------------------------------------------------------------
# I/VDS
#
# File:	vds/vdtbl/cmd/makefile 
#
# Description:
#
# Dependencies:
#
# Revision History:
#
# History:
#	MM/DD/YY	AUTHOR		DESCRIPTION
# -------------------------------------------------------------------

target:
	@if test ${ISDP_MAKE_SP} -eq 1; \
	then \
		ksh grmake -r -k -f make_SP; \
	else \
		ksh grmake -r -k -f make_PLOAD; \
	fi;
