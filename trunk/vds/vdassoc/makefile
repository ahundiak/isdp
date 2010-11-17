# $Id: makefile,v 1.2 2001/04/03 15:22:11 ramarao Exp $

# -------------------------------------------------------------------
# I/VDS
#
# File:	vds/vdassoc/makefile 
#
# Description:
#
# Dependencies:
#
# Revision History:
#	$Log: makefile,v $
#	Revision 1.2  2001/04/03 15:22:11  ramarao
#	Fixed TR# 4527
#	
#	Revision 1.1.1.1  2001/01/04 21:07:41  cvs
#	Initial import to CVS
#	
# Revision 1.1  1997/05/08  14:50:02  pinnacle
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

TGT = vdidloadassoc

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

mkfile: vdassoc.m
	grmakemake vdassoc.m mkfile

clean:
	@rm -f mkfile *.o *.c

