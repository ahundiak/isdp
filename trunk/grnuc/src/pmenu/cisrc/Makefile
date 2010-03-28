.SUFFIXES: .u .e

FILES = uicreatepmnu.e

COMPILE: $(FILES)

.u.e :
	@echo "\t$< -> $*.e"
	$(GRNUC)/bin/ppl -q -s $(DOPT1) $<
	ln $*.e $(GRLIB)/ppl/bin
