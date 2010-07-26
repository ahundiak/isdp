#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/rfsup/macpxform.c */
extern IGRboolean MAcpxform __((IGRlong *message, struct IGRcv_prism *in_cvgeom, IGRmatrix t_matrix, struct IGRcv_prism *out_cvgeom));

#if defined(__cplusplus)
}
#endif


#undef __
