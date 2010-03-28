SLIC = $(EXNUC)/bin/slic -p $(GRNUC)/spec

commands = $(GRNUC)/config/commands
SLICOPT1 = -Csi
SLICOPT2 = -t

ALL: SI AOS
SI : COgrpevent.S COplfence.S COsaveelem.S COlocelig.S
AOS : $(commands)/GRPRcFn \
      $(commands)/GRPPlFn \
      $(commands)/GRSlEInV \
      $(commands)/GRSlEInFn \
      $(commands)/GRDfSlSt \
      $(commands)/GRSlEInSl \
      $(commands)/GRSlEClInF \
      $(commands)/GRSlEOnLy \
      $(commands)/GRSlAlE \
      $(commands)/GRSlESy \
      $(commands)/GRCpFnE \
      $(commands)/GRFncPlEle \
      $(commands)/GRSvEl \
      $(commands)/GRLcElFm

COgrpevent.S: grpevent.sl
	$(SLIC) $(SLICOPT2) grpevent.sl
	rm -f $(GRNUC)/spec/$@
	ln $@ $(GRNUC)/spec

COlocelig.S: COlocelig.sl
	$(SLIC) $(SLICOPT2) COlocelig.sl
	rm -f $(GRNUC)/spec/$@
	ln $@ $(GRNUC)/spec

COplfence.S: plfence.sl $(GRNUC)/spec/COnpt.S
	$(SLIC) $(SLICOPT2) plfence.sl
	rm -f $(GRNUC)/spec/$@
	ln $@ $(GRNUC)/spec

COsaveelem.S: saveelem.sl grpevent.sl
	$(SLIC) $(SLICOPT2) saveelem.sl
	rm -f $(GRNUC)/spec/$@
	ln $@ $(GRNUC)/spec

$(commands)/GRLcElFm: COlocelig.sl
	$(SLIC) $(SLICOPT1) COlocelig.sl

$(commands)/GRPRcFn : rectfence.sl plfence.sl
	$(SLIC) $(SLICOPT1) rectfence.sl

$(commands)/GRPPlFn : polyfence.sl plfence.sl
	$(SLIC) $(SLICOPT1) polyfence.sl

$(commands)/GRSlEInV : elinview.sl grpevent.sl
	$(SLIC) $(SLICOPT1) elinview.sl 

$(commands)/GRSlEInFn : elinfence.sl grpevent.sl
	$(SLIC) $(SLICOPT1) elinfence.sl 

$(commands)/GRDfSlSt : selectset.sl grpevent.sl
	$(SLIC) $(SLICOPT1) selectset.sl 

$(commands)/GRSlEInSl : elemss.sl grpevent.sl
	$(SLIC) $(SLICOPT1) elemss.sl

$(commands)/GRSlEClInF : elclipfence.sl grpevent.sl
	$(SLIC) $(SLICOPT1) elclipfence.sl 

$(commands)/GRSlEOnLy : elonlayer.sl grpevent.sl
	$(SLIC) $(SLICOPT1) elonlayer.sl

$(commands)/GRSlESy : elofsymb.sl grpevent.sl
	$(SLIC) $(SLICOPT1) elofsymb.sl

$(commands)/GRSlAlE : elinmaster.sl grpevent.sl
	$(SLIC) $(SLICOPT1) elinmaster.sl 

$(commands)/GRCpFnE : filefence.sl grpevent.sl
	$(SLIC) $(SLICOPT1) filefence.sl

$(commands)/GRFncPlEle : fenceele.sl grpevent.sl
	$(SLIC) $(SLICOPT1) fenceele.sl

$(commands)/GRSvEl : saveelem.t saveelem.sl grpevent.sl
	$(SLIC) $(SLICOPT1) saveelem.t
