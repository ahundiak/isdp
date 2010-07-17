
TGT = VLlocate

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

mkfile: locate.m
	grmakemake locate.m mkfile
