SRC
$(MODEL)/hsurf/src/driver_func
LIB
$(MDTARG)/hsurf/src/driver_func/driver_func.o
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
$(MODEL)/hsurf/src/spec
$(EXNUC)/spec
$(GRNUC)/spec
$(MODEL)/spec
INCLUDE
$(INGRHOME)/include
$(GRNUC)/ingrsys
$(MODEL)/hsurf/src/include
$(EXNUC)/include
$(GRNUC)/include
$(MODEL)/include
$(MODEL)/proto_include
$(BS)/include
$(BS)/include/prototypes
$(BS)/include/prototypes
#ifdef X11
$(XINC)
#endif
#if defined (XGL)
$(XGLHOME)/include
$(XGLHOME)/include/xgl
#endif
OPP
$(EXTARG)/bin/opp
OMCPP
$(EXTARG)/bin/omcpp
SOURCE
HSgetedges.I
HStildriver.C
HStilopt.I
HStl_dexel.C
HStl_feedbck.C
HSckzrange.c
HSdriver.c
