target:	VLseaLinCmdi.I \
	VLbutLinCmdi.I \
	VLallLinCmdi.I \
	mkfile
	grmake -r -k -f mkfile

VLbutLinCmdi.I: VLbutLinCmd.sl $(LOFT)/include/vlmsg.h
	slic -C VLbutLinCmd.sl -p $(LOFT)/spec

VLseaLinCmdi.I: VLseaLinCmd.sl $(LOFT)/include/vlmsg.h
	slic -C VLseaLinCmd.sl -p $(LOFT)/spec

VLallLinCmdi.I: VLallLinCmd.sl $(LOFT)/include/vlmsg.h
	slic -C VLallLinCmd.sl -p $(LOFT)/spec

mkfile:	coline.m
	grmakemake coline.m mkfile
