#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/ptngo/GRclipconn.I */
extern IGRint GRclip_connect __((IGRlong *msg, struct GRmd_env *current_mod, struct GRmd_env *target_mod, IGRchar *prism, struct GRid *in, struct GRid *out, struct GRid *ovl, IGRlong *clip_flags, IGRlong *index, struct GRid *clip_obj));

#if defined(__cplusplus)
}
#endif


#undef __
