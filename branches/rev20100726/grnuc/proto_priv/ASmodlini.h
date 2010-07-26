#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/assoc/gopara/ASmodlini.I */
static before __((IGRpoint p1, IGRpoint p2, int ind, IGRdouble orient));
static void project_point __((IGRpoint p0, IGRpoint v0, IGRpoint p_from, IGRpoint p_proj));
extern int ASdummy_index __((struct GRid point_grid, struct GRid *index_grid));
extern int AStake_and_kill_mod __((struct GRid old_modif, struct GRid new_modif, char *typ_new, char *par_new, int *nmodif, struct GRmd_env *md_env));
extern int ASextend_line __((IGRint count, struct GRid *parent, struct GRmd_env *md_env, IGRdouble *points, IGRdouble *v0, IGRint change_ext));
extern IGRint ASpartial_delete __((struct GRid *parent, struct GRmd_env *md_env, IGRdouble points[], IGRint *npt, IGRdouble v0[]));
extern int in_delete __((struct GRid *obj, struct GRid *deleted, int count_deleted));
extern int ASmodif_parent_deleted __((IGRint *msg, int count_deleted, struct GRid *deleted, struct GRid my_grid, IGRchar *typ_mod, IGRchar *par_mod, IGRint *nmodif, struct GRmd_env *md_env));
extern int ASmodif_locate_owner __((IGRlong *msg, struct GRid my_grid, struct GRlc_cvl *cvl, struct GRlc_path *path, IGRint *pos));

#if defined(__cplusplus)
}
#endif


#undef __
