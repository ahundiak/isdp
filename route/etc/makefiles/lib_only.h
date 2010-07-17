# $Id: lib_only.h,v 1.5 2001/08/24 20:15:37 ahundiak Exp $ 

#--------------------------------------------------------------------------
# I/ROUTE
#
# File:        route/etc/makefiles/lib_only.h
#
# Description: The template (based on the template created by Art) for
#              makefiles which generate one library from one .m file
#              both sharing the same name which is specified by TGT.
#
# Dependencies:
#
# Revision History:
#      $Log: lib_only.h,v $
#      Revision 1.5  2001/08/24 20:15:37  ahundiak
#      ah
#
#      Revision 1.4  2001/02/06 17:06:22  build
#      *** empty log message ***
#
#      Revision 1.3  2001/01/22 18:32:02  anand
#      if conditions in makefiles need test arguments!!
#
#      Revision 1.2  2001/01/21 20:56:50  anand
#      Corrected an error in makefiles. Makefiles do not understand
#      parameter substitution as shell scripts do! :(
#
#      Revision 1.1  2001/01/19 20:09:30  anand
#      Template makefile for I/Route. This template may be used by
#      (and is similar to the templates in) other products as well.
#      The makefile of each directory contains an include directive
#      for either this or one of the other files in this directory.
#
#
#
# History:
# MM/DD/YY  AUTHOR  DESCRIPTION
# 01/17/01  Anand   creation -> Caution: Will NOT work for Service Pack as
#		    names of .m and .o files are different.
#--------------------------------------------------------------------------

target:	mkfile
	grmake -r -k -f mkfile
	@if test ${ISDP_MAKE_SP} -eq 1 ; \
	then \
	   ld -z text -G -o ${SPXR}/lib/${TGT}.so  ${SPXR}/lib/${TGT}.o; \
	   /bin/cp ${SPXR}/lib/${TGT}.so /usr/tmp;   \
	   /bin/mv ${SPXR}/lib/${TGT}.so ${SPR};   \
	fi

mkfile:	${TGT}.m
	grmakemake ${TGT}.m mkfile

