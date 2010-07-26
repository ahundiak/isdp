
#ifndef NT
ARCHIVE
$(GRLIB)/src/fontbuilder/fconv/lib/FF.a
#else
ARCHIVE
$(GRLIB)/src/fontbuilder/fconv/lib/FF.lib
#endif

SRC 
$(GRNUC)/src/fontbuilder/fconv/FF_src

SOURCE
FFerror.c
FFinit.c
FFinitVLT.c

CC
$(COMPILER)

COPT
$(COMPOPT)

SPEC

INCLUDE
$(INGRHOME)/include
$(BS)/include
$(EXNUC)/include
$(GRNUC)/include
$(GRNUC)/src/fontbuilder/fconv/include
$(BS)/proto_include
$(GRNUC)/proto_pub
$(GRNUC)/proto_priv
