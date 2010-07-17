target:	VLstfTplCmdi.I \
	mkfile \
	pplmkfile
	grmake -r -k -f mkfile
	grmake -r -k -f pplmkfile

VLstfTplCmdi.I: VLstfTplCmd.sl $(LOFT)/include/vlmsg.h
	slic -C VLstfTplCmd.sl -p $(LOFT)/spec

mkfile:	tpl_stf.m
	grmakemake tpl_stf.m mkfile

pplmkfile: ppltpl_stf.m
	ksh $(LOFT)/etc/bin/mkmkppl ppltpl_stf.m pplmkfile $(LOFT)
