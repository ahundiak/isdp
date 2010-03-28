SLIC= $(EXNUC)/bin/slic -p $(GRNUC)/spec
ALL IDRAFT: COexp.S DEnpt.S
IDRAW:  COexp.S

 COexp.S: COexp.sl
	 $(SLIC) $?
	 rm -f $(GRNUC)/spec/$@
	 ln $@ $(GRNUC)/spec

 DEnpt.S: DEnpt.sl
	 $(SLIC) $?
	 rm -f $(GRNUC)/spec/$@
	 ln $@ $(GRNUC)/spec
