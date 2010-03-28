#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/assoc/gopara/ASrevbspi.I */
extern int ASrevbsp_evaluate __((struct GRid *list, struct GRmd_env *md_env, struct GRid as_grid, struct GRid *go_grid));

#if defined(__cplusplus)
}
#endif


#undef __
