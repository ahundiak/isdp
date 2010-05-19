# $Id: makefile,v 1.3 2001/06/06 16:38:38 hans Exp $

# -------------------------------------------------------------------
# I/VDS
#
# File:	vds/vdrap/makefile
#
# Description:
#
# Dependencies:
#
# Revision History:
#	$Log: makefile,v $
#	Revision 1.3  2001/06/06 16:38:38  hans
#	Fix for TR#5210 - Start/Stop record not working if ISDP_JOURNAL is not set.
#	
#	Revision 1.2  2001/03/05 15:45:37  hans
#	*** empty log message ***
#	
#	Revision 1.1  2001/03/02 22:55:54  hans
#	Created
#	
#
# History:
#	MM/DD/YY	AUTHOR		DESCRIPTION
#
# -------------------------------------------------------------------

TGT = vdirap

target:	sl \
	mkfile
	grmake -r -k -f mkfile
	@if test ${ISDP_MAKE_SP} -eq 1; \
	then \
	   ldso    ${SPXV}/lib/${TGT}; \
	   /bin/cp ${SPXV}/lib/${TGT}.so ${SPV};   \
	   /bin/mv ${SPXV}/lib/${TGT}.so /usr/tmp; \
	else \
	   ldso    ${VDS}/lib/${TGT}; \
	   /bin/mv ${VDS}/lib/${TGT}.so /usr/tmp; \
	fi

sl:	$(VDS)/config/commands/VDRAPcobCO \
	$(VDS)/config/commands/VDStrtRcrd \
	$(VDS)/config/commands/VDStopRcrd \
	$(VDS)/config/commands/VDShRc

$(VDS)/config/commands/VDRAPcobCO : VDRAPcobCO.t \
	$(VDS)/include/SMmsg.h $(VDS)/include/SMcmd.h \
	$(VDS)/include/VDmsg.h $(VDS)/include/VDcmd.h
	$(EXNUC)/bin/slic -p$(VDS)/spec VDRAPcobCO.t

$(VDS)/config/commands/VDStrtRcrd : VDRAPcobCO.t startrec.t \
	$(VDS)/include/SMmsg.h $(VDS)/include/SMcmd.h \
	$(VDS)/include/VDmsg.h $(VDS)/include/VDcmd.h
	$(EXNUC)/bin/slic -p$(VDS)/spec startrec.t

$(VDS)/config/commands/VDStopRcrd : VDRAPcobCO.t stoprec.t \
	$(VDS)/include/SMmsg.h $(VDS)/include/SMcmd.h \
	$(VDS)/include/VDmsg.h $(VDS)/include/VDcmd.h
	$(EXNUC)/bin/slic -p$(VDS)/spec stoprec.t

$(VDS)/config/commands/VDShRc : VDRAPcobCO.t shutdownrec.t \
	$(VDS)/include/SMmsg.h $(VDS)/include/SMcmd.h \
	$(VDS)/include/VDmsg.h $(VDS)/include/VDcmd.h
	$(EXNUC)/bin/slic -p$(VDS)/spec shutdownrec.t

mkfile:	vdrap.m
	grmakemake vdrap.m mkfile
