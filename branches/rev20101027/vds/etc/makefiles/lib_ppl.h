#/* $Id: lib_ppl.h,v 1.2 2002/02/26 15:33:35 ahundiak Exp $  */

#/***************************************************************************
# * I/VDS
# *
# * File:        vds/etc/makefiles/lib_ppl.h
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
# *      Revision 1.2  2002/02/26 15:33:35  ahundiak
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
# * 02/26/02  ah      Had some SPX variables in the pload section
# ***************************************************************************/

target:	mkfile \
	pplmkfile
	grmake -r -k -f mkfile
	grmake -r -k -f pplmkfile
	@if test ${ISDP_MAKE_SP} -eq 1; \
	then \
	   ld -z text -G -o ${SPXV}/lib/${TGT}.so ${SPXV}/lib/${TGT}.o ; \
	   /bin/cp ${SPXV}/lib/${TGT}.so ${SPV};   \
	   /bin/mv ${SPXV}/lib/${TGT}.so /usr/tmp; \
	else \
	   ld -z text -G -o ${VDS}/lib/${TGT}.so ${VDS}/lib/${TGT}.o ; \
	   /bin/mv ${VDS}/lib/${TGT}.so /usr/tmp; \
	fi

mkfile:	${TGT}.m
	grmakemake ${TGT}.m mkfile

pplmkfile: ${TGT_PPL}.m
	@if test ${ISDP_MAKE_SP} -eq 1; \
	then \
	   ksh $(VDS_PATH)/etc/bin/mkmkppl ${TGT_PPL}.m pplmkfile $(SP); \
	else \
	   ksh $(VDS_PATH)/etc/bin/mkmkppl ${TGT_PPL}.m pplmkfile $(VDS); \
	fi

