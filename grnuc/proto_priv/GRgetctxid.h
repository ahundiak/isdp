#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/rfsup/GRgetctxid.I */
extern IGRlong GRgetctxid __((IGRlong *msg, IGRshort *type, IGRmatrix matrix, struct GRid *gr_oid, struct GRid *context_id));

#if defined(__cplusplus)
}
#endif


#undef __
