#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/gosup/GObcsclisect.c */
extern IGRboolean GObcsclisect __((IGRlong *msg, struct IGRbsp_curve *bc, struct IGRbsp_surface *bs, struct IGRline *ln, int tol, IGRpoint ipoint, IGRdouble *u1, IGRdouble *u2, IGRdouble *u3));

#if defined(__cplusplus)
}
#endif


#undef __
