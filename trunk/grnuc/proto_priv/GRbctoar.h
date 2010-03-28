#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/gosup/GRbctoar.c */
extern int GRbctoar __((IGRlong *msg, struct IGRbsp_curve *curve, struct IGRarc *arc));

#if defined(__cplusplus)
}
#endif


#undef __
