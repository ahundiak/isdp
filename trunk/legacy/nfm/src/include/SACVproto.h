#ifndef SACV_PROTO_H
#define SACV_PROTO_H

#if defined(__STDC__) || defined(__cplusplus)
# define __SACV(s) s
#else
# define __SACV(s) ()
#endif


/* NFMconv_file.c */
extern long NFMconv_file __SACV((long user_id, char *oper_env));
extern int fail_log __SACV((NFMsa_index **lsa_index_ptr, long sa_no, char *msg, char *fname, char **data2, long j_in, long j_lim));
extern long NFMf_std __SACV((char *f_name, long sa_no, NFMsa_index *lsa_index_ptr, char **data2, long j_lim));
extern int isnum __SACV((int c));
extern int isfile __SACV((char *filename));

/* NFMdebug.c */
extern void _NFMdebug_function __SACV((int va_alist));

/* NFMdef_sch.c */
extern long NFMdef_schema __SACV((char *env_name));

/* NFMg_item_l.c */
extern long NFMget_item_list __SACV((MEMptr *out_buffer_list, char *cat_name, char *cat_no, long length1, long length2, long from_row, long to_row));

/* NFMget_sa_l.c */
extern long NFMget_sa_list __SACV((MEMptr *list));

/* NFMinit_us.c */
extern void NFMinit_sausage __SACV((char *program_name, char *usage));

/* NFMins_cat.c */
extern int NFMins_cat __SACV((long user_id, MEMptr list, char *catnoformat, long catnosize, char *catnameformat, long catnamesize, MEMptr *out_list));

/* NFMins_cat_v.c */
extern int NFMins_cat_val __SACV((long user_id, MEMptr list, MEMptr *out_list, char *catno, char *catname));

/* NFMlabels.c */
extern int NFMlabel1 __SACV((void));
extern int NFMlabel2 __SACV((void));

/* NFMlist_catn.c */
extern long NFMlist_cat_names __SACV((long user_id, MEMptr *list, char *search_name, char *sort_name, long flag));

/* NFMlock_tab.c */
extern int NFMlock_table __SACV((long user_id, char *table_name, long lock_flag));

/* NFMprintf.c */
extern void _NFMprintf __SACV((char *format, int va_alist));

/* NFMup_tab.c */
extern int NFMupdate_table __SACV((long user_id, char *table_name, long update_flag, long from_row, long to_row));

/* NFMw_ris_par.c */
extern long NFMwrite_ris_parameters __SACV((char *node_name));

/* main.c */
extern int main __SACV((int argc, char **argv));

#undef __SACV

#endif
