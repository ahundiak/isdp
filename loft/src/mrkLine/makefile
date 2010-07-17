target:	VLplCntrCmdi.I \
	VLplMarkCmdi.I \
	VLplRollCmdi.I \
	mkfile \
	pplmkfile
	grmake -r -k -f mkfile
	grmake -r -k -f pplmkfile

VLplCntrCmdi.I:	VLplCntrCmd.sl $(LOFT)/include/vlmsg.h
	slic -C VLplCntrCmd.sl -p $(LOFT)/spec

VLplMarkCmdi.I:	VLplMarkCmd.sl $(LOFT)/include/vlmsg.h
	slic -C VLplMarkCmd.sl -p $(LOFT)/spec

VLplRollCmdi.I:	VLplRollCmd.sl $(LOFT)/include/vlmsg.h
	slic -C VLplRollCmd.sl -p $(LOFT)/spec

mkfile:	mrkLine.m
	grmakemake mrkLine.m mkfile

pplmkfile: pplmrkLine.m
	ksh $(LOFT)/etc/bin/mkmkppl pplmrkLine.m pplmkfile $(LOFT)
