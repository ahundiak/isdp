# $Id: makefile,v 1.2 2001/05/16 16:51:40 hans Exp $

# -------------------------------------------------------------------
# I/VDS
#
# File:	vds/emsfixes/model/makefile
#
# Description:
#
# Dependencies:
#
# Revision History:
#	$Log: makefile,v $
#	Revision 1.2  2001/05/16 16:51:40  hans
#	Fix for TR# MP4946
#	
#	Revision 1.1.1.1  2001/01/04 21:07:28  cvs
#	Initial import to CVS
#
# Revision 1.1  1997/05/08  14:57:40  pinnacle
# rep bin w/txt
#
# Revision 1.1  1996/02/07  23:44:38  pinnacle
# Created: ./emsfixes/model/makefile by azuurhou for vds.240
#
#
# History:
#	MM/DD/YY	AUTHOR		DESCRIPTION
#
# -------------------------------------------------------------------

TGT = vdidloadmodel

target : mkfile
	grmake -r -k -f mkfile
	@if test ${ISDP_MAKE_SP} -eq 1; \
	then \
	   ldso    ${SPXV}/lib/${TGT}; \
	   /bin/cp ${SPXV}/lib/${TGT}.so ${SPV};   \
	   /bin/mv ${SPXV}/lib/${TGT}.so /usr/tmp; \
	else \
	   ldso    ${VDS}/lib/${TGT}; \
	   /bin/mv ${VDS}/lib/${TGT}.so /usr/tmp; \
	fi

mkfile : vdmd.m
	grmakemake vdmd.m mkfile

