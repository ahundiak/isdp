
#ifndef NT
ARCHIVE
$(GRLIB)/src/fontbuilder/fconv/lib/FS.a
#else
ARCHIVE
$(GRLIB)/src/fontbuilder/fconv/lib/FS.lib
#endif

SRC
$(GRNUC)/src/fontbuilder/fconv/FS_src

SOURCE

FSaccess.c
FSio.c
FScrypt.c
FSfindChdr.c
FSfindKern.c
FSsortChdr.c
FSsortKern.c

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
