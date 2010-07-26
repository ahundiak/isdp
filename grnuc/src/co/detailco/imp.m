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
$(GRLIB)/lib/detailco.o
#else
ARCHIVE
$(GRLIB)/lib/detail.lib
#endif

#else

ARCHIVE
$GRMDS/lib/detailco.a

#endif

SOURCE
DYauxview.I
DYprinview.I
DYtrnele.I
DYtrnelevi.I
DYauxcsrot.I
GRbldcvprism.C
GRconstrcs.I
GRconstrds.I
GRconstrdv.I
GRdvidmatrix.C
GRparsename.C
COdetaili.I
COdtlfrm.I
COdtlfunc.I
COdtlsend.I
COdtlset.I
COdtlrev.I
COdtloption.I
