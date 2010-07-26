SLIC = slic -p $(GRNUC)/spec

ALL: SI AOS IDRAW
SI: COref.S \
    COreviewele.S \
    COstrfnc.S

AOS: 	$(GRNUC)/config/commands/GRAtRfFl \
	$(GRNUC)/config/commands/GRDtRfFl \
	$(GRNUC)/config/commands/GRRvE \
	$(GRNUC)/config/commands/GRStFnE \
	$(GRNUC)/config/commands/GRMdClPlDp \
	$(GRNUC)/config/commands/GRDrRfFlSy 

IDRAW: 	$(GRNUC)/config/commands/GRAtRfFl \
	$(GRNUC)/config/commands/GRDtRfFl \
	$(GRNUC)/config/commands/GRRvE \
	$(GRNUC)/config/commands/GRStFnE 

COref.S: COref.sl
	$(SLIC) $?
	rm -f $(GRNUC)/spec/$@
	ln $@ $(GRNUC)/spec

COreviewele.S: COreviewele.sl
	$(SLIC) $?
	rm -f $(GRNUC)/spec/$@
	ln $@ $(GRNUC)/spec

COstrfnc.S: COstrfnc.sl
	$(SLIC) $?
	rm -f $(GRNUC)/spec/$@
	ln $@ $(GRNUC)/spec

$(GRNUC)/config/commands/GRAtRfFl: COref.sl GRAtRfFl.t
	$(SLIC) GRAtRfFl.t

$(GRNUC)/config/commands/GRDtRfFl: COref.sl GRDtRfFl.t
	$(SLIC) GRDtRfFl.t

$(GRNUC)/config/commands/GRMdClPlDp: COref.sl GRModClpZ.t
	$(SLIC) GRModClpZ.t

$(GRNUC)/config/commands/GRDrRfFlSy: COref.sl GRDropRFS.t
	$(SLIC) GRDropRFS.t

$(GRNUC)/config/commands/GRRvE: COreviewele.sl COreviewele.t
	$(SLIC) -TCsi COreviewele.t

$(GRNUC)/config/commands/GRStFnE: COstrfnc.sl COstrfnc.t
	$(SLIC) -TCsi COstrfnc.t



