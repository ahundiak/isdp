#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/assoc/absg_graph/GMhcode.C */
extern int GMh_activate __((ushort modulo, ushort nb_elmt, ushort step_size, ushort content_size, ushort key_size, int (*f_cmp_key )(), char *p_fct_info, int (*f_hash )(), struct GMhcode *p_hcode));
extern int GMh_disactivate __((struct GMhcode *p_hcode));
extern int GMh_clear __((struct GMhcode *p_hcode));
extern int GMh_add __((char *p_key, char *p_content, struct GMhcode *p_hcode));
extern int GMh_remove __((char *p_key, struct GMhcode *p_hcode));
extern int GMh_give_content __((char *p_key, struct GMhcode *p_hcode, char **pp_content, ushort *p_index));
extern int GMh_duplicate __((struct GMhcode *p_hcode, struct GMhcode *p_dup_hcode));
extern char *GMh_content __((struct GMhcode *p_hcode, ushort index));
extern char *GMh_key __((struct GMhcode *p_hcode, ushort index));
extern int GMh_getlist __((struct GMhcode *p_hcode, int (*select_fctu )(), char *p_sel_argu, ushort **pp_index, int *p_nb_elmt));
extern int GMh_in_list __((char *p_key, ushort index_head, struct GMhcode *p_hcode, ushort *p_index_list));
extern int GMh_insert_in_list __((char *p_key, char *p_content, ushort index_head, struct GMhcode *p_hcode));

#if defined(__cplusplus)
}
#endif


#undef __
