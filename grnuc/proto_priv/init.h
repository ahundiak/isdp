#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/dim/dim_utils/init.I */
extern IGRint DMinit_dim_params __((int dim_stan, OMuword osnum, struct DMenv_param *par_env, struct DMloc_param *par_loc, struct DMmisc_param *par_misc, struct DMsenv_param *par_senv, struct DMglobal_param *par_glob, struct DMweld_param *par_weld));
extern IGRint DMprocess_keyin __((IGRboolean flag, OMuword osnum, struct DM_data_st *p_dm_gadget, struct DMenv_param *par_env, struct DMloc_param *par_loc, struct DMmisc_param *par_misc, struct DMsenv_param *par_senv, struct DMglobal_param *par_glob, struct DMweld_param *par_weld));
extern IGRint DMprocess_keyin_FORM_DISPLAY __((IGRboolean flag, OMuword osnum, struct DM_data_st *p_dm_gadget, struct DMenv_param *par_env, struct DMloc_param *par_loc, struct DMmisc_param *par_misc));
extern IGRint DMprocess_keyin_NOT_ON_FORM __((IGRboolean flag, OMuword osnum, struct DM_data_st *p_dm_gadget, struct DMenv_param *par_env, struct DMloc_param *par_loc, struct DMmisc_param *par_misc, struct DMsenv_param *par_senv, struct DMglobal_param *par_glob, struct DMweld_param *par_weld));
extern IGRint DMprocess_keyin_FORM_ENVIRON __((IGRboolean flag, OMuword osnum, struct DM_data_st *p_dm_gadget, struct DMenv_param *par_env, struct DMloc_param *par_loc, struct DMmisc_param *par_misc, struct DMglobal_param *par_glob));
extern IGRint DMprocess_keyin_FORM_LOCAL __((IGRboolean flag, OMuword osnum, struct DM_data_st *p_dm_gadget, struct DMenv_param *par_env, struct DMloc_param *par_loc, struct DMmisc_param *par_misc));
extern IGRint DMmap_gadget_value __((IGRboolean flag, IGRchar *p_value, struct DM_data_st *p_dm_gadget));
extern void clear_dbl __((double *d, int n));
extern void clear_chr __((char *c, int n));
extern int process_color __((IGRshort *color, struct DM_data_st *p_dm_gadget));

#if defined(__cplusplus)
}
#endif


#undef __
