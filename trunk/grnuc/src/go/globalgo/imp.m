CC
acc -knr

SOURCE
globalgo.c

INCLUDE
$(INGRHOME)/include
$(GRNUC)/include
$(EXNUC)/include
$(BS)/include
$(BS)/include/prototypes
$(FORMS)/include
$(GRNUC)/proto_pub
$(GRNUC)/proto_priv

SRC
$(GRNUC)/src/go/globalgo

#ifndef NT
LIB
$(GRLIB)/lib/globalgo.o
#else
ARCHIVE
$(GRLIB)/lib/globalgo.lib
#endif

