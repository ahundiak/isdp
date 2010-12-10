## @start 1
## Process this file with automake to produce Makefile.in

bin_PROGRAMS = tests

tests_SOURCES  = main.c part.c VDrisQryRc.c VDrisUtilRc.c VDrisUtil.c

tests_CFLAGS   = $(gio_DEPS_CFLAGS) -I$(RIS)/include -I$(VDS)/include

tests_LDADD    = $(gio_DEPS_LIBS) /opt/ingr/lib/ris.a /opt/ingr/lib/ums.a

## @end 1
