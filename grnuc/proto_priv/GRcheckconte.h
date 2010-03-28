#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/rfsup/GRcheckconte.I */
extern int GRcheckcontext __((IGRlong *msg, IGRdouble *matrix, struct GRid *Super_id, struct GRid *ref_id, IGRboolean *construct_flag, struct GRid *context, IGRboolean *new_context));

#if defined(__cplusplus)
}
#endif


#undef __
