## @start 1
## Process this file with automake to produce Makefile.in

EXNUC = @EXNUC@

lib_LTLIBRARIES = libisdp_exnuc_som.la vdisom.la

libisdp_exnuc_som_la_SOURCES = som_ISO_fetch.c
libisdp_exnuc_som_la_CFLAGS  = $(gmodule_DEPS_CFLAGS) -I$(EXNUC)/include
libisdp_exnuc_som_la_LDFLAGS = -version-info 0:0:0

vdisom_la_SOURCES = som_ISO_fetch.c
vdisom_la_CFLAGS  = $(gmodule_DEPS_CFLAGS) -I$(EXNUC)/include
vdisom_la_LDFLAGS = -module -avoid-version

## %DLOAD-E-ILLREDEF, "/usr/tmp/vdisom.so":  Illegal redefinition of global variable "_lib_version".
# ld -z text -G -h vdisom.so -o .libs/vdisom.so  .libs/vdisom_la-som_ISO_fetch.o

## @end 1
