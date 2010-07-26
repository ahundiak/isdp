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
acc -knr

COPT
-ga

SRC
$(GRNUC)/src/go/dsgo

#ifndef IDRAW

#ifndef NT
LIB
$(GRLIB)/lib/dsgo.o
#else
ARCHIVE
$(GRLIB)/lib/dsgo.lib
#endif


#else

ARCHIVE
$GRMDS/lib/dsgo.a

#endif

SOURCE
GRdsi.I
GRdsnewi.I
GRdsfunk.I
