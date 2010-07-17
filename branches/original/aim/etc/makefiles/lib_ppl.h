#/* $Id: lib_ppl.h,v 1.3 2002/05/29 21:52:01 ylong Exp $  */

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
# *      Revision 1.3  2002/05/29 21:52:01  ylong
# *      *** empty log message ***
# *
# *      Revision 1.2  2002/05/02 18:30:22  ahundiak
# *      *** empty log message ***
# *
# *      Revision 1.1  2002/01/16 20:26:57  jdsauby
# *      Initial Add into CVS, for making AIM Service Packs
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
	@if test ${ISDP_MAKE_SP} -eq 1 ; \
	then \
	   ld -z text -G -o ${SPXA}/src/lib/${TGT}.so ${SPXA}/src/lib/${TGT}.o ; \
	   /bin/cp ${SPXA}/src/lib/${TGT}.so ${SPA};   \
	   /bin/mv ${SPXA}/src/lib/${TGT}.so /usr/tmp; \
	else \
	   ld -z text -G -o ${AIM}/src/lib/${TGT}.so ${SPXA}/src/lib/${TGT}.o ; \
	   /bin/mv ${AIM}/src/lib/${TGT}.so /usr/tmp; \
	fi

mkfile:	${TGT}.m
	grmakemake ${TGT}.m mkfile

pplmkfile: ${TGT_PPL}.m
	@if test ${ISDP_MAKE_SP} -eq 1; \
	then \
	   ksh $(AIM_PATH)/etc/bin/mkmkppl ${TGT_PPL}.m pplmkfile $(SP); \
	else \
	   ksh $(AIM_PATH)/etc/bin/mkmkppl ${TGT_PPL}.m pplmkfile $(AIM); \
	fi
