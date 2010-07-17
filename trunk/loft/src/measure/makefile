target:	VLeqMemCmdi.I \
	pplmkfile \
	mkfile
	grmake -r -k -f mkfile
	grmake -r -k -f pplmkfile

VLeqMemCmdi.I: VLeqMemCmd.sl $(LOFT)/include/vlmsg.h
	slic -C VLeqMemCmd.sl -p $(LOFT)/spec

mkfile: measure.m
	grmakemake measure.m mkfile

pplmkfile: pplmeasure.m
	ksh $(LOFT)/etc/bin/mkmkppl pplmeasure.m pplmkfile $(LOFT)
