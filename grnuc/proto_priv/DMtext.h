#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/dim/csrc_130/DMtext.I */
extern IGRint DMundo_text_string __((struct DMdat_environ *p_dat_environ, struct DMnon_ascii_text *p_dim_text, struct DMdat_elem *p_dat_elem));
extern int build_text __((struct DMdat_environ *p_dat_environ, struct DMnon_ascii_text *p_dim_text, struct DMfields_contents fields_contents[], struct DMnon_ascii_text *p_text));
extern IGRint DMtext_processing __((int mode, struct DMdat_environ *p_dat_environ, struct DMdat_fields *p_dat_fields, struct DMdat_elem *p_dat_elem, struct DMnon_ascii_text *p_dim_text, struct DMnon_ascii_text *p_sys_fields, struct DMnon_ascii_text *p_usr_fields));
extern int value_prefix __((int mode, struct DMdat_environ *p_dat_environ, struct DMdat_elem *p_dat_elem, struct DMnon_ascii_text *p_non_ascii_text));
extern int value_symbol_before __((int mode, struct DMdat_environ *p_dat_environ, struct DMdat_elem *p_dat_elem, struct DMnon_ascii_text *p_non_ascii_text));
extern int box_dimension_global __((int mode, struct DMdat_environ *p_dat_environ, struct DMdat_fields *p_dat_fields, struct DMdat_elem *p_dat_elem, struct DMnon_ascii_text *p_dim_text, struct DMnon_ascii_text *p_sys_fields, struct DMnon_ascii_text *p_usr_fields));
extern int box_dimension_unit __((int mode, int unit, struct DMdat_environ *p_dat_environ, struct DMdat_fields *p_dat_fields, struct DMdat_elem *p_dat_elem, struct DMnon_ascii_text *p_dim_text, struct DMnon_ascii_text *p_sys_fields, struct DMnon_ascii_text *p_usr_fields));
extern int value_dimension __((int mode, int unit, struct DMdat_environ *p_dat_environ, struct DMdat_fields *p_dat_fields, struct DMdat_elem *p_dat_elem, struct DMnon_ascii_text *p_non_ascii_text));
extern int value_tolerance_up __((int mode, int unit, struct DMdat_environ *p_dat_environ, struct DMdat_fields *p_dat_fields, struct DMdat_elem *p_dat_elem, struct DMnon_ascii_text *p_non_ascii_text));
extern int value_tolerance_low __((int mode, int unit, struct DMdat_environ *p_dat_environ, struct DMdat_fields *p_dat_fields, struct DMdat_elem *p_dat_elem, struct DMnon_ascii_text *p_non_ascii_text));
extern int value_tolerance_plus_minus __((int mode, int unit, struct DMdat_environ *p_dat_environ, struct DMdat_fields *p_dat_fields, struct DMdat_elem *p_dat_elem, struct DMnon_ascii_text *p_non_ascii_text));
extern int value_tolerance_middle __((int mode, int unit, struct DMdat_environ *p_dat_environ, struct DMdat_fields *p_dat_fields, struct DMdat_elem *p_dat_elem, struct DMnon_ascii_text *p_non_ascii_text));
extern int value_dimension_maxi __((int mode, int unit, struct DMdat_environ *p_dat_environ, struct DMdat_fields *p_dat_fields, struct DMdat_elem *p_dat_elem, struct DMnon_ascii_text *p_non_ascii_text));
extern int value_dimension_mini __((int mode, int unit, struct DMdat_environ *p_dat_environ, struct DMdat_fields *p_dat_fields, struct DMdat_elem *p_dat_elem, struct DMnon_ascii_text *p_non_ascii_text));
extern int value_symbol_after __((int mode, struct DMdat_environ *p_dat_environ, struct DMdat_elem *p_dat_elem, struct DMnon_ascii_text *p_non_ascii_text));
extern int value_suffix __((int mode, struct DMdat_environ *p_dat_environ, struct DMdat_elem *p_dat_elem, struct DMnon_ascii_text *p_non_ascii_text));
extern int add_fields __((struct DMnon_ascii_text *p_text1, struct DMnon_ascii_text *p_text2, int fields_addr0));
extern int add_symbol __((struct DMdat_environ *p_dat_environ, struct DMnon_ascii_text *p_text, int symbol));
extern int add_string __((struct DMnon_ascii_text *p_text, char *string));
extern int add_convert __((struct DMdat_elem *p_dat_elem, struct DMdat_environ *p_dat_environ, struct DMnon_ascii_text *p_text, char *format, double value));
extern int convert_to_frac __((char *string, int accuracy, double value, int *index));
extern int DMdat_environ_print __((struct DMdat_environ *p_dat_environ));
extern int DMdat_local_print __((struct DMdat_local *p_dat_local));
extern int DMdat_cmpx_print __((struct DMdat_cmpx *p_dat_cmpx));
extern int DMdat_cmpx_feet_print __((struct DMdat_cmpx_feet *p_dat_cmpx_feet));
extern int DMdat_elem_print __((struct DMdat_elem *p_dat_elem));
extern int DMdat_elem_feet_print __((struct DMdat_elem_feet *p_dat_elem_feet));
extern int DMdat_fields_dump __((struct DMdat_fields *p_dat_fields));
extern int DMlstrcat __((struct DMnon_ascii_text *p_text, char *data));
extern int DMlstrncat __((struct DMnon_ascii_text *p_text, char *data, int n));
extern int DMlstrlcat __((struct DMnon_ascii_text *p_text1, struct DMnon_ascii_text *p_text2));
extern int DMlstrcpy __((struct DMnon_ascii_text *p_text, char *data));
extern int DMlstrlcpy __((struct DMnon_ascii_text *p_text1, struct DMnon_ascii_text *p_text2));
extern int DMlstrshl __((struct DMnon_ascii_text *p_text, int index, int n));
extern int DMlstrshr __((struct DMnon_ascii_text *p_text, int index, int n));
extern int DMlstrcut __((char *text1, int n, struct DMnon_ascii_text *p_text2));
extern int DMlstrprint __((struct DMnon_ascii_text *p_text));
extern int DMlstrdump __((struct DMnon_ascii_text *p_text));
extern int trace_in __((char *function_name));
extern int trace_out __((char *function_name));
extern int DMreplace_cap __((struct DMdat_environ *p_dat_environ, char *s, char *t, int n));
extern int DMconvert_to_sixteen_bit __((char *string, char *string16));
extern int DMget_active_font_info __((short *font_num, struct vfont_entry *font_info));
extern int DMget_font_info __((int font_num, struct vfont_entry *font_info));
extern int DMfont_sixteen_bit __((int font_num));
extern int DMget_ascii_font __((int font_num, short *ascii_font_num));

#if defined(__cplusplus)
}
#endif


#undef __
