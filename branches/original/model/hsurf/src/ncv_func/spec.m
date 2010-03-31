SRC
$(MODEL)/hsurf/src/ncv_func
LIB
$(MDTARG)/hsurf/src/ncv_func/ncv_func.o
#if defined (sun)
CC
cc
#endif
COPT
-ga
CC
acc -knr
INCLUDE
$(INGRHOME)/include
$(GRNUC)/ingrsys
$(EXNUC)/include
$(GRNUC)/include
$(MODEL)/include
$(MODEL)/proto_include
$(BS)/include
$(BS)/include/prototypes
#ifdef X11
$(XINC)
#endif
#if defined (XGL)
$(XGLHOME)/include
$(XGLHOME)/include/xgl
#endif
SOURCE
NCd_co_op_dm.c
NCd_co_op_ht.c
NCd_noshad.c
NCd_sm_op_dm.c
NCd_sm_op_ht.c
NCgen_swvol.c
NCmath.c
NCmemory.c
NCmilling.c
NCorient.c
NCpaint.c
NCsimulate.c
NCsubtract.c
NCtool.c
NCtool_pbust.c
NCtoolpath.c
NCtrap.c
NCwindow.c
