#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/rfsup/GRcontextcon.I */
extern IGRlong GRcontextconn __((IGRlong *msg, IGRshort *ctx_mx_type, IGRmatrix ctx_mx, GRspacenum *osnum, struct GRid *user_id, OM_S_CHANSELECT *user_chan, IGRint *user_index));

#if defined(__cplusplus)
}
#endif


#undef __
