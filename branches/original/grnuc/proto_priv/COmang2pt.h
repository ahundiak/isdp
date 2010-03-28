#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/co/meas/COmang2pt.C */
extern IGRlong CO_measure_angle_2pts __((IGRlong *msg, IGRdouble *first_pt, IGRdouble *second_pt, GRobjid window_id, IGRchar *angle_type, IGRdouble *p_angle));

#if defined(__cplusplus)
}
#endif


#undef __
