#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/co/symbco/GRgetcell.I */
extern IGRint GRget_cell __((IGRlong *msg, GRspacenum osnum, GRobjid objid, struct GRmd_env *mod_env, IGRchar name[], struct GRid *gs_id, OM_p_CHANSELECT p_chanselect));
extern IGRint GRget_all_cells __((IGRlong *msg, GRspacenum osnum, GRobjid objid, struct GRmd_env *mod_env, IGRint num_objids, OM_S_BTREE_CONTENTS sd_objids[], struct GRid *gs_id, OM_p_CHANSELECT p_chanselect));
extern IGRint GRcell_action_handler __((struct temp *action_args, struct GRlc_info *new_entry, IGRchar *locate_args, enum GRlocate_action *action));

#if defined(__cplusplus)
}
#endif


#undef __
