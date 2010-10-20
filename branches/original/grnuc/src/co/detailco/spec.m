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
$(EXNUC)/fi/spec
$(EXNUC)/icob/spec
$(EXNUC)/message/spec
$(EXNUC)/ms/spec
$(GRNUC)/spec

OPP
$(EXTARG)/bin/opp

OMCPP
$(EXTARG)/bin/omcpp

CC
acc -knr -O3

COPT
-ga

SRC
$(GRNUC)/src/co/detailco

#ifndef IDRAW

#ifndef NT
LIB
$(GRLIB)/lib/detailcosp.o
#else
ARCHIVE
$(GRLIB)/lib/detailcosp.lib
#endif

#else

LIB
$GRMDS/lib/detailcosp.o

#endif

SOURCE
COdetail.S