target:	VLtpl2dCmdi.I \
	VLtpl3dCmdi.I \
	VLprjTplCmdi.I \
	VLmodTplCmdi.I \
	VLchtTplCmdi.I \
	VLheiTplCmdi.I \
	mkfile \
	pplmkfile
	grmake -r -k -f mkfile
	grmake -r -k -f pplmkfile

VLtpl2dCmdi.I: VLtpl2dCmd.sl $(LOFT)/include/vlmsg.h
	slic -C VLtpl2dCmd.sl -p $(LOFT)/spec

VLtpl3dCmdi.I: VLtpl3dCmd.sl $(LOFT)/include/vlmsg.h
	slic -C VLtpl3dCmd.sl -p $(LOFT)/spec

VLprjTplCmdi.I: VLprjTplCmd.sl $(LOFT)/include/vlmsg.h
	slic -C VLprjTplCmd.sl -p $(LOFT)/spec

VLmodTplCmdi.I: VLmodTplCmd.sl $(LOFT)/include/vlmsg.h
	slic -C VLmodTplCmd.sl -p $(LOFT)/spec

VLchtTplCmdi.I: VLchtTplCmd.sl $(LOFT)/include/vlmsg.h
	slic -C VLchtTplCmd.sl -p $(LOFT)/spec

VLheiTplCmdi.I: VLheiTplCmd.sl $(LOFT)/include/vlmsg.h
	slic -C VLheiTplCmd.sl -p $(LOFT)/spec

mkfile:	template.m
	grmakemake template.m mkfile

pplmkfile: ppltemplate.m
	ksh $(LOFT)/etc/bin/mkmkppl ppltemplate.m pplmkfile $(LOFT)
