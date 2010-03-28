#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/rfsup/GRgetcurves.C */
extern IGRboolean GRgetcurves __((IGRlong *msg, struct IGRbsp_curve *curve, IGRlong *how_many, struct IGRbsp_curve **curve_ptr_array));

#if defined(__cplusplus)
}
#endif


#undef __
