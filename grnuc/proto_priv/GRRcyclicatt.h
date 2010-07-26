#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/rfsup/GRRcyclicatt.I */
extern int GRcyclic_check __((IGRlong *msg, OM_S_CHANSELECT *nested_files_chan, struct GRid *context_id, GRspacenum *osnum, IGRshort *flag));

#if defined(__cplusplus)
}
#endif


#undef __
