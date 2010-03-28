#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/co/meas/COmang4pts.C */
extern IGRlong CO_meas_angle_pts_arbaxis __((IGRlong *msg, IGRdouble *axis1_pt1, IGRdouble *axis1_pt2, IGRdouble *axis2_pt1, IGRdouble *axis2_pt2, IGRdouble *quad_pt, IGRboolean proj, GRobjid window_id, IGRchar *angle_type, IGRdouble *p_angle));

#if defined(__cplusplus)
}
#endif


#undef __
