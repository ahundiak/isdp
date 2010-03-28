#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/assoc/gopara/ASextbspi.I */
extern int ASextbsp_evaluate __((struct GRid *list, struct GRmd_env *md_env, struct GRid as_grid, struct GRid *go_grid));
extern int ASextract_cv __((struct GRid bsp_to_split, IGRdouble *p0, IGRdouble *p1, struct GRmd_env *md_env, struct GRid *result));

#if defined(__cplusplus)
}
#endif


#undef __
