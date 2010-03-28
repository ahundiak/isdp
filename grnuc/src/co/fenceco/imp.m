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
$(GRNUC)/src/co/fenceco

#ifndef IDRAW

#ifndef NT
LIB
$(GRLIB)/lib/fenceco.o
#else
ARCHIVE
$(GRLIB)/lib/fenceco.lib
#endif

#else

ARCHIVE
$GRMDS/lib/fenceco.a

#endif

SOURCE
GRgsquery.I
GRparsekeyin.C
grpeventi.I
plfencei.I
GRsetinqgs.C
COloceligi.I
#ifndef IDRAW
saveelemi.I
GRdelnotlist.I
#endif
GRgscellact.I
COgenseti.I
COgensetf.I
COsymbact.I
COputset.C
COgetwin.C
LClocelig.I
