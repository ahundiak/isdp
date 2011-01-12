binaries:\
	SLI

objects:\
	DIRECTORIES \
	ACTIONS \
	CEO \
	STATE \
	TRANS \
	UTIL \
	SHFN \
	$(TARGET)/icob/lib/give_vers.o

DIRECTORIES:
	@if test ! -d $(TARGET)/icob/lib; then mkdir $(TARGET)/icob/lib; fi

ACTIONS: $(TARGET)/icob/actions/makefile
	@cd $(TARGET)/icob/actions; \
	pwd; \
	$(MAKE)

CEO: $(TARGET)/icob/ceo/makefile
	@cd $(TARGET)/icob/ceo; \
	pwd; \
	$(MAKE)

STATE: $(TARGET)/icob/state/makefile
	@cd $(TARGET)/icob/state; \
	pwd; \
	$(MAKE)

TRANS: $(TARGET)/icob/trans/makefile
	@cd $(TARGET)/icob/trans; \
	pwd; \
	$(MAKE)

UTIL: $(TARGET)/icob/util/makefile
	@cd $(TARGET)/icob/util; \
	pwd; \
	$(MAKE)

SHFN: $(TARGET)/icob/shfn/makefile
	@cd $(TARGET)/icob/shfn; \
	pwd; \
	$(MAKE)

SLI: $(TARGET)/icob/sli/makefile
	@cd $(TARGET)/icob/sli; \
	pwd; \
	$(MAKE)

$(TARGET)/icob/lib/give_vers.o:
	@echo 'give_cob_version (){ return $(COB_VER_D); }' > $(TARGET)/icob/lib/give_vers.c
	@cd $(TARGET)/icob/lib; \
	$(CC) -c $(COPT) $(IPATH) $(DOPT) $(DOPT1) $(DOPT2) $(TARGET)/icob/lib/give_vers.c

$(TARGET)/icob/actions/makefile: $(EXNUC)/icob/actions/actions.m
	cd $(EXNUC)/icob/actions; \
	$(MAKEMAKE) actions.m $(TARGET)/icob/actions/makefile

$(TARGET)/icob/ceo/makefile: $(EXNUC)/icob/ceo/ceo.m
	cd $(EXNUC)/icob/ceo; \
	$(MAKEMAKE) ceo.m $(TARGET)/icob/ceo/makefile

$(TARGET)/icob/shfn/makefile: $(EXNUC)/icob/shfn/shfn.m
	cd $(EXNUC)/icob/shfn; \
	$(MAKEMAKE) shfn.m $(TARGET)/icob/shfn/makefile

$(TARGET)/icob/sli/makefile: $(EXNUC)/icob/sli/sli.m $(TARGET)/icob/sli/y.tab.h
	cd $(EXNUC)/icob/sli; \
	$(MAKEMAKE) sli.m $(TARGET)/icob/sli/makefile

$(TARGET)/icob/sli/y.tab.h:
	touch $@

$(TARGET)/icob/state/makefile: $(EXNUC)/icob/state/state.m
	cd $(EXNUC)/icob/state; \
	$(MAKEMAKE) state.m $(TARGET)/icob/state/makefile

$(TARGET)/icob/trans/makefile: $(EXNUC)/icob/trans/trans.m
	cd $(EXNUC)/icob/trans; \
	$(MAKEMAKE) trans.m $(TARGET)/icob/trans/makefile

$(TARGET)/icob/util/makefile: $(EXNUC)/icob/util/util.m
	cd $(EXNUC)/icob/util; \
	$(MAKEMAKE) util.m $(TARGET)/icob/util/makefile
