SRC
$(MODEL)/hplot/src/hplot_func
LIB
hplot_func.o
#if defined (sun)
CC
cc
#else
CC
acc -knr
#endif
COPT
-ga
INCLUDE
$(PWD)
$(INGRHOME)/include
$(GRNUC)/ingrsys
/usr/include
$(HSURF)/src/include
$(MODEL)/hsurf/src/include
$(EXNUC)/include
$(GRNUC)/include
$(MODEL)/include
$(MODEL)/proto_include
$(BS)/include
$(BS)/include/prototypes
#if defined (X11)
$(XINC)
$(XINC)/X11
#endif
#if defined (XGL)
$(XGLHOME)/include
$(XGLHOME)/include/xgl
#endif
SOURCE
HPavail_mem.c
HPbanding.c
HPcvrt_bdrys.c
HPfini_band.c
HPfini_zbuf.c
HPinit_band.c
HPinit_hsurf.c
HPinit_zbuf.c
HPinitpant.c
HPr_af_op.c
HPr_af_tn.c
HPr_co_op.c
HPr_co_tn.c
HPr_dzine5.c
HPr_dzine6.c
HPr_ph.c
HPr_pl_ln.c
HPr_pt.c
HPr_radge5.c
HPr_radge6.c
HPr_rhl.c
HPr_rl.c
HPr_sm_op.c
HPr_sm_tn.c
HPr_swine5.c
HPr_swine6.c
HPr_swine7.c
HPreport.c
HPset_style.c
HPtiming.c
HPtype25.c
HPuniq_name.c
HPutil.c
HPzbuf_curve.c
HPzbuf_surf.c