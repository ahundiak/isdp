SLIC=$(EXNUC)/bin/slic -p $(GRNUC)/spec

SFILES:	COcctform.S

COcctform.S: COcctform.sl $(GRNUC)/include/cctmsg.h
	$(SLIC) COcctform.sl
	rm -f $(GRNUC)/spec/$@
	ln COcctform.S $(GRNUC)/spec
