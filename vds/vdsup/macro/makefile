target: pplmkfile
#	grmake -r -k -f pplmkfile

pplmkfile: pplsup.m
	ksh ${VDS}/etc/bin/mkmkppl pplsup.m pplmkfile $(VDS)

clean:
	@rm -f pplmkfile *.e

