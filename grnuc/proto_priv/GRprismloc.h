#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/grsetgo/GRprismloc.I */
extern IGRint GRprism_locate __((IGRlong *msg, struct GRmd_env *mod_env, struct GRid *window_id, struct GRlc_locate *attributes, struct GRlc_classes *classinfo, IGRint prism_type, IGRchar *prism, IGRint prism_attr, IGRint inside_outside, IGRint *layers, IGRchar (*action_handler )(), IGRchar *action_args));

#if defined(__cplusplus)
}
#endif


#undef __
