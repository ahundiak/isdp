#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/display/grdisplay/DPwnareaf.C */
extern int DPperwnarea __((IGRlong *msg, IGRint in_flags, IGRdouble *wld_pts, IGRdouble *old_coi, IGRdouble *wld_to_view, IGRdouble *r_angle, IGRdouble *r_eye, IGRdouble *r_coi));

#if defined(__cplusplus)
}
#endif


#undef __
