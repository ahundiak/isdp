# $Id: makefile,v 1.1.1.1 2001/01/04 21:07:38 cvs Exp $

# -------------------------------------------------------------------
# I/VDS
#
# File:	vds/smspace/ppl/makefile 
#
# Description:
#
# Dependencies:
#
# Revision History:
#	$Log: makefile,v $
#	Revision 1.1.1.1  2001/01/04 21:07:38  cvs
#	Initial import to CVS
#	
# Revision 1.1  1997/05/08  15:16:50  pinnacle
# rep bin w/txt
#
# Revision 1.2  1995/10/27  14:12:02  pinnacle
# Replaced: smspace/ppl/makefile for:  by sundar for vds.240
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

#
# Temporary makefile, because mkmkppl has reached its limits (too many
#			include files)
# 92/10/28

target: mkfile 
#	grmake -r -k -f mkfile

mkfile: smbndppl.m
	ksh ${VDS}/etc/bin/mkmkppl smbndppl.m mkfile $(VDS)

clean:
	@rm -f mkfile *.e

