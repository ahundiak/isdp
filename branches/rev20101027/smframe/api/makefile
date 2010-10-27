# $Id: makefile,v 1.2 2001/05/09 15:46:40 ylong Exp $

#***********************************************************************
# I/VDS
#
# File:		smframe/api/makefile
#
# Description:
#
# Dependencies:
#
# Revision History
#	$Log: makefile,v $
#	Revision 1.2  2001/05/09 15:46:40  ylong
#	*** empty log message ***
#	
#	Revision 1.1.1.1  2001/01/04 21:07:34  cvs
#	Initial import to CVS
#	
# Revision 1.1  1997/05/08  15:06:32  pinnacle
# rep bin w/txt
#
# Revision 1.1  1996/02/20  20:33:54  pinnacle
# Created: ./smframe/api/makefile by azuurhou for vds.240
#
#
# History:
#	MM/DD/YY	AUTHOR		DESCRIPTION
#
#***********************************************************************

target:	mkfile
	grmake -r -k -f mkfile 
	@if test ${ISDP_MAKE_SP} -eq 1; \
	then \
	   ldso    ${SPXV}/lib/smiframeapi; \
	   /bin/cp ${SPXV}/lib/smiframeapi.so ${SPV};   \
	   /bin/mv ${SPXV}/lib/smiframeapi.so /usr/tmp; \
	else \
	   ldso    ${VDS}/lib/smiframeapi; \
	   /bin/mv ${VDS}/lib/smiframeapi.so /usr/tmp; \
	fi

mkfile: smfrmapi.m
	grmakemake smfrmapi.m mkfile
