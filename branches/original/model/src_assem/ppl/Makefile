.SUFFIXES: .u .e

ppl_execs=\
        RevAssly.e\
        updascii.e

COMPILE: $(ppl_execs)
.u.e :
	@echo "\t$< -> $*.e"
	$(GRNUC)/bin/ppl -Xexternfn $<
	ln $*.e $(MDTARG)/ppl/bin
