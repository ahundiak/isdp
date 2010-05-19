#/* $Id: makefile,v 1.1 2001/05/07 13:15:28 paul_noel Exp $  */

#/***************************************************************************
# * I/VDS
# *
# * File:        vds/vdfile/cmd/makefile
# *
# * Description: 
# *
# * Dependencies:
# *
# * Revision History:
# * $Log: makefile,v $
# * Revision 1.1  2001/05/07 13:15:28  paul_noel
# * Inital Creation File Browser
# *
# *
# * History:
# * MM/DD/YY  AUTHOR  DESCRIPTION
# * 05/02/01  pn      Creation
# *
# ***************************************************************************/

TGT = vdifilecmd

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
