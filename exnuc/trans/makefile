binaries: \
	CCD \
	EXSP

CCD: $(TARGET)/trans/ccd/makefile
	@echo "\n\tMaking ccd ..."
	@cd $(TARGET)/trans/ccd; pwd; $(MAKE);

$(TARGET)/trans/ccd/makefile: $(EXNUC)/trans/ccd/ccd.m
	cd $(EXNUC)/trans/ccd; \
	$(MAKEMAKE) ccd.m $(TARGET)/trans/ccd/makefile

EXSP: $(TARGET)/trans/sp_proc/makefile
	@echo "\n\tMaking sp_proc ..."
	@cd $(TARGET)/trans/sp_proc; pwd; $(MAKE);

$(TARGET)/trans/sp_proc/makefile: $(EXNUC)/trans/sp_proc/sp_proc.m
	cd $(EXNUC)/trans/sp_proc; \
	$(MAKEMAKE) sp_proc.m $(TARGET)/trans/sp_proc/makefile
