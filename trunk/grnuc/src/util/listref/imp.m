INCLUDE
$(INGRHOME)/include
$(EXNUC)/include
$(GRNUC)/include
$(BS)/include
$(BS)/include/prototypes
$(GRNUC)/proto_pub
$(GRNUC)/proto_priv

SPEC
$(EXNUC)/spec
$(GRNUC)/spec

OPP
$(EXTARG)/bin/opp

OMCPP
$(EXTARG)/bin/omcpp

CC
acc -knr

COPT
-ga

#ifdef SUNOS_2.4
EXECOPT
-L /usr/5lib
#endif

SRC
$(GRNUC)/src/util/listref

EXECUTABLE
$(GRLIB)/bin/listref

DEPLIB
$(GRLIB)/lib/utilmisc.a
#ifdef BIG_ENDIAN
$(GRLIB)/src/go/transgo/GUconv_utils.o
#endif

SOURCE
listref.c
