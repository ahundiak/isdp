#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/co/meas/COcvtptlcl.I */
extern IGRint COcvt_pts_to_lcl_coord __((IGRlong *msg, IGRint num_pts, IGRdouble *in_points, IGRdouble *out_points));

#if defined(__cplusplus)
}
#endif


#undef __
