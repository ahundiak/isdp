SRC
$(MODEL)/ve/src/co_imp
LIB
co_imp.o
#if defined (sun)
CC
cc
#else
CC
acc -knr
#endif
COPT
-ga
SPEC
$(EXNUC)/spec
$(GRNUC)/spec
$(MODEL)/spec
INCLUDE
$(INGRHOME)/include
$(GRNUC)/ingrsys
#ifdef X11
$(XINC)
#endif
$(EXNUC)/include
$(GRNUC)/include
$(BS)/include
$(BS)/include/prototypes
$(MODEL)/include
$(MODEL)/proto_include
#if defined (XGL)
$(XGLHOME)/include
$(XGLHOME)/include/xgl
#endif
OPP
$(EXTARG)/bin/opp
OMCPP
$(EXTARG)/bin/omcpp
SOURCE
VEcheformi.I
VEedgescmdsi.I
VEretrievei.I
VEtogglei.I
