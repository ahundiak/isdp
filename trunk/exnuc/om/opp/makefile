#
#  Targets must be built in
#  the following order:
#

all:\
	TOOLS \
	SYMTAB \
	OMCPP \
	OPP \
	DDP

TOOLS: $(TARGET)/om/opp/tools/makefile
	@echo "\n\tMaking tools ..."
	@cd $(TARGET)/om/opp/tools; pwd; $(MAKE)

$(TARGET)/om/opp/tools/makefile: $(EXNUC)/om/opp/tools/tools.m
	cd $(EXNUC)/om/opp/tools; \
	$(MAKEMAKE) tools.m $(TARGET)/om/opp/tools/makefile

SYMTAB: $(TARGET)/om/opp/symtab/makefile
	@echo "\n\tMaking symtab ..."
	@cd $(TARGET)/om/opp/symtab; pwd; $(MAKE)

$(TARGET)/om/opp/symtab/makefile: $(EXNUC)/om/opp/symtab/symtab.m
	cd $(EXNUC)/om/opp/symtab; \
	$(MAKEMAKE) symtab.m $(TARGET)/om/opp/symtab/makefile

OMCPP: $(TARGET)/om/opp/cpp/makefile
	@echo "\n\tMaking cpp ..."
	@cd $(TARGET)/om/opp/cpp; pwd; $(MAKE)

$(TARGET)/om/opp/cpp/makefile: $(EXNUC)/om/opp/cpp/cpp.m
	cd $(EXNUC)/om/opp/cpp; \
	$(MAKEMAKE) cpp.m $(TARGET)/om/opp/cpp/makefile

OPP: $(TARGET)/om/opp/opp/makefile
	@echo "\n\tMaking opp ..."
	@cd $(TARGET)/om/opp/opp; pwd; $(MAKE)

#
#	Have to make sure some generated files exist before makemake
#	will work.  This should only happen on the first makemake for
#	that directory.
#

$(TARGET)/om/opp/opp/makefile: \
	$(EXNUC)/om/opp/opp/opp.m \
	$(TARGET)/om/opp/opp/kpster.h \
	$(TARGET)/om/opp/opp/kptype.h \
	$(TARGET)/om/opp/opp/y.tab.h
	cd $(EXNUC)/om/opp/opp; \
	$(MAKEMAKE) opp.m $(TARGET)/om/opp/opp/makefile

$(TARGET)/om/opp/opp/kpster.h $(TARGET)/om/opp/opp/kptype.h $(TARGET)/om/opp/opp/y.tab.h:
	if test "$(UNAMESR)" = "SunOS 5.5.1" -o "$(UNAMESR)" = "SunOS 5.5" -o "$(UNAMESR)" = "SunOS 5.4" -o "$(UNAMESR)" = "SunOS 5.8" -o "$(UNAMESR2)" = "IRIX 5"; \
	then \
		cp $(EXNUC)/om/opp/opp/ntkpster.h $(TARGET)/om/opp/opp/kpster.h; \
		cp $(EXNUC)/om/opp/opp/ntkptype.h $(TARGET)/om/opp/opp/kptype.h; \
		cp $(EXNUC)/om/opp/opp/nty.tab.h $(TARGET)/om/opp/opp/y.tab.h; \
	else \
		touch $@; \
	fi

DDP: $(TARGET)/om/opp/ddp/makefile
	@echo "\n\tMaking ddp ..."
	@cd $(TARGET)/om/opp/ddp; pwd; $(MAKE)

$(TARGET)/om/opp/ddp/makefile: $(EXNUC)/om/opp/ddp/ddp.m
	cd $(EXNUC)/om/opp/ddp; \
	$(MAKEMAKE) ddp.m $(TARGET)/om/opp/ddp/makefile
