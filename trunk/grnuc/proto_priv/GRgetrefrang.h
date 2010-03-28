#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/rfsup/GRgetrefrang.I */
extern IGRlong GRgetrefrange __((IGRlong *msg, GRspacenum *osnum, IGRshort *context_type, IGRmatrix context_matrix, IGRdouble *window_range, IGRmatrix world_to_dit_matrix, GRrange range));

#if defined(__cplusplus)
}
#endif


#undef __
