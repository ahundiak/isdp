#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/co/meas/COcenconic.I */
extern IGRlong CO_center_of_conic __((IGRlong *msg, struct GRid *p_grid, IGRdouble *cen_pt));

#if defined(__cplusplus)
}
#endif


#undef __
