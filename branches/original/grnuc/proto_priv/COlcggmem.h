#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/co/grgrpco/COlcggmem.I */
extern IGRint COlcggmem __((struct GR_gg_member_action_args *arglist, struct GRlc_info *loc_obj, IGRchar *locate_args, enum GRlocate_action *action));

#if defined(__cplusplus)
}
#endif


#undef __
