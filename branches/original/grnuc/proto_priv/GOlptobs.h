#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/gosup/GOlptobs.c */
extern IGRboolean GOlptobs __((IGRlong *msg, struct IGRbsp_surface *bs, IGRpoint pt, IGRdouble *u, IGRdouble *v, IGRdouble *sol_u, IGRdouble *sol_v, struct IGRbsp_curve *bc_ln));

#if defined(__cplusplus)
}
#endif


#undef __
