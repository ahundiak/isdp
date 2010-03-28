#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/assoc/symb_mac/ACheadloc.I */
extern IGRint ACheader_handl __((struct ACShandl_info *act_parms, struct GRlc_info *new_entry, struct LC_action_args *locate_args, IGRchar *action));
extern int ACScreate_dyn_tf_foot __((struct GRid *loc_obj, struct GRid *tf_foot));
extern int ACSset_tf_foot_symb __((struct GRid *header, struct GRid *tf_foot));
extern int ACSget_part_path __((struct tf_foot *loc_foot, struct GRid *model));
extern int ACScreate_tf_foot __((struct GRid *loc_obj, struct GRid *tf_foot, struct ACSdyn_info *dyn_info));

#if defined(__cplusplus)
}
#endif


#undef __
