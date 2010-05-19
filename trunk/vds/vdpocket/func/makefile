# $Id: makefile,v 1.2 2001/08/30 19:31:30 ramarao Exp $

# -------------------------------------------------------------------
# I/VDS
#
# File:	vds/vdpocket/func/makefile 
#
# Description:
#
# Dependencies:
#
# Revision History:
#	$Log: makefile,v $
#	Revision 1.2  2001/08/30 19:31:30  ramarao
#	Added functionality to add command keys to the pocket menu.
#	
#	Revision 1.1.1.1  2001/01/04 21:09:01  cvs
#	Initial import to CVS
#	
# Revision 1.1  1997/05/08  15:39:24  pinnacle
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
#
# -------------------------------------------------------------------

TGT = vdipockfc

target: mkfile
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

mkfile:	vdpockfc.m
	grmakemake vdpockfc.m mkfile
