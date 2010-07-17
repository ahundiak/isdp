TGT = VLunfold

target: mkfile
	grmake -r -k -f mkfile
	@if test ${ISDP_MAKE_SP} -eq 1; \
	then \
	    ldso    ${SPXL}/lib/${TGT}; \
	    /bin/cp ${SPXL}/lib/${TGT}.so ${SPL};   \
	    /bin/mv ${SPXL}/lib/${TGT}.so /usr/tmp; \
	else \
	    ldso    ${LOFT}/lib/${TGT}; \
	    /bin/mv ${LOFT}/lib/${TGT}.so /usr/tmp; \
	fi

VLmodUnwCmdi.I: VLmodUnwCmd.sl $(LOFT)/include/vlmsg.h
	slic -C VLmodUnwCmd.sl -p $(LOFT)/spec

VLunwrapCmdi.I: VLunwrapCmd.sl $(LOFT)/include/vlmsg.h
	slic -C VLunwrapCmd.sl -p $(LOFT)/spec

VLunwRpCmdi.I: VLunwRpCmd.sl $(LOFT)/include/vlmsg.h
	slic -C VLunwRpCmd.sl -p $(LOFT)/spec

VLstrecVCmdi.I: VLstrecVCmd.sl $(LOFT)/include/vlmsg.h
	slic -C VLstrecVCmd.sl -p $(LOFT)/spec

VLstrRpCmdi.I: VLstrRpCmd.sl $(LOFT)/include/vlmsg.h
	slic -C VLstrRpCmd.sl -p $(LOFT)/spec

mkfile: unfold.m
	grmakemake unfold.m mkfile

pplmkfile: pplunfold.m
	ksh $(LOFT)/etc/bin/mkmkppl pplunfold.m pplmkfile $(LOFT)
