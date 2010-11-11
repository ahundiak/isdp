# $Id: makefile,v 1.1.1.1 2001/01/04 21:09:12 cvs Exp $

# -------------------------------------------------------------------
# I/VDS
#
# File:	vds/vdris/ris/makefile 
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
# Revision 1.1  1997/05/08  15:42:42  pinnacle
# rep bin w/txt
#
# Revision 1.5  1996/04/08  13:43:16  pinnacle
# Replaced: vdris/ris/makefile for:  by v240_int for vds.240
#
# Revision 1.4  1995/12/14  18:13:24  pinnacle
# Replaced: ./vdris/ris/makefile for:  by azuurhou for vds.240
#
# Revision 1.3  1995/11/21  21:21:20  pinnacle
# Replaced: ./vdris/ris/makefile for:  by azuurhou for vds.240
#
# Revision 1.2  1995/10/30  17:00:50  pinnacle
# Replaced: vdris/ris/makefile for:  by sundar for vds.240
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
#	12/14/95	adz		make system dependent makefiles.
#	04/08/96	tlb		Add ksh to support -DEBUG option
#
# -------------------------------------------------------------------

target:
	ksh grmake -r -k -f make_"`uname -s`"

clean:
	@rm -f *.o *.c
	@rm -f ${VDS}/vdris/lib/VdsRisLib.o

