# $Id: makefile,v 1.4 2002/03/30 15:17:35 ad Exp $

# -------------------------------------------------------------------
# I/VDS
#
# File:	vds/emsfixes/grnuc/makefile 
#
# Description:
#
# Dependencies:
#
# Revision History:
#	$Log: makefile,v $
#	Revision 1.4  2002/03/30 15:17:35  ad
#	Changed the makefile to reflect generic script.
#	
#	Revision 1.3  2001/06/04 13:44:39  jdsauby
#	CR3403, needed to fix GRprtmod.I and GRprtchg.I
#	
#	Revision 1.2  2001/03/08 19:13:32  ramarao
#	Added this in elinmaster.sl file in cvs.
#	
#	Revision 1.1.1.1  2001/01/04 21:07:28  cvs
#	Initial import to CVS
#	
# History:
#	MM/DD/YY	AUTHOR		DESCRIPTION
#
# -------------------------------------------------------------------

TGT = vdidloadgrnuc

include ${VDS_PATH}/etc/makefiles/lib_only.h

clean:
	@rm -f mkfile *.o *.c

#if 0
#target : elinmasteri.I \
#	 mkfile
#	 grmake -r -k -f mkfile

#elinmasteri.I: elinmaster.sl $(VDS)/include/VDmsg.h
#	slic -isTC elinmaster.sl

#mkfile : vdgr.m
#	grmakemake vdgr.m mkfile
#endif
