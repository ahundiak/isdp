#/* $Id: lib_only.h,v 1.2 2002/04/08 16:25:53 ahundiak Exp $  */

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
# *      Revision 1.2  2002/04/08 16:25:53  ahundiak
# *      ah
# *
# *      Revision 1.1  2001/04/06 17:17:45  ahundiak
# *      ah
# *
# *      Revision 1.1  2001/01/14 16:15:18  art
# *      sp merge
# *
# *
# * History:
# * MM/DD/YY  AUTHOR  DESCRIPTION
# * 01/14/01  ah      creation
# ***************************************************************************/

target:	mkfile
	grmake -r -k -f mkfile
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

