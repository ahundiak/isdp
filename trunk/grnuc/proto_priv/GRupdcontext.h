#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/rfsup/GRupdcontext.I */
extern int GRupdcontext __((IGRlong *msg, struct GRmd_env *md_env, IGRmatrix ref_to_master_matrix, IGRboolean *constr_flag, GRobjid *ref_objid, struct GRid *context_objid));

#if defined(__cplusplus)
}
#endif


#undef __
