#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/so/DEsoi.I */
extern int DEresolve_inter __((int *done, int *used, int count, double *bdrys, struct IGRdisplay *sbts, DEsoe *ptr, DEsoe *entry, struct GRid *win, int wn_ndx, struct GRmd_env *md_env, int ctx_ndx, int type, OM_S_OBJID target_id));
extern int DEbuild_entry __((long *msg, DEsoe *entry, OM_S_OBJID sooid, int add, int type, OM_S_OBJID objid, IGRdouble u1, IGRdouble u2, struct IGRdisplay *symb, struct GRid *window, int wn_ndx, struct GRmd_env *md_env, int ctx_ndx));
static DEset_dirty __((DEsoe *soes, int size, int index, OM_S_OBJID objid, int state));
static DEmalloc_parms __((void));
extern int DElock_view __((long *msg, OM_S_OBJID viewid));
extern int DEunlock_view __((long *msg, OM_S_OBJID viewid));
extern int DEis_locked __((OM_S_OBJID viewid));
static DEcompare_soe __((DEsoe *p1, DEsoe *p2));
static DEsort_boundaries __((DEsoe *soes, int size, int index, OM_S_OBJID so_objid));

#if defined(__cplusplus)
}
#endif


#undef __
