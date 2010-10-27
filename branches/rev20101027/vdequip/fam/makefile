# $Id: makefile,v 1.1.1.1 2001/01/04 21:08:43 cvs Exp $

# -------------------------------------------------------------------
# I/VDS
#
# File:	vds/vdequip/fam/makefile 
#
# Description:
#
# Dependencies:
#
# Revision History:
#	$Log: makefile,v $
#	Revision 1.1.1.1  2001/01/04 21:08:43  cvs
#	Initial import to CVS
#	
# Revision 1.1  1997/05/08  15:33:26  pinnacle
# rep bin w/txt
#
# Revision 1.4  1995/12/15  14:58:52  pinnacle
# Replaced: vdequip/fam/makefile for:  by v240_int for vds.240
#
# Revision 1.3  1995/02/16  21:40:22  pinnacle
# Replaced: vdequip/fam/makefile by jwfrosch r#
#
# Revision 1.2  1995/02/14  19:27:12  pinnacle
# Replaced: vdequip/fam by azuurhou r#
#
# Revision 1.1  1995/02/07  22:48:56  pinnacle
# Created: vdequip/fam/makefile by tdumbach r#
#
# Revision 1.1  1994/11/16  20:17:08  pinnacle
# forgotten directory
#
#
# History:
#	MM/DD/YY	AUTHOR		DESCRIPTION
#	12/15/95	adz		Add "sl" make option.
#
# -------------------------------------------------------------------

target: sl mkfile
	grmake -r -k -f mkfile

sl:	${VDS}/config/commands/VDGnFmFl

${VDS}/config/commands/VDGnFmFl : VDCmdGenFam.t VDCmdGenFam.S	\
        ${VDS}/include/SMmsg.h ${VDS}/include/SMcmd.h		\
        ${VDS}/include/VDmsg.h ${VDS}/include/VDcmd.h
	$(EXNUC)/bin/slic -isTC -p${VDS}/spec VDCmdGenFam.t

mkfile: vdequipfam.m
	grmakemake vdequipfam.m mkfile
