#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/co/meas/COmlenalng.I */
extern IGRlong CO_meas_length_along __((IGRlong *msg, struct GRid *p_grid, IGRdouble *start_pt, IGRdouble *end_pt, IGRdouble *dir_pt, GRobjid window_id, IGRdouble *p_length));

#if defined(__cplusplus)
}
#endif


#undef __
