all:\
	directories \
	LIB \
	SRC

directories:
	@if test ! -d $(TARGET)/package/bin; then mkdir $(TARGET)/package/bin; fi

LIB: $(TARGET)/package/lib/makefile
	@cd $(TARGET)/package/lib; \
	pwd; \
	$(MAKE)

$(TARGET)/package/lib/makefile: $(EXNUC)/package/lib/lib.m
	cd $(EXNUC)/package/lib; \
	$(MAKEMAKE) lib.m $(TARGET)/package/lib/makefile

SRC: $(TARGET)/package/src/makefile
	@cd $(TARGET)/package/src; \
	pwd; \
	$(MAKE)

$(TARGET)/package/src/makefile: $(EXNUC)/package/src/src.m
	cd $(EXNUC)/package/src; \
	$(MAKEMAKE) src.m $(TARGET)/package/src/makefile
