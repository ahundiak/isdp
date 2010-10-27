# $Id: makefile,v 1.4 2002/05/20 15:20:38 ylong Exp $

# -------------------------------------------------------------------
# I/VDS
#
# File:	vds/vddraw/cmd/makefile 
#
# Description:
#
# Dependencies:
#
# Revision History:
#	$Log: makefile,v $
#	Revision 1.4  2002/05/20 15:20:38  ylong
#	*** empty log message ***
#	
#	Revision 1.3  2002/02/26 15:59:10  ahundiak
#	ah
#	
#	Revision 1.2  2001/10/08 22:37:05  jayadev
#	*** empty log message ***
#	
#	Revision 1.1.1.1  2001/01/04 21:08:36  cvs
#	Initial import to CVS
#	
# Revision 1.1  1997/05/08  15:30:54  pinnacle
# rep bin w/txt
#
# Revision 1.8  1995/08/21  16:51:54  pinnacle
# Replaced: vddraw/cmd/makefile for:  by azuurhou for vds.240
#
# Revision 1.7  1995/06/27  19:22:00  pinnacle
# Replaced: vddraw/cmd/makefile for:  by azuurhou for vds.240
#
# Revision 1.6  1995/03/16  19:12:58  pinnacle
# Replaced: vddraw/cmd/makefile by azuurhou r#
#
# Revision 1.5  1995/01/20  21:04:28  pinnacle
# Replaced:  vddraw/cmd/makefile r#
#
# Revision 1.4  1995/01/20  21:01:16  pinnacle
# Replaced: vddraw/cmd/makefile by azuurhou r#
#
# Revision 1.3  1995/01/09  17:04:28  pinnacle
# Replaced: vddraw/cmd by azuurhou r#
#
# Revision 1.2  1994/12/23  20:03:08  pinnacle
# Replaced: vddraw/cmd/makefile by tdumbach r#
#
# Revision 1.1  1994/12/22  22:10:26  pinnacle
# OPE
#
#
# History:
#	MM/DD/YY	AUTHOR		DESCRIPTION
#	12/01/94	adz		creation date
#	10/03/95	adz		added drawing parameters command.
#	25/06/95	adz		added Push queue command.
#	08/21/95	adz		Delete atlernative section-cut com.
#
# -------------------------------------------------------------------

# Kludged below lines for Service Pack
target: sl \
	${VDS}/config/commands/VDDfDwLo	\

target:	mkfile 
	grmake -r -k -f mkfile
	@if test ${ISDP_MAKE_SP} -eq 1; \
	then \
	  ldso    ${SPXV}/lib/vdcdrawcmd; \
	  /bin/cp ${SPXV}/lib/vdcdrawcmd.so ${SPV};   \
	  /bin/mv ${SPXV}/lib/vdcdrawcmd.so /usr/tmp; \
	else \
	  ldso    ${VDS}/lib/vdcdrawcmd; \
	  /bin/mv ${VDS}/lib/vdcdrawcmd.so /usr/tmp; \
	fi

sl	: $(VDS)/config/commands/VDOPE_ExDr \
	VDCmdDrwVw.S	\
	VDCmdDfDwLo.S	\
	VDCmdSctCts.S

VDCmdSctCts.S : VDCmdSctCts.sl \
	${VDS}/include/SMmsg.h ${VDS}/include/SMcmd.h \
	${VDS}/include/VDmsg.h ${VDS}/include/VDcmd.h
	slic -CT -p$(VDS)/spec VDCmdSctCts.sl

VDCmdDrwVw.S : VDCmdDrwVw.sl \
	${VDS}/include/SMmsg.h ${VDS}/include/SMcmd.h \
	${VDS}/include/VDmsg.h ${VDS}/include/VDcmd.h
	slic -CT -p$(VDS)/spec VDCmdDrwVw.sl

VDCmdDfDwLo.S : VDCmdDfDwLo.sl \
	${VDS}/include/SMmsg.h ${VDS}/include/SMcmd.h \
	${VDS}/include/VDmsg.h ${VDS}/include/VDcmd.h
	slic -CT -p$(VDS)/spec VDCmdDfDwLo.sl

$(VDS)/config/commands/VDOPE_ExDr : VDCmdExDr.t \
	${VDS}/include/SMmsg.h ${VDS}/include/SMcmd.h \
	${VDS}/include/VDmsg.h ${VDS}/include/VDcmd.h
	slic -p$(VDS)/spec VDCmdExDr.t

mkfile : vddrawcmd.m
	grmakemake vddrawcmd.m mkfile

