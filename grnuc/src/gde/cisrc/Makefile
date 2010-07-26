.SUFFIXES: .u .e

ppl_execs=\
	run_gde.e 

COMPILE: $(ppl_execs)
.u.e :
	@echo "    $< -> $*.e"
	$(GRNUC)/bin/ppl $(GRLIB)/src/gde/cisrc/$< $(MKDOPT)
	ln $*.e $(GRLIB)/ppl/bin
