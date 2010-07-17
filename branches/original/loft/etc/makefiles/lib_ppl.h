#/* $Id: lib_ppl.h,v 1.2 2002/04/02 22:59:49 ad Exp $  */

#/***************************************************************************
# * I/VDS
# *
# * File:        loft/etc/makefiles/lib_ppl.h
# *
# * Description: The template for makefiles which generates one library
# *              and some ppl.s
# *              TGT_LIB is for the library
# *              TGT_PPL is for the ppl's
# *
# * Dependencies:
# *
# * Revision History:
# *      $Log: lib_ppl.h,v $
# *      Revision 1.2  2002/04/02 22:59:49  ad
# *      Update SPXL into LOFT for ISDP_MAKE_SP = 0 process.
# *
# *      Revision 1.1  2001/04/06 17:17:46  ahundiak
# *      ah
# *
# *      Revision 1.1  2001/03/30 20:26:09  ahundiak
# *      ah
# *
# *      Revision 1.1  2001/01/14 16:15:18  art
# *      sp merge
# *
# *
# * History:
# * MM/DD/YY  AUTHOR  DESCRIPTION
# * 03/30/01  ah      creation
# ***************************************************************************/

target:	mkfile \
	pplmkfile
	grmake -r -k -f mkfile
	grmake -r -k -f pplmkfile
	@if test ${ISDP_MAKE_SP} -eq 1; \
	then \
	   ld -z text -G -o ${SPXL}/lib/${TGT}.so ${SPXL}/lib/${TGT}.o ; \
	   /bin/cp ${SPXL}/lib/${TGT}.so ${SPL};   \
	   /bin/mv ${SPXL}/lib/${TGT}.so /usr/tmp; \
	else \
	   ld -z text -G -o ${LOFT}/lib/${TGT}.so ${LOFT}/lib/${TGT}.o ; \
	   /bin/mv ${LOFT}/lib/${TGT}.so /usr/tmp; \
	fi

mkfile:	${TGT}.m
	grmakemake ${TGT}.m mkfile

pplmkfile: ${TGT_PPL}.m
	@if test ${ISDP_MAKE_SP} -eq 1; \
	then \
	   ksh $(LOFT_PATH)/etc/bin/mkmkppl ${TGT_PPL}.m pplmkfile $(SP); \
	else \
	   ksh $(LOFT_PATH)/etc/bin/mkmkppl ${TGT_PPL}.m pplmkfile $(LOFT); \
	fi

