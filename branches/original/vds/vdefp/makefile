# $Id: makefile,v 1.4 2002/04/18 18:55:18 ylong Exp $

# *************************************************************************
# I/VDS
#
#  File:        vdefp/makefile
#
#  Description:
#
#  Dependencies:
#
#  Revision History:
#       $Log: makefile,v $
#       Revision 1.4  2002/04/18 18:55:18  ylong
#       *** empty log message ***
#
#       Revision 1.3  2001/04/22 17:08:17  ramarao
#       Applied Symbology to 'neat_cont' macro.
#
#       Revision 1.2  2001/01/11 19:04:50  art
#       sp merge
#
# Revision 1.2  2000/04/28  19:40:10  pinnacle
# ah
#
#
#  History:
#  MM/DD/YY  AUTHOR  DESCRIPTION
#  04/25/00  ah	     Add ppl
# ************************************************************************/

TGT = vdiefp

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

pplmkfile: ppl${TGT}.m
	@if test ${ISDP_MAKE_SP} -eq 1; \
	then \
	   ksh $(SPX)/etc/bin/mkmkppl ppl${TGT}.m pplmkfile $(SPB); \
	else \
	   ksh $(VDS)/etc/bin/mkmkppl ppl${TGT}.m pplmkfile $(VDS); \
	fi

