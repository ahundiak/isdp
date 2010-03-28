#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/assoc/nmacro_co/COm_place3.I */
extern int NDduplicate_root __((int nb_root, struct GRid *root));
extern int COm_place_get_active_symb __((struct sup *dup, struct GRid *Temp_List, struct GRid *def_id, short *active_level, struct IGRdisplay *active_display, struct GRmd_env *md_env));

#if defined(__cplusplus)
}
#endif


#undef __
