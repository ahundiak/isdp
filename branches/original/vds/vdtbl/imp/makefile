# $Id: makefile,v 1.6 2002/04/04 21:00:49 ylong Exp $

# I/VDS
#
# File:		vdtbl/imp/makefile 
#
# Description:
#
# Dependencies:
#	$Log: makefile,v $
#	Revision 1.6  2002/04/04 21:00:49  ylong
#	*** empty log message ***
#	
#	Revision 1.5  2001/05/03 14:25:18  ylong
#	*** empty log message ***
#	
#	Revision 1.4  2001/02/12 22:39:38  build
#	Add compilation of PPL
#	
#	Revision 1.3  2001/02/09 22:13:38  build
#	Included mkdir line
#	
#	Revision 1.2  2001/02/07 18:15:59  ramarao
#	*** empty log message ***
#	
#	Revision 1.1.1.1  2001/01/04 21:09:28  cvs
#	Initial import to CVS
#	
# Revision 1.1  1997/05/08  15:44:56  pinnacle
# rep bin w/txt
#
# Revision 1.1  1995/06/07  20:13:28  pinnacle
# Created: vdtbl/imp/* by tdumbach for vds.240
#
# Revision 1.1  1995/04/14  16:09:04  pinnacle
# Created: vdtbl/imp/makefile by tdumbach r#
# rno
#
# Revision 1.1  1995/03/08  21:59:00  pinnacle
# Created: vdtbl/imp/makefile by azuurhou r#
# rno
#
#
# History:
#	MM/DD/YY	AUTHOR		DESCRIPTION
#	03/08/95	mf		creation date

target:	mkfile \
	pplmkfile
	grmake -r -k -f mkfile
	grmake -r -k -f pplmkfile
	@ldso	${VDS_PATH}/lib/vditblimp; \
	if test ${ISDP_MAKE_SP} -eq 1; \
	then \
	   /bin/cp ${VDS_PATH}/lib/vditblimp.so ${SPV}; \
	   TBLAPI=${SP}/api; \
	else \
	   TBLAPI=${VDS}/api/tbl; \
	fi; \
	/bin/mv ${VDS_PATH}/lib/vditblimp.so /usr/tmp/.; \
	mkdir -p $${TBLAPI}; \
	chmod +w $${TBLAPI}/.; \
	if test -f $${TBLAPI}/VDrow_info.u; \
	then \
	   chmod +w $${TBLAPI}/*; \
	fi; \
	/bin/cp VDrow_info.u $${TBLAPI};

	   
mkfile:	vdtblimp.m
	grmakemake vdtblimp.m mkfile

pplmkfile: ppltbli.m
	@if test ${ISDP_MAKE_SP} -eq 1; \
	then \
	   ksh ${VDS_PATH}/etc/bin/mkmkppl ppltbli.m pplmkfile ${SP}; \
	else \
	   ksh ${VDS_PATH}/etc/bin/mkmkppl ppltbli.m pplmkfile ${VDS}; \
	fi
