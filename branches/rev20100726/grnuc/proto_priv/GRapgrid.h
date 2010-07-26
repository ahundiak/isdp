#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/ptngo/GRapgrid.C */
extern IGRint GRapgrid __((IGRlong *msg, IGRshort *wtv_mxtype, IGRmatrix wtv, IGRshort *vtw_mxtype, IGRmatrix vtw, IGRpoint origin, IGRdouble range[], IGRdouble dx, IGRdouble dy, IGRboolean first, IGRint max_pts, IGRboolean *more, IGRlong *npts, IGRpoint pts[]));

#if defined(__cplusplus)
}
#endif


#undef __
