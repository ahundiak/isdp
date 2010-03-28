SLIC = $(EXNUC)/bin/slic -p $(GRNUC)/spec

ALL: SI AOS
SI: COrlocks.S \
    COrattr.S

AOS: 	$(GRNUC)/config/commands/GRSetRMem \
	$(GRNUC)/config/commands/RSSBcCl

COrattr.S: COrattr.sl
	$(SLIC) $?
	rm -f $(GRNUC)/spec/$@
	ln $@ $(GRNUC)/spec

COrlocks.S: COrlocks.sl
	$(SLIC) $?
	rm -f $(GRNUC)/spec/$@
	ln $@ $(GRNUC)/spec

$(GRNUC)/config/commands/GRSetRMem: COrattr.sl GRSetRMem.t
	$(SLIC) GRSetRMem.t

$(GRNUC)/config/commands/RSSBcCl: COrattr.sl GRSetRgBg.t
	$(SLIC) GRSetRgBg.t
