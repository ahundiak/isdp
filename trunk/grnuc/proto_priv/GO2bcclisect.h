#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/gosup/GO2bcclisect.c */
extern IGRboolean GO2bcclisect __((IGRlong *msg, struct IGRbsp_curve *bc1, struct IGRbsp_curve *bc2, struct IGRline *ln, int tol, IGRpoint ipoint, IGRdouble *u1, IGRdouble *u2));

#if defined(__cplusplus)
}
#endif


#undef __
