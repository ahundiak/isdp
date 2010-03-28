#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/rfsup/GRctxstack.I */
extern int GRsetupcontext __((IGRlong *msg, GRobjid *Super_objid, GRspacenum *Super_osnum, OMuword *PDM_wakeup));
extern int GRputcontextid __((IGRlong *msg, GRobjid *context_id, GRobjid *saved_contextid));
extern int GRgetcurrentctx __((IGRlong *msg, struct GRid *context_id));
extern IGRlong GRgetctxsuper __((IGRlong *msg, struct GRid *Super_id));
extern int GRset_expansion_mode __((IGRint *expand_flag));
extern IGRboolean GRexpansion_valid __((void));
extern int GRrestore_context_stack __((IGRint *PDM_sleep));
extern int GRget_env __((IGRshort *matrix_type, IGRdouble *matrix));
extern int GRpush_env __((IGRshort *new_matrix_type, IGRdouble *new_matrix));

#if defined(__cplusplus)
}
#endif


#undef __
