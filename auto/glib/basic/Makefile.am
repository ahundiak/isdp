## @start 1
## Process this file with automake to produce Makefile.in

bin_PROGRAMS = tests
tests_SOURCES  = main.c basic.c hash.c

tests_CFLAGS     = $(DEPS_CFLAGS) -I../lib
tests_LIBS           = $(DEPS_LIBS)
tests_LDADD      = $(DEPS_LIBS) ../lib/libisdp_glib.la

## @end 1
