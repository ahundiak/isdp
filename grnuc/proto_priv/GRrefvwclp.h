#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/rfsup/GRrefvwclp.c */
extern IGRlong GRrefvwclp __((IGRlong *msg, struct IGRlbsys *lbsys, struct IGRcv_prism *cv_prism, IGRboolean *intersect, struct IGRcv_prism *out_cvprism));

#if defined(__cplusplus)
}
#endif


#undef __
