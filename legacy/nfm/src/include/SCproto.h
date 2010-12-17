#ifndef SC_PROTO_H
#define SC_PROTO_H

#if defined(__STDC__) || defined(__cplusplus)
# define __SC(s) s
#else
# define __SC(s) ()
#endif


/* NFMcopy_wr.c */
extern int EX_print_copyright __SC((void));

/* SCcolumn.c */
extern int SCprocess_column_form __SC((struct SCcolumn_data_st *user_data, char *print_file));
extern int SCcolumn_form_input __SC((void));
extern int SCfill_column_table __SC((int mode));
extern int SCadd_a_null_row __SC((int mode));
extern int SCfill_in_title __SC((WINDOW *win, char *title));
extern int place_cursor __SC((void));
extern int SCprint_column_table __SC((void));

/* SCfree.c */
extern int SCprocess_free_form __SC((struct SCfree_data_st *user_data, char *print_file));
extern int SCfill_free_table __SC((int mode));
extern int SCfill_free_header __SC((int mode));
extern int SCfree_form_input __SC((void));
extern int place_cur __SC((void));
extern int SCdisplay_cur_pos __SC((void));
extern int update_page_string __SC((int count, char *buffer));
extern int SCprint_free_table __SC((int mode));
extern int SCprint_vertical_table __SC((void));

/* SCfunctions.c */
extern int put_string __SC((char **to_string, char *cp_string));
extern int SCdisplay_msg __SC((char *s));
extern int SCclear_msg __SC((void));
extern int SCdisplay_ref __SC((char *s));
extern int SCclear_ref __SC((char *s));
extern int SCdisplay_err __SC((char *s));
extern int SCclear_err __SC((void));
extern int SCclear_col_form __SC((void));
extern int SCclear_free_form __SC((void));
extern int data_in_string __SC((int pos, int width, int just, char data[], char string[], int string_len));
extern int clear_array_except __SC((int n, int a[], int size));
extern int strncmp_ignore_case __SC((char *s1, char *s2, int n));

/* SCglobals.c */

/* SCload.c */
extern int load_function_struct __SC((struct SCconfig_st **p, struct SCfunc_st **s));

/* SCmain.c */
extern int main __SC((int argc, char **argv));
extern int update_cmd_win __SC((void));
extern int update_cmd_pointers __SC((void));
extern int Signal_function __SC((int sig));
extern int check_for_function __SC((struct SCfunc_st *ptr, char *name, struct SCfunc_st **match_ptr, int *count));
extern int execute_func __SC((void));

/* SCrap.c */

/* SCraputil.c */

/* SCread.c */
extern int read_function_file __SC((struct SCfunc_st **p, char *filename));
extern int get_ch __SC((void));
extern int get_nonwhite_ch __SC((void));
extern int get_function_name __SC((struct SCfunc_st *p));
extern int get_string __SC((struct SCfunc_st *p, int mode));
extern int get_function __SC((struct SCfunc_st **p));
extern int get_group __SC((struct SCfunc_st **p));
extern int spaces __SC((int level));
extern int print_tree __SC((struct SCfunc_st *p, int level));
extern int add_exit __SC((struct SCfunc_st *p, int level));

/* SCread_cfg.c */
extern int read_config_file __SC((struct SCconfig_st **p, char *filename));
extern int get_config_string __SC((struct SCconfig_st *p, int mode));

/* SCredraw.c */
extern int SCredraw_forms __SC((void));

#undef __SC

#endif
