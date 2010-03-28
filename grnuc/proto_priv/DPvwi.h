#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/co/displayco/DPvwi.I */
extern IGRint DPget_curr_win __((IGRlong *msg, GRobjid win_objid, struct DPbase_gg_t *base_p, struct DPview_wrk_t *wrk_p, struct DPpyramid_t *pyrmd_p));
extern IGRint DPunload_dynamics __((IGRlong *msg, struct DPview_wrk_t *wrk_p));
extern IGRint DPload_dynamics __((IGRlong *msg, IGRint win_class, struct DPview_wrk_t *wrk_p, struct DPbase_gg_t *base_p));
extern IGRint DPdyn_phase __((IGRlong *msg, struct DPbase_gg_t *base_p, struct DPview_wrk_t *wrk_p, struct DPpyramid_t *pyrmd_p));
extern IGRint DPwrk_to_gg __((IGRlong *msg, struct DPview_wrk_t *wrk_p, struct DPgra_gad *curr_gg_p, IGRint update));
extern IGRint DPco_erase_win __((IGRlong *msg, IGRint win_no, IGRint xlo, IGRint ylo, IGRint xhi, IGRint yhi));
extern IGRint DPget_base_wrk __((IGRlong *msg, struct DPbase_gg_t *base_p, struct DPview_wrk_t *wrk_p));
extern IGRint DPbase_to_wrk __((IGRlong *msg, struct DPbase_gg_t *base_p, struct DPview_wrk_t *wrk_p));
extern IGRint DPvw_start __((IGRlong *msg, struct DPview_wrk_t *wrk_p));
extern IGRint DPvw_end __((IGRlong *msg, struct DPview_wrk_t *wrk_p, IGRint in_flags));
extern IGRint DPpick_curr_window __((IGRlong *msg, GRobjid win_objid, struct DPview_wrk_t *wrk_p));
extern IGRint DPdp_pyramid __((IGRlong *msg, struct DPpyramid_t *pyrmd_p, struct DPview_wrk_t *wrk_p, IGRdouble *view_to_wld, IGRint erase));
extern IGRint DPset_pyramid __((IGRlong *msg, struct DPpyramid_t *pyrmd_p, struct DPview_wrk_t *wrk_p, IGRdouble *view_to_wld));
extern IGRint DPlevels_is_included __((char *levels1, char *levels2));
extern IGRint DPwindow_class __((struct GRid *window));
extern IGRint DPfactor_zoom __((IGRlong *msg, IGRdouble factor, struct DPbase_gg_t *base_p, struct DPview_wrk_t *wrk_p, struct DPpyramid_t *pyrmd_p));
extern void DPcvrt_wld_pnt_to_dits __((OM_S_OBJID win_id, OMuword win_os, IGRdouble x, IGRdouble y, IGRdouble z, IGRint *dit_x, IGRint *dit_y));

#if defined(__cplusplus)
}
#endif


#undef __
