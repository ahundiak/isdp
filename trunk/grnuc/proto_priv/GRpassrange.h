#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/rfsup/GRpassrange.c */
extern IGRboolean GRpassrange __((IGRlong *msg, IGRdouble *pt1, IGRdouble *pt2, IGRshort *type, IGRmatrix matrix, struct IGRcv_prism *clip_poly, IGRdouble *vw_volume, IGRmatrix master_to_ref_matrix, IGRmatrix vw_matrix, GRrange range, IGRshort compute_range, IGRshort is_skew, IGRdouble *tolerance, IGRchar *range_key));

#if defined(__cplusplus)
}
#endif


#undef __
