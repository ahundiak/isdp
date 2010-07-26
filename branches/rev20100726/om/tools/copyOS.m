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
$(EXNUC)/om/tools

SOURCE
copyOS.I

DEPLIB
$(TARGET)/$(LIBLOC)/libOM.a
$(TARGET)/om/tools/OMclassinit.o
$(TARGET)/om/tools/OMapplinit.o
#ifdef INTEL
/usr/lib/libmapmalloc.so
#else
$(LIBXC_LIB_PATH)/libxcmalloc.a
#endif
$(LIBXC_LIB_PATH)/libxc.a

LINKLIB
#	if defined (CLIX)
-lix
-lmath
-lbsd
#	elif defined(SUNOS)
-ldl
-lm
-lfpstub
#	elif defined(IRIX)
-lm
#	endif
-lc 

OMCPP
$(EXNUC)/bin/omcpp

EXEC
$(TARGET)/bin/copyOS

INCLUDE
$(EXNUC)/include
$(LIBXC_INC_PATH)

SPEC
$(EXNUC)/spec
$(EXNUC)/om/spec

DEFINE
CCDEF
OMCPPDEF

POST_SPECIAL
opl = $(BASE)/bin/opl

$(TARGET)/om/tools/OMclassinit.o:
	@echo "\t$(SRC)/OMclassinit.C";
	@cd $(TARGET)/om/tools; \
	$(opl); \
	$(OMCPPDEF) OMclassinit.C OMclassinit.c; \
	$(CCDEF) -c OMclassinit.c; \
	rm OMclassinit.c

$(TARGET)/om/tools/OMapplinit.o:
	@echo "\t$(SRC)/OMapplinit.C";
	@cd $(TARGET)/om/tools; \
	$(opl) -a; \
	$(OMCPPDEF) OMapplinit.C OMapplinit.c; \
	$(CCDEF) -c OMapplinit.c; \
	rm OMapplinit.c
END_SPECIAL

OPP
$(BASE)/bin/opp

OMCPP
$(BASE)/bin/omcpp

