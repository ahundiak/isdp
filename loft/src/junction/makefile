target: mkfile \
	pplmkfile
	grmake -r -k -f mkfile
	grmake -r -k -f pplmkfile

mkfile:	junction.m
	grmakemake junction.m mkfile

pplmkfile: ppljunction.m
	ksh $(LOFT)/etc/bin/mkmkppl ppljunction.m pplmkfile $(LOFT)
