target: VLplEdAtCmdi.I \
	pplmkfile \
	mkfile
	grmake -r -k -f mkfile 
	grmake -r -k -f pplmkfile

VLplEdAtCmdi.I:	VLplEdAtCmd.sl $(LOFT)/include/vlmsg.h
	slic -C VLplEdAtCmd.sl -p $(LOFT)/spec

mkfile:	attrib.m
	grmakemake attrib.m mkfile

pplmkfile: pplattrib.m
	ksh $(LOFT)/etc/bin/mkmkppl pplattrib.m pplmkfile $(LOFT)
