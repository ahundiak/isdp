#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/gosup/GOarctnbcp.c */
extern IGRboolean GOarctnbcpt __((IGRlong *msg, IGRpoint center, struct IGRbsp_curve *bc, IGRpoint tanpt, IGRpoint endpt, IGRvector view, struct IGRbsp_curve *bsp_arc));

#if defined(__cplusplus)
}
#endif


#undef __
