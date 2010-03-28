
#ifndef NT
ARCHIVE
$(GRLIB)/src/fontbuilder/fconv/lib/Flib.a
#else
ARCHIVE
$(GRLIB)/src/fontbuilder/fconv/lib/Flib.lib
#endif

SRC
$(GRNUC)/src/fontbuilder/fconv/Flib_src

SOURCE
Flib.c
FlibCheck.c
FlibConv.c
FlibckIGDS.c
FlibFSlib.c
FlibIo.c
FlibPub.c

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
