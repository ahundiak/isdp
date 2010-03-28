INCLUDE
$(INGRHOME)/include
$(XINC)
$(EXNUC)/include
$(GRNUC)/include
$(BS)/include
$(BS)/include/prototypes
$(GRNUC)/proto_pub
$(GRNUC)/proto_priv
#if defined (XGL)
$(XGLHOME)/include
$(XGLHOME)/include/xgl
#endif

SPEC
$(EXNUC)/spec
$(GRNUC)/spec

OPP
$(EXTARG)/bin/opp

OMCPP
$(EXTARG)/bin/omcpp

CC
acc -knr -O3

COPT
-ga

#ifndef IDRAW

SRC
$(GRNUC)/src/co/fenceco

#ifndef NT
LIB
$(GRLIB)/lib/fencecosp.o
#else
ARCHIVE
$(GRLIB)/lib/fencecosp.lib
#endif

#else

LIB
$GRMDS/lib/fencecosp.o

#endif

SOURCE
COgrpevent.S
COplfence.S
COlocelig.S
COgenset.S
#ifndef IDRAW
COsaveelem.S
#endif
