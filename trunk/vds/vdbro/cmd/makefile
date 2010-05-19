# $Id: makefile,v 1.1.1.1 2001/01/04 21:07:57 cvs Exp $  

#/***************************************************************************
# * I/VDS
# *
# * File:        vdbro/cmd/makefile
# *
# * Description:
# *
# * Dependencies:
# *
# * Revision History:
# *      $Log: makefile,v $
# *      Revision 1.1.1.1  2001/01/04 21:07:57  cvs
# *      Initial import to CVS
# *
# Revision 1.3  1997/11/25  16:56:10  pinnacle
# VDmaster
#
# Revision 1.1  1997/10/29  17:23:02  pinnacle
# ah creation
#
# *
# * History:
# *      MM/DD/YY  AUTHOR  DESCRIPTION
# *      10/29/97  ah      added header
# ***************************************************************************/

target:	sl \
	mkfile
	grmake -r -k -f mkfile

sl: ${VDS}/config/commands/VDbro

${VDS}/config/commands/VDbro: VDCbro.S VDCbro.t \
	${VDS}/include/SMmsg.h ${VDS}/include/SMcmd.h \
        ${VDS}/include/VDmsg.h ${VDS}/include/VDcmd.h
	slic -C -p${VDS}/spec VDCbro.t

mkfile:	vdcbro.m
	grmakemake vdcbro.m mkfile
