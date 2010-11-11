
target: mkfile
	grmake -r -k -f mkfile
	@if test ${ISDP_MAKE_SP} -eq 1; \
	then \
	   ldso    ${SPXV}/lib/vdmisc; \
	   /bin/cp ${SPXV}/lib/vdmisc.so ${SPV};   \
	   /bin/mv ${SPXV}/lib/vdmisc.so /usr/tmp; \
        else \
	   ldso    ${VDS}/lib/vdmisc; \
	   /bin/mv ${VDS}/lib/vdmisc.so /usr/tmp; \
        fi

pplmkfile: vdimiscppl.m
	ksh $(VDS)/etc/bin/mkmkppl vdimiscppl.m pplmkfile $(VDS)

mkfile: vdmisc.m
	grmakemake vdmisc.m mkfile

clean:
	@rm -f mkfile pplmkfile *.e *.o *.c
	@svn update
