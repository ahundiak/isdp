SLIC = slic -p $(GRNUC)/spec

ALL:	SI CMDS

SI: 	COreplace.S COrevcell.S

CMDS: 	$(GRNUC)/config/commands/GRRvClDf \
	$(GRNUC)/config/commands/GRRpAlClGl \
	$(GRNUC)/config/commands/GRRpAlSyGl \
	$(GRNUC)/config/commands/GRRpClGl \
	$(GRNUC)/config/commands/GRRpSyGl \
	$(GRNUC)/config/commands/GRRpSyIn \
	$(GRNUC)/config/commands/GRDlClDf \
	$(GRNUC)/config/commands/GRDrSySy
   
COreplace.S: COreplace.sl
	$(SLIC) -t $?
	rm -f $(GRNUC)/spec/$@
	ln $@ $(GRNUC)/spec

COrevcell.S: COrevcell.sl
	$(SLIC) -t COrevcell.sl
	rm -f $(GRNUC)/spec/$@
	ln $@ $(GRNUC)/spec

$(GRNUC)/config/commands/GRRvClDf: COrevcell.sl
	$(SLIC) -si COrevcell.sl

$(GRNUC)/config/commands/GRRpAlClGl: globrepcl.t COreplace.sl
	$(SLIC) -si globrepcl.t

$(GRNUC)/config/commands/GRRpAlSyGl: globrepsm.t COreplace.sl
	$(SLIC) -si globrepsm.t

$(GRNUC)/config/commands/GRRpClGl: repallcl.t COreplace.sl
	$(SLIC) -si repallcl.t

$(GRNUC)/config/commands/GRRpSyGl: repallsm.t COreplace.sl
	$(SLIC) -si repallsm.t

$(GRNUC)/config/commands/GRRpSyIn: repsmcl.t COreplace.sl
	$(SLIC) -si repsmcl.t

$(GRNUC)/config/commands/GRDlClDf: sddelete.t COreplace.sl
	$(SLIC) -si sddelete.t

$(GRNUC)/config/commands/GRDrSySy: dropsymb.t COreplace.sl
	$(SLIC) -si dropsymb.t
