#/* $Id: makefile,v 1.1 2001/07/17 13:36:58 paul_noel Exp $  */

#/***************************************************************************
# * I/VDS
# *
# * File:        vds/vdtvw/cmd/makefile
# *
# * Description: 
# *
# * Dependencies:
# *
# * Revision History:
# *
# * History:
# * MM/DD/YY  AUTHOR  DESCRIPTION
# * 06/22/01  pn      Creation
# *
# ***************************************************************************/

TGT = vditvwcmd

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
	fi;

mkfile:	${TGT}.m
	grmakemake ${TGT}.m mkfile
