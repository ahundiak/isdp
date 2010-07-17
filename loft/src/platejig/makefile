target:	VLpltJigCmdi.I \
	VLjigTblCmdi.I \
	mkfile \
	 pplmkfile
	grmake -r -k -f mkfile
	grmake -r -k -f pplmkfile

VLpltJigCmdi.I: VLpltJigCmd.sl $(LOFT)/include/vlmsg.h
	slic -C VLpltJigCmd.sl -p $(LOFT)/spec

VLjigTblCmdi.I: VLjigTblCmd.sl $(LOFT)/include/vlmsg.h
	slic -C VLjigTblCmd.sl -p $(LOFT)/spec

mkfile:	platejig.m
	grmakemake platejig.m mkfile

pplmkfile: pplplatejig.m
	ksh $(LOFT)/etc/bin/mkmkppl pplplatejig.m pplmkfile $(LOFT)
