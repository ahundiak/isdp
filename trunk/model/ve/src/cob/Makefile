SLIC=$(EXNUC)/bin/slic -p $(MODEL)/ve/src/spec

ALL: SFILES TFILES

SFILES:	$(MODEL)/ve/src/spec/VEedgescmds.S $(MODEL)/ve/src/spec/VEcheform.S $(MODEL)/ve/src/spec/VEretrieve.S \
	$(MODEL)/ve/src/spec/VEtoggle.S

TFILES: $(MODEL)/config/commands/VECrVsEd $(MODEL)/config/commands/VECrPrEd \
	$(MODEL)/config/commands/VECrBtEdIn $(MODEL)/config/commands/VERtEdRsFS \
	$(MODEL)/config/commands/VETgHdLnRd

$(MODEL)/ve/src/spec/VEedgescmds.S: VEedgescmds.sl
	$(SLIC) VEedgescmds.sl
	@mv VEedgescmds.S $(MODEL)/ve/src/spec
	@ln -f $(MODEL)/ve/src/spec/VEedgescmds.S $(MODEL)/spec
	@mv VEedgescmdsi.I $(MODEL)/ve/src/co_imp

$(MODEL)/ve/src/spec/VEcheform.S: VEcheform.sl
	$(SLIC) VEcheform.sl
	@mv VEcheform.S $(MODEL)/ve/src/spec
	@ln -f $(MODEL)/ve/src/spec/VEcheform.S $(MODEL)/spec
	@mv VEcheformi.I $(MODEL)/ve/src/co_imp

$(MODEL)/ve/src/spec/VEretrieve.S: VEretrieve.sl
	$(SLIC) VEretrieve.sl
	@mv VEretrieve.S $(MODEL)/ve/src/spec
	@ln -f $(MODEL)/ve/src/spec/VEretrieve.S $(MODEL)/spec
	@mv VEretrievei.I $(MODEL)/ve/src/co_imp


$(MODEL)/ve/src/spec/VEtoggle.S: VEtoggle.sl
	$(SLIC) VEtoggle.sl
	@mv VEtoggle.S $(MODEL)/ve/src/spec
	@ln -f $(MODEL)/ve/src/spec/VEtoggle.S $(MODEL)/spec
	@mv VEtogglei.I $(MODEL)/ve/src/co_imp

$(MODEL)/config/commands/VECrVsEd: VEcheform.sl \
	                           $(MODEL)/include/vecmd.h \
	                           $(MODEL)/include/vemessage.h
	$(SLIC) -si VEcheform.sl

$(MODEL)/config/commands/VECrPrEd: VEcheform.sl \
	                           $(MODEL)/include/vecmd.h \
	                           $(MODEL)/include/vemessage.h
	$(SLIC) -si VEcheform.sl

$(MODEL)/config/commands/VECrBtEdIn: VEedgescmds.sl \
	                             $(MODEL)/include/vecmd.h \
	                             $(MODEL)/include/vemessage.h
	$(SLIC) -si VEedgescmds.sl

$(MODEL)/config/commands/VERtEdRsFS: VEretrieve.sl \
	                             $(MODEL)/include/vecmd.h \
	                             $(MODEL)/include/vemessage.h
	$(SLIC) -si VEretrieve.sl


$(MODEL)/config/commands/VETgHdLnRd: VEtoggle.sl \
	                             $(MODEL)/include/vecmd.h \
	                             $(MODEL)/include/vemessage.h
	$(SLIC) -si VEtoggle.sl

