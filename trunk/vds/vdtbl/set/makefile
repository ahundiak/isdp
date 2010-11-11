# $Id: makefile,v 1.2 2001/07/27 14:13:01 ylong Exp $

# -------------------------------------------------------------------
# I/VDS
#
# File:	vds/vdtbl/set/makefile 
#
# Description:
#
# Dependencies:
#
# Revision History:
#
# History:
#	MM/DD/YY	AUTHOR		DESCRIPTION
#	04/14/95	R. Manem	Creation
#
# -------------------------------------------------------------------

target:	mkfile
	grmake -r -k -f mkfile
	@ldso   ${VDS_PATH}/lib/vditblset; \
	if test ${ISDP_MAKE_SP} -eq 1; \
	then \
	   /bin/cp ${VDS_PATH}/lib/vditblset.so ${SPV}; \
	fi; \
	/bin/mv ${VDS_PATH}/lib/vditblset.so /usr/tmp/.;

mkfile:	vdtblset.m
	grmakemake vdtblset.m mkfile

clean:
	@rm -f mkfile *.o *.c

