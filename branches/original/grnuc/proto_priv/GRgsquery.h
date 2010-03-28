#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/co/fenceco/GRgsquery.I */
extern IGRint GRgsquery_all __((IGRlong *msg, struct GRmd_env *loc_env, struct GRlc_locate *attributes, struct GRlc_classes *classinfo, IGRint layers[], struct EX_button *button, IGRint (*action_handler )(), IGRchar *action_args));

#if defined(__cplusplus)
}
#endif


#undef __
