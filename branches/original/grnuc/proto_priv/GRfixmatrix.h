#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/rfsup/GRfixmatrix.c */
extern int GRfixmatrix __((IGRlong *msg, IGRshort *in_type, IGRmatrix matrix, IGRmatrix out_matrix, IGRshort *out_type));

#if defined(__cplusplus)
}
#endif


#undef __
