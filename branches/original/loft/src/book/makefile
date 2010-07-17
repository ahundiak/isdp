target:	VLprBookCmdi.I \
	VLexBookCmdi.I \
	mkfile \
	pplmkfile
	grmake -r -k -f mkfile
	grmake -r -k -f pplmkfile

VLprBookCmdi.I:	VLprBookCmd.sl $(LOFT)/include/vlmsg.h
	slic -C VLprBookCmd.sl -p $(LOFT)/spec

VLexBookCmdi.I:	VLexBookCmd.sl $(LOFT)/include/vlmsg.h
	slic -C VLexBookCmd.sl -p $(LOFT)/spec

mkfile:	book.m
	grmakemake book.m mkfile

pplmkfile: pplbook.m
	ksh $(LOFT)/etc/bin/mkmkppl pplbook.m pplmkfile $(LOFT)
