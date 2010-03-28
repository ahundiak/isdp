#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/dim/dim_text/DMfields.I */
extern IGRint DMstart_str __((struct DMtxt_str *dim_text, int field_num, struct DMstd_param *std_arr));
extern IGRint DMcompute_prefix __((char *prefix_val, struct DMtxt_str *dim_text, int field_num, struct DMstd_param *std_arr, IGRshort kanji_font, IGRshort text_font));
extern IGRint DMtext_box __((struct DMtxt_str *dim_text, int field_num));
extern IGRint DMcompute_symbol_text __((OMuword osnum, struct DMsymbol_info *symbol_struct, struct DMtxt_str *dim_text, int field_num, struct DMstd_param *std_arr, int act_font));
extern IGRint DMcompute_single_start __((struct DMtxt_str *dim_text, int field_num, struct DMstd_param *std_arr, struct DMloc_param *loc_param));
extern IGRint DMcompute_single_end __((struct DMtxt_str *dim_text, int field_num, struct DMstd_param *std_arr, struct DMloc_param *p_par_loc, IGRint move_flag));
extern IGRint DMdual_above_start __((struct DMtxt_str *dim_text, int field_num, struct DMstd_param *std_arr, struct DMenv_param *env_param, struct DMloc_param *loc_param));
extern IGRint DMdual_above_middle __((struct DMtxt_str *dim_text, int field_num, struct DMstd_param *std_arr, struct DMloc_param *p_par_loc));
extern IGRint DMdual_above_end __((struct DMtxt_str *dim_text, int field_num, struct DMstd_param *std_arr, struct DMloc_param *p_par_loc));
extern IGRint DMadd_dimension_field __((struct DMtxt_str *dim_text, int field_num, double dimn_val, struct DMenv_param *env_param, struct DMloc_param *p_loc, struct DMmisc_param *p_misc, int mode));
extern IGRint DMadd_angular_field __((OMuword osnum, struct DMtxt_str *dim_text, int dim_field_no, double dimn_val, struct DMenv_param *p_env, struct DMloc_param *p_loc, struct DMmisc_param *p_misc));
extern IGRint DMtol_up_low_start __((struct DMtxt_str *dim_text, int dim_field, int field_num, struct DMstd_param *std_arr, double tol_size, int tol_weig, double descent_r));
extern IGRint DMtol_up_low_center __((struct DMtxt_str *dim_text, int dim_field, int field_num, struct DMstd_param *std_arr, double tol_size, double descent_r));
extern IGRint DMtol_up_low_end __((struct DMtxt_str *dim_text, int field_num, struct DMstd_param *std_arr, double tol_size, int text_weight, double descent_r));
extern IGRint DMtol_middle_start __((struct DMtxt_str *dim_text, int field_num, int dim_field, struct DMstd_param *std_arr));
extern IGRint DMtol_end __((struct DMtxt_str *dim_text));
extern IGRint DMtol_limit_start __((struct DMtxt_str *dim_text, int field_num, struct DMstd_param *std_arr));
extern IGRint DMtol_limit_center __((struct DMtxt_str *dim_text, int field_num, int orig_field, struct DMstd_param *std_arr));
extern IGRint DMadd_label_field __((struct DMtxt_str *dim_text, int field_num, char *str, int flag));
extern IGRint DMtol_lim_end __((struct DMtxt_str *dim_text, int field_num, struct DMstd_param *std_arr));
extern IGRint DMcompute_suffix __((char *suffix_val, struct DMtxt_str *dim_text, int field_num, struct DMstd_param *std_arr, IGRshort kanji_font, IGRshort text_font));
extern IGRint DMend_dim __((struct DMtxt_str *dim_text, int field_num, struct DMstd_param *std_arr));
extern IGRint DMadd_symbol_text __((OMuword osnum, struct DMtxt_str *dim_text, struct DMsymbol_info *p_sym, int text_font));
extern IGRint DMreturn_dim_field __((int dim_mode, int dim_type, int tole_mode, int unit_mode, int *field_no));
extern IGRint DMmake_alter_text __((OMuword osnum, struct DMtxt_str *dim_text, IGRdouble dimn_val, struct DMenv_param *p_env, struct DMloc_param *p_loc, struct DMmisc_param *p_misc, struct DMstd_param *std_arr, int mea_type));
extern int DMadd_prefix_suffix __((struct DMtxt_str *dim_text, unsigned char *prefix, IGRshort text_font, IGRshort kanji_font));
extern int DMadd_begin_paren_field __((struct DMtxt_str *dim_text, struct DMstd_param *std_prm, char *str));
extern int DMadd_end_paren_field __((struct DMtxt_str *dim_text, struct DMstd_param *std_prm, char *str));
extern int DMcompute_ref_suffix_field __((struct DMtxt_str *dim_text, int field_num, struct DMstd_param *std_prm));
extern int DMcompute_ref_subfix_field __((struct DMtxt_str *dim_text, int field_num, int dual_mode, struct DMstd_param *std_prm));

#if defined(__cplusplus)
}
#endif


#undef __
