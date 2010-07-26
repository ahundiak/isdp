INCLUDE
$(INGRHOME)/include
$(XINC)
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
acc -knr -O3

COPT
-ga

SRC
$(GRNUC)/src/co/csco

#ifndef NT
LIB
$(GRLIB)/lib/cscosp.o
#else
ARCHIVE
$(GRLIB)/lib/cscosp.lib
#endif

SOURCE
COcstoggle.S
#ifndef IDRAW
COcsdefault.S
COcsdefine.S
COcsreview.S
#endif
