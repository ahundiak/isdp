#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/gosup/GRarc2ptr.c */
extern IGRboolean GRarc2ptr __((IGRlong *message, IGRpoint center, IGRpoint st_pt, IGRpoint sw_pt, IGRdouble *radius, IGRvector view_vc, struct IGRbsp_curve *arc));

#if defined(__cplusplus)
}
#endif


#undef __
