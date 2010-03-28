SLIC=slic -p $(GRNUC)/spec

ALL: SI AOS
SI: RAPcobCO.S

AOS:	$(GRNUC)/config/commands/GRApndRcrd \
	$(GRNUC)/config/commands/GRStrtRcrd \
	$(GRNUC)/config/commands/GRStopRcrd \
	$(GRNUC)/config/commands/GRShRc

RAPcobCO.S: RAPcobCO.sl
	$(SLIC) $?
	rm -f $(GRNUC)/spec/$@
	ln $@ $(GRNUC)/spec

$(GRNUC)/config/commands/GRApndRcrd: RAPcobCO.sl appendrec.t
	$(SLIC) -Csi appendrec.t

$(GRNUC)/config/commands/GRStrtRcrd: RAPcobCO.sl startrec.t
	$(SLIC) -Csi startrec.t

$(GRNUC)/config/commands/GRStopRcrd: RAPcobCO.sl stoprec.t
	$(SLIC) -Csi stoprec.t

$(GRNUC)/config/commands/GRShRc: RAPcobCO.sl shutdownrec.t
	$(SLIC) -Csi shutdownrec.t
