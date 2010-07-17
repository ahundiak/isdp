target:	pplmkfile
	grmake -r -k -f pplmkfile

pplmkfile: ${TGT}.m
	@if test ${ISDP_MAKE_SP} -eq 1; \
	then \
	   ksh $(STRUCT_PATH)/etc/bin/mkmkppl ${TGT}.m pplmkfile $(SP); \
	else \
	   ksh $(STRUCT_PATH)/etc/bin/mkmkppl ${TGT}.m pplmkfile $(STRUCT); \
	fi
