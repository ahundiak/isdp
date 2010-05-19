# $Id: makefile,v 1.1.1.1 2001/01/04 21:09:23 cvs Exp $ 

#/***************************************************************************
# * I/VDS
# *
# * File:        vdsup/cmp/makefile
# *
# * Description:
# *
# * Dependencies:
# *
# * Revision History:
# *      $Log: makefile,v $
# *      Revision 1.1.1.1  2001/01/04 21:09:23  cvs
# *      Initial import to CVS
# *
# Revision 1.2  1997/10/29  15:20:36  pinnacle
# Added Headers
#
# *
# * History:
# *      MM/DD/YY        AUTHOR          DESCRIPTIO
# *      10/29/97        ah              added header
# ***************************************************************************/

target:	sl \
	mkfile
	grmake -r -k -f mkfile

sl: ${VDS}/config/commands/VDsupCrvPl

${VDS}/config/commands/VDsupCrvPl: VDCsupGenPl.S VDCsupGenPl.t \
	${VDS}/include/SMmsg.h ${VDS}/include/SMcmd.h \
        ${VDS}/include/VDmsg.h ${VDS}/include/VDcmd.h
	slic -C -p${VDS}/spec VDCsupGenPl.t

mkfile:	vdcsup.m
	grmakemake vdcsup.m mkfile
