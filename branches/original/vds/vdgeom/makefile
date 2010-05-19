#/* $Id: makefile,v 1.2 2001/01/11 18:41:19 art Exp $  */

#/***************************************************************************
# * I/VDS
# *
# * File:        vdah/makefile
# *
# * Description:
# *
# * Dependencies:
# *
# * Revision History:
# *      $Log: makefile,v $
# *      Revision 1.2  2001/01/11 18:41:19  art
# *      sp merge
# *
# Revision 1.1  2000/04/11  17:14:28  pinnacle
# ah
#
# Revision 1.2  2000/03/31  17:00:56  pinnacle
# ah
#
# Revision 1.2  2000/03/31  16:59:18  pinnacle
# ah
#
# Revision 1.1  2000/03/24  17:16:32  pinnacle
# ah
#
# Revision 1.1  1997/11/25  01:19:14  pinnacle
# AssyTree
#
# *
# * History:
# * MM/DD/YY  AUTHOR  DESCRIPTION
# * 03/22/00  ah      Creation
# * 01/11/01  ah      sp merge
# ***************************************************************************/

TGT = vdigeom

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
