#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/gosup/GOfillet.c */
extern IGRboolean GOfillet __((IGRlong *msg, struct IGRbsp_curve *bc1, struct IGRbsp_curve *bc2, IGRpoint tanpt1, IGRpoint tanpt2, IGRdouble *radius, IGRpoint center, IGRvector view, struct IGRbsp_curve *bsp_arc));

#if defined(__cplusplus)
}
#endif


#undef __
