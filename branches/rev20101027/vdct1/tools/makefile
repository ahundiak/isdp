#/* $Id: makefile,v 1.3 2001/02/06 17:44:04 build Exp $  */

#/***************************************************************************
# * I/VDS
# *
# * File:        vds/vdct1/cmd/makefile
# *
# * Description: 
# *
# * Dependencies:
# *
# * Revision History:
# * $Log: makefile,v $
# * Revision 1.3  2001/02/06 17:44:04  build
# * Reverting to 1.1 revision
# *
# * Revision 1.1  2001/01/12 15:08:18  art
# * sp merge
# *
# Revision 1.1  2000/07/31  13:37:14  pinnacle
# pn
#
# *
# * History:
# * MM/DD/YY  AUTHOR  DESCRIPTION
# * 05/29/99  ah      Creation
# *
# ***************************************************************************/

TGT = vdict1tools

target:	mkfile
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

mkfile:	${TGT}.m
	grmakemake ${TGT}.m mkfile
