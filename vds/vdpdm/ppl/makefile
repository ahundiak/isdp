#/* $Id: makefile,v 1.1 2001/02/12 21:27:18 jdsauby Exp $  */

#/***************************************************************************
# * I/VDS
# *
# * File:        vds/vdpdm/ppl/makefile
# *
# * Description: 
# *
# * Dependencies:
# *
# * Revision History:
# * $Log: makefile,v $
# * Revision 1.1  2001/02/12 21:27:18  jdsauby
# * Added for CR 4088
# *
# * Revision 1.2  2001/01/24 20:11:12  ahundiak
# * ah
# *
# * Revision 1.1  2001/01/11 21:48:41  art
# * sp merge
# *
# Revision 1.2  2000/09/20  21:08:34  pinnacle
# js
#
# Revision 1.3  2000/09/20  21:05:08  pinnacle
# js
#
# Revision 1.1  2000/07/27  15:13:14  pinnacle
# ah
#
# *
# * History:
# * MM/DD/YY  AUTHOR  DESCRIPTION
# * 05/29/99  ah      Creation
# * 01/11/01  ah      sp merge
# ***************************************************************************/

TGT = vdpdmppl
TPT = vdpdmpplppl

target:	mkfile \
	pplmkfile
	grmake -r -k -f mkfile
	grmake -r -k -f pplmkfile
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

pplmkfile: ${TPT}.m
	@if test ${ISDP_MAKE_SP} -eq 1; \
	then \
	   ksh $(SPX)/etc/bin/mkmkppl ${TPT}.m pplmkfile $(SP); \
	else \
	   ksh $(VDS)/etc/bin/mkmkppl ${TPT}.m pplmkfile $(VDS); \
	fi

