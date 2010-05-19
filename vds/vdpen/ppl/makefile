# $Id: makefile,v 1.6 2001/05/16 15:52:53 ylong Exp $

# -------------------------------------------------------------------
# I/VDS
#
# File:	vds/vdpen/ppl/makefile 
#
# Description:
#
# Dependencies:
#
# Revision History:
#	$Log: makefile,v $
#	Revision 1.6  2001/05/16 15:52:53  ylong
#	*** empty log message ***
#	
#	Revision 1.5  2001/05/09 19:56:31  ylong
#	*** empty log message ***
#	
#	Revision 1.4  2001/01/24 22:24:22  build
#	*** empty log message ***
#	
#	Revision 1.3  2001/01/24 15:18:53  ad
#	*** empty log message ***
#	
#	Revision 1.2  2001/01/19 22:32:35  jayadev
#	*** empty log message ***
#	
#	Revision 1.1.1.1  2001/01/04 21:08:58  cvs
#	Initial import to CVS
#	
#
# History:
#	MM/DD/YY	AUTHOR		DESCRIPTION
#	05/02/99	adz/jhanson	first integration
# -------------------------------------------------------------------

target: pplmkfile \
	mkfile
	grmake -r -k -f mkfile
	grmake -r -k -f pplmkfile
	@ldso   ${VDS_PATH}/lib/vdipen; \
	if test ${ISDP_MAKE_SP} -eq 1; \
	then \
	   /bin/cp ${VDS_PATH}/lib/vdipen.so ${SPV}; \
	fi; \
	/bin/mv ${VDS_PATH}/lib/vdipen.so /usr/tmp/.; 

mkfile: vdpen.m
	grmakemake vdpen.m mkfile

pplmkfile: vdpenppl.m
	@if test ${ISDP_MAKE_SP} -eq 1; \
	then \
	   ksh ${VDS_PATH}/etc/bin/mkmkppl vdpenppl.m pplmkfile ${SP}; \
	else \
	   ksh ${VDS_PATH}/etc/bin/mkmkppl vdpenppl.m pplmkfile ${VDS}; \
	fi
