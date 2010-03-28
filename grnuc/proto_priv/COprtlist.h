#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/co/partco/COprtlist.I */
extern IGRint COpart_add_to_partslist __((IGRint *msg, struct GRmd_env *mod_env, IGRchar *partslist, struct GRpart_item *list, IGRint list_size, struct GRobj_env *object, IGRint *line_no));
extern IGRint COpart_write_to_file __((IGRint *msg, struct GRmd_env *mod_env, FILE *file, struct GRpart_item *list, IGRint list_size, struct GRobj_env *object));
extern IGRint COpart_list_func __((IGRint type, IGRint *msg, struct GRmd_env *mod_env, IGRchar *partslist, FILE *file, struct GRobj_env *object, IGRint num_objects, IGRint *line_no));
extern IGRint COpart_delete_partslist_entries_func __((IGRint *msg, struct GRmd_env *mod_env, IGRchar *partslist));
extern IGRint COpart_update_partslist_func __((IGRint *msg, struct GRmd_env *mod_env, IGRchar *partslist));

#if defined(__cplusplus)
}
#endif


#undef __
