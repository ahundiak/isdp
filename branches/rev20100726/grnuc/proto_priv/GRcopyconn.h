#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/supfungo/GRcopyconn.I */
extern IGRint GRcopy_and_connect_object __((IGRlong *msg, GRspacenum osnum, GRobjid objid, struct GRmd_env *mod_env, struct GRmd_env *target_env, struct GRid *target_id, IGRint channel_type, IGRint connection_type, struct GRid *new_id));
extern IGRint GRconnect_object __((IGRlong *msg, GRspacenum osnum, GRobjid objid, struct GRid *target_id, IGRint channel_type, IGRint connection_type, IGRint target_index, IGRint obj_index));

#if defined(__cplusplus)
}
#endif


#undef __
