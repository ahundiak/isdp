# $Id: makefile,v 1.1.1.1 2001/01/04 21:08:33 cvs Exp $

# -------------------------------------------------------------------
# I/VDS
#
# File:	vds/vddb/source/makefile 
#
# Description:
#
# Dependencies:
#
# Revision History:
#	$Log: makefile,v $
#	Revision 1.1.1.1  2001/01/04 21:08:33  cvs
#	Initial import to CVS
#	
# Revision 1.1  1997/05/08  15:29:58  pinnacle
# rep bin w/txt
#
# Revision 1.4  1996/05/27  19:35:34  pinnacle
# Replaced: vddb/source/makefile for:  by v240_int for vds.240
#
# Revision 1.3  1996/04/08  13:48:34  pinnacle
# Replaced: vddb/source/makefile for:  by v240_int for vds.240
#
# Revision 1.2  1995/11/21  21:22:06  pinnacle
# Replaced: ./vddb/source/makefile for:  by azuurhou for vds.240
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
#	11/21/95	adz/tlb		modified for multiplatforms.
#	04/08/96	tlb		Add ksh to support -DEBUG option
#
# -------------------------------------------------------------------

target:	mkfile 
	ksh grmake -r -k -f mkfile 
	ksh grmake -r -k -f make_$${CPUTYPE}

mkfile:	vddb_${CPUTYPE}.m 
	grmakemake vddb_${CPUTYPE}.m mkfile 

