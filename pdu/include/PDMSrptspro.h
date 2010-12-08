#ifndef PDMS_RPTS_PRO_H
#define PDMS_RPTS_PRO_H

#include "PDMbom_strct.h"

#if defined(__STDC__) || defined(__cplusplus)
#ifndef __PDMS
#define __PDMS(args) args
#endif
#else
#ifndef __PDMS
#define __PDMS(args) ()
#endif
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./reports/PDMbom_rps.c */
extern int PDMgen_bomparts_list __PDMS((MEMptr *return_buffer));
extern int PDMi_setup_table1 __PDMS((char *bom, int p_level, char *table_name));
extern int PDMload_seq_tagnos __PDMS((char *bom, MEMptr bufr));
extern int PDMi_find_seqtagnos __PDMS((char *bom, char *cat, char *part, char *rev, int level, char *tagno, char *alttagno, char *quantity, char *desc));
extern int PDMgen_summary_bom __PDMS((MEMptr *return_buffer));
extern int PDMi_setup_table2 __PDMS((char *bom, int req_level, char *table_name));
extern int PDMi_query_non_assemblies __PDMS((char *bom, MEMptr *bufr, int max_level));
extern int PDMGetChildListBufr __PDMS((char *bom, MEMptr *bufr, int max_level));
extern long PDMRetrieveMembersWithModifiedQty __PDMS((int pcat_no, int pitem_no, int level, int curr_level, struct PDMbom_member *set_head, struct PDMbom_member *set_end, int *num_members, double Qty));

/* ./reports/PDMcit_rps.c */
extern int PDMsgen_where_used_imm __PDMS((MEMptr *return_buffer));
extern int PDMi_setup_table3 __PDMS((int catno, int partno, char *table_name));
extern int PDMsgen_where_used_top __PDMS((MEMptr *return_buffer));
extern int PDMi_setup_table4 __PDMS((int catno, int partno, char *table_name));
extern int PDMi_recurse_to_highest __PDMS((char *a1, char *a2, char *a3, char *a4, MEMptr bufr1, MEMptr *bufr3));
extern int PDMreport_of_loc __PDMS((MEMptr *return_buffer));
extern int PDMreport_of_catalog __PDMS((MEMptr *return_buffer));
extern int PDMcreate_nfmpdmcat_view __PDMS((void));

/* ./reports/PDMcvt_bufr.c */
extern int PDMcvt_bufr_struct __PDMS((MEMptr def_op, MEMptr def_list, int list_total, int process, char *template_type, char *templib, char *where, struct PSUrpt *psurpt));
extern int PDMcvt_struct_bufr __PDMS((MEMptr *def_op, MEMptr *def_list, int *list_total, int *process, char *template_type, char *templib, char *where, struct PSUrpt psurpt));
extern int PDMcreate_dba_op __PDMS((MEMptr *attr_list));
extern int PDMcreate_dba_list __PDMS((MEMptr *attr_list));
extern int PDMinit_psurpt __PDMS((struct PSUrpt *psurpt));

/* ./reports/PDMdef_qry.c */
extern long PDMdefine_query __PDMS((char *query_name, char *query_desc, short query_type, char *application, char *user_name, struct NFMquery_info query_info));
extern long PDMretrieve_query __PDMS((char *query_name, struct NFMquery_info *query_info));
extern long PDMretrieve_query_info __PDMS((char *query_name, char *query_type, char *application, char *appl_type, char *query_desc, char *owner, struct NFMquery_info *query_info));
extern long _PDMread_query_info __PDMS((char *report_file, struct NFMquery_info *query_struct));

/* ./reports/PDMmove_rpt.c */
extern long PDMmove_rpt_file __PDMS((char *from_area, char *working_area, char *file_name));
extern long PDMimport_ris_rpt __PDMS((char *working_area, struct PSUrpt report, int file_move));
extern long PDMexport_ris_rpt __PDMS((char *working_area, char *report));
extern long PDMdelete_ris_rpt __PDMS((char *report));

/* ./reports/PDMnfm_rpts.c */
extern int PDMslist_reports __PDMS((MEMptr *output_buffers));

/* ./reports/PDMpdm_rpts.c */
extern int PDMsvalidate_report_name __PDMS((void));
extern int PDMsread_report_format __PDMS((MEMptr bufr, MEMptr def_bufr, MEMptr *def_op, MEMptr *def_list));
extern int PDMsread_criteria __PDMS((MEMptr *ret_bufr));
extern int PDMsadd_report __PDMS((MEMptr def_op, MEMptr def_list));
extern int PDMsadd_criteria __PDMS((MEMptr bufr, MEMptr input_buffers));
extern int PDMvalidate_querys __PDMS((void));
extern int PDMsdelete_report __PDMS((void));
extern int PDMsshow_boms __PDMS((MEMptr *return_buffer));
extern int PDMload_criteria_bufr __PDMS((MEMptr *attr_list, struct NFMquery_info query_info));

/* ./reports/PDMstls.c */
extern int PSUexe_rpt __PDMS((struct PSUrpt *psurpt, char *schema));
extern int PDMreport_from_tmpfile __PDMS((char *schema, char *table, char *templib, char *template, char *saname, char *output));
extern int PDMIndentReportFile __PDMS((char *ReportFile, int LevelSize));

#if defined(__cplusplus)
}
#endif

#endif
