#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/assoc/absg_graph/GMlist.C */
extern int GMl_activate __((int default_number, int inc_number, int elmt_size, int (*equal_funct )(), char *p_fct_info, int size_info, struct GMlist *list));
extern int GMl_disactivate __((struct GMlist *list));
extern int GMl_clear __((struct GMlist *list));
extern int GMl_insert __((char *p_content, struct GMlist *in_list));
extern int GMl_add __((char *p_content, struct GMlist *in_list));
extern int GMl_replace __((char *p_content, struct GMlist *in_list));
extern int GMl_remove __((struct GMlist *in_list));
extern int GMl_first __((struct GMlist *of_list));
extern int GMl_last __((struct GMlist *of_list));
extern int GMl_next __((struct GMlist *of_list));
extern int GMl_previous __((struct GMlist *of_list));
extern int GMl_select __((char *p_content, struct GMlist *list));
extern int GMl_at_end __((struct GMlist *of_list));
extern int GMl_at_begin __((struct GMlist *of_list));
extern char *GMl_current __((struct GMlist *of_list));
extern int GMl_count __((struct GMlist *list));
extern char *GMl_ptr __((struct GMlist *list));
extern int GMl_duplicate __((struct GMlist *list, struct GMlist *l_dup));
extern int GMl_in __((char *p_content, struct GMlist *list, int (*usr_fct )(), char *usr_arg));

#if defined(__cplusplus)
}
#endif


#undef __
