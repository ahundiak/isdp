#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/detailgo/GRactownmgri.I */
extern int GRactive_owner_temp_clear __((int *old_value));
extern IGRint GRadd_component_to_active_owner __((IGRlong *msg, struct GRmd_env *mod_env, GRspacenum osnum, GRobjid objid));
extern IGRint GRactive_owner_fun __((IGRlong *msg, IGRint flag, struct GRid *mod_id, struct GRid *active_owner_id));

#if defined(__cplusplus)
}
#endif


#undef __
