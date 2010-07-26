#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/ptngo/GRapagrid.C */
extern IGRint GRangle_grid __((IGRlong *msg, struct IGRbsp_curve *curve, IGRdouble angle, IGRshort *wtv_mxtype, IGRmatrix wtv, IGRshort *vtw_mxtype, IGRmatrix vtw, IGRpoint origin, IGRdouble range[], IGRdouble dx, IGRdouble dy, IGRboolean first, IGRint max_pts, IGRboolean *more, IGRlong *npts, IGRpoint pts[]));

#if defined(__cplusplus)
}
#endif


#undef __
