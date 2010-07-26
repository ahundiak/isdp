#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/textgo/GRcreatelbs.C */
extern IGRboolean GRcreate_lbs __((IGRlong *msg, IGRdouble *active_angle, IGRdouble *rot_matrix, IGRdouble *origin, struct extents *lbs_extents, struct IGRlbsys *lbs_geom));

#if defined(__cplusplus)
}
#endif


#undef __
