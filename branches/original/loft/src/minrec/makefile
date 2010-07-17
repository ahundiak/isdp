target:	VLminRecCmdi.I \
	mkfile
	grmake -r -k -f mkfile

VLminRecCmdi.I: VLminRecCmd.sl $(LOFT)/include/vlmsg.h
	slic -C VLminRecCmd.sl -p $(LOFT)/spec

mkfile:	minrec.m
	grmakemake minrec.m mkfile
