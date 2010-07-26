#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/rfsup/GRgetcontext.I */
extern int GRgetcontext __((IGRlong *msg, struct GRid *ref_id, struct GRid *mgr_id, OMuword *osnum, struct GRid *context_id, IGRshort *flag));

#if defined(__cplusplus)
}
#endif


#undef __
