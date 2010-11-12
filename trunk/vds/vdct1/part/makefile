#/* $Id: makefile,v 1.2 2001/01/24 15:38:10 ahundiak Exp $  */

#/***************************************************************************
# * I/VDS
# *
# * File:        vds/vdct1/part/makefile
# *
# * Description: 
# *
# * Dependencies:
# *
# * Revision History:
# * $Log: makefile,v $
# * Revision 1.2  2001/01/24 15:38:10  ahundiak
# * ah
# *
# * Revision 1.1  2001/01/12 14:35:59  art
# * sp merge
# *
# Revision 1.1  2000/05/31  21:04:10  pinnacle
# ah
#
# *
# * History:
# * MM/DD/YY  AUTHOR  DESCRIPTION
# * 05/31/00  ah      Creation
# * 01/12/01  ah      sp merge
# ***************************************************************************/

TGT = vdict1part
TPT = vdict1ppl

target:	mkfile \
	pplmkfile
	grmake -r -k -f mkfile
#	grmake -r -k -f pplmkfile
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

clean:
	@rm -f mkfile pplmkfle *.e *.o
