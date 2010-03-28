#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/rfsup/GRfindcontex.I */
extern IGRlong GRfindcontext __((IGRlong *msg, IGRshort *ctx_mx_type, IGRmatrix ctx_mx, GRspacenum *osnum, struct GRid *context_id));

#if defined(__cplusplus)
}
#endif


#undef __
