#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/co/meas/COmang2line.I */
extern IGRlong CO_meas_angle_two_lines __((IGRlong *msg, struct GRid *p_grid1, struct GRid *p_grid2, IGRdouble *quad_pt, IGRboolean proj, GRobjid window_id, IGRchar *angle_type, IGRdouble *p_angle));

#if defined(__cplusplus)
}
#endif


#undef __
