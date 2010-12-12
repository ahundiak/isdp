## @start 1
## Process this file with automake to produce Makefile.in

VDS = @VDS@
RIS = @RIS@

# Generic ris library
lib_LTLIBRARIES         = libisdp_ris.la

libisdp_ris_la_SOURCES  = ris_stubs.c ris_stmt.c

libisdp_ris_la_LDFLAGS  = -version-info 0:0:0
libisdp_ris_la_CFLAGS   = $(gio_DEPS_CFLAGS)

# test Executable
bin_PROGRAMS = tests

tests_SOURCES  = main.c part.c VDrisQryRc.c VDrisUtilRc.c VDrisUtil.c

tests_CFLAGS   = $(gio_DEPS_CFLAGS) -I$(RIS)/include -I$(VDS)/include

tests_LDADD    = $(gio_DEPS_LIBS) libisdp_ris.la

## @end 1
