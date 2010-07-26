#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/pplsrc/src/cilchandler.C */
extern int PPLlocate_act __((CIlocargs *act_parms, struct GRlc_info *new_entry, struct LC_action_args *locate_args, char *action));

#if defined(__cplusplus)
}
#endif


#undef __
