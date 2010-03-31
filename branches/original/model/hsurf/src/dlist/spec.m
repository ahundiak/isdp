SRC
$(MODEL)/hsurf/src/dlist
LIB
$(MDTARG)/hsurf/src/dlist/dlist.o
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
$(MODEL)/hsurf/spec
$(MODEL)/spec
$(MODEL)/ve/spec
INCLUDE
$(INGRHOME)/include
$(GRNUC)/ingrsys
$(EXNUC)/include
$(GRNUC)/include
$(MODEL)/include
$(BS)/include
$(BS)/include/prototypes
$(MODEL)/proto_include
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
HSdl_bbs.C
HSdl_display.I
HSdl_init.I
HSdl_misc.C
HSdl_msc.I
HSdl_notify.I
HSdl_mem.c
