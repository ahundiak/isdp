CC
$(COMPILER)

SOURCE

FlibConv.c
FlibIo.c

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
$(GRNUC)/src/fontbuilder/fconv/Flib_src


#ifndef NT
ARCHIVE
$(GRLIB)/src/fontbuilder/fconv/lib/Flib.a 
#else
ARCHIVE
$(GRLIB)/src/fontbuilder/fconv/lib/Flib.lib 
#endif

OPP
$(EXTARG)/bin/opp

OMCPP
$(EXTARG)/bin/omcpp
