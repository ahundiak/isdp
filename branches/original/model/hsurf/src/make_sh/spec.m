SRC
$(MODEL)/hsurf/src/make_sh
LIB
$(MDTARG)/hsurf/lib/hsurf.o
CC
acc -knr
DEPLIB
$(MDTARG)/hsurf/src/co_func/co_func.o
$(MDTARG)/hsurf/src/co_imp/co_imp.o
$(MDTARG)/hsurf/src/display_func/display_func.o
$(MDTARG)/hsurf/src/dpb_imp/dpb_imp.o
$(MDTARG)/hsurf/src/driver_func/driver_func.o
$(MDTARG)/hsurf/src/gragad_imp/gragad_imp.o
$(MDTARG)/hsurf/src/hplot_imp/hplot_imp.o
$(MDTARG)/hsurf/src/ncv_func/ncv_func.o
$(MDTARG)/hsurf/src/pbust_func/pbust_func.o
$(MDTARG)/hsurf/src/render_imp/render_imp.o
$(MDTARG)/hsurf/src/tiler_func/tiler_func.o
$(MDTARG)/hsurf/src/lvhl/lvhl.o
$(MDTARG)/hsurf/src/bundle_imp/bundle_imp.o
$(MDTARG)/hsurf/src/dlist/dlist.o
INCLUDE
$(INGRHOME)/include
$(XINC)
$(GRNUC)/ingrsys
$(EXNUC)/include
$(GRNUC)/include
$(MODEL)/include
#if defined (XGL)
$(XGLHOME)/include
$(XGLHOME)/include/xgl
#endif
SOURCE
hsurf_global.c
