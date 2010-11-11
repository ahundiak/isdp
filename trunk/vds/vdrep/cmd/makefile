# $Id: makefile,v 1.3 2001/10/24 21:13:36 ylong Exp $

# -------------------------------------------------------------------
# I/VDS
#
# File:	vds/vdrep/cmd/makefile 
#
# Description:
#
# Dependencies:
#
# Revision History:
#	$Log: makefile,v $
#	Revision 1.3  2001/10/24 21:13:36  ylong
#	*** empty log message ***
#	
#	Revision 1.2  2001/01/08 19:06:19  art
#	ah
#	
# Revision 1.1  1997/05/08  15:42:16  pinnacle
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
	pplmkfile \
	mkfile
	grmake -r -k -f mkfile
#	grmake -r -k -f pplmkfile
	@if test ${ISDP_MAKE_SP} -eq 1; \
	then \
	   ldso    ${VDS_PATH}/lib/vdcrepcmd; \
	   /bin/mv ${VDS_PATH}/lib/vdcrepcmd.so ${SPV};   \
	fi; \

sl: VDCmdRep.S \
	VDCmdChgRep.S \
	VDCmdChgPth.S 


VDCmdRep.S : VDCmdRep.sl \
	${VDS}/include/SMmsg.h ${VDS}/include/SMcmd.h \
        ${VDS}/include/VDmsg.h ${VDS}/include/VDcmd.h
	slic -C -p${VDS}/spec VDCmdRep.sl

VDCmdChgRep.S : VDCmdChgRep.sl \
	${VDS}/include/SMmsg.h ${VDS}/include/SMcmd.h \
        ${VDS}/include/VDmsg.h ${VDS}/include/VDcmd.h
	slic -C -p${VDS}/spec VDCmdChgRep.sl

VDCmdChgPth.S : VDCmdChgPth.sl \
	${VDS}/include/SMmsg.h ${VDS}/include/SMcmd.h \
        ${VDS}/include/VDmsg.h ${VDS}/include/VDcmd.h
	slic -C -p${VDS}/spec VDCmdChgPth.sl

mkfile: vdrepcmd.m
	grmakemake vdrepcmd.m mkfile

pplmkfile: vdrepppl.m
	ksh $(VDS)/etc/bin/mkmkppl vdrepppl.m pplmkfile $(VDS)

clean:
	@rm -f mkfile pplmkfile *.e *.o *.c
