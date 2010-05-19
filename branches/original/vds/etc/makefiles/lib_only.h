#/* $Id: lib_only.h,v 1.2 2002/02/28 22:04:21 ahundiak Exp $  */

#/***************************************************************************
# * I/VDS
# *
# * File:        vds/etc/makefiles/lib_only.h
# *
# * Description: The template for makefiles which generate one library
# *              From one .m file both sharing the same name
# *              Which is specified by TGT
# *
# * Dependencies:
# *
# * Revision History:
# *      $Log: lib_only.h,v $
# *      Revision 1.2  2002/02/28 22:04:21  ahundiak
# *      ah
# *
# *      Revision 1.1  2001/01/14 16:15:18  art
# *      sp merge
# *
# *
# * History:
# * MM/DD/YY  AUTHOR  DESCRIPTION
# * 01/14/01  ah      creation
# * 02/27/02  ah      removed the ldso dependency
# ***************************************************************************/

target:	mkfile
	grmake -r -k -f mkfile
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

