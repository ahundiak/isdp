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
$(GRNUC)/src/co/symbco

#ifdef IDRAW

ARCHIVE
$GRMDS/lib/symbco.a

#else

#ifndef NT
LIB
$(GRLIB)/lib/symbco.o
#else
ARCHIVE
$(GRLIB)/lib/symbco.lib
#endif

#endif

SOURCE
COdefactsmi.I
COdefsymlibi.I
COrevcelli.I
COsdcreatei.I
COsdrenamei.I
COsmtocli.I
COsymplacei.I
DYsddyn.I
GRclplace.I
GRcpsdasl.I
GRcvttime.C
GRgetcell.I
GRggplace.I
GRparse.C
GRparseyn.C
GRsmplace.I
GRsmplmat.C
COreplacei.I
