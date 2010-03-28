#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/rfsup/macpexten.c */
extern IGRboolean MAcpextents __((IGRlong *message, struct IGRcv_prism *cv_prism, IGRpoint low_point, IGRpoint high_point));

#if defined(__cplusplus)
}
#endif


#undef __
