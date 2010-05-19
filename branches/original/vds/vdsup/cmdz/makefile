target:	sl \
	mkfile
	grmake -r -k -f mkfile

sl: ${VDS}/config/commands/VDzupCrvPl

${VDS}/config/commands/VDzupCrvPl: VDCzupGenPl.S VDCzupGenPl.t \
	${VDS}/include/SMmsg.h ${VDS}/include/SMcmd.h \
        ${VDS}/include/VDmsg.h ${VDS}/include/VDcmd.h
	slic -C -p${VDS}/spec VDCzupGenPl.t

mkfile:	vdcsup.m
	grmakemake vdcsup.m mkfile
