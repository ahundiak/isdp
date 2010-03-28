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
acc -knr -O2

COPT
-ga

SRC
$(GRNUC)/src/co/csco

#ifndef NT
LIB
$(GRLIB)/lib/csco.o
#else
ARCHIVE
$(GRLIB)/lib/csco.lib
#endif

SOURCE
COcstogglei.I
#ifndef IDRAW
COcsdefaulti.I
COcsdefinei.I
COcsreviewi.I
#endif
