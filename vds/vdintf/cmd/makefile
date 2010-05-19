# $Id: makefile,v 1.2 2001/07/10 18:35:55 hans Exp $

# -------------------------------------------------------------------
# I/VDS
#
# File:	vds/vdintf/cmd/makefile 
#
# Description:
#
# Dependencies:
#
# Revision History:
#	$Log: makefile,v $
#	Revision 1.2  2001/07/10 18:35:55  hans
#	No TR. Optimizations for suppressing FALSE Interferences
#	
#	Revision 1.1.1.1  2001/01/04 21:08:52  cvs
#	Initial import to CVS
#	
# Revision 1.3  1997/12/31  17:17:16  pinnacle
# Replaced: vdintf/cmd/makefile for:  by jwfrosch for vds
#
# Revision 1.2  1997/08/04  20:58:10  pinnacle
# Replaced: vdintf/cmd/makefile for:  by jwfrosch for vds
#
# Revision 1.1  1997/05/08  15:35:54  pinnacle
# rep bin w/txt
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

TGT = vdcintfcmd

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

sl:	${VDS}/config/commands/VDIntfAnl \
	${VDS}/config/commands/VDIntfRev

${VDS}/config/commands/VDIntfAnl : VDintf.t \
	${VDS}/include/SMmsg.h ${VDS}/include/SMcmd.h \
	${VDS}/include/VDmsg.h ${VDS}/include/VDcmd.h
	$(EXNUC)/bin/slic -p${VDS}/spec VDintf.t

${VDS}/config/commands/VDIntfRev : VDrevintf.t \
	${VDS}/include/SMmsg.h ${VDS}/include/SMcmd.h \
	${VDS}/include/VDmsg.h ${VDS}/include/VDcmd.h
	$(EXNUC)/bin/slic -p${VDS}/spec VDrevintf.t

mkfile:	vdintfcmd.m
	grmakemake vdintfcmd.m mkfile
