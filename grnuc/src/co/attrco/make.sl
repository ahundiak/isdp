SLIC=$(EXNUC)/bin/slic -p $(GRNUC)/spec

ALL: SI AOS
SI: COattr.S \
    COcpattr.S

AOS: 	$(GRNUC)/config/commands/GRCCrDr \
	$(GRNUC)/config/commands/GRSAn \
	$(GRNUC)/config/commands/GRSAn2Pn \
	$(GRNUC)/config/commands/GRSAn3Pn \
	$(GRNUC)/config/commands/GRSCl \
        $(GRNUC)/config/commands/GRSWg \
        $(GRNUC)/config/commands/GRSSt \
        $(GRNUC)/config/commands/GRSLy \
	$(GRNUC)/config/commands/GRSSc \
	$(GRNUC)/config/commands/GRSAnMsUn \
        $(GRNUC)/config/commands/GRSArPtDl \
        $(GRNUC)/config/commands/GRSEdPtDl \
	$(GRNUC)/config/commands/GRSTxFn \
	$(GRNUC)/config/commands/GRSTxSz \
        $(GRNUC)/config/commands/GRSTxChSp \
        $(GRNUC)/config/commands/GRSTxJs \
	$(GRNUC)/config/commands/GRCpSy \
	$(GRNUC)/config/commands/GRCpTxPr \
	$(GRNUC)/config/commands/GRCrLsNmE 

COattr.S: COattr.sl
	$(SLIC) $?
	rm -f $(GRNUC)/spec/$@
	ln $@ $(GRNUC)/spec

COcpattr.S: COcpattr.sl
	$(SLIC) $?
	rm -f $(GRNUC)/spec/$@
	ln $@ $(GRNUC)/spec

$(GRNUC)/config/commands/GRCCrDr: COattr.sl GRlocks.t
	$(SLIC) GRlocks.t

$(GRNUC)/config/commands/GRSAn: COattr.sl GRSetAA.t
	$(SLIC) GRSetAA.t

$(GRNUC)/config/commands/GRSAn3Pn: COattr.sl GRSetAA3Pt.t
	$(SLIC) GRSetAA3Pt.t

$(GRNUC)/config/commands/GRSAn2Pn: COattr.sl GRSetAA2Pt.t
	$(SLIC) GRSetAA2Pt.t

$(GRNUC)/config/commands/GRSCl: COattr.sl GRSetACo.t
	$(SLIC) GRSetACo.t

$(GRNUC)/config/commands/GRSWg: COattr.sl GRSetAWt.t
	$(SLIC) GRSetAWt.t

$(GRNUC)/config/commands/GRSSt: COattr.sl GRSetASt.t
	$(SLIC) GRSetASt.t

$(GRNUC)/config/commands/GRSLy: COattr.sl GRSetALy.t
	$(SLIC) GRSetALy.t

$(GRNUC)/config/commands/GRSSc: COattr.sl GRSetAS.t
	$(SLIC) GRSetAS.t

$(GRNUC)/config/commands/GRSAnMsUn: COattr.sl GRSetAUniA.t
	$(SLIC) GRSetAUniA.t

$(GRNUC)/config/commands/GRSArPtDl: COattr.sl GRSetAPDel.t
	$(SLIC) GRSetAPDel.t

$(GRNUC)/config/commands/GRSEdPtDl: COattr.sl GRSetEPDel.t
	$(SLIC) GRSetEPDel.t

$(GRNUC)/config/commands/GRSTxFn: COattr.sl GRSetTxtFt.t
	$(SLIC) GRSetTxtFt.t

$(GRNUC)/config/commands/GRSTxJs: COattr.sl GRSetTxtJs.t
	$(SLIC) GRSetTxtJs.t

$(GRNUC)/config/commands/GRSTxSz: COattr.sl GRSetTxtSz.t
	$(SLIC) GRSetTxtSz.t

$(GRNUC)/config/commands/GRSTxChSp: COattr.sl GRSetTxtCs.t
	$(SLIC) GRSetTxtCs.t

$(GRNUC)/config/commands/GRCpSy: COcpattr.sl GRCopySymb.t
	$(SLIC) GRCopySymb.t

$(GRNUC)/config/commands/GRCpTxPr: COcpattr.sl GRCopyTxPa.t
	$(SLIC) GRCopyTxPa.t

$(GRNUC)/config/commands/GRCrLsNmE: COcpattr.sl GRCopyName.t
	$(SLIC) GRCopyName.t

