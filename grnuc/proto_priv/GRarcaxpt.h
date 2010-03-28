#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/gosup/GRarcaxpt.c */
extern IGRboolean GRarcaxpt __((IGRlong *message, IGRpoint center, IGRpoint smj_pt, IGRpoint pt, IGRvector vc, struct IGRbsp_curve *arc));

#if defined(__cplusplus)
}
#endif


#undef __
