all: \
	directories \
	SRC

directories:
	@if test ! -d $(TARGET)/message/lib; then mkdir $(TARGET)/message/lib; fi

SRC: $(TARGET)/message/src/makefile
	@cd $(TARGET)/message/src; \
	pwd; \
	$(MAKE)

$(TARGET)/message/src/makefile: $(EXNUC)/message/src/message.m
	cd $(EXNUC)/message/src; \
	$(MAKEMAKE) message.m $(TARGET)/message/src/makefile

