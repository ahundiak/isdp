SRC
$(MODEL)/hsurf/src/dpb_imp
LIB
$(MDTARG)/hsurf/src/dpb_imp/dpb_imp.o
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
$(GRNUC)/proto_priv
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
HSNCdpbi.I
HSNCtoolpthi.I
HScolor_info.C
HSconvert.I
HSctbl2i.I
HSdpb2i.I
HSedgeII_vlt.C
HSfemmode.C
HSlghtsrc.I
HSlight_src.I
HSmodes.C
HSrhl_info.C
HSshad_symb.I
NCVdpbi.I
