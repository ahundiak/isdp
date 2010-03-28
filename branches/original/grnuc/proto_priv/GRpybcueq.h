#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/gosup/GRpybcueq.C */
extern IGRboolean GRpybcueqspace __((IGRlong *message, struct IGRbsp_curve *curve, IGRlong *npts, int startpt, int stoppt, int dirpt, IGRdouble *u1, IGRdouble *u2, IGRdouble *u3, struct IGRpolyline *polyline));

#if defined(__cplusplus)
}
#endif


#undef __
