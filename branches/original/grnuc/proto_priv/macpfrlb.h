#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/rfsup/macpfrlb.c */
extern IGRboolean MAcpfrlb __((IGRlong *message, struct IGRlbsys *lbsys, struct IGRcv_prism *cv_prism));

#if defined(__cplusplus)
}
#endif


#undef __
