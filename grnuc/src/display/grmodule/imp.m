SOURCE
GRmodulei.I
GRmodinit.I
DPmderahil.I
GRaddfnt.I
GRaddfntbl.I
GRchgfstfnt.I
GRdelfnt.I
GRdelfntbl.I
GRmddisbybuf.I
GRmddisbyoid.I
GRmdinfntptr.I
GRmdupdall.I

SPEC
$(EXNUC)/spec
$(GRNUC)/spec

INCLUDE
$(INGRHOME)/include
$(XINC)
$(GRNUC)/include
$(EXNUC)/include
$(BS)/include
$(BS)/proto_include
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
$(GRLIB)/lib/grmodule.o
#else
ARCHIVE
$(GRLIB)/lib/grmodule.lib
#endif

#else
ARCHIVE
$GRMDS/lib/grmodule.a
#endif
