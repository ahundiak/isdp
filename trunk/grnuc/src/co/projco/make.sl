SLIC=slic -p $(GRNUC)/spec

ALL: SI AOS
SI: COproj.S

AOS: 	$(GRNUC)/config/commands/GRPrEl \
	$(GRNUC)/config/commands/GRPrPn

COproj.S: COproj.sl
	$(SLIC) $?
	rm -f $(GRNUC)/spec/$@
	ln $@ $(GRNUC)/spec

$(GRNUC)/config/commands/GRPrEl: COproj.sl GRPrjEle.t
	$(SLIC) GRPrjEle.t

$(GRNUC)/config/commands/GRPrPn: COproj.sl GRPrjPt.t
	$(SLIC) GRPrjPt.t
