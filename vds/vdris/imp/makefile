# $Id: makefile,v 1.1.1.1 2001/01/04 21:09:12 cvs Exp $

# -------------------------------------------------------------------
# I/VDS
#
# File:	vds/vdris/imp/makefile 
#
# Description:
#
# Dependencies:
#
# Revision History:
#	$Log: makefile,v $
#	Revision 1.1.1.1  2001/01/04 21:09:12  cvs
#	Initial import to CVS
#	
# Revision 1.1  1997/05/08  15:42:48  pinnacle
# rep bin w/txt
#
# Revision 1.2  1996/04/08  13:45:38  pinnacle
# Replaced: vdris/imp/makefile for:  by v240_int for vds.240
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
#	04/08/96	tlb		Add ksh to support -DEBUG option 
#
# -------------------------------------------------------------------

target:	loadmkfile execmkfile 
	ksh grmake -r -k -f loadmkfile
	ksh grmake -r -k -f execmkfile

loadmkfile: risload.m
	grmakemake risload.m loadmkfile

execmkfile: risexec.m
	grmakemake risexec.m execmkfile

clean:
	@rm -f loadmkfile execmkfile *.o *.c

