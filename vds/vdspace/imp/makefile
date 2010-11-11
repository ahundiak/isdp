# $Id: makefile,v 1.1.1.1 2001/01/04 21:09:22 cvs Exp $

# -------------------------------------------------------------------
# I/VDS
#
# File:	vdspace/imp/makefile 
#
# Description:
#
# Dependencies:
#
# Revision History:
#	$Log: makefile,v $
#	Revision 1.1.1.1  2001/01/04 21:09:22  cvs
#	Initial import to CVS
#	
# Revision 1.1  1997/05/08  15:43:10  pinnacle
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

mkfile: vdspaceimp.m
	grmakemake vdspaceimp.m mkfile

clean:
	@rm -f mkfile *.o *.c

