# $Id: slic_n_lib.h,v 1.6 2002/05/08 15:46:52 anand Exp $ 

#--------------------------------------------------------------------------
# I/ROUTE
#
# File:        route/etc/makefiles/slic_n_lib.h
#
# Description:	The template for makefiles which generate one library 
#		from one .m file both sharing the same name which is specified
#		by TGT, and the directory having .sl or .t files that
#		require slic-ing. The Slic process is done before the
#		grmakemake. Pload/Builds use vrslic; service packs do
#		an itemized Slic.
#
# Dependencies:
#
# Revision History:
#      $Log: slic_n_lib.h,v $
#      Revision 1.6  2002/05/08 15:46:52  anand
#      Prevent .sl and .t files to be slic-ed twice during a
#      Service Pack cycle.
#
#      Revision 1.5  2001/04/20 15:43:41  anand
#      Introduced a new target (.t .sl:).
#
#      Revision 1.4  2001/04/03 20:32:08  anand
#      TR JTS 4485
#
#      Revision 1.3  2001/01/22 18:32:02  anand
#      if conditions in makefiles need test arguments!!
#
#      Revision 1.2  2001/01/21 20:56:54  anand
#      Corrected an error in makefiles. Makefiles do not understand
#      parameter substitution as shell scripts do! :(
#
#      Revision 1.1  2001/01/19 20:09:30  anand
#	Template makefile for I/Route. This template may be used by (and is
#	similar to the  templates in) other products as well. The makefile of
#	each directory contains in include directive for either this or one of
#	the other files in this directory.
#
#
#
# History:
# MM/DD/YY  AUTHOR  DESCRIPTION
# 01/18/01  Anand   creation
# 04/20/01  Anand   Ensured .sl and .t files get always slic-ed.
#--------------------------------------------------------------------------

target:	.t .sl mkfile 
	grmake -r -k -f mkfile
	@if test "${ISDP_MAKE_SP}" = "1" ; \
	then \
	   ld -z text -G -o ${SPXR}/lib/${TGT}.so  ${SPXR}/lib/${TGT}.o; \
	   /bin/mv ${SPXR}/lib/${TGT}.so ${SPR}; \
	fi

.sl:
	@if test "${ISDP_MAKE_SP}" = "1" ; \
	then \
	    if /bin/ls ./*.sl >/dev/null 2>&1 ; \
	    then \
		for i in *.sl ; \
		do \
		    echo Slic-ing ${PWD}/$$i with options TCIs ; \
		    ${EXNUC}/bin/Slic -p${ROUTE}/spec -p${VDS}/spec -TCIs $$i; \
		done; \
	    else \
		echo No sl files to slic in ${PWD} for service pack. ; \
	    fi; \
	else \
	    ksh ${ROUTE}/etc/bin/vrslic . ; \
	fi

.t:
	@if test "${ISDP_MAKE_SP}" = "1" ; \
	then \
	    if /bin/ls ./*.t >/dev/null 2>&1 ; \
	    then \
		for i in *.t ; \
		do \
		    echo Slic-ing ${PWD}/$$i with options TCis ; \
		    ${EXNUC}/bin/Slic -p${ROUTE}/spec -p${VDS}/spec -TCis $$i; \
		done; \
	    else \
		echo No t files to slic in ${PWD} for service pack. ; \
	    fi; \
	else \
	    ksh ${ROUTE}/etc/bin/vrslic . ; \
	fi

mkfile:	${TGT}.m
	grmakemake ${TGT}.m mkfile

