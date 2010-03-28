#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/gosup/GR2bcisectut.c */
extern IGRboolean GR2bcisectutil __((IGRlong *msg, struct IGRbsp_curve **bc1, struct IGRbsp_curve **bc2, struct GRparms *parms1, struct GRparms *parms2, struct GRprops *props1, struct GRprops *props2, struct IGRbsp_curve *bc_ln1, struct IGRbsp_curve *bc_ln2));

#if defined(__cplusplus)
}
#endif


#undef __
