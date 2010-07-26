#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/display/grdisplay/DPexsetpp.I */
extern int DPcompersp __((IGRlong *msg, struct GRid *gg_id, IGRshort in_flags, IGRshort *ret_flags, IGRdouble *vrp, IGRdouble *vpn, IGRdouble *vup, IGRdouble *eye_pt, IGRdouble *coi, IGRdouble *vw_angle, IGRdouble *near, IGRdouble *far, IGRdouble *fence_pts, IGRdouble *r_vrp, IGRdouble *r_vpn, IGRdouble *r_vup, IGRdouble *r_eye_pt, IGRdouble *r_coi, IGRdouble *r_vw_angle, IGRdouble *r_near, IGRdouble *r_far, IGRdouble *z_scrn_dist, IGRdouble *tilt));

#if defined(__cplusplus)
}
#endif


#undef __
