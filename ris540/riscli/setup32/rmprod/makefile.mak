# Do not alter this SPC information: $Revision: 1.15.3.1 $
!include $(RISDEVDIR)\ristools\include\makeenv.nt
!include $(RISDEVDIR)\riscli\setup32\setupenv.nt

RM_DIR=riscli\setup32\rmprod

IPATH=	\
	-I$(RISDEVDIR)\riscom\internal \
	-I$(RISDEVDIR)\rissrv\setup32 \
	-I$(RISDEVDIR)\riscli\setup32\remove \
	-I$(RISDEVDIR)\riscli\setup32\csource \
	-I$(RISDEVDIR)\riscli\setup32\bldcui \
	-I"$(NT_SETUP_DIR)\isdklib" \
	-I"$(NT_SETUP_DIR)\csource\bldcui" \
	-I"$(NT_SETUP_DIR)\csource" \
	-I"$(NT_SETUP_DIR)\remove" 

IPATH_RC=	\
		-I$(RISDEVDIR)\riscom\internal \
		-I$(RISDEVDIR)\rissrv\setup32 \
		-I$(RISDEVDIR)\riscli\setup32\csource \
		-I$(RISDEVDIR)\riscli\setup32\bldcui \
		-I"$(NT_SETUP_DIR)\csource\bldcui" 

fast: $(RISDEVDIR)\$(RM_EXE_DIR)\remove.exe 

$(RISDEVDIR)\$(RMPROD_DIR)\$(OBJDIR)\remove.obj: \
		$(RISDEVDIR)\$(RM_DIR)\remove.c \
		$(RISDEVDIR)\riscom\internal\risdebug.h \
		$(RISDEVDIR)\riscom\internal\risver.h \
		$(RISDEVDIR)\riscli\setup32\remove\risrem.h \
		$(RISDEVDIR)\riscli\setup32\rmprod\rmprod.h
	@echo Making remove.obj
	$(cc) -c $(IPATH) $(cdebug) -D$(RIS_PRODUCT) -D$(IS_RISSRV) $(cflags) \
		$(cvarsdll) $(RISDEVDIR)\$(RM_DIR)\remove.c
	@if exist $@ del $@
	@move $(@F) $(@)

$(RISDEVDIR)\$(RMPROD_DIR)\$(OBJDIR)\rmprod.obj: \
		$(RISDEVDIR)\$(RM_DIR)\rmprod.c \
		$(RISDEVDIR)\$(RM_DIR)\ingrreg.h \
		$(RISDEVDIR)\riscli\setup32\remove\risrem.h \
		$(RISDEVDIR)\riscom\internal\risver.h \
		$(RISDEVDIR)\riscli\setup32\csource\setupver.h \
		$(RISDEVDIR)\rissrv\setup32\defines.h \
		$(RISDEVDIR)\riscli\setup32\rmprod\rmprod.h
	@echo Making rmprod.obj
	$(cc) -c $(IPATH) $(cdebug) -D$(RIS_PRODUCT) -D$(IS_RISSRV) $(cflags) \
		$(cvarsdll) $(RISDEVDIR)\$(RM_DIR)\rmprod.c
	@if exist $@ del $@
	@move $(@F) $(@)

$(RISDEVDIR)\$(RMPROD_DIR)\$(OBJDIR)\remove.res: \
		$(RISDEVDIR)\$(RMPROD_DIR)\remove.rc \
		$(RISDEVDIR)\riscom\internal\risver.h \
		$(RISDEVDIR)\riscli\setup32\bldcui\cuirsc.rc
	@echo remove.rc -to- remove.res
	$(rc) -r /l 0x409 $(rcvars) $(IPATH_RC) -D$(RIS_PRODUCT) \
		-D$(IS_RISSRV) -fo $(RISDEVDIR)\$(RMPROD_DIR)\remove.res \
		$(cvars) $(RISDEVDIR)\$(RMPROD_DIR)\remove.rc
	@if exist $@ del $@
	@move $(@F) $(@)

$(RISDEVDIR)\$(RM_EXE_DIR)\remove.exe: \
		$(RISDEVDIR)\riscli\setup32\bin\nt\risrem.lib \
		$(RISDEVDIR)\$(RMPROD_DIR)\$(OBJDIR)\remove.obj \
		$(RISDEVDIR)\$(RMPROD_DIR)\$(OBJDIR)\rmprod.obj \
		$(RISDEVDIR)\$(RMPROD_DIR)\$(OBJDIR)\remove.res
	@echo Making remove.exe
	$(link) $(guiflags) -out:$@ \
		$(RISDEVDIR)\riscli\setup32\bin\nt\risrem.lib \
		$(RISDEVDIR)\$(RMPROD_DIR)\$(OBJDIR)\remove.obj \
		$(RISDEVDIR)\$(RMPROD_DIR)\$(OBJDIR)\rmprod.obj \
		$(RISDEVDIR)\$(RMPROD_DIR)\$(OBJDIR)\remove.res \
	        "$(NT_SETUP_DIR)\isdklib\isdk.lib" \
	        "$(NT_SETUP_DIR)\csource\cingr.lib" \
		$(guilibsdll) \
		version.lib
