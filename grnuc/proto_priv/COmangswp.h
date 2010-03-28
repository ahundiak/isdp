#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/co/meas/COmangswp.I */
extern IGRlong CO_measure_sweep_angle_conic __((IGRlong *msg, struct GRid *p_grid, IGRchar *angle_type, IGRdouble *p_angle));

#if defined(__cplusplus)
}
#endif


#undef __
