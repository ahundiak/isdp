#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/rfsup/GRfindosnum.I */
extern int GRfindosnum __((IGRlong *msg, struct GRid *context_id, GRspacenum *osnum));

#if defined(__cplusplus)
}
#endif


#undef __
