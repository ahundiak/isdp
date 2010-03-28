#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/rfsup/GRgetrefleve.I */
extern IGRlong GRgetreflevels __((IGRlong *msg, IGRshort *mx_type, IGRmatrix matrix, GRspacenum *osnum, IGRint *levels));

#if defined(__cplusplus)
}
#endif


#undef __
