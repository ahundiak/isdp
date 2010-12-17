#ifndef CVT_PROTO_H
#define CVT_PROTO_H

#if defined(__STDC__) || defined(__cplusplus)
# define __CVT(s) s
#else
# define __CVT(s) ()
#endif


/* CVT.c */
extern long CVTsearch_sort_files __CVT((void));
extern long CVTget_report_name __CVT((int tableno, int fileno, char *report_file));
extern int CVTcheck_reports_start __CVT((void));

/* CVTattr.c */
extern long CVTrename_attr __CVT((void));
extern long CVTdelete_attr __CVT((void));

/* CVTcomplete.c */
extern long CVTcompletion_check __CVT((void));

/* CVTcr_cat.c */
extern long CVTconvert_catalogs __CVT((UNIT_INFO *catalogs, int cat_selection[]));
extern int CVTcheck_catalog_start __CVT((void));
extern int CVTupdate_catalog_end __CVT((void));
extern long CVTconvert_catalog __CVT((char *catalog_name));
extern int CVTcreate_catalog __CVT((char *catalog_name, long *insert_bad));
extern int CVTinsert_all_new_attributes __CVT((int catalog_no, int f_catalog_no));
extern int CVTinsert_new_attributes __CVT((int catalog_no, char *catalog_type, char *attr_name));
extern int CVTcat_unload __CVT((char *catalog_name));
extern int CVTNprocess_catalog __CVT((char *catalog_name, long *insert_bad));
extern int CVTNprocess_f_catalog __CVT((char *catalog_name, long *insert_bad));
extern int CVTdelete_all_new_attributes __CVT((int catalog_no, int f_catalog_no));
extern int CVTdelete_new_attributes __CVT((int table_no, char *attr_name));
extern int CVTdrop_o_catalogs __CVT((char *catalog_name));
extern int CVTcat_restore __CVT((char *catalog_name));
extern int _CVTget_next_seq_no __CVT((char *nfmtablename, char *column_name, long table_no, long *index_no));
extern int CVTcatalog_load_info __CVT((char *schema));
extern int CVTload_cat_names __CVT((char *catalog_name));
extern int CVTNcat_script __CVT((char *catalog_name, char *o_catalog_name));
extern int CVTwrite_bad_insert __CVT((char *catalog, char *insert_stmt));
extern long CVTcat_date __CVT((char *old_date, char *old_time, char *insert_date, long *pass_no));
extern long CVTget_s_cat_no __CVT((char *catalog_name, char *s_cat_no));
extern long CVTupdates __CVT((char *catalog_name));

/* CVTfgets.c */
extern char *CVTfgets __CVT((char *s, int n, FILE *stream));

/* CVTfile.c */
extern long CVTresolve_file_attrs __CVT((char *catalog));

/* CVTmain.c */
extern int main __CVT((int argc, char **argv));
extern long CVTlogout __CVT((long exit_flag));
extern long CVTdate_ud_attrs __CVT((long take_defaults));
extern int CVTprint_date_link __CVT((void));
extern int CVTfree_date_link __CVT((void));
extern long CVTdate_timestamp __CVT((void));
extern long CVTresolve_date __CVT((long take_defaults));

/* CVTmod_query.c */
extern long CVTmodify_query __CVT((char *query_name, char *query_desc, char *query_type, char *application, char *app_type, struct NFMquery_info query_info, long *new_query_no));

/* CVTparse.c */
extern int CVTload_definition __CVT((char *where_clause, char **ret_string));
extern int CVTparse_trio __CVT((char *trio, char **ret_string));
extern int CVTload_definition2 __CVT((char *order_clause, char **ret_string));
extern int CVTparse_attr __CVT((char *attr, char **ret_string));

/* CVTpath.c */
extern long CVTconvert_optical_path __CVT((char *inpath, char *outpath));
extern long CVTextract_platter_name __CVT((char *inpath, char *platter));

/* CVTprocess.c */
extern long CVTprocess_on_transition __CVT((void));
extern long CVTcheck_process_tables __CVT((void));
extern long CVTprocesses __CVT((void));
extern long CVTmodify_program __CVT((char *program_name, char *program_desc, char *old_prog_file, char *old_prog_num));

/* CVTqueries.c */
extern long NFMdefault_queries __CVT((void));

/* CVTread.c */
extern long CVTread_report_search __CVT((char *search_file, char *search_name, char **search_str));
extern long CVTread_report_sort __CVT((char *sort_file, char *sort_name, char **sort_str));

/* CVTrecreate.c */
extern long CVTconvert_sys_tables __CVT((char *activity));
extern int CVTunload __CVT((char *table_name));
extern int CVTdrop_sys_table __CVT((char *table_name));
extern int CVTrename_dmp_file __CVT((char *table_name));
extern int CVTrisload_o_tablename __CVT((char *table_name));
extern int CVTrisload_new_tables_spec __CVT((char *table_name));
extern int CVTrisload_new_index __CVT((char *table_name));
extern long CVTalter_table_add_col __CVT((char *tablename, char *columnname, char *datatype));
extern int CVTconvert_to_ansi __CVT((char *data, char new_date[20 ], char time[10 ]));
extern int CVTconvert_validate __CVT((char *data, char new_date[20 ], char time[10 ]));
extern int CVTvalidate __CVT((char *v_date));
extern int CVTdrop_old_table __CVT((char *table_name));
extern long CVTtable_script __CVT((void));
extern long CVTcat_script __CVT((void));
extern int CVTrecreate_table __CVT((char *table_name));
extern int CVTload_function __CVT((char *table_name));
extern int CVTact_table __CVT((void));

/* CVTsearch.c */
extern long CVTsearch_files __CVT((void));

/* CVTsignal.c */
extern long CVTinit_signal_handler __CVT((void));
extern void CVTsignal_handler __CVT((int sig));

/* CVTsort.c */
extern long CVTsort_files __CVT((void));

/* CVTsysattr.c */
extern long CVTconvert_nfmsysattributes __CVT((void));
extern long CVTload_attributes_data __CVT((void));
extern long _CVTconvert_sys __CVT((long *new_attrno));
extern long _CVTconvert_template __CVT((long *new_attrno));
extern long Convert_nfmattributes __CVT((long old_table_no, long new_table_no, char *tablename, long *new_attrno));
extern long Convert_nfmvalues_nfmlists __CVT((long old_attr_no, long new_attr_no));
extern int CVTrisload_s_tables __CVT((void));
extern long CVTdrop_s_tables __CVT((void));

/* CVTsystables.c */
extern int CVTnfmactivity __CVT((char *a_data));
extern int CVTnfmarchives __CVT((char *table_name));
extern int CVTnfmattributes __CVT((char *table_name));
extern int CVTnfmcatalogs __CVT((char *table_name));
extern int CVTnfmsignoff __CVT((char *table_name));
extern int CVTnfmcommands __CVT((char *table_name));
extern int CVTnfmnodes __CVT((char *table_name));
extern int CVTnfmprocesses __CVT((char *table_name));
extern int CVTnfmprograms __CVT((char *table_name));
extern int CVTnfmprojects __CVT((char *table_name));
extern int CVTnfmreports __CVT((char *table_name));
extern int CVTnfmsafiles __CVT((char *table_name));
extern int CVTnfmsavesets __CVT((char *table_name));
extern int CVTnfmstoragearea __CVT((char *table_name));
extern int CVTnfmtables __CVT((char *table_name));
extern int CVTnfmvalues __CVT((char *table_name));
extern int CVTnfmworkflow __CVT((char *table_name));
extern int CVTnfmacls __CVT((char *table_name));
extern int CVTnfmlists __CVT((char *table_name));
extern int CVTnfmstates __CVT((char *table_name));
extern int CVTnfmsyscat __CVT((void));
extern int CVTnfmtransitions __CVT((void));
extern int CVTnfmusers __CVT((void));
extern long CVTstamp_status __CVT((void));
extern long CVTcheck_date_name __CVT((char *n_name, long *timestamp_flag));

/* CVTtables.c */
extern long CVTcreate_cvtlog_tables __CVT((void));
extern long CVTupdate_cvtlog __CVT((char *table_name, char *status_flag, int last_row));
extern long CVTupdate_cvtindex __CVT((char *tabcolumn, int oldvalue, int newvalue));
extern long CVTquery_cvtlog_entry __CVT((char *table, char *status_flag, long *last_row));
extern long CVTprint_cvtlog __CVT((void));
extern int CVTcheck_nfm_stop_convert __CVT((void));

/* CVTuserdefwf.c */
extern long CVTuser_def_wf __CVT((void));
extern long CVTuser_exist __CVT((void));

/* CVTutil_30.c */
extern long _CVTget_next_slot __CVT((char *nfmtablename, char *column_name, long *index_no));
extern long CVTansi_to_timestamp __CVT((char *source, char *dest));
extern long CVTamerican_to_timestamp __CVT((char *source, char *dest));
extern long CVTcheck_for_ansi __CVT((char *source));
extern int menu __CVT((char *main_title, char *titles[], char *def_val[], short *attr, char *extra_char[], UNIT_INFO *data, char *o_titles[]));
extern int menu3 __CVT((char *main_title, UNIT_INFO *data));
extern long confirmation __CVT((void));
extern long get_terminal_name __CVT((char *str));
extern void heading __CVT((void));
extern long CVTget_schema_info __CVT((char *env_name, char *schema_name, char *schema_passwd));
extern long CVTdefault_schema __CVT((char *schema_name, char *schema_passwd));
extern int menu2 __CVT((char *title, UNIT_INFO list, int sel[], int *start, int *flag));
extern int display_menu2 __CVT((char *title, UNIT_INFO functions, int *no_titles, int *start));
extern int get_input2 __CVT((unsigned long ch, char *functions[], int no_titles, int *selec, int *sel, int min, int *flag));
extern int CVTget_db_type __CVT((void));
extern long CVTline_options __CVT((int argc, char **argv, char *filename, char *username, char *password, char *environment, char *activity, long *take_defaults));
extern long CVTvalidate_administrator __CVT((char *username, char *password));
extern long CVTcheck_ris_bad __CVT((char *ris_bad_file));
extern long _CVTconvert_to_timestamp __CVT((char *in_str1, char *out_str));

/* CVTwf.c */
extern long CVTconvert_workflow __CVT((void));
extern long CVTconvert_wf __CVT((void));
extern long CVTreseq_table __CVT((char *table_name));
extern long CVTdelete_command __CVT((void));
extern long CVTdelete __CVT((char *c_data));
extern long CVTupdate __CVT((char **data, char *trans, int *transno));
extern long CVTadd_command __CVT((void));
extern long CVTadd_transition __CVT((void));
extern long CVTdelete_transition __CVT((void));
extern long CVTchange_entity __CVT((void));
extern long CVTadd_exist __CVT((void));
extern long CVTrename __CVT((void));
extern long CVTcatalog_wf __CVT((void));
extern long CVTstates __CVT((long workflowno, char **s_data));
extern long CVTupdate_states __CVT((char **data, int seqno));
extern long CVTworkflow __CVT((void));
extern long CVTupdate_workflow __CVT((char **data, int name));
extern int CVTnfmaccess __CVT((char *data, int num));
extern int CVTdelete_nfmaccess __CVT((char *data));
extern int CVTcheck_process_on_transitions __CVT((void));
extern int CVTprocess_tran __CVT((char *data, int num));

#undef __CVT

#endif
