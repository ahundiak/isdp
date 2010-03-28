#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/locate/locate/LCgsinit.I */
extern int LCgsinit __((struct GRmd_env *mod, struct GRid *gs_id, struct GRid *sv_id));

#if defined(__cplusplus)
}
#endif


#undef __
