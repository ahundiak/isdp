#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/gosup/GOarcptrdcv.c */
extern IGRboolean GOarcptrdcv __((IGRlong *msg, IGRpoint pt, IGRdouble *rad, struct IGRbsp_curve *bc, IGRdouble *u, IGRpoint tanpt, IGRpoint center, IGRvector view, IGRboolean *flag, struct IGRbsp_curve *out_geom));

#if defined(__cplusplus)
}
#endif


#undef __
