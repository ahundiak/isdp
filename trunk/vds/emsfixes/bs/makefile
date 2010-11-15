# $Id: makefile,v 1.2 2001/04/09 20:24:12 ramarao Exp $

# -------------------------------------------------------------------
# I/VDS
#
# File:	vds/emsfixes/bs/makefile 
#
# Description:
#
# Dependencies:
#
# Revision History:
#	$Log: makefile,v $
#	Revision 1.2  2001/04/09 20:24:12  ramarao
#	Modified makefile to suit service pack.
#	
#	Revision 1.1.1.1  2001/01/04 21:07:27  cvs
#	Initial import to CVS
#	
#
# History:
#	MM/DD/YY	AUTHOR		DESCRIPTION
#
# -------------------------------------------------------------------

TGT = vdidloadbsp

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

mkfile: vdbs.m
	grmakemake vdbs.m mkfile

clean:
	@rm -f mkfile *.o
