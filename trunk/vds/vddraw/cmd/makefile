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

clean:
	@rm -f mkfile *.o *.c

