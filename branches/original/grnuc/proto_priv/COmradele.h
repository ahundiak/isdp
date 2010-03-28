#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/co/meas/COmradele.I */
extern IGRlong CO_measure_radius __((IGRlong *msg, struct GRid *p_grid, IGRdouble *rad_pt, GRobjid window_id, IGRdouble *p_radius));

#if defined(__cplusplus)
}
#endif


#undef __
