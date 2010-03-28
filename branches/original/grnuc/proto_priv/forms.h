#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/dim/dim_utils/forms.I */
extern int DMstrncpy __((char *s1, char *s2, int n));
extern int DMupper_to_lower __((char *s));
extern int DMstrip __((char *string, char *strip));
extern int DMcar_pos __((char *string, int character));
extern int DMstrequ __((char *sentence1, char *sentence0));
extern int DMstrcat __((char *s1, int index, char *s2));
extern int DMkeyboard_to_internal __((struct DMkeyboard *p_dm_keyboard, struct DM_data_st *p_dm_gadget));
extern IGRint DMinternal_to_keyboard __((struct DM_data_st *p_dm_gadget, struct DMkeyboard *p_dm_keyboard, int tabulation_flag));
extern int DMform_to_internal __((struct CIform_st *form_st, struct DM_data_st *p_dm_gadget));
extern int DMconvert_form_value __((int g_type, int f_type, struct CIform_st *form_st, struct DM_data_st *p_dm_gadget));
extern int DMput_by_value __((struct DM_data_st *p_dm_gadget));
extern int DMget_keyin_index __((int form_no, int label));
extern int DMget_option_count __((int form_no, int label));
extern char *DMget_option __((int form_no, int label, int opt_index));
extern int DMlist_keyins __((char *filename));
extern int DMactive_values __((char *filename, struct DMenv_param *par_env, struct DMloc_param *par_loc, struct DMmisc_param *par_misc, struct DMsenv_param *par_senv));
extern IGRint DMnotify_form __((int form_label, int label, double value, Form form_ptr));
extern IGRint DMatof __((char s[], double *d));

#if defined(__cplusplus)
}
#endif


#undef __
