SOURCE
DPwncons.I
DPwndisbyoid.I
DPwndisbybuf.I
DPwnerahil.I
DPwnupdall.I
DPezfunc.C

SPEC
$(EXNUC)/spec
$(GRNUC)/spec

INCLUDE
$(INGRHOME)/include
$(EXNUC)/include
$(GRNUC)/include
$(BS)/include
$(BS)/include/prototypes
$(GRNUC)/proto_pub
$(GRNUC)/proto_priv

SRC
$(GRNUC)/src/display/grwindow

#ifndef IDRAW

#ifndef NT
LIB
$(GRLIB)/lib/grwindow.o
#else
ARCHIVE
$(GRLIB)/lib/grwindow.lib
#endif

#else

ARCHIVE
$GRMDS/lib/grwindow.a

#endif

OPP
$(EXTARG)/bin/opp

OMCPP
$(EXTARG)/bin/omcpp

CC
acc -knr

COPT
-ga
