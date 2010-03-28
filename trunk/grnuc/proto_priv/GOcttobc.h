#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/gosup/GOcttobc.c */
extern IGRboolean GOcttobc __((IGRlong *msg, struct IGRbsp_curve *bc, IGRpoint center_diam, IGRpoint tent_pt, IGRint *center_diam_flag, IGRdouble *sol_u, struct IGRbsp_curve *bc_circle));

#if defined(__cplusplus)
}
#endif


#undef __
