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
$(GRNUC)/src/co/eventsco

#ifdef IDRAW

LIB
$GRMDS/lib/eventscosp.o

#else

#ifndef NT
LIB
$(GRLIB)/lib/eventscosp.o
#else
ARCHIVE
$(GRLIB)/lib/eventscosp.lib
#endif

#endif

SOURCE
COevgen.S
