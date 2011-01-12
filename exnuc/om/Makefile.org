all: \
	binaries \
	objects
	
binaries: \
	OPP \
	OPL

objects: \
	SPEC \
	IGRDIR \
	SRC \
	Copy_libOM \
	TOOLS \
	COPYOS \
	AUTORECLUSTER

OPP:
	@echo "\n\tMaking opp ..."
	@cd $(TARGET)/om/opp; pwd; $(MAKE);

OPL: $(TARGET)/om/opl/makefile
	@if test "$(UNAME)" = "CLIX"; \
	then \
		echo "\n\tMaking opl ..."; \
		cd $(TARGET)/om/opl; pwd; $(MAKE); \
	elif test "$(UNAME)" = "SunOS"; \
		then \
			echo "\n\tMaking opl ..."; \
			cd $(TARGET)/om/opl; pwd; $(MAKE); \
	elif test "$(UNAME)" = "IRIX"; \
	then \
			echo "\n\tMaking opl ..."; \
			cd $(TARGET)/om/opl; pwd; $(MAKE); \
	else \
		echo "$UNAME: invalid uname" >&2; \
		exit 2; \
	fi

$(TARGET)/om/opl/makefile: $(EXNUC)/om/opl/opl.m
	cd $(EXNUC)/om/opl; \
	$(MAKEMAKE) opl.m $(TARGET)/om/opl/makefile

TOOLS: $(TARGET)/om/tools/makefile
	@echo "\n\tMaking tools ..."
	@cd $(TARGET)/om/tools; pwd; $(MAKE);

$(TARGET)/om/tools/makefile: $(EXNUC)/om/tools/tools.m
	cd $(EXNUC)/om/tools; \
	$(MAKEMAKE) tools.m $(TARGET)/om/tools/makefile

AUTORECLUSTER: $(TARGET)/om/recluster/makefile
	@echo "\n\tMaking autorecluster ..."
	@cd $(TARGET)/om/recluster; \
	pwd; \
	$(MAKE) $(TARGET)/bin/autorecluster

$(TARGET)/om/recluster/makefile: $(EXNUC)/om/recluster/recluster.m
	cd $(EXNUC)/om/recluster; \
	$(MAKEMAKE) recluster.m $(TARGET)/om/recluster/makefile

COPYOS: $(TARGET)/om/tools/copyOS.mk
	@echo "\n\tMaking copyOS ..."
	@cd $(TARGET)/om/tools; \
	pwd; \
	$(MAKE) -f copyOS.mk

$(TARGET)/om/tools/copyOS.mk: $(EXNUC)/om/tools/copyOS.m
	cd $(EXNUC)/om/tools; \
	$(MAKEMAKE) copyOS.m $(TARGET)/om/tools/copyOS.mk

SPEC: $(TARGET)/om/spec/makefile
	@echo "\n\tMaking spec ..."
	@cd $(TARGET)/om/spec; \
	pwd; \
	$(MAKE)

$(TARGET)/om/spec/makefile: $(EXNUC)/om/spec/spec.m
	cd $(EXNUC)/om/spec; \
	$(MAKEMAKE) spec.m $(TARGET)/om/spec/makefile

SRC: $(TARGET)/om/src/makefile
	@echo "\n\tMaking src ..."
	@cd $(TARGET)/om/src; \
	pwd; \
	$(MAKE)

$(TARGET)/om/src/makefile: $(EXNUC)/om/src/src.m
	cd $(EXNUC)/om/src; \
	$(MAKEMAKE) src.m $(TARGET)/om/src/makefile

Copy_libOM:
	@if test "$(UNAME)" = "CLIX"; \
	then \
		echo "\n\tCoping $(LIBLOC)/libOM.a ..."; \
		cp $(TARGET)/$(LIBLOC)/libOM.a $(EXNUC)/../$(OTHERLOC)/$(LIBLOC)/libOM.a ; \
		ls -lst $(TARGET)/$(LIBLOC)/libOM.a ; \
		ls -lst $(EXNUC)/../$(OTHERLOC)/$(LIBLOC)/libOM.a ; \
		echo; \
	else \
		echo "\tOnly copy libOM.a on CLIX." >&2; \
	fi

IGRDIR: 
	@echo "\n\tMaking IGRdir ..."
	@cd $(TARGET)/om/IGRdir; \
	pwd; \
	$(MAKE)

TEST: $(TARGET)/om/test/makefile
	@echo "\n\tMaking test ..."
	@cd $(TARGET)/om/test; pwd; $(MAKE)

$(TARGET)/om/test/makefile: $(EXNUC)/om/test/test.m
	cd $(EXNUC)/om/test; \
	$(MAKEMAKE) test.m $(TARGET)/om/test/makefile
