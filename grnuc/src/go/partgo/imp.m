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
$(GRNUC)/src/go/partgo

#ifndef NT
LIB
$(GRLIB)/lib/partgo.o
#else
ARCHIVE
$(GRLIB)/lib/partgo.lib
#endif


SOURCE
GRparti.I
GRprtconstr.I
GRprtcopy.I
GRprtcopyown.I
GRprtdelete.I
GRprtdrop.I
GRprtadd.I
GRprtrem.I
GRprtmod.I
GRprtget.I
GRprtfunc.I
GRprtchg.I
GRprtname.I
GRprtpdm.I
GRprtanalyze.I
