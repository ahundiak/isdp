#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/gosup/GRbrlncon.c */
extern IGRboolean GRbrlnconstr __((IGRlong *msg, IGRpoint point, IGRmatrix view, struct IGRline *boreline));

#if defined(__cplusplus)
}
#endif


#undef __
