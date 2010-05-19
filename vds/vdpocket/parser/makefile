# $Id: makefile,v 1.1.1.1 2001/01/04 21:09:01 cvs Exp $

# -------------------------------------------------------------------
# I/VDS
#
# File:	vds/vdpocket/parser/makefile 
#
# Description:
#
# Dependencies:
#
# Revision History:
#	$Log: makefile,v $
#	Revision 1.1.1.1  2001/01/04 21:09:01  cvs
#	Initial import to CVS
#	
# Revision 1.1  1997/05/08  15:39:36  pinnacle
# rep bin w/txt
#
# Revision 1.4  1995/05/09  15:58:08  pinnacle
# Replace: vdpocket/parser/makefile by tdumbach for OPE
#
# Revision 1.3  1995/01/23  15:30:08  pinnacle
# Replaced: vdpocket/parser/makefile by tlbriggs r#
#
# Revision 1.2  1995/01/23  15:19:24  pinnacle
# Replaced: vdpocket/parser/makefile by tlbriggs r#
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
#	01/16/95	tlb		added target test to compile 
#					   standalone test program 
# -------------------------------------------------------------------

# make options
# MK_OPT = -DEBUG VERBOSE_RULES=yes
# MKMK_OPT = -DEBUG -v

target:	mkfile 
	grmake ${MK_OPT} -r -k -f mkfile

mkfile:	imp.m
	grmakemake ${MKMK_OPT} imp.m mkfile

test: target 
	grmake ${MK_OPT} -r -k -f mkfile query.o
	acc -o query query.o sql.o
