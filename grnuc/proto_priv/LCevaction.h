#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/locate/locate/LCevaction.C */
extern int LCevaction __((IGRchar *info, struct GRlc_info *new_entry, struct LC_action_args *locate_args, enum GRlocate_action *action, IGRint *env_flag));

#if defined(__cplusplus)
}
#endif


#undef __
