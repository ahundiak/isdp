SOURCE
globalco.c

INCLUDE
$(INGRHOME)/include
$(GRNUC)/include
$(EXNUC)/include
$(BS)/include
$(BS)/include/prototypes
$(GRNUC)/proto_pub
$(GRNUC)/proto_priv

SRC
$(GRNUC)/src/co/globalco

#ifdef IDRAW

ARCHIVE
$GRMDS/lib/globalco.a

#else

#ifndef NT
LIB
$(GRLIB)/lib/globalco.o
#else
ARCHIVE
$(GRLIB)/lib/globalco.lib
#endif

#endif

CC
acc -knr -o3
