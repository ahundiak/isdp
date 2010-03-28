SLIC=$(EXNUC)/bin/slic -p $(GRNUC)/spec

ALL: SI AOS

SI: COretco.S

AOS: 	$(SOURCE)/config/commands/GRRtOpFr

COretco.S: COretco.sl
	$(SLIC) $?
	rm -f $(GRNUC)/spec/$@
	ln $@ $(GRNUC)/spec

$(SOURCE)/config/commands/GRRtOpFr: COretco.sl GRRetOptFrm.t
	$(SLIC) GRRetOptFrm.t
