#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/gosup/GR2ptlsext.c */
extern IGRboolean GR2ptlsext __((IGRlong *msg, IGRpoint pt1, IGRpoint pt2, IGRdouble *sf, int spt1, int spt2));

#if defined(__cplusplus)
}
#endif


#undef __
