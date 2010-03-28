#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/grsetgo/GRsvcriteria.I */
extern IGRint GRgscriteria __((struct GRid *sv_id, struct GRlc_info *new_entry, IGRchar *locate_args, enum GRlocate_action *action));

#if defined(__cplusplus)
}
#endif


#undef __
