#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/dim/dim_co/weldform.I */
extern int DMprocess_weld_form __((int form_label, int label, double value, Form form, Form subform1, Form subform2, Form subform3, Form subform4, IGRboolean toggle_x_section, IGRboolean *above_input, IGRint *form_display, IGRboolean display, IGRboolean edit_cmd, IGRboolean *save_data, IGRboolean *ignore_data, struct DMweld_param *par_weld));
extern int DMoutput_group_center __((Form form, struct DMweld_param *par_weld));
extern int DMoutput_group_above __((Form form, struct DMweld_param *par_weld));
extern int DMoutput_group_below __((Form form, struct DMweld_param *par_weld));
extern int get_value_ALPHA __((Form form, IGRint label, unsigned char *weld_str));
extern int set_value_ALPHA __((Form form, IGRint label, unsigned char *weld_str));
extern int set_symbol_index __((Form form, IGRint label, IGRint symbol_num));
extern int set_value_NUMERIC __((Form form, IGRint label, IGRboolean value));
extern int get_value_HILITE __((Form form, IGRint label, IGRint *value));
extern int set_gadget_HILITE __((Form form, IGRint label, IGRint value));
extern int display_label __((Form form, IGRint label));
extern int erase_label __((Form form, IGRint label));
extern int get_weld_symbol __((IGRboolean above, IGRint label, IGRint *sym_label, IGRint *symbol_num));
extern int display_weldform __((Form form));
extern int delete_form __((Form form));
extern int erase_form __((Form form));
extern int erase_group __((IGRint grp_num, Form form));
extern int DMcheck_cs __((IGRboolean set, IGRboolean set_value, IGRboolean check, struct DMweld_param *par_weld, Form form));

#if defined(__cplusplus)
}
#endif


#undef __
