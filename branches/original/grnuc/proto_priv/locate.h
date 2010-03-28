#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/dim/dim_utils/locate.I */
extern IGRint DMis_comp_crv __((struct GRid grid));
extern IGRint DMaction_handler __((struct DMact_info *act_parms, struct GRlc_info *new_entry, struct LC_action_args *locate_args, IGRchar *action));
extern IGRint DMlocate __((IGRlong *rc, struct GRevent *event1, struct GRevent *event2, IGRlong *mask1, IGRlong *mask2, IGRlong display_flag, IGRint *response, IGRchar *response_data, IGRchar *locate_prompt, IGRchar *acc_prompt, IGRchar *relocate_prompt, struct GRlc_locate *attributes, struct DMact_info *act_parms, struct GRlc_dynamics *hand_dyn));
extern IGRint DMlocate_dynamics __((struct GRid *grid, struct GRevent *event, struct GRid *cmd));
extern IGRint DMupdate_event __((struct GRevent *event));
extern int DMget_fence_objects __((IGRlong *msg, struct GRmd_env *md_env, struct GRid set_id, IGRlong *num_obj, struct GRid **objects, IGRlong *response, IGRchar *response_data));
extern int DMget_dim_grid __((struct GRid lc_grid, struct GRmd_env *md_env, struct GRid *objects, int *num_obj, int hilite));

#if defined(__cplusplus)
}
#endif


#undef __
