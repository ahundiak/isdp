target: VLstfBenCmdi.I \
	VLheiStbCmdi.I \
	mkfile \
	pplmkfile
	grmake -r -k -f mkfile
	grmake -r -k -f pplmkfile

VLstfBenCmdi.I: VLstfBenCmd.sl $(LOFT)/include/vlmsg.h
	slic -C VLstfBenCmd.sl -p $(LOFT)/spec

VLheiStbCmdi.I: VLheiStbCmd.sl $(LOFT)/include/vlmsg.h
	slic -C VLheiStbCmd.sl -p $(LOFT)/spec

mkfile:	bend.m
	grmakemake bend.m mkfile

pplmkfile: pplbend.m
	ksh $(LOFT)/etc/bin/mkmkppl pplbend.m pplmkfile $(LOFT)
