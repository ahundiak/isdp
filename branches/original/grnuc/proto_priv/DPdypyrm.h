#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/co/displayco/DPdypyrm.I */
extern IGRint DPbuildpyrm __((IGRlong *msg, IGRint state, IGRdouble *coi_pt, IGRdouble *eye_pt, IGRdouble *vup_pt, IGRdouble *view_angle, IGRdouble *near_distance, IGRdouble *far_distance, struct IGRpolyline *polyline));
extern IGRint DPbuildparall __((IGRlong *msg, IGRint state, IGRdouble *coi_pt, IGRdouble *eye_pt, IGRdouble *vup_pt, IGRdouble *radius, IGRdouble *near_distance, IGRdouble *far_distance, struct IGRpolyline *polyline));
extern IGRint DPdypyrm __((struct dyn_pyrm_st *py_info, struct EX_button *pt2, IGRdouble *mtx, struct GRid **objects, IGRint *num_objects, struct DPele_header **buffers, IGRint *num_buffers, IGRchar *dummy1, IGRchar *dummy2, IGRchar *dummy3, IGRchar **dummy4, IGRchar **dummy5, IGRchar **dummy6));
extern IGRint DPdypyrminit __((IGRshort dyn_on_off, IGRint state, struct IGRdisplay *dis_attr[], IGRdouble *coi_pt, IGRdouble *eye_pt, IGRdouble *vup_pt, IGRdouble *angle_radius, IGRdouble *near_distance, IGRdouble *far_distance, IGRdouble *vrp_pt, IGRdouble *vpn_pt));

#if defined(__cplusplus)
}
#endif


#undef __
