#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/gosup/GRcbclnexten.c */
extern IGRboolean GRcbclnextend __((IGRlong *msg, struct IGRbsp_curve *bc_ln, IGRpoint low_point, IGRpoint high_point, struct IGRbsp_curve *ext_bc_ln));

#if defined(__cplusplus)
}
#endif


#undef __
