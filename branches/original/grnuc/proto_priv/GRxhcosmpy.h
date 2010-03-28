#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/co/xhatch/GRxhcosmpy.C */
extern IGRint GRxh_gen_horiz_points __((IGRlong *msg, IGRdouble *delta, IGRdouble *origin, IGRdouble *range, IGRdouble offset, struct IGRpolyline *polyline));

#if defined(__cplusplus)
}
#endif


#undef __
