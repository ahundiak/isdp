#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/rfsup/GRrfloccheck.I */
extern IGRlong GRrfloccheck __((IGRlong *msg, struct GRmd_env *md_env, IGRint *locate_properties, IGRint *levels));

#if defined(__cplusplus)
}
#endif


#undef __
