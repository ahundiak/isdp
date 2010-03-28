#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/co/partco/COprtconstr.I */
extern IGRint COpart_construct_func __((IGRint *msg, struct GRmd_env *mod_env, IGRchar *parts_dir, IGRchar *catalog, IGRchar *number, IGRchar *revision, IGRchar *description, struct GRid *part, IGRchar *attr[], IGRchar *value[], IGRint type[], IGRint num, struct GRobj_env object[], IGRint num_objects, IGRint gg_flag));
extern IGRint COpart_construct_partslist_func __((IGRint *msg, struct GRmd_env *mod_env, struct GRid *partslist, IGRchar *name, IGRchar *desc, struct GRid *block, IGRint cols, IGRchar **attribute, IGRchar **justification, struct GRid *text, struct GRid *line));

#if defined(__cplusplus)
}
#endif


#undef __
