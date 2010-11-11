#/* $Id: makefile,v 1.2 2001/01/11 21:21:51 art Exp $  */

#/***************************************************************************
# * I/VDS
# *
# * File:        vdat/cmd/makefile
# *
# * Description:
# *
# * Dependencies:
# *
# * Revision History:
# *      $Log: makefile,v $
# *      Revision 1.2  2001/01/11 21:21:51  art
# *      sp merge
# *
# *      Revision 1.1.1.1  2001/01/04 21:07:42  cvs
# *      Initial import to CVS
# *
# Revision 1.1  1997/12/10  22:41:24  pinnacle
# AssyTree
#
# *
# * History:
# *      MM/DD/YY  AUTHOR  DESCRIPTION
# *      12/01/97  ah      creation
# *
# ***************************************************************************/

TGT = vdiatcmd

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

