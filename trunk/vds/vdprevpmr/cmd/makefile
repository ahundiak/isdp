target:	sl \
	mkfile
	grmake -r -k -f mkfile

sl :	VDPCmdRvPmr.S \
	${VDS}/config/commands/VDPRvPmrWP

${VDS}/config/commands/VDPRvPmrWP: VDPCmdRvPmr.t \
	${VDS}/include/SMmsg.h ${VDS}/include/SMcmd.h \
	${VDS}/include/VDmsg.h ${VDS}/include/VDcmd.h
	slic -p${VDS}/spec VDPCmdRvPmr.t

mkfile:	vdprvpcmd.m
	grmakemake vdprvpcmd.m mkfile
