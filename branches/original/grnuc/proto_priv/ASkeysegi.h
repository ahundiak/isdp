#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/assoc/gopara/ASkeysegi.I */
extern int AScompute_key_seg __((IGRlong *msg, IGRdouble tol, struct IGRbsp_curve *bc, IGRdouble initial_u, IGRdouble *project, IGRdouble *nearest_p, IGRdouble *other_p));

#if defined(__cplusplus)
}
#endif


#undef __
