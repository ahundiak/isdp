#/* $Id: makefile,v 1.3 2001/01/11 16:34:32 art Exp $  */

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
# *      Revision 1.3  2001/01/11 16:34:32  art
# *      sp merge
# *
# *      Revision 1.1  2001/01/11 16:20:59  art
# *      s merge
# *
# Revision 1.1  2000/12/06  14:53:10  pinnacle
# ah
#
# Revision 1.2  2000/12/01  14:12:30  pinnacle
# ah
#
# Revision 1.1  2000/04/28  19:11:36  pinnacle
# ah
#
# Revision 1.1  1997/11/25  01:19:14  pinnacle
# AssyTree
#
# *
# * History:
# *      MM/DD/YY  AUTHOR  DESCRIPTION
# *      11/25/97  ah      creation
# *      11/28/00  ah      Standalone adjustments
# ***************************************************************************/

TGT = vdiahom

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
	@svn update

