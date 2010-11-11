# $Id: makefile,v 1.2 2001/06/08 19:34:20 ylong Exp $

# -------------------------------------------------------------------
# I/VDS
#
# File:	vds/vdtbl/mgr/makefile 
#
# Description:
#
# Dependencies:
#
# Revision History:
#	$Log: makefile,v $
#	Revision 1.2  2001/06/08 19:34:20  ylong
#	TR5299
#	
#	Revision 1.1.1.1  2001/01/04 21:09:28  cvs
#	Initial import to CVS
#	
# Revision 1.1  1997/05/08  15:45:00  pinnacle
# rep bin w/txt
#
# Revision 1.1  1995/06/07  20:09:28  pinnacle
# Created: vdtbl/mgr/* by tdumbach for vds.240
#
# Revision 1.1  1995/04/17  15:00:54  pinnacle
# Created: vdtbl/mgr/makefile by hverstee r#
# rno
#
#
# History:
#	MM/DD/YY	AUTHOR		DESCRIPTION
#
# -------------------------------------------------------------------

target:	mkfile
	grmake -r -k -f mkfile
	@ldso    ${VDS_PATH}/lib/vditblmgr
	@if test ${ISDP_MAKE_SP} -eq 1; \
	then \
	   /bin/cp ${VDS_PATH}/lib/vditblmgr.so ${SPV}; \
	fi; \
	/bin/mv ${VDS_PATH}/lib/vditblmgr.so /usr/tmp;

mkfile : vdtblmgr.m
	grmakemake vdtblmgr.m mkfile

clean:
	@rm -f mkfile *.o *.c


