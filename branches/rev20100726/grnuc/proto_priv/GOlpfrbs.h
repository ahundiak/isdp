#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/gosup/GOlpfrbs.c */
extern IGRboolean GOlpfrbs __((IGRlong *msg, struct IGRbsp_surface *bs, IGRpoint pt, IGRdouble *u, IGRdouble *v, struct IGRbsp_curve *bc_ln));

#if defined(__cplusplus)
}
#endif


#undef __
