SLIC=$(EXNUC)/bin/slic -p $(MODEL)/hsurf/src/spec

ALL: SFILES TFILES

SFILES:	$(MODEL)/hsurf/src/spec/HSwindow.S $(MODEL)/hsurf/src/spec/HSactive.S \
	$(MODEL)/hsurf/src/spec/HSanimate.S $(MODEL)/hsurf/src/spec/HSchsform.S $(MODEL)/hsurf/src/spec/HScnghsform.S \
	$(MODEL)/hsurf/src/spec/HSdisplmode.S $(MODEL)/hsurf/src/spec/HSdisplreg.S $(MODEL)/hsurf/src/spec/HSgetzmem.S \
	$(MODEL)/hsurf/src/spec/HSplacelite.S $(MODEL)/hsurf/src/spec/HSplotform.S $(MODEL)/hsurf/src/spec/HSzddd.S \
	$(MODEL)/hsurf/src/spec/HSsdpform.S  $(MODEL)/hsurf/src/spec/HStoggle.S $(MODEL)/hsurf/src/spec/HStogshdacc.S \
	$(MODEL)/hsurf/src/spec/NCVmodes.S $(MODEL)/hsurf/src/spec/NCcretp.S $(MODEL)/hsurf/src/spec/NCdistp.S \
	$(MODEL)/hsurf/src/spec/HSsaraform.S $(MODEL)/hsurf/src/spec/HScraform.S $(MODEL)/hsurf/src/spec/HSmfvd.S \
	$(MODEL)/hsurf/src/spec/HSsupsym.S $(MODEL)/hsurf/src/spec/HSppddform.S

TFILES: $(MODEL)/config/commands/HLChHdSy $(MODEL)/config/commands/HLDlDtDs \
	$(MODEL)/config/commands/HLDmHdSy $(MODEL)/config/commands/HLPrDtDs \
	$(MODEL)/config/commands/HLSpHdSy $(MODEL)/config/commands/HSCShPlFl \
	$(MODEL)/config/commands/HSCpRnAt $(MODEL)/config/commands/HSDsIm \
	$(MODEL)/config/commands/HSDsRg $(MODEL)/config/commands/HSGtZMm \
	$(MODEL)/config/commands/HSPlMdLg $(MODEL)/config/commands/HSSShAc \
	$(MODEL)/config/commands/HSStAcRnAt $(MODEL)/config/commands/HSStDsPr \
	$(MODEL)/config/commands/HSStShVrPr $(MODEL)/config/commands/HSSvIm \
	$(MODEL)/config/commands/HSTgAsII $(MODEL)/config/commands/HSTgEdEm \
	$(MODEL)/config/commands/HSTgShAcMd $(MODEL)/config/commands/HSTgShClMd \
	$(MODEL)/config/commands/HSTgVDsMd $(MODEL)/config/commands/HSVrShTl \
	$(MODEL)/config/commands/HScretp $(MODEL)/config/commands/HSMlFrSvFr \
	$(MODEL)/config/commands/HSMlFrVwDy $(MODEL)/config/commands/HL2DPrDtDs


$(MODEL)/hsurf/src/spec/HSsupsym.S: HSsupsym.sl
	$(SLIC) HSsupsym.sl
	@mv HSsupsym.S $(MODEL)/hsurf/src/spec
	@ln -f $(MODEL)/hsurf/src/spec/HSsupsym.S $(MODEL)/spec
	@mv HSsupsymi.I $(MODEL)/hsurf/src/co_imp

$(MODEL)/hsurf/src/spec/HSmfvd.S: HSmfvd.sl
	$(SLIC) HSmfvd.sl
	@mv HSmfvd.S $(MODEL)/hsurf/src/spec
	@ln -f $(MODEL)/hsurf/src/spec/HSmfvd.S $(MODEL)/spec
	@mv HSmfvdi.I $(MODEL)/hsurf/src/co_imp

$(MODEL)/hsurf/src/spec/HSwindow.S: HSwindow.sl
	$(SLIC) HSwindow.sl
	@mv HSwindow.S $(MODEL)/hsurf/src/spec
	@ln -f $(MODEL)/hsurf/src/spec/HSwindow.S $(MODEL)/spec
	@mv HSwindowi.I $(MODEL)/hsurf/src/co_imp

$(MODEL)/hsurf/src/spec/HSactive.S: HSactive.sl
	$(SLIC) HSactive.sl
	@mv HSactive.S $(MODEL)/hsurf/src/spec
	@ln -f $(MODEL)/hsurf/src/spec/HSactive.S $(MODEL)/spec
	@mv HSactivei.I $(MODEL)/hsurf/src/co_imp

$(MODEL)/hsurf/src/spec/HSanimate.S: HSanimate.sl
	$(SLIC) HSanimate.sl
	@mv HSanimate.S $(MODEL)/hsurf/src/spec
	@ln -f $(MODEL)/hsurf/src/spec/HSanimate.S $(MODEL)/spec
	@mv HSanimatei.I $(MODEL)/hsurf/src/co_imp

$(MODEL)/hsurf/src/spec/HSchsform.S: HSchsform.sl
	$(SLIC) HSchsform.sl
	@mv HSchsform.S $(MODEL)/hsurf/src/spec
	@ln -f $(MODEL)/hsurf/src/spec/HSchsform.S $(MODEL)/spec
	@mv HSchsformi.I $(MODEL)/hsurf/src/co_imp

$(MODEL)/hsurf/src/spec/HSppddform.S: HSppddform.sl
	$(SLIC) HSppddform.sl
	@mv HSppddform.S $(MODEL)/hsurf/src/spec
	@ln -f $(MODEL)/hsurf/src/spec/HSppddform.S $(MODEL)/spec
	@mv HSppddformi.I $(MODEL)/hsurf/src/co_imp

$(MODEL)/hsurf/src/spec/HScnghsform.S: HScnghsform.sl
	$(SLIC) HScnghsform.sl
	@mv HScnghsform.S $(MODEL)/hsurf/src/spec
	@ln -f $(MODEL)/hsurf/src/spec/HScnghsform.S $(MODEL)/spec
	@mv HScnghsformi.I $(MODEL)/hsurf/src/co_imp

$(MODEL)/hsurf/src/spec/HSdisplmode.S: HSdisplmode.sl
	$(SLIC) HSdisplmode.sl
	@mv HSdisplmode.S $(MODEL)/hsurf/src/spec
	@ln -f $(MODEL)/hsurf/src/spec/HSdisplmode.S $(MODEL)/spec
	@mv HSdisplmodei.I $(MODEL)/hsurf/src/co_imp

$(MODEL)/hsurf/src/spec/HSdisplreg.S: HSdisplreg.sl
	$(SLIC) HSdisplreg.sl
	@mv HSdisplreg.S $(MODEL)/hsurf/src/spec
	@ln -f $(MODEL)/hsurf/src/spec/HSdisplreg.S $(MODEL)/spec
	@mv HSdisplregi.I $(MODEL)/hsurf/src/co_imp

$(MODEL)/hsurf/src/spec/HSgetzmem.S: HSgetzmem.sl
	$(SLIC) HSgetzmem.sl
	@mv HSgetzmem.S $(MODEL)/hsurf/src/spec
	@ln -f $(MODEL)/hsurf/src/spec/HSgetzmem.S $(MODEL)/spec
	@mv HSgetzmemi.I $(MODEL)/hsurf/src/co_imp

$(MODEL)/hsurf/src/spec/HSplacelite.S: HSplacelite.sl
	$(SLIC) HSplacelite.sl
	@mv HSplacelite.S $(MODEL)/hsurf/src/spec
	@ln -f $(MODEL)/hsurf/src/spec/HSplacelite.S $(MODEL)/spec
	@mv HSplacelitei.I $(MODEL)/hsurf/src/co_imp

$(MODEL)/hsurf/src/spec/HSplotform.S: HSplotform.sl
	$(SLIC) HSplotform.sl
	@mv HSplotform.S $(MODEL)/hsurf/src/spec
	@ln -f $(MODEL)/hsurf/src/spec/HSplotform.S $(MODEL)/spec
	@mv HSplotformi.I $(MODEL)/hsurf/src/co_imp

$(MODEL)/hsurf/src/spec/HSzddd.S: HSzddd.sl
	$(SLIC) HSzddd.sl
	@mv HSzddd.S $(MODEL)/hsurf/src/spec
	@ln -f $(MODEL)/hsurf/src/spec/HSzddd.S $(MODEL)/spec
	@mv HSzdddi.I $(MODEL)/hsurf/src/co_imp

$(MODEL)/hsurf/src/spec/HSsdpform.S: HSsdpform.sl
	$(SLIC) HSsdpform.sl
	@mv HSsdpform.S $(MODEL)/hsurf/src/spec
	@ln -f $(MODEL)/hsurf/src/spec/HSsdpform.S $(MODEL)/spec
	@mv HSsdpformi.I $(MODEL)/hsurf/src/co_imp

$(MODEL)/hsurf/src/spec/HStoggle.S: HStoggle.sl
	$(SLIC) HStoggle.sl
	@mv HStoggle.S $(MODEL)/hsurf/src/spec
	@ln -f $(MODEL)/hsurf/src/spec/HStoggle.S $(MODEL)/spec
	@mv HStogglei.I $(MODEL)/hsurf/src/co_imp

$(MODEL)/hsurf/src/spec/HStogshdacc.S: HStogshdacc.sl
	$(SLIC) HStogshdacc.sl
	@mv HStogshdacc.S $(MODEL)/hsurf/src/spec
	@ln -f $(MODEL)/hsurf/src/spec/HStogshdacc.S $(MODEL)/spec
	@mv HStogshdacci.I $(MODEL)/hsurf/src/co_imp

$(MODEL)/hsurf/src/spec/NCVmodes.S: NCVmodes.sl
	$(SLIC) NCVmodes.sl
	@mv NCVmodes.S $(MODEL)/hsurf/src/spec
	@ln -f $(MODEL)/hsurf/src/spec/NCVmodes.S $(MODEL)/spec
	@mv NCVmodesi.I $(MODEL)/hsurf/src/co_imp

$(MODEL)/hsurf/src/spec/NCcretp.S: NCcretp.sl
	$(SLIC) NCcretp.sl
	@mv NCcretp.S $(MODEL)/hsurf/src/spec
	@ln -f $(MODEL)/hsurf/src/spec/NCcretp.S $(MODEL)/spec
	@mv NCcretpi.I $(MODEL)/hsurf/src/co_imp

$(MODEL)/hsurf/src/spec/NCdistp.S: NCdistp.sl
	$(SLIC) NCdistp.sl
	@mv NCdistp.S $(MODEL)/hsurf/src/spec
	@ln -f $(MODEL)/hsurf/src/spec/NCdistp.S $(MODEL)/spec
	@mv NCdistpi.I $(MODEL)/hsurf/src/co_imp

$(MODEL)/hsurf/src/spec/HSsaraform.S: HSsaraform.sl
	$(SLIC) HSsaraform.sl
	@mv HSsaraform.S $(MODEL)/hsurf/src/spec
	@ln -f $(MODEL)/hsurf/src/spec/HSsaraform.S $(MODEL)/spec
	@mv HSsaraformi.I $(MODEL)/hsurf/src/co_imp

$(MODEL)/hsurf/src/spec/HScraform.S: HScraform.sl
	$(SLIC) HScraform.sl
	@mv HScraform.S $(MODEL)/hsurf/src/spec
	@ln -f $(MODEL)/hsurf/src/spec/HScraform.S $(MODEL)/spec
	@mv HScraformi.I $(MODEL)/hsurf/src/co_imp


$(MODEL)/config/commands/HLChHdSy: HScnghsform.sl \
	                           $(MODEL)/include/hscmd.h \
	                           $(MODEL)/include/hsmessage.h
	$(SLIC) -si HScnghsform.sl

$(MODEL)/config/commands/HLDlDtDs: HSzddd.sl \
	                           $(MODEL)/include/hscmd.h \
	                           $(MODEL)/include/hsmessage.h
	$(SLIC) -si HSzddd.sl

$(MODEL)/config/commands/HLDmHdSy: HSzddd.sl \
	                           $(MODEL)/include/hscmd.h \
	                           $(MODEL)/include/hsmessage.h
	$(SLIC) -si HSzddd.sl

$(MODEL)/config/commands/HLPrDtDs: HSchsform.sl \
	                           $(MODEL)/include/hscmd.h \
	                           $(MODEL)/include/hsmessage.h
	$(SLIC) -si HSchsform.sl

$(MODEL)/config/commands/HL2DPrDtDs: HSppddform.sl \
	                           $(MODEL)/include/hscmd.h \
	                           $(MODEL)/include/hsmessage.h
	$(SLIC) -si HSppddform.sl

$(MODEL)/config/commands/HLSpHdSy: HSsupsym.sl \
	                           $(MODEL)/include/hscmd.h \
	                           $(MODEL)/include/hsmessage.h
	$(SLIC) -si HSsupsym.sl

$(MODEL)/config/commands/HSCShPlFl: HSplotform.sl \
	                            $(MODEL)/include/hscmd.h \
	                            $(MODEL)/include/hsmessage.h
	$(SLIC) -si HSplotform.sl

$(MODEL)/config/commands/HSCpRnAt: HScraform.sl \
	                           $(MODEL)/include/hscmd.h \
	                           $(MODEL)/include/hsmessage.h
	$(SLIC) -si HScraform.sl

$(MODEL)/config/commands/HSDsIm: HSanimate.sl \
	                         $(MODEL)/include/hscmd.h \
	                         $(MODEL)/include/hsmessage.h
	$(SLIC) -si HSanimate.sl

$(MODEL)/config/commands/HSDsRg: HSdisplreg.sl \
	                         $(MODEL)/include/hscmd.h \
	                         $(MODEL)/include/hsmessage.h
	$(SLIC) -si HSdisplreg.sl

$(MODEL)/config/commands/HSGtZMm: HSgetzmem.sl \
	                          $(MODEL)/include/hscmd.h \
	                          $(MODEL)/include/hsmessage.h
	$(SLIC) -si HSgetzmem.sl

$(MODEL)/config/commands/HSPlMdLg: HSplacelite.sl \
	                           $(MODEL)/include/hscmd.h \
	                           $(MODEL)/include/hsmessage.h
	$(SLIC) -si HSplacelite.sl

$(MODEL)/config/commands/HSSShAc: HSactive.sl \
	                          $(MODEL)/include/hscmd.h \
	                          $(MODEL)/include/hsmessage.h
	$(SLIC) -si HSactive.sl

$(MODEL)/config/commands/HSStAcRnAt: HSsaraform.sl \
	                             $(MODEL)/include/hscmd.h \
	                             $(MODEL)/include/hsmessage.h
	$(SLIC) -si HSsaraform.sl

$(MODEL)/config/commands/HSStDsPr: HSsdpform.sl \
	                           $(MODEL)/include/hscmd.h \
	                           $(MODEL)/include/hsmessage.h
	$(SLIC) -si HSsdpform.sl

$(MODEL)/config/commands/HSStShVrPr: NCVmodes.sl \
	                             $(MODEL)/include/hscmd.h \
	                             $(MODEL)/include/hsmessage.h
	$(SLIC) -si NCVmodes.sl

$(MODEL)/config/commands/HSSvIm: HSanimate.sl \
	                         $(MODEL)/include/hscmd.h \
	                         $(MODEL)/include/hsmessage.h
	$(SLIC) -si HSanimate.sl

$(MODEL)/config/commands/HSTgAsII: HStoggle.sl \
	                           $(MODEL)/include/hscmd.h \
	                           $(MODEL)/include/hsmessage.h
	$(SLIC) -si HStoggle.sl

$(MODEL)/config/commands/HSTgEdEm: HStoggle.sl \
	                           $(MODEL)/include/hscmd.h \
	                           $(MODEL)/include/hsmessage.h
	$(SLIC) -si HStoggle.sl

$(MODEL)/config/commands/HSTgShAcMd: HStogshdacc.sl \
	                             $(MODEL)/include/hscmd.h \
	                             $(MODEL)/include/hsmessage.h
	$(SLIC) -si HStogshdacc.sl

$(MODEL)/config/commands/HSTgShClMd: HStoggle.sl \
	                             $(MODEL)/include/hscmd.h \
	                             $(MODEL)/include/hsmessage.h
	$(SLIC) -si HStoggle.sl

$(MODEL)/config/commands/HSTgVDsMd: HSdisplmode.sl \
	                            $(MODEL)/include/hscmd.h \
	                            $(MODEL)/include/hsmessage.h
	$(SLIC) -si HSdisplmode.sl

$(MODEL)/config/commands/HSVrShTl: NCdistp.sl \
	                           $(MODEL)/include/hscmd.h \
	                           $(MODEL)/include/hsmessage.h
	$(SLIC) -si NCdistp.sl

$(MODEL)/config/commands/HScretp: NCcretp.sl \
	                          $(MODEL)/include/hscmd.h \
	                          $(MODEL)/include/hsmessage.h
	$(SLIC) -si NCcretp.sl

$(MODEL)/config/commands/HSMlFrSvFr: HSmfvd.sl \
	                             $(MODEL)/include/hscmd.h \
	                             $(MODEL)/include/hsmessage.h
	$(SLIC) -si HSmfvd.sl

$(MODEL)/config/commands/HSMlFrVwDy: HSmfvd.sl \
	                             $(MODEL)/include/hscmd.h \
	                             $(MODEL)/include/hsmessage.h
	$(SLIC) -si HSmfvd.sl


