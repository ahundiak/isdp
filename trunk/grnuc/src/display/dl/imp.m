SOURCE
DLglobal.c
DLbsp_curve.c
DLcurve.c
DLfeedback.c
DLinit.c
DLline.c
DLmatrix.c
DLmatsup.c
DLpoly.c
DLsurf.c
DLtoler.c
DLviewport.c
DLgraphics.c
DLclip.c
DLxform.c
DLbezstrok.c
DLbbstrok.c
DLtri_edges.c
DLtri_facet.c
DLtri_main.c
DLtri_mesh.c
DLtri_reg.c
DLtri_sort.c

SPEC
$(EXNUC)/spec
$(GRNUC)/spec

INCLUDE
$(INGRHOME)/include
#ifdef X11
$(XINC)
#endif
$(GRNUC)/include
$(EXNUC)/include
$(BS)/include
$(BS)/include/prototypes
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
$(GRNUC)/src/display/dl

LIB
$(GRLIB)/lib/dl.o
