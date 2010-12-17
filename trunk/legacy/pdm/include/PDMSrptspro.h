#ifndef PDM_PROTO_H
#define PDM_PROTO_H

#if defined(__STDC__) || defined(__cplusplus)
#ifndef __PDM
#define __PDM(args) args
#endif
#else
#ifndef __PDM
#define __PDM(args) ()
#endif
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./reports/PDMbom_rps.c */
extern int PDMgen_bomparts_list __PDM((MEMptr *return_buffer));
extern int PDMi_setup_table1 __PDM((char *bom, int p_level, char *table_name));
extern int PDMload_seq_tagnos __PDM((char *bom, MEMptr bufr));
extern int PDMi_find_seqtagnos __PDM((char *bom, char *cat, char *part, char *rev, int level, char *tagno, char *alttagno, char *quantity, char *desc));
extern int PDMgen_summary_bom __PDM((MEMptr *return_buffer));
extern int PDMi_setup_table2 __PDM((char *bom, int req_level, char *table_name));
extern int PDMi_query_non_assemblies __PDM((char *bom, MEMptr *bufr, int max_level));

/* ./reports/PDMcit_rps.c */
extern int PDMsgen_where_used_imm __PDM((MEMptr *return_buffer));
extern int PDMi_setup_table3 __PDM((int catno, int partno, char *table_name));
extern int PDMsgen_where_used_top __PDM((MEMptr *return_buffer));
extern int PDMi_setup_table4 __PDM((int catno, int partno, char *table_name));
extern int PDMi_recurse_to_highest __PDM((char *a1, char *a2, char *a3, char *a4, MEMptr bufr1, MEMptr *bufr3));
extern int PDMreport_of_loc __PDM((MEMptr *return_buffer));
extern int PDMreport_of_catalog __PDM((MEMptr *return_buffer));

/* ./reports/PDMcvt_bufr.c */
extern int PDMcvt_bufr_struct __PDM((MEMptr def_op, MEMptr def_list, int list_total, int process, char *template_type, char *templib, char *where, struct PSUrpt *psurpt));
extern int PDMcvt_struct_bufr __PDM((MEMptr *def_op, MEMptr *def_list, int *list_total, int *process, char *template_type, char *templib, char *where, struct PSUrpt psurpt));
extern int PDMcreate_dba_op __PDM((MEMptr *attr_list));
extern int PDMcreate_dba_list __PDM((MEMptr *attr_list));
extern int PDMfind_system_path __PDM((char *pathname, int *sano));
extern int PDMinit_psurpt __PDM((struct PSUrpt *psurpt));

/* ./reports/PDMdef_qry.c */
extern long PDMdefine_query __PDM((char *query_name, char *query_desc, short query_type, char *application, char *user_name, struct NFMquery_info query_info));
extern long PDMretrieve_query __PDM((char *query_name, struct NFMquery_info *query_info));
extern long PDMretrieve_query_info __PDM((char *query_name, char *query_type, char *application, char *appl_type, char *query_desc, char *owner, struct NFMquery_info *query_info));
extern long _PDMread_query_info __PDM((char *report_file, struct NFMquery_info *query_struct));

/* ./reports/PDMmove_rpt.c */
extern long PDMmove_rpt_file __PDM((char *from_area, char *working_area, char *file_name));
extern long PDMimport_ris_rpt __PDM((char *working_area, struct PSUrpt report));
extern long PDMexport_ris_rpt __PDM((char *working_area, char *report));
extern long PDMdelete_ris_rpt __PDM((char *report));

/* ./reports/PDMnfm_rpts.c */
extern int PDMslist_reports __PDM((MEMptr *output_buffers));

/* ./reports/PDMpdm_rpts.c */
extern int PDMsvalidate_report_name __PDM((void));
extern int PDMsread_report_format __PDM((MEMptr bufr, MEMptr def_bufr, MEMptr *def_op, MEMptr *def_list));
extern int PDMsread_criteria __PDM((MEMptr *ret_bufr));
extern int PDMsadd_report __PDM((MEMptr def_op, MEMptr def_list));
extern int PDMsadd_criteria __PDM((MEMptr bufr, MEMptr input_buffers));
extern int PDMvalidate_querys __PDM((void));
extern int PDMsdelete_report __PDM((void));
extern int PDMsshow_boms __PDM((MEMptr *return_buffer));
extern int PDMload_criteria_bufr __PDM((MEMptr *attr_list, struct NFMquery_info query_info));
extern int PDMquery_report_type __PDM((char *report, char *type, char *lib, char *out_file));

#if defined(__cplusplus)
}
#endif

#if defined(__STDC__) || defined(__cplusplus)
#ifndef __PDM
#define __PDM(args) args
#endif
#else
#ifndef __PDM
#define __PDM(args) ()
#endif
#endif

#endif
