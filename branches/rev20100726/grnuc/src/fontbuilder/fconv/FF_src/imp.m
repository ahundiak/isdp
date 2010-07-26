CC
$(COMPILER)

SOURCE

FFerror.c

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
$(GRNUC)/src/fontbuilder/fconv/FF_src

#ifndef NT
ARCHIVE
$(GRLIB)/src/fontbuilder/fconv/lib/FF.a 
#else
ARCHIVE
$(GRLIB)/src/fontbuilder/fconv/lib/FF.lib
#endif

OPP
$(EXTARG)/bin/opp

OMCPP
$(EXTARG)/bin/omcpp
