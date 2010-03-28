#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/co/cob/DElocact.I */
extern IGRint DElocact __((IGRchar *args, struct GRlc_info *new_entry, struct LC_action_args *locate_args, enum GRlocate_action *action));

#if defined(__cplusplus)
}
#endif


#undef __
