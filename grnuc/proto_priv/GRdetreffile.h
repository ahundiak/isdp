#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/rfsup/GRdetreffile.I */
extern IGRlong GRdetreffile __((IGRlong *msg, IGRlong *properties, IGRboolean *pass_to_nested_spaces, struct EX_button *point, IGRint *sizebuf, struct GRmd_env *md_env, IGRint *nret));

#if defined(__cplusplus)
}
#endif


#undef __
