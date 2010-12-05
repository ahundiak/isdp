## @start 1
## Process this file with automake to produce Makefile.in

# ======================================
# First Module
lib_LTLIBRARIES           = module01.la

module01_la_SOURCES  = module01.c

module01_la_LDFLAGS   = -no-undefined -version-info 0:0:0 -module

module01_la_CFLAGS     = $(gmodule_DEPS_CFLAGS)

# ======================================
# Second Module
lib_LTLIBRARIES           = module02.la

module02_la_SOURCES  = module02.c

module02_la_LDFLAGS   = -no-undefined -version-info 0:0:0 -module

module02_la_CFLAGS     = $(gmodule_DEPS_CFLAGS)

# ======================================
# Test Program
bin_PROGRAMS = tests

tests_SOURCES  = tests.c

tests_CFLAGS     = $(gmodule_DEPS_CFLAGS) -I../lib

tests_LDADD      = $(gmodule_DEPS_LIBS) ../lib/libisdp_glib.la module02.la


## @end 1
