target:	makeppl
	grmake -r -k -f makeppl
	cp ${VDS}/ppl/bin/VDpostconn.e /opt/ingr/sp/ppl/bin
	
makeppl: ppl.m
	ksh $(VDS)/etc/bin/mkmkppl ppl.m makeppl $(VDS)
