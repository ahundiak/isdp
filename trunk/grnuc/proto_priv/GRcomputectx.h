#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/rfsup/GRcomputectx.c */
extern IGRboolean GRcomputectx __((IGRlong *msg, IGRshort *env_type, IGRmatrix env_matrix, IGRmatrix ref_to_master_matrix, IGRshort *context_type, IGRmatrix context_matrix));

#if defined(__cplusplus)
}
#endif


#undef __
