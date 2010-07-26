#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/assoc/nmacro_co/COm_place4.I */
extern int COm_display_line __((char *fp, int num_col, int i, char *prompt, int Temp_Type, struct ret_struct *Temp_Value, struct GRid *Temp_List, int mytype));
extern int COm_display_elig __((char *fp, int text_hdr, int field, struct GRid *elig_coll, struct ret_struct *str));
extern int COm_set_form_select __((struct GRid *macro_def, char *macro_name, char *fp));
extern int COm_list_macro __((struct GRid *macro_lib, struct GRid *macro_def, char *fp));

#if defined(__cplusplus)
}
#endif


#undef __
