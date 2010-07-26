SLIC = slic -p $(GRNUC)/spec

ALL:		SIFILES TFILES

SIFILES:	COplot.S COploti.I

TFILES:		$(GRNUC)/config/commands/GRCrPlRq

COplot.S COploti.I: COplot.sl
	$(SLIC) -SItc $?
	rm -f $(GRNUC)/spec/$@
	ln $@ $(GRNUC)/spec

$(GRNUC)/config/commands/GRCrPlRq: COplot.sl
	$(SLIC) -siTc $?
