ALL: SI AOS
SI: COparti.I 

AOS: 	$(GRNUC)/config/commands/GRCrPr \
	$(GRNUC)/config/commands/GREdPr \
	$(GRNUC)/config/commands/GRRvPr \
	$(GRNUC)/config/commands/GRCrPrLs \
	$(GRNUC)/config/commands/GRUpPrLs \
	$(GRNUC)/config/commands/GRSvPrDt \
	$(GRNUC)/config/commands/GRPlPr \
	$(GRNUC)/config/commands/GRAdPrTPrL


COparti.I: COpart.sl
	slic COpart.sl

$(GRNUC)/config/commands/GRCrPr: COpart.S  GRCrPrt.t
	slic GRCrPrt.t

$(GRNUC)/config/commands/GREdPr: COpart.S  GREdPrt.t
	slic GREdPrt.t

$(GRNUC)/config/commands/GRRvPr: COpart.S  GRRvPrt.t
	slic GRRvPrt.t

$(GRNUC)/config/commands/GRCrPrLs: COpart.S  GRCrLst.t
	slic GRCrLst.t

$(GRNUC)/config/commands/GRUpPrLs: COpart.S  GRUpLst.t
	slic GRUpLst.t

$(GRNUC)/config/commands/GRSvPrDt: COpart.S  GRLsPrt.t
	slic GRLsPrt.t

$(GRNUC)/config/commands/GRPlPr: COpart.S  GRPlPrt.t
	slic GRPlPrt.t

$(GRNUC)/config/commands/GRAdPrTPrL: COpart.S  GRAdLst.t
	slic GRAdLst.t

