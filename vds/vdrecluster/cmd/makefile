# $Id: makefile,v 1.1.1.1 2001/01/04 21:09:06 cvs Exp $

#**********************************************************************
# I/VDS
#
# File: vds240/vdrecluster/cmd/makefile
#
# Description:
#
# Dependencies:
#
# Revision History:
#       $Log: makefile,v $
#       Revision 1.1.1.1  2001/01/04 21:09:06  cvs
#       Initial import to CVS
#
# Revision 1.1  1997/05/08  15:41:56  pinnacle
# rep bin w/txt
#
# Revision 1.1  1995/12/06  15:59:36  pinnacle
# Created: vdrecluster/cmd/makefile by jwfrosch for vds.240
#
#
# History:
#       MM/DD/YY        AUTHOR          DESCRIPTION
#
#**********************************************************************

target: mkfile
	grmake -r -k -f mkfile

mkfile : vdrecluscmd.m
	grmakemake vdrecluscmd.m mkfile

clean:
	@rm -f mkfile *.o *.c
