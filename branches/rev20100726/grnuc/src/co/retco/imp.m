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

SRC
$(GRNUC)/src/co/retco

#ifndef IDRAW

#ifndef NT
LIB
$(GRLIB)/lib/retco.o
#else
ARCHIVE
$(GRLIB)/lib/retco.lib
#endif

#else

ARCHIVE
$GRMDS/lib/retco.a

#endif

SOURCE
COretcoi.I
