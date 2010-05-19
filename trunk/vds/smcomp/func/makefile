# $Id: makefile,v 1.2 2001/11/05 18:15:19 ylong Exp $

# -------------------------------------------------------------------
# I/VDS
#
# File:	vds/smcomp/func/makefile 
#
# Description:
#
# Dependencies:
#
# Revision History:
#	$Log: makefile,v $
#	Revision 1.2  2001/11/05 18:15:19  ylong
#	*** empty log message ***
#	
#	Revision 1.1.1.1  2001/01/04 21:07:33  cvs
#	Initial import to CVS
#	
# Revision 1.1  1997/05/08  15:01:12  pinnacle
# rep bin w/txt
#
# Revision 1.1  1994/11/14  22:42:32  pinnacle
# Create vds.240 from vds.232
#
# Revision 1.1  1994/11/08  16:07:00  pinnacle
# create vds.232
#
#
# History:
#	MM/DD/YY	AUTHOR		DESCRIPTION
#
# -------------------------------------------------------------------

target: mkfile 
	grmake -r -k -f mkfile 
	ldso    ${VDS_PATH}/lib/smicompfc
	@if test ${ISDP_MAKE_SP} -eq 1; \
	then \
		/bin/cp ${VDS_PATH}/lib/smicompfc.so ${SPV}; \
	fi; \
	/bin/mv ${VDS_PATH}/lib/smicompfc.so /usr/tmp;

mkfile : smcompfc.m
	grmakemake smcompfc.m mkfile


