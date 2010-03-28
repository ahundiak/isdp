#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/rfsup/GRdecinvtab.I */
extern int GRdecinvtable __((IGRlong *msg, struct GRid *context_id, IGRint *count_check_only, GRspacenum *osnum, IGRint *new_count));

#if defined(__cplusplus)
}
#endif


#undef __
