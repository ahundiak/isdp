include $(top_srcdir)/build/makerules

# SUFFIXES = .I .S .C

#.S.c .I.c:
#	@echo   OPP     $<
#	@$(IG_OPP) $(IG_OPP_FLAGS) $(IG_OPP_INCLUDES) $(IG_OPP_DEFINES) $<

#.C.c:
#	@echo   CPP     $<
#	@$(IG_CPP) $(IG_OPP_FLAGS) $(IG_OPP_INCLUDES) $(IG_OPP_DEFINES) $< $@

# =============================================
bin_PROGRAMS = Exnuc

Exnuc_SOURCES  = main.c OMclassinit.c

Exnuc_CFLAGS   = $(gio_DEPS_CFLAGS)
Exnuc_LDADD    = $(gio_DEPS_LIBS) -lm -lX11 -lXt -lXext \
  ../lib/libexnuc.la \
  ../../xforms/source/xfi/src10/libxfi.la


OMclassinit.c : ../lib/.libs/libexnuc.a
	oplx    ../lib/.libs/libexnuc.a
