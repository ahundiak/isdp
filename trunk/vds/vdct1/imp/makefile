#/* $Id: makefile,v 1.2 2001/01/11 22:21:09 art Exp $  */

#/***************************************************************************
# * I/VDS
# *
# * File:        vdct1/imp/makefile
# *
# * Description:
# *
# * Dependencies:
# *
# * Revision History:
# *      $Log: makefile,v $
# *      Revision 1.2  2001/01/11 22:21:09  art
# *      sp merge
# *
# *      Revision 1.1.1.1  2001/01/04 21:08:02  cvs
# *      Initial import to CVS
# *
# Revision 1.1  1999/06/29  18:28:08  pinnacle
# ct
#
# *
# * History:
# * MM/DD/YY  AUTHOR  DESCRIPTION
# * 05/28/99  ah      creation
# * 01/11/01  ah      sp merge
# ***************************************************************************/

TGT = vdict1imp

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

clean:
	@rm -f mkfile *.o *.c

