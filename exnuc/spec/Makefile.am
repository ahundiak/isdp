include $(top_srcdir)/build/makerules

# SUFFIXES = .I .S

# .S.c .I.c:
#	$(IG_OPP) $(IG_OPP_FLAGS) $(IG_OPP_INCLUDES) $(IG_OPP_DEFINES) $<

noinst_LTLIBRARIES  = libspec.la

libspec_la_SOURCES  = fake.c Root.S

libspec_la_CFLAGS   = $(gio_DEPS_CFLAGS)

CLEANFILES = Root.c