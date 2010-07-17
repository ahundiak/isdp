target:	mkfile \
	pplmkfile \
	$(LOFT)/bin/IsOmFile
#	grmake -rkf mkfile
#	grmake -rkf pplmkfile

mkfile:	convert.m
#	grmakemake convert.m mkfile

pplmkfile: pplconvert.m
#	ksh $(LOFT)/etc/bin/mkmkppl pplconvert.m pplmkfile $(LOFT)

$(LOFT)/bin/IsOmFile: is_om_file.c
#	acc is_om_file.c -o $(LOFT)/bin/IsOmFile ${COMPOPT}
#	strip $(LOFT)/bin/IsOmFile
