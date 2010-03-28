#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/dim/dim_text/DMfun.I */
extern IGRint DMcompute_angular_text __((OMuword osnum, struct DMtxt_str *dim_text, double dimn_val, struct DMenv_param *p_env, struct DMloc_param *p_loc, struct DMmisc_param *p_misc, struct DMstd_param *p_std));
extern IGRint DMcompute_dim_text __((OMuword osnum, struct DMtxt_str *dim_text, int dim_type, double dimn_val, struct DMenv_param *p_env, struct DMloc_param *p_loc, struct DMmisc_param *p_misc, struct DMstd_param *p_std, int mode));
extern IGRint DMcompute_tol_up_low __((struct DMtxt_str *dim_text, int field_no, struct DMstd_param *std_arr, struct DMenv_param *p_env, struct DMloc_param *p_loc, struct DMmisc_param *p_misc, int type));
extern IGRint DMcompute_tol_middle __((OMuword osnum, struct DMtxt_str *dim_text, int field_num, struct DMstd_param *std_arr, struct DMenv_param *p_env, struct DMloc_param *p_loc, struct DMmisc_param *p_misc, int type, int pm_flag));
extern IGRint DMcompute_tol_limits __((struct DMtxt_str *dim_text, double dimn_val, int tol_field_no, struct DMstd_param *p_std, struct DMenv_param *p_env, struct DMloc_param *p_loc, struct DMmisc_param *p_misc, int type));
extern IGRint DMcompute_ang_limits __((OMuword osnum, struct DMtxt_str *dim_text, double dimn_val, int tol_field_no, struct DMstd_param *p_std, struct DMenv_param *p_env, struct DMloc_param *p_loc, struct DMmisc_param *p_misc));
extern IGRint DMadd_angular_text __((OMuword osnum, struct DMtxt_str *dim_text, struct measure_unit *unit_type, double dimn_val, struct DMloc_param *p_loc, struct DMenv_param *p_env));
extern IGRint DMadd_char_str __((struct DMtxt_str *dim_text, char *tol_val));
extern IGRint DMcompute_dim_string __((struct DMtxt_str *dim_text, struct DMloc_param *p_loc, struct DMenv_param *p_env, double dim_val, struct DMmisc_param *p_misc, int mode));
extern IGRint DMadd_format_string __((IGRint ftflag, struct DMtxt_str *dim_text, int metric, struct measure_unit *unit_type, double dim_val, struct DMenv_param *p_env, struct DMloc_param *p_loc));
extern IGRint DMget_plus_minus_flag __((struct DMloc_param *p_loc, int *pmflag, int mode));
extern IGRint DMget_frac_index __((double dim_val, int *index, int accuracy, int *flag));
extern IGRint DMdeci_dimension __((double dim_val, struct measure_unit *unit_type, struct DMtxt_str *dim_text, struct DMloc_param *p_loc));
extern IGRint DMsupress_digit __((char *dim_str, int leading, int trailing, char *result_str));
extern IGRint DMmake_fields __((unsigned char *string, int text_length, struct DMfield_def *dmfields));
extern IGRint DMget_prefix_suffix_val __((unsigned char *string, struct DMfield_def *dmfields, struct DMmisc_param *p_misc, int field_no));
extern IGRint DMget_dimn_string_val __((unsigned char *string, struct DMfield_def *dm_fields, struct DMmisc_param *p_misc, struct DMloc_param *p_loc, struct DMenv_param *p_env, int field_no, int flag));
extern IGRint DMfld_fil __((unsigned char *string, int text_length, struct IGRdisplay *display, struct GRdpb_text_symb *text_symb));
extern int analyse_string __((unsigned char *string, int text_length));
extern int DMpreproc_presuf __((int dir, char *str));

#if defined(__cplusplus)
}
#endif


#undef __
