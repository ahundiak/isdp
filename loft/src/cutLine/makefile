target: mkfile \
	pplmkfile
	grmake -r -k -f mkfile
	grmake -r -k -f pplmkfile

mkfile:	cutLine.m
	grmakemake cutLine.m mkfile

pplmkfile: pplcutLine.m
	ksh ${LOFT}/etc/bin/mkmkppl pplcutLine.m pplmkfile $(LOFT)
