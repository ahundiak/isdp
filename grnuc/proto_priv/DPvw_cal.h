#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/co/displayco/DPvw_cal.I */
extern IGRdouble DPoffset __((IGRdouble x1, IGRdouble x2, IGRdouble rub_ratio, IGRdouble max_value));
extern int DPcenter __((IGRlong *msg, IGRdouble *actz_pt, int update, struct DPbase_gg_t *base_p, struct DPview_wrk_t *wrk_p));
extern int DPcal_zoom __((IGRlong *msg, IGRdouble factor, struct DPbase_gg_t *base_p, struct DPview_wrk_t *wrk_p, IGRint in_flags));
extern int DPcal_around_coi __((IGRlong *msg, IGRdouble rad_v, IGRdouble rad_h, struct DPbase_gg_t *base_p, struct DPview_wrk_t *wrk_p, IGRint in_flags));
extern int DPcal_around_eye __((IGRlong *msg, IGRdouble rad_v, IGRdouble rad_h, struct DPbase_gg_t *base_p, struct DPview_wrk_t *wrk_p, IGRint in_flags));
extern int DPcal_tilt __((IGRlong *msg, IGRdouble rad, struct DPbase_gg_t *base_p, struct DPview_wrk_t *wrk_p, IGRint in_flags));
extern int DPcal_vwangle __((IGRlong *msg, struct DPbase_gg_t *base_p, struct DPview_wrk_t *wrk_p, IGRint in_flags));
extern int DPcal_pan __((IGRlong *msg, IGRdouble dist_x, IGRdouble dist_y, struct DPbase_gg_t *base_p, struct DPview_wrk_t *wrk_p, IGRint in_flags));
extern int DPview_indexing __((IGRdouble *vup, IGRdouble *vpn, IGRdouble *vxx, IGRdouble *r_vup, IGRdouble *eye_pt, IGRdouble *coi, IGRint adjust, IGRdouble idx_tol, IGRint *idx_flag));
extern int DPalign_vpn __((IGRint axis, IGRint positive, IGRdouble *eye_pt, IGRdouble *coi, IGRint adjust));
extern int DPalign_vup __((IGRint axis, IGRint positive_direction, IGRdouble *r_vup, IGRdouble *eye_pt, IGRdouble *coi, IGRint adjust));
extern int DPalign_vxx __((IGRint axis, IGRdouble *r_vup, IGRdouble *eye_pt, IGRdouble *coi, IGRint adjust));
extern int DPlevel_indexing __((IGRlong *msg, struct DPbase_gg_t *base_p, struct DPview_wrk_t *wrk_p));
extern int DPfocal_indexing __((IGRlong *msg, struct DPview_wrk_t *wrk_p, IGRint *idx));
extern int DPset_angle __((IGRlong *msg, struct DPbase_gg_t *base_p, struct DPview_wrk_t *wrk_p, struct DPpyramid_t *pyrmd_p, IGRdouble angle));

#if defined(__cplusplus)
}
#endif


#undef __
