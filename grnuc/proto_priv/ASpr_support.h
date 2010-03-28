#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/assoc/gopara/ASpr_support.I */
extern int asprinter_init __((struct GRmd_env *md_env, FILE *str, IGRint is_it_a_macro));
extern int as_printer_cimachdr __((IGRint count, struct GRid list[], struct GRmd_env *md_env, int *ci_macro_flag));
extern int asprinter_end __((void));
extern int asprinter_exec_print __((IGRint count, struct GRid list[]));
extern int asprinter_store_name __((OM_S_OBJID object_id, char *name));
extern int asprinter_find_name __((OM_S_OBJID object_id, char *name));
extern int asprinter_set_name __((OM_S_OBJID object_id, char *prefix, char *name));
extern int asprinter_get_name __((OM_S_OBJID parent_id, char *name));
extern int asprinter_print_root __((OM_S_OBJID objid, GRspacenum osnum, IGRint flag));
extern int asprinter_print_symb __((struct GRsymbology *symb, IGRushort *prop, OM_S_OBJID objid, GRspacenum osnum));
extern int asprinter_print_parents __((OM_S_OBJID objid, GRspacenum osnum, struct GRid *root, IGRint root_size, IGRint *nb_parent));
extern int asstrcmp __((char *s1, char *s2));
extern int asprinter_init_min_dir __((char *name));
extern int asprinter_find_min_dir __((struct GRid obj));
extern int asprinter_get_di_name __((struct GRid obj, char *name));
extern int asprinter_print_dir __((char *name_init));

#if defined(__cplusplus)
}
#endif


#undef __
