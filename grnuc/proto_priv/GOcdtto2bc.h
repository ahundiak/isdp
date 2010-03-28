#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/gosup/GOcdtto2bc.c */
extern IGRboolean GOcdtto2bc __((IGRlong *msg, struct IGRbsp_curve *bc1, struct IGRbsp_curve *bc2, IGRpoint tent_pt1, IGRpoint tent_pt2, IGRdouble *sol_u1, IGRdouble *sol_u2, struct IGRbsp_curve *bc_circle));

#if defined(__cplusplus)
}
#endif


#undef __
