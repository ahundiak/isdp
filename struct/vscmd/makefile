#/* $Id $  */

#/***************************************************************************
# * I/STRUCT
# *
# * File:        isdp/struct/vscmd/makefile
# *
# * Description:
# *
# * Dependencies:
# *
# * Revision History:
# *      $Log $
# *
# * History:
# * MM/DD/YY  AUTHOR  DESCRIPTION
# * 05/06/01  Jayadev File Creation
# ***************************************************************************/
# TGT = vscmd
# include ${STRUCT}/etc/makefiles/lib_only.h

target: VSselectCmdi.I mkfile
	grmake -r -k -f mkfile
	@if test ${ISDP_MAKE_SP} -eq 1; \
	then \
	  ldso    ${SPXS}/lib/vscmd; \
	  /bin/cp ${SPXS}/lib/vscmd.so ${SPS}; \
	  /bin/mv ${SPXS}/lib/vscmd.so /usr/tmp ; \
	else \
	  ldso    ${STRUCT}/lib/vscmd; \
	  /bin/mv ${STRUCT}/lib/vscmd.so /usr/tmp ; \
	fi

VSselectCmdi.I: VSselectCmd.sl
	/bin/touch -c VSselectCmd.sl
	slic -C VSselectCmd.sl -p $(STRUCT)/spec

mkfile: vscmd.m
	grmakemake vscmd.m mkfile
