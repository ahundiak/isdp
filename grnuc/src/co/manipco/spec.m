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
$(GRNUC)/IGRdir/spec
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
$(GRNUC)/src/co/manipco

#ifdef IDRAW
LIB
$GRMDS/lib/manipcosp.o

#else

#ifndef NT
LIB
$(GRLIB)/lib/manipcosp.o
#else
ARCHIVE
$(GRLIB)/lib/manipcosp.lib
#endif

#endif

SOURCE
COchange.S
COcpparal.S
COgsmanip.S
COmanip.S
