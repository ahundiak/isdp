SLIC = slic -p $(GRNUC)/spec

ALL:	SI TFILES

SI:	QYnpt.S QYnpti.I

TFILES:	$(GRNUC)/config/commands/Query

QYnpt.S QYnpti.I: QYnpt.sl
	$(SLIC) $?
	rm -f $(GRNUC)/spec/$@
	ln $@ $(GRNUC)/spec

$(GRNUC)/config/commands/Query: query.t
	$(SLIC) $?
