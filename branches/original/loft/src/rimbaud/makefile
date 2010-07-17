target: VLcoToAlCmdi.I \
	mkfile
	grmake -r -k -f mkfile

VLcoToAlCmdi.I:	VLcoToAlCmd.sl $(LOFT)/include/vlmsg.h
	slic -C VLcoToAlCmd.sl -p $(LOFT)/spec

mkfile:	rimbaud.m
	grmakemake rimbaud.m mkfile
