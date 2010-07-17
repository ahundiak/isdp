#/* $Id: lib_only.h,v 1.2 2002/03/01 14:54:26 ahundiak Exp $  */

#/***************************************************************************
# * I/STRUCT
# *
# * File:        struct/etc/makefiles/lib_only.h
# *
# * Description: The template for makefiles which generate one library
# *              From one .m file both sharing the same name
# *              Which is specified by TGT
# *
# * Dependencies:
# *
# * Revision History:
# *      $Log: lib_only.h,v $
# *      Revision 1.2  2002/03/01 14:54:26  ahundiak
# *      ah
# *
# *      Revision 1.1  2001/01/16 22:46:27  ramarao
# *      *** empty log message ***
# *
# *
# * History:
# * MM/DD/YY  AUTHOR  DESCRIPTION
# * 01/16/01  RR      File Creation.
# * 03/01/02  ah      Removed ldso dependency
# ***************************************************************************/

target:	mkfile
	grmake -r -k -f mkfile
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

