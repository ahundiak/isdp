#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/co/fenceco/COsymbact.I */
extern IGRint COsymbology_action __((struct COsymbact *symbact, struct GRlc_info *new_entry, IGRchar *locate_args, enum GRlocate_action *action));

#if defined(__cplusplus)
}
#endif


#undef __
