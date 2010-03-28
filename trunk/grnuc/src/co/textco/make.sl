SLIC = slic -p $(GRNUC)/spec

ALL:      NOTDRAW DRAW
IDRAW:    DRAW

NOTDRAW:  COsvtxasfl.S COsvtxasfli.I $(SOURCE)/config/commands/GRSvTxTAsF \
	  COcptxfljf.S COcptxfljfi.I $(SOURCE)/config/commands/GRCpTxFlJs \
          $(SOURCE)/config/commands/GRPVInTx \
          $(SOURCE)/config/commands/GRPVInFtTx

DRAW:     COtext.S COtexti.I \
          COplytext.S COplytexti.I $(SOURCE)/config/commands/GRCTxtPol\
          COtxalel.S COtxaleli.I $(SOURCE)/config/commands/GRPTxAlEl \
          $(SOURCE)/config/commands/GRPTx \
          $(SOURCE)/config/commands/GRPFtTx

COtext.S: COtext.sl
	$(SLIC) -Sitc $?
	rm -f $(GRNUC)/spec/$@
	ln $@ $(GRNUC)/spec

COtexti.I: COtext.sl
	$(SLIC) -Istc $?

COsvtxasfl.S: COsvtxasfl.sl
	$(SLIC) -Sitc $?
	rm -f $(GRNUC)/spec/$@
	ln $@ $(GRNUC)/spec

COsvtxasfli.I: COsvtxasfl.sl
	$(SLIC) -Istc $?

$(SOURCE)/config/commands/GRSvTxTAsF: COsvtxasfl.sl
	$(SLIC) -Tsic $?

COcptxfljf.S: COcptxfljf.sl
	$(SLIC) -Sitc $?
	rm -f $(GRNUC)/spec/$@
	ln $@ $(GRNUC)/spec

COcptxfljfi.I: COcptxfljf.sl
	$(SLIC) -Istc $?

$(SOURCE)/config/commands/GRCpTxFlJs: COcptxfljf.sl
	$(SLIC) -Tsic $?

COplytext.S: COplytext.sl
	$(SLIC) -Sitc $?
	rm -f $(GRNUC)/spec/$@
	ln $@ $(GRNUC)/spec

COplytexti.I: COplytext.sl
	$(SLIC) -Istc $?

$(SOURCE)/config/commands/GRCTxtPol: COplytext.sl
	$(SLIC) -Tsic $?

COtxalel.S: COtxalel.sl
	$(SLIC) -Sitc $?
	rm -f $(GRNUC)/spec/$@
	ln $@ $(GRNUC)/spec

COtxaleli.I: COtxalel.sl
	$(SLIC) -Istc $?

$(SOURCE)/config/commands/GRPTxAlEl: GRPTxAlEl.t
	$(SLIC) -Tsic $?

$(SOURCE)/config/commands/GRPTx $(SOURCE)/config/commands/GRPVInTx: GRPTx.t
	$(SLIC) $?

$(SOURCE)/config/commands/GRPFtTx $(SOURCE)/config/commands/GRPVInFtTx: GRPFtTx.t
	$(SLIC) $?
