SRC
$(GRNUC)/src/grdpb/grdpb

CC 
acc -knr

SOURCE
GRdpbclass.I
GRdpbdebug.I
GRdpbelcl.I
GRdpbfunc.I
GRdpbi.I
GRdpbname.I
GRsetinq.I
GRdpbget.I

#ifndef NT
LIB
$(GRLIB)/lib/grdpb.o
#else
ARCHIVE
$(GRLIB)/lib/grdpb.lib
#endif


SPEC
$(EXNUC)/spec
$(GRNUC)/spec

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

OPP
$(EXTARG)/bin/opp

OMCPP
$(EXTARG)/bin/omcpp
