#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/grsetgo/GRgsaction.I */
extern IGRint GRgsaction __((struct GRlc_info *new_entry, enum GRlocate_action *action, struct GRid *gs_id, struct GRid *sv_id, IGRint *type, IGRint use_sv_id));
extern IGRint GRgs_locate_action __((struct GRid action_args[], struct GRlc_info *new_entry, IGRchar *locate_args, enum GRlocate_action *action));
extern IGRint GRgs_rp_action __((struct GRrp_action_args *action_args, struct GRlc_info *new_entry, IGRchar *locate_args, enum GRlocate_action *action));
extern IGRint GRgs_symb_action __((struct GRsymb_action_args *action_args, struct GRlc_info *new_entry, IGRchar *locate_args, enum GRlocate_action *action));
extern IGRint GRgs_delete_action __((struct GRdelete_action *action_args, struct GRlc_info *new_entry, IGRchar *locate_args, enum GRlocate_action *action));

#if defined(__cplusplus)
}
#endif


#undef __
