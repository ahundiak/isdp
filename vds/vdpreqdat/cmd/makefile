target:	sl \
	mkfile
	grmake -r -k -f mkfile

sl :	VDPCmdPMDef.S \
	${VDS}/config/commands/VDPRqPMDat

${VDS}/config/commands/VDPRqPMDat: VDPCmdPMDef.t \
	${VDS}/include/SMmsg.h ${VDS}/include/SMcmd.h \
	${VDS}/include/VDmsg.h ${VDS}/include/VDcmd.h
	slic -p${VDS}/spec VDPCmdPMDef.t

mkfile:	vdpreqcmd.m
	grmakemake vdpreqcmd.m mkfile
