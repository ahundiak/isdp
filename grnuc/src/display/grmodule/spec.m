SOURCE
GRmodule.S

SPEC
$(EXNUC)/spec
$(GRNUC)/spec

INCLUDE
$(INGRHOME)/include
$(XINC)
$(GRNUC)/include
$(EXNUC)/include
$(BS)/include/prototypes
$(GRNUC)/proto_pub
$(GRNUC)/proto_priv
#if defined (XGL)
$(XGLHOME)/include
$(XGLHOME)/include/xgl
#endif

CC
acc -knr

COPT
-ga

OPP
$(EXTARG)/bin/opp

OMCPP
$(EXTARG)/bin/omcpp

SRC
$(GRNUC)/src/display/grmodule

#ifndef IDRAW

#ifndef NT
LIB
$(GRLIB)/lib/grmodulesp.o
#else
ARCHIVE
$(GRLIB)/lib/grmodulesp.lib
#endif
#else
LIB
$GRMDS/lib/grmodulesp.o
#endif
