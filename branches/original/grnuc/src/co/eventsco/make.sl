SLIC=$(EXNUC)/bin/slic -p $(GRNUC)/spec

ALL:	SI TFILES
SI:	COevgen.S
TFILES:	$(GRNUC)/config/commands/GRSlPnAnFr	\
	$(GRNUC)/config/commands/GRSlPnCn	\
	$(GRNUC)/config/commands/GRSlPnIn	\
	$(GRNUC)/config/commands/GRPnSnPn	\
	$(GRNUC)/config/commands/GRSlTnPnKy

COevgen.S: COevgen.sl
	$(SLIC) COevgen.sl
	rm -f $(GRNUC)/spec/$@
	ln $@ $(GRNUC)/spec

$(GRNUC)/config/commands/GRSlPnAnFr: COPtAng.t
	$(SLIC) $?

$(GRNUC)/config/commands/GRSlPnCn: COPtGen.t
	$(SLIC) $?

$(GRNUC)/config/commands/GRSlTnPnKy: COPtTky.t
	$(SLIC) $?

$(GRNUC)/config/commands/GRPnSnPn: COsnap.t
	$(SLIC) $?

$(GRNUC)/config/commands/GRSlPnIn: COPtInt.t
	$(SLIC) $?
