#/* $Id: lib_only.h,v 1.4 2002/05/29 18:18:24 ylong Exp $  */

#/***************************************************************************
# * I/VDS
# *
# * File:        aim/etc/makefiles/lib_only.h
# *
# * Description: The template for makefiles which generate one library
# *              From one .m file both sharing the same name
# *              Which is specified by TGT
# *
# * Dependencies:
# *
# * Revision History:
# *      $Log: lib_only.h,v $
# *      Revision 1.4  2002/05/29 18:18:24  ylong
# *      *** empty log message ***
# *
# *      Revision 1.3  2002/05/28 21:18:13  ylong
# *      *** empty log message ***
# *
# *      Revision 1.2  2002/05/02 18:30:20  ahundiak
# *      *** empty log message ***
# *
# *      Revision 1.1  2002/01/16 20:26:55  jdsauby
# *      Initial Add into CVS, for making AIM Service Packs
# *
# *      Revision 1.1  2001/01/14 16:15:18  art
# *      sp merge
# *
# *
# * History:
# * MM/DD/YY  AUTHOR  DESCRIPTION
# * 05/02/02  adz     creation-update
# ***************************************************************************/

target:	mkfile
	grmake -r -k -f mkfile
	@if test ${ISDP_MAKE_SP} -eq 1 ; \
	then \
	   ld -z text -G -o ${SPXA}/src/lib/${TGT}.so ${SPXA}/src/lib/${TGT}.o; \
	   /bin/cp ${SPXA}/src/lib/${TGT}.so ${SPA};   \
	   /bin/mv ${SPXA}/src/lib/${TGT}.so /usr/tmp; \
	else \
	   ld -z text -G -o ${AIM}/src/lib/${TGT}.so ${AIM}/src/lib/${TGT}.o ; \
	   /bin/mv ${AIM}/src/lib/${TGT}.so /usr/tmp; \
	fi

mkfile:	${TGT}.m
	grmakemake ${TGT}.m mkfile

