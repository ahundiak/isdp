SLIC=$(EXNUC)/bin/slic -p $(GRNUC)/spec

#SLICOPT1 = -Csi
#SLICOPT2 = -t
#SLICOPT3 = -C

ALL: SI AOS
SI : COdetail.S  
AOS : $(GRNUC)/config/commands/GRCrDrV \
      $(GRNUC)/config/commands/GRCrAxDrV \
      $(GRNUC)/config/commands/GRCrPrDrV \
      $(GRNUC)/config/commands/GRTrOfLyRf \
      $(GRNUC)/config/commands/GRTrOnLyRf \
      $(GRNUC)/config/commands/GRDtMdFrDr \
      $(GRNUC)/config/commands/GRAtMdTDrV \
      $(GRNUC)/config/commands/GRCDrVSc \
      $(GRNUC)/config/commands/GRScRfFl \
      $(GRNUC)/config/commands/GRDrDrVAl \
      $(GRNUC)/config/commands/GRSDrVSh \
      $(GRNUC)/config/commands/GRAlDrV \
      $(GRNUC)/config/commands/GRCrDrSh \
      $(GRNUC)/config/commands/GRRvDrV \
      $(GRNUC)/config/commands/GRRvRfFl \
      $(GRNUC)/config/commands/GRRvDrShSt

COdetail.S: COdetail.sl
	$(SLIC) $?
	rm -f $(GRNUC)/spec/$@
	ln $@ $(GRNUC)/spec

$(GRNUC)/config/commands/GRCrDrV : GRCreDv.t COdetail.sl
	$(SLIC) GRCreDv.t

$(GRNUC)/config/commands/GRCrAxDrV : GRCreAuxDv.t COdetail.sl
	$(SLIC) GRCreAuxDv.t

$(GRNUC)/config/commands/GRCrPrDrV : GRCrePrinDv.t COdetail.sl
	$(SLIC) GRCrePrinDv.t 

$(GRNUC)/config/commands/GRTrOfLyRf : GRRefLyOff.t COdetail.sl
	$(SLIC) GRRefLyOff.t

$(GRNUC)/config/commands/GRTrOnLyRf : GRRefLyOn.t COdetail.sl
	$(SLIC) GRRefLyOn.t

$(GRNUC)/config/commands/GRDtMdFrDr : GRDetMod.t COdetail.sl
	$(SLIC) GRDetMod.t

$(GRNUC)/config/commands/GRAtMdTDrV : GRAttMod.t COdetail.sl
	$(SLIC) GRAttMod.t

$(GRNUC)/config/commands/GRCDrVSc : GRScaDv.t COdetail.sl
	$(SLIC) GRScaDv.t

$(GRNUC)/config/commands/GRScRfFl : GRScaRef.t COdetail.sl
	$(SLIC) GRScaRef.t

$(GRNUC)/config/commands/GRDrDrVAl : GRDrpDvAlgn.t COdetail.sl
	$(SLIC) GRDrpDvAlgn.t

$(GRNUC)/config/commands/GRSDrVSh : GRSetActDv.t COdetail.sl
	$(SLIC) GRSetActDv.t

$(GRNUC)/config/commands/GRAlDrV : GRAlgnDv.t COdetail.sl
	$(SLIC) GRAlgnDv.t

$(GRNUC)/config/commands/GRCrDrSh: GRCreDs.t COdetail.sl
	$(SLIC) GRCreDs.t

$(GRNUC)/config/commands/GRRvDrShSt: GRRevEdtDs.t COdetail.sl
	$(SLIC) GRRevEdtDs.t

$(GRNUC)/config/commands/GRRvRfFl: GRRevRef.t COdetail.sl
	$(SLIC) GRRevRef.t

$(GRNUC)/config/commands/GRRvDrV: GRRevDv.t COdetail.sl
	$(SLIC) GRRevDv.t


