#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/co/displayco/marang2vc.C */
extern IGRboolean MArang2vc __((IGRlong *message, IGRvector a, IGRvector b, IGRvector z, IGRdouble *angle));

#if defined(__cplusplus)
}
#endif


#undef __
