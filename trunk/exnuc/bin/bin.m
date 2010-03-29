COPT
#ifdef NT

#ifdef _DEBUG
-W3 -Zp8 -Gd -nologo -Od -Zi -MTd
#else /* _DEBUG */
-W3 -Zp8 -Gd -nologo -O2
#endif /* _DEBUG */

#else /* NT */
-DBASE_EMS
#endif /* NT */

SRC
$(EXNUC)/bin

DEFINE
CCDEF
OMCPPDEF

INCLUDE
$(EXNUC)/include
#if defined (X11)
$(X11_INC_PATH)
#endif

SPECIAL
OPPFLAGS=$(IPATH)
END_SPECIAL

POST_SPECIAL
opl = $(BASE)/bin/opl
omcpp= $(BASE)/bin/omcpp

ARCHIVE = libexnuc.a

EXOBJECTS = \
	$(TARGET)/lib/igefei.o \
	$(TARGET)/lib/exforceref.o \
        $(TARGET)/$(LIBLOC)/$(ARCHIVE)

XLIB    =
XSTUB   =

UMSLIB   = $(UMS_LIB_PATH)/libUMS.a
UMSLIB   = -lUMS
        
#if defined (XGL)
XGLLIB = /opt/SUNWits/Graphics-sw/xgl/lib/libxgl.so
SYSXLIB  = $(FORMS_LIB_PATH)/libforms_s.a $(FONTSERVE_LIB_PATH)/libXFS_s.a -lgpipe_s -ltools_s $(FORMS_LIB_PATH)/libhelp.a
SYSLIB   = $(SYSXLIB) $(LINKLIB1) $(XLIB) $(LINKLIB2) $(UMSLIB) $(XGLLIB) -ldl -lnsl -lsocket -lw
MGUI_LIB_PATH = .
#elif defined (SUNOS5)
SYSXLIB  = $(FORMS_LIB_PATH)/libforms_s.a $(FONTSERVE_LIB_PATH)/libXFS_s.a -lgpipe_s -ltools_s $(FORMS_LIB_PATH)/libhelp.a
SYSLIB   = $(SYSXLIB) $(LINKLIB1) $(XLIB) $(LINKLIB2) $(UMSLIB) -lICE -lSM -ldl -lnsl -lsocket -lw
MGUI_LIB_PATH = .
#else
SYSXLIB  = $(FORMS_LIB_PATH)/libforms_s.a $(FONTSERVE_LIB_PATH)/libFS_s.a -lgpipe_s -ltools_s $(HELPDP_LIB_PATH)/libhlibEV.a
SYSLIB   = $(SYSXLIB) $(LINKLIB1) $(XLIB) $(LINKLIB2) $(UMSLIB)
#endif

OBJECTS = \
	$(TARGET)/bin/main.o \
	$(TARGET)/bin/OMclassinit.o \
	$(TARGET)/lib/rapstub.o

SPECOBJECTS = \
	$(TARGET)/spec/exnucspec.o \
	$(TARGET)/om/spec/OMISO.o \
	$(TARGET)/om/spec/OMMOSDOS.o \
	$(TARGET)/om/spec/OMOSCO.o \
	$(TARGET)/om/spec/OMTag.o \
	$(TARGET)/om/spec/OMTagCon.o

#if defined (SUNOS)
$(TARGET)/bin/Exnuc: $(EXOBJECTS) $(OBJECTS) $(TARGET)/lib/OMapplinit.o $(XSTUB)
	@$(MAKE) version
	$(CC) -o $(TARGET)/bin/Exnuc \
	$(LDFLAGS) $(EXECOPT) \
	$(TARGET)/bin/exversion.o \
	$(TARGET)/bin/main.o \
	$(TARGET)/bin/OMclassinit.o \
	$(TARGET)/lib/OMapplinit.o \
	$(TARGET)/lib/rapstub.o \
	-lfpstub \
	$(XSTUB) \
	$(TARGET)/lib/igefei.o \
	-L $(TARGET)/$(LIBLOC) -lXexnuc \
	$(SYSLIB)
	@echo
	@ls -ls $(TARGET)/bin/Exnuc
	@if test "$(UNAME)" = "IRIX"; \
	then \
		if test ! -d $(TARGET)/config/dload/init; \
		then \
			mkdir $(TARGET)/config/dload/init; \
		fi; \
		nm -Be $(TARGET)/bin/Exnuc > $(TARGET)/config/dload/init/symbols; \
	fi
	@echo
#else
$(TARGET)/bin/Exnuc: $(EXOBJECTS) $(OBJECTS) $(TARGET)/lib/OMapplinit.o $(XSTUB)
	@$(MAKE) version
	$(CC) -o $(TARGET)/bin/Exnuc \
	$(LDFLAGS) $(EXECOPT) \
	$(TARGET)/bin/exversion.o \
	$(TARGET)/bin/main.o \
	$(TARGET)/bin/OMclassinit.o \
	$(TARGET)/lib/OMapplinit.o \
	$(TARGET)/lib/rapstub.o \
	$(XSTUB) \
	$(EXOBJECTS) \
	$(SYSLIB)
	@echo
	@ls -ls $(TARGET)/bin/Exnuc
	@if test "$(UNAME)" = "IRIX"; \
	then \
		if test ! -d $(TARGET)/config/dload/init; \
		then \
			mkdir $(TARGET)/config/dload/init; \
		fi; \
		nm -Be $(TARGET)/bin/Exnuc > $(TARGET)/config/dload/init/symbols; \
	fi
	@echo
#endif

$(TARGET)/bin/OMclassinit.o: $(SPECOBJECTS)
	@echo "\t$(TARGET)/bin/OMclassinit.o"; \
	cd $(TARGET)/bin; \
	$(opl) $(SPECOBJECTS); \
	$(OMCPPDEF) OMclassinit.C OMclassinit.c; \
	$(CCDEF) -c OMclassinit.c; \
	rm -f OMclassinit.c

$(TARGET)/lib/OMapplinit.o: $(TARGET)/lib/$(PRODUCT_NAME)ver.o
	@echo "\t$(TARGET)/lib/OMapplinit.o"; \
	cd $(TARGET)/lib; \
	$(opl) -a $(PRODUCT_NAME)ver.o; \
	$(OMCPPDEF) OMapplinit.C OMapplinit.c; \
	$(CCDEF) -c OMapplinit.c; \
	rm -f OMapplinit.c

version:
	@echo
	@echo "#define exdatestr \"`date`\"" > $(TARGET)/bin/exversion.c
	@echo "#define exverstr \"I/$(PRODUCT_NAME) version $(PRODUCT_VERSION)\"" >> $(TARGET)/bin/exversion.c
	@cat $(EXNUC)/bin/exvers.c >> $(TARGET)/bin/exversion.c
	cd $(TARGET)/bin; $(CCDEF) -c exversion.c

$(TARGET)/bin/main.o: $(TARGET)/bin/makemain $(EXNUC)/bin/APP_main.C
	@echo "\n\tMaking $(TARGET)/bin/main.o ...";
	cd $(TARGET)/bin; \
	pwd; \
	$(MAKE) -f makemain

$(TARGET)/bin/makemain: $(EXNUC)/bin/makemain.m
	cd $(EXNUC)/bin; \
	$(MAKEMAKE) makemain.m $(TARGET)/bin/makemain
END_SPECIAL
