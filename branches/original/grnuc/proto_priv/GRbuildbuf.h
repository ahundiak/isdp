#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/rfsup/GRbuildbuf.c */
extern int GRbuildbuf __((struct GRfunction_info *buffer, struct GRmd_env *md_env, IGRshort pass_on, IGRchar *info));

#if defined(__cplusplus)
}
#endif


#undef __
