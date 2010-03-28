.SUFFIXES: .u .e

ppl_execs = \
	TSddc.e

COMPILE: $(ppl_execs)

.u.e :
	@echo "\t$< -> $*.e"
	$(GRNUC)/bin/ppl -q -s $(DOPT1) $<
	ln $*.e ../bin
	ln $*.e $(GRNUC)/ppl/bin
