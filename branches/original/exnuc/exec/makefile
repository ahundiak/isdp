objects:\
	directories \
	LOCALE \
	FONTEXEC \
	CMDSERVER \
	EXEC \
	EXPRODLIB \
	Copy_libexprod \
	EXECCO \
	MODULE \
	WL \
	CM \
	IGECOLOR \
	WFI \
	IGEWINDOW \
	UDATA \
	SHEXEC

directories:
	@if test ! -d $(TARGET)/exec/lib; then mkdir $(TARGET)/exec/lib; fi

binaries:\
	DRIVER \
	JNL

LOCALE: $(TARGET)/exec/locale/makefile
	@cd $(TARGET)/exec/locale; \
	pwd; \
	$(MAKE)

$(TARGET)/exec/locale/makefile: $(EXNUC)/exec/locale/locale.m
	cd $(EXNUC)/exec/locale; \
	$(MAKEMAKE) locale.m $(TARGET)/exec/locale/makefile

FONTEXEC: $(TARGET)/exec/fontexec/makefile
	@cd $(TARGET)/exec/fontexec; \
	pwd; \
	$(MAKE)

$(TARGET)/exec/fontexec/makefile: $(EXNUC)/exec/fontexec/fontexec.m
	cd $(EXNUC)/exec/fontexec; \
	$(MAKEMAKE)  fontexec.m $(TARGET)/exec/fontexec/makefile

CMDSERVER: $(TARGET)/exec/cmdserver/makefile
	@cd $(TARGET)/exec/cmdserver; \
	pwd; \
	$(MAKE)

$(TARGET)/exec/cmdserver/makefile: $(EXNUC)/exec/cmdserver/cmdserver.m
	cd $(EXNUC)/exec/cmdserver; \
	$(MAKEMAKE) cmdserver.m $(TARGET)/exec/cmdserver/makefile

EXEC: $(TARGET)/exec/exec/makefile
	@cd $(TARGET)/exec/exec; \
	pwd; \
	$(MAKE)

$(TARGET)/exec/exec/makefile: $(EXNUC)/exec/exec/exec.m
	cd $(EXNUC)/exec/exec; \
	$(MAKEMAKE) exec.m $(TARGET)/exec/exec/makefile

EXPRODLIB: $(TARGET)/exec/exec/makefile
	@cd $(TARGET)/exec/exec; \
	pwd; \
	$(MAKE) $(TARGET)/$(LIBLOC)/libexprod.a

Copy_libexprod:
	@if test "$(UNAME)" = "CLIX"; \
	then \
		echo "\n\tCoping $(LIBLOC)/libexprod.a ..."; \
		cp $(TARGET)/$(LIBLOC)/libexprod.a $(EXNUC)/../$(OTHERLOC)/$(LIBLOC)/libexprod.a ; \
		ls -lst $(TARGET)/$(LIBLOC)/libexprod.a ; \
		ls -lst $(EXNUC)/../$(OTHERLOC)/$(LIBLOC)/libexprod.a ; \
		echo; \
	else \
		echo "\tOnly copy libexprod.a on CLIX." >&2; \
	fi

EXECCO: $(TARGET)/exec/execco/makefile
	@cd $(TARGET)/exec/execco; \
	pwd; \
	$(MAKE)

$(TARGET)/exec/execco/makefile: $(EXNUC)/exec/execco/execco.m
	cd $(EXNUC)/exec/execco; \
	$(MAKEMAKE) execco.m $(TARGET)/exec/execco/makefile

WL: $(TARGET)/exec/wl/makefile
	@cd $(TARGET)/exec/wl; \
	pwd; \
	$(MAKE)

$(TARGET)/exec/wl/makefile: $(EXNUC)/exec/wl/wl.m
	cd $(EXNUC)/exec/wl; \
	$(MAKEMAKE) wl.m $(TARGET)/exec/wl/makefile

CM: $(TARGET)/exec/cm/makefile
	@cd $(TARGET)/exec/cm; \
	pwd; \
	$(MAKE)

$(TARGET)/exec/cm/makefile: $(EXNUC)/exec/cm/cm.m
	cd $(EXNUC)/exec/cm; \
	$(MAKEMAKE) cm.m $(TARGET)/exec/cm/makefile

IGECOLOR: $(TARGET)/exec/IGEcolor/makefile
	@cd $(TARGET)/exec/IGEcolor; \
	pwd; \
	$(MAKE)

$(TARGET)/exec/IGEcolor/makefile: $(EXNUC)/exec/IGEcolor/IGEcolor.m
	cd $(EXNUC)/exec/IGEcolor; \
	$(MAKEMAKE) IGEcolor.m $(TARGET)/exec/IGEcolor/makefile

MODULE: $(TARGET)/exec/module/makefile
	@cd $(TARGET)/exec/module; \
	pwd; \
	$(MAKE)

$(TARGET)/exec/module/makefile: $(EXNUC)/exec/module/module.m
	cd $(EXNUC)/exec/module; \
	$(MAKEMAKE) module.m $(TARGET)/exec/module/makefile

WFI: $(TARGET)/exec/wfi/makefile
	@cd $(TARGET)/exec/wfi; \
	pwd; \
	$(MAKE) 

$(TARGET)/exec/wfi/makefile: $(EXNUC)/exec/wfi/wfi.m
	cd $(EXNUC)/exec/wfi; \
	$(MAKEMAKE) wfi.m $(TARGET)/exec/wfi/makefile

IGEWINDOW: $(TARGET)/exec/igewindow/makefile
	@cd $(TARGET)/exec/igewindow; \
	pwd; \
	$(MAKE)

$(TARGET)/exec/igewindow/makefile: $(EXNUC)/exec/igewindow/igewindow.m
	cd $(EXNUC)/exec/igewindow; \
	$(MAKEMAKE) igewindow.m $(TARGET)/exec/igewindow/makefile

SHEXEC: $(TARGET)/exec/shexec/makefile
	@cd $(TARGET)/exec/shexec; \
	pwd; \
	$(MAKE)

$(TARGET)/exec/shexec/makefile:  $(EXNUC)/exec/shexec/shexec.m
	cd $(EXNUC)/exec/shexec; \
	$(MAKEMAKE) shexec.m $(TARGET)/exec/shexec/makefile


DRIVER: $(TARGET)/exec/driver/makefile
	@cd $(TARGET)/exec/driver; \
	pwd; \
	$(MAKE)

$(TARGET)/exec/driver/makefile: $(EXNUC)/exec/driver/driver.m
	cd $(EXNUC)/exec/driver; \
	$(MAKEMAKE) driver.m $(TARGET)/exec/driver/makefile

JNL: $(TARGET)/exec/jnl/makefile
	@cd $(TARGET)/exec/jnl; \
	pwd; \
	$(MAKE)

$(TARGET)/exec/jnl/makefile: $(EXNUC)/exec/jnl/jnl.m
	cd $(EXNUC)/exec/jnl; \
	$(MAKEMAKE) jnl.m $(TARGET)/exec/jnl/makefile

UDATA: $(TARGET)/exec/udata/makefile
	@cd $(TARGET)/exec/udata; \
	pwd; \
	$(MAKE)

$(TARGET)/exec/udata/makefile: $(EXNUC)/exec/udata/udata.m
	cd $(EXNUC)/exec/udata; \
	$(MAKEMAKE) udata.m $(TARGET)/exec/udata/makefile

