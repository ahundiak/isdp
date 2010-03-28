#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/rfsup/GRstrokcp.c */
extern int GRstrokcp __((IGRlong *msg, struct IGRbsp_curve *top_curve, struct IGRbsp_curve *bot_curve, struct IGRcv_prism *cv_prism, struct IGRbsp_curve *out_curve));

#if defined(__cplusplus)
}
#endif


#undef __
