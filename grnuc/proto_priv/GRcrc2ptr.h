#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/gosup/GRcrc2ptr.c */
extern IGRboolean GRcrc2ptr __((IGRlong *message, IGRpoint center, IGRpoint pt1, IGRpoint pt2, IGRdouble *radius, IGRvector z_vect, struct IGRbsp_curve *circle));

#if defined(__cplusplus)
}
#endif


#undef __
