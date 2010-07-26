#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/co/meas/COmangline.I */
extern IGRlong CO_measure_angle_line __((IGRlong *msg, struct GRid *p_grid, GRobjid window_id, IGRchar *angle_type, IGRdouble *p_angle));

#if defined(__cplusplus)
}
#endif


#undef __
