#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/assoc/nmacro_co/COm_option.I */
extern int COm_get_form_options __((char *fp, int macro_type, int *symb, enum ACm_poss_scroll *hdr_scroll, enum ACm_poss_hdr *hdr_type, enum ACm_poss_def_par *hdr_def, char *search_path, struct ACdef_param *ACglobal));
extern int COm_set_form_options __((char *fp, int symb, enum ACm_poss_scroll hdr_scroll, enum ACm_poss_hdr hdr_type, enum ACm_poss_def_par hdr_def, char *search_path));
extern int ACrecursive_incr_layer __((struct GRid *hdr, int active_level));
extern int COmchg_symb __((int symb, struct GRid *hdr, int active_level, struct IGRdisplay *active_display, struct GRmd_env *md_env));
extern int COm_get_option_grid __((struct GRid *macro, struct GRid *def_id, char *arg_def_name));
extern int COm_get_options __((struct GRid *macro, int *symb, enum ACm_poss_scroll *hdr_scroll, enum ACm_poss_hdr *hdr_type, enum ACm_poss_def_par *hdr_def, char *search_path, char *post_placement, struct GRid *def_occ, struct GRmd_env *md_env));
extern int ACcreate_def_temp __((enum ACm_poss_def_par search_option, char *search_path, int symbology, enum ACm_poss_hdr hdr_type, enum ACm_poss_scroll hdr_scroll, struct GRid *macro, struct ret_struct *temp_val, struct GRid *temp_grid, struct GRid *feet_grid, struct GRid *def_col, struct GRid *def_occ));

#if defined(__cplusplus)
}
#endif


#undef __
