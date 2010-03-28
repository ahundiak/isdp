SLIC = $(EXNUC)/bin/slic -p $(GRNUC)/spec

ALL: SI AOS
SI: COpal.S 

AOS: 	$(GRNUC)/config/commands/GRAdCmTPl \
	$(GRNUC)/config/commands/GRCrPlFrFl \
	$(GRNUC)/config/commands/GRCrPl \
	$(GRNUC)/config/commands/GRDlPl \
	$(GRNUC)/config/commands/GRDlCmFrPl \
	$(GRNUC)/config/commands/GRSvPlTFl \
	$(GRNUC)/config/commands/GRPalStu


COpal.S: COpal.sl
	$(SLIC) $?
	rm -f $(GRNUC)/spec/$@
	ln $@ $(GRNUC)/spec

$(GRNUC)/config/commands/GRCrPl: COpal.sl GRPalCre.t
	$(SLIC) GRPalCre.t

$(GRNUC)/config/commands/GRCrPlFrFl: COpal.sl GRPalCfl.t
	$(SLIC) GRPalCfl.t

$(GRNUC)/config/commands/GRAdCmTPl: COpal.sl GRPalAdd.t
	$(SLIC) GRPalAdd.t

$(GRNUC)/config/commands/GRDlCmFrPl: COpal.sl GRPalRem.t
	$(SLIC) GRPalRem.t

$(GRNUC)/config/commands/GRSvPlTFl: COpal.sl GRPalSav.t
	$(SLIC) GRPalSav.t

$(GRNUC)/config/commands/GRDlPl: COpal.sl GRPalDel.t
	$(SLIC) GRPalDel.t

$(GRNUC)/config/commands/GRPalStu: COpal.sl GRPalStu.t
	$(SLIC) GRPalStu.t


