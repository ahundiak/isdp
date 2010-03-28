SLIC = $(EXNUC)/bin/slic -p $(GRNUC)/spec

ALL:	SI TFILES
SI:	COpattern.S
TFILES:	$(GRNUC)/config/commands/GRPArPt  \
        $(GRNUC)/config/commands/GRPEdPt

COpattern.S: COpattern.sl
	$(SLIC) $?
	rm -f $(GRNUC)/spec/$@
	ln $@ $(GRNUC)/spec

$(GRNUC)/config/commands/GRPArPt: COareapat.t
	$(SLIC) $?

$(GRNUC)/config/commands/GRPEdPt: COedgepat.t
	$(SLIC) $?
