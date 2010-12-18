include $(top_srcdir)/build/makerules

noinst_LTLIBRARIES  = libom_spec.la

libom_spec_la_CFLAGS   = $(gio_DEPS_CFLAGS)

libom_spec_la_SOURCES  = \
 OMISO.S    \
 OMMOSDOS.S \
 OMOSCO.S   \
 OMTag.S    \
 OMTagCon.S

CLEANFILES = \
 OMISO.c     \
 OMMOSDOS.c  \
 OMOSCO.c    \
 OMTag.c     \
 OMTagCon.c
