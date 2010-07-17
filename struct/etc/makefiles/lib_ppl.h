#/* $Id: lib_ppl.h,v 1.1 2002/04/23 16:02:26 ahundiak Exp $  */

#/***************************************************************************
# * I/VDS
# *
# * File:        struct/etc/makefiles/lib_ppl.h
# *
# * Description: The template for makefiles which generates one library
# *              and some ppl.s
# *              TGT     is for the library
# *              TGT_PPL is for the ppl's
# *
# * Dependencies:
# *
# * Revision History:
# *      $Log: lib_ppl.h,v $
# *      Revision 1.1  2002/04/23 16:02:26  ahundiak
# *      ah
# *
# *      Revision 1.2  2002/02/26 15:33:35  ahundiak
# *      ah
# *
# *
# * History:
# * MM/DD/YY  AUTHOR  DESCRIPTION
# * 04/23/02  ah      creation, copied from vds
# ***************************************************************************/

target:	mkfile \
	pplmkfile
	grmake -r -k -f mkfile
	grmake -r -k -f pplmkfile
	@if test ${ISDP_MAKE_SP} -eq 1; \
	then \
	   ld -z text -G -o ${SPXS}/lib/${TGT}.so ${SPXS}/lib/${TGT}.o ; \
	   /bin/cp ${SPXS}/lib/${TGT}.so ${SPS};   \
	   /bin/mv ${SPXS}/lib/${TGT}.so /usr/tmp; \
	else \
	   ld -z text -G -o ${STRUCT}/lib/${TGT}.so ${STRUCT}/lib/${TGT}.o ; \
	   /bin/mv ${STRUCT}/lib/${TGT}.so /usr/tmp; \
	fi

mkfile:	${TGT}.m
	grmakemake ${TGT}.m mkfile

pplmkfile: ${TGT_PPL}.m
	@if test ${ISDP_MAKE_SP} -eq 1; \
	then \
	   ksh $(STRUCT_PATH)/etc/bin/mkmkppl ${TGT_PPL}.m pplmkfile $(SP); \
	else \
	   ksh $(STRUCT_PATH)/etc/bin/mkmkppl ${TGT_PPL}.m pplmkfile $(STRUCT); \
	fi

