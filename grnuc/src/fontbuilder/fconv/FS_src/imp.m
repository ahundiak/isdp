CC
$(COMPILER)

COPT
$(COMPOPT)

SOURCE

FSaccess.c
FScrypt.c
FSfindChdr.c
FSfindKern.c
FSio.c
FSsortChdr.c
FSsortKern.c

SPEC
$(EXNUC)/spec
$(GRNUC)/spec

INCLUDE
$(INGRHOME)/include
$(GRNUC)/src/fontbuilder/fconv/include
$(GRNUC)/include
$(EXNUC)/include
$(BS)/include
$(BS)/include/prototypes
$(GRNUC)/proto_pub
$(GRNUC)/proto_priv

SRC
$(GRNUC)/src/fontbuilder/fconv/FS_src


#ifndef NT
ARCHIVE
$(GRLIB)/src/fontbuilder/fconv/lib/FS.a 
#else
ARCHIVE
$(GRLIB)/src/fontbuilder/fconv/lib/FS.lib 
#endif

OPP
$(EXTARG)/bin/opp

OMCPP
$(EXTARG)/bin/omcpp
