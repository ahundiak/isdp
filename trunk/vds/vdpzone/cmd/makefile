target:	sl \
	mkfile
	grmake -r -k -f mkfile

sl :	VDPCmdCmpRl.S \
	VDPCmdZone.S \
	${VDS}/config/commands/VDPMngZone \
	${VDS}/config/commands/VDPCrCmRln

${VDS}/config/commands/VDPCrCmRln: VDPCmdCmpRl.t \
	${VDS}/include/SMmsg.h ${VDS}/include/SMcmd.h \
	${VDS}/include/VDmsg.h ${VDS}/include/VDcmd.h
	slic -p${VDS}/spec VDPCmdCmpRl.t

${VDS}/config/commands/VDPMngZone: VDPCmdZone.t \
	${VDS}/include/SMmsg.h ${VDS}/include/SMcmd.h \
	${VDS}/include/VDmsg.h ${VDS}/include/VDcmd.h
	slic -p${VDS}/spec VDPCmdZone.t

mkfile:	vdpzoncmd.m
	grmakemake vdpzoncmd.m mkfile
