.SUFFIXES: .u .e

ppl_execs = \
	TScrexp.e

COMPILE: $(ppl_execs)

.u.e :
	@echo "\t$< -> $*.e"
	$(GRNUC)/bin/ppl -q -s $(DOPT1) $<
	ln $*.e ../bin
	ln $*.e $(GRNUC)/ppl/bin
