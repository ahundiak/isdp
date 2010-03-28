#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/gosup/GRbclnextend.c */
extern IGRboolean GRbclnextend __((IGRlong *msg, struct IGRbsp_curve *bc_ln, struct IGRbsp_curve *ext_bc_ln));

#if defined(__cplusplus)
}
#endif


#undef __
