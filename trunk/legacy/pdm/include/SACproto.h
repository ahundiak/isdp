#ifndef SAC_PROTO_H
#define SAC_PROTO_H

#if defined(__STDC__) || defined(__cplusplus)
# define __SAC(s) s
#else
# define __SAC(s) ()
#endif


/* NFMadd_col.c */
extern int NFMadd_col __SAC((long user_id, MEMptr list, char *new_format, long data_size, MEMptr *out_list, char *column_name));

/* NFMadd_col_v.c */
extern int NFMadd_col_val __SAC((long user_id, MEMptr list, MEMptr *out_list, char *value));

/* NFMattr_list.c */
extern int NFMattr_list __SAC((long user_id, char *cat_name, char *cat_no, MEMptr *out_list, MEMptr in_attr_list));

/* NFMbzero.c */
extern long NFMbzero __SAC((char *string, int size));

/* NFMcmp_attr.c */
extern long NFMcmp_attr_list __SAC((MEMptr list1, MEMptr list2, MEMptr *mis_attr_list));

/* NFMcom_attr.c */
extern int NFMcom_attr_list __SAC((long user_id, MEMptr cat_list, MEMptr *out_list));

/* NFMdebug.c */

/* NFMgen_list.c */
extern long NFMgen_list __SAC((long user_id, MEMptr attr_list, MEMptr *out_list, char *cat_name, char *cat_no, char *search_name, char *sort_name));

/* NFMl_cat.c */
extern int main __SAC((int argc, char **argv));
extern int rm_newline __SAC((char *s));

/* NFMlist_catn.c */
extern long NFMlist_cat_names __SAC((long user_id, MEMptr *list, char *search_name, char *sort_name, long flag));

/* NFMsac.c */
extern long NFMsearch_across_catalogs __SAC((long user_id, char *cat_search_str, char *cat_sort_str, char *item_search_str, char *item_sort_str, MEMptr in_attr_list, MEMptr *out_buffer_list, MEMptr *mis_attr_list));

/* NFMsaoe.c */
extern long NFMsearch_across_oper_env __SAC((long user_id, char *cat_search_str, char *cat_sort_str, char *item_search_str, char *item_sort_str, MEMptr in_attr_list, MEMptr env_list, MEMptr *out_buffer_list, MEMptr *mis_attr_list));

#undef __SAC

#endif
