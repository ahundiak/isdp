LIB
display_func.o

COPT
-ga

SOURCE
HSd_af_ifb.c
HSd_af_op.c
HSd_af_tn.c
HSd_co_ifb.c
HSd_co_op_dm.c
HSd_co_op_ht.c
HSd_co_tn_dm.c
HSd_co_tn_ht.c
HSd_drawtrap.c
HSd_fem_dir.c
HSd_fem_dith.c
HSd_fixedpt.c
HSd_paint.c
HSd_pl_ln.c
HSd_pt.c
HSd_radges.c
HSd_radged.c
HSd_vedge.c
HSd_repaint.c
HSd_rl.c
HSd_rl_dl.c
HSd_rl_ifb.c
HSd_rl_rop.c
HSd_sm_ifb.c
HSd_sm_op_dm.c
HSd_sm_op_ht.c
HSd_sm_tn_dm.c
HSd_sm_tn_ht.c
HSd_ztrap.c
HSd_ctbl.c
HSd_swine.c
HSd_dzine.c

CC
acc -knr 

INCLUDE
#ifdef X11
$(XINC)
#endif
../include
$(EXNUC)/include
$(GRNUC)/include
$(MODEL)/include
$(MODEL)/proto_include
$(BS)/include
