# $Id: makefile,v 1.4 2002/03/30 16:08:16 ad Exp $

#***********************************************************************
# I/VDS
#
# File:		vdlocate/api/makefile
#
# Description:
#
# Dependencies:
#
# Revision History
#	$Log: makefile,v $
#	Revision 1.4  2002/03/30 16:08:16  ad
#	*** empty log message ***
#	
#	Revision 1.3  2002/03/30 15:56:29  ad
#	*** empty log message ***
#	
#	Revision 1.2  2001/06/04 21:43:51  ramarao
#	Fixed TR# 5287.
#	
#	Revision 1.1.1.1  2001/01/04 21:08:53  cvs
#	Initial import to CVS
#	
# Revision 1.1  1997/05/08  15:36:26  pinnacle
# rep bin w/txt
#
# Revision 1.1  1996/02/20  20:34:18  pinnacle
# Created: ./vdlocate/api/makefile by azuurhou for vds.240
#
#
# History:
#	MM/DD/YY	AUTHOR		DESCRIPTION
#			i-paris		creation date
#
#***********************************************************************

TGT = vdilocapi

target: mkfile
	grmake -r -k -f mkfile
	@if test ${ISDP_MAKE_SP} -eq 1; \
	then \
	   ldso    ${SPXV}/lib/vdilocapi ; \
	   /bin/cp ${SPXV}/lib/vdilocapi.so ${SPV}; \
	   /bin/mv ${SPXV}/lib/vdilocapi.so /usr/tmp; \
	else \
	   ldso    ${VDS}/lib/vdilocapi ; \
	   /bin/mv ${VDS}/lib/vdilocapi.so /usr/tmp; \
	fi

mkfile: ${TGT}.m
	grmakemake ${TGT}.m mkfile
