#/* $Id: makefile,v 1.2 2001/01/11 21:18:27 art Exp $  */

#/***************************************************************************
# * I/VDS
# *
# * File:        vdat/imp/makefile
# *
# * Description:
# *
# * Dependencies:
# *
# * Revision History:
# *      $Log: makefile,v $
# *      Revision 1.2  2001/01/11 21:18:27  art
# *      sp merge
# *
# *      Revision 1.1.1.1  2001/01/04 21:07:42  cvs
# *      Initial import to CVS
# *
# Revision 1.3  1998/04/09  14:33:28  pinnacle
# ah
#
# Revision 1.2  1998/04/09  14:29:20  pinnacle
# ah
#
# Revision 1.2  1998/04/09  14:24:48  pinnacle
# ah
#
# Revision 1.2  1997/11/26  22:03:00  pinnacle
# AssyTree
#
# Revision 1.1  1997/11/25  16:23:36  pinnacle
# AssyTree
#
# *
# * History:
# *      MM/DD/YY  AUTHOR  DESCRIPTION
# *      11/25/97  ah      creation
# *
# ***************************************************************************/

TGT = vdiatimp

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
