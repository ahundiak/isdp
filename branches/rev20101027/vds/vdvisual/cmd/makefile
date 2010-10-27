# $Id: makefile,v 1.1.1.1 2001/01/04 21:09:32 cvs Exp $

# -------------------------------------------------------------------
# I/VDS
#
# File:	vds/vdvisual/cmd/makefile 
#
# Description:
#
# Dependencies:
#
# Revision History:
#	$Log: makefile,v $
#	Revision 1.1.1.1  2001/01/04 21:09:32  cvs
#	Initial import to CVS
#	
# Revision 1.1  1997/05/08  15:46:38  pinnacle
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

target: sl \
	${VDS}/config/commands/VDRpDr \
	$(VDS)/ppl/bin/COdircmdfrm.e \
	mkfile
	grmake -r -k -f mkfile

sl: VDCmdGridOn.S \
	VDCmdGridOf.S 

VDCmdGridOn.S : VDCmdGridOn.sl \
	${VDS}/include/SMmsg.h ${VDS}/include/SMcmd.h \
        ${VDS}/include/VDmsg.h ${VDS}/include/VDcmd.h
	slic -C -p${VDS}/spec VDCmdGridOn.sl

VDCmdGridOf.S : VDCmdGridOf.sl \
	${VDS}/include/SMmsg.h ${VDS}/include/SMcmd.h \
        ${VDS}/include/VDmsg.h ${VDS}/include/VDcmd.h
	slic -C -p${VDS}/spec VDCmdGridOf.sl

$(VDS)/config/commands/VDRpDr : VDCmdDirRpt.t \
	${VDS}/include/SMmsg.h ${VDS}/include/SMcmd.h \
        ${VDS}/include/VDmsg.h ${VDS}/include/VDcmd.h
	slic -CT -p${VDS}/spec VDCmdDirRpt.t

$(VDS)/ppl/bin/COdircmdfrm.e : COdircmdfrm.u
	@/bin/echo "\t remaking COdircmdfrm.e\n"
	$(GRNUC)/bin/cci -m -q -s -p$(EXNUC)/bin/omcpp \
	-I$(BS)/include			\
	-I$(EXNUC)/include		\
	-I$(GRNUC)/include		\
	-I$(MODEL)/include		\
	-I$(VDS)/include		COdircmdfrm.u
	mv COdircmdfrm.e $(VDS)/ppl/bin/COdircmdfrm.e

mkfile : vdvisucmd.m
	grmakemake vdvisucmd.m mkfile

