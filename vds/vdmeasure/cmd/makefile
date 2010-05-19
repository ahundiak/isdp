# $Id: makefile,v 1.1.1.1 2001/01/04 21:08:56 cvs Exp $

#***********************************************************************
# I/VDS
#
# File:         vdmeasure/cmd/makefile
#
# Description:
#
# Dependencies:
#
# Revision History
#       $Log: makefile,v $
#       Revision 1.1.1.1  2001/01/04 21:08:56  cvs
#       Initial import to CVS
#
# Revision 1.1  1997/05/08  15:38:04  pinnacle
# rep bin w/txt
#
# Revision 1.3  1997/03/12  18:06:02  pinnacle
# Replaced: vdmeasure/cmd/makefile for:  by v241_int for vds.241
#
# Revision 1.2  1997/03/12  17:16:16  pinnacle
# Replaced: vdmeasure/cmd/makefile for:  by v241_int for vds.241
#
# Revision 1.1  1996/11/08  21:49:12  pinnacle
# Created: vdmeasure/cmd/makefile by v241_int for vds.241
#
#
# History:
#       MM/DD/YY        AUTHOR          DESCRIPTION
#       11/08/96        mf              creation date
#
#***********************************************************************



target:	sl \
	mkfile
	grmake -r -k -f mkfile 

sl :	VDCmdMeas.S

VDCmdMeas.S :	VDCmdMeas.sl \
	${VDS}/include/SMmsg.h ${VDS}/include/SMcmd.h \
	${VDS}/include/VDmsg.h ${VDS}/include/VDcmd.h
	slic -CT -p ${VDS}/spec VDCmdMeas.sl

mkfile: vdmeascmd.m
	grmakemake vdmeascmd.m mkfile

