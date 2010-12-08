#ifndef PDMS_CICO_PRO_H
#define PDMS_CICO_PRO_H

#include "PDUnode.h"

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

/* ./cicocp/PDMCheckOut.c */
extern int PDMcheckout_part __PDMS((MEMptr file_bufr, MEMptr *out_file_bufr, MEMptr *attach_bufr));
extern int PDMCheckoutPart __PDMS((char *catalog_name, long catalog_no, char *item_name, char *item_revision, char *working_area, MEMptr *file_bufr));
extern int PDMcancel_checkout_part __PDMS((MEMptr *delete_list, MEMptr attach_list, struct PDUcat_node *para_cats, MEMptr *mul_files));
extern int PDMundo_part_file_co_changes __PDMS((MEMptr *file_bufr));
extern long PDMRetrieveAssyFiles __PDMS((MEMptr assy_buf, MEMptr *status_buffer));

// Conflicts with proto defined later in file
//tern int PDMCancelCheckoutPart __PDMS((char *catalog_name, long catalog_no, char *item_name, char *item_revision, char *working_area, MEMptr *delete_list));

extern int PDMOLDCancelCheckoutPart __PDMS((char *catalog_name, long catalog_no, char *item_name, char *item_revision, char *working_area));

/* ./cicocp/PDMassy_mem.c */
extern long PDMXXget_set_members __PDMS((long cat_no, long *item_no_list, long num_item, long level));
extern long PDMXXsort_linked_list __PDMS((struct child_info *sorting_list));
extern long PDMXXfree_linked_list __PDMS((void));
extern int _PDMprint_childinfo_struct1 __PDMS((char *struct_name, struct child_info *set));
extern int PDMget_assy_members __PDMS((int catno, int partno, int level, struct NFMset_member **set_head, struct NFMset_member **set_end, int *nch));
extern int PDMsort_set_member_list __PDMS((struct NFMset_member *sorting_list));
extern int PDMget_assy_members_for_cancel_part_co __PDMS((int catno, int partno, int level, struct NFMset_member **set_head, struct NFMset_member **set_end, int *nch, MEMptr attach_list, MEMptr child_bufr));

/* ./cicocp/PDMchkin_i.c */
extern int PDMcomplete_item_checkin __PDMS((PDMexec_ptr PDMexec));
extern int PDMprepare_item_checkin __PDMS((PDMexec_ptr PDMexec));
extern int PDMcancel_item_checkin __PDMS((PDMexec_ptr PDMexec));

/* ./cicocp/PDMchkout_i.c */
extern int PDMcomplete_item_checkout __PDMS((PDMexec_ptr PDMexec));
extern int PDMprepare_item_checkout __PDMS((PDMexec_ptr PDMexec));
extern int PDMcancel_item_checkout __PDMS((PDMexec_ptr PDMexec));

/* ./cicocp/PDMci_set.c */
extern long PDMXprepare_set_checkin __PDMS((char *cat_name, char *item_name, char *item_rev, long level, MEMptr *data_list));
extern long PDMXXcancel_set_checkin __PDMS((long user_id, MEMptr attr_list, MEMptr data_list));

/* ./cicocp/PDMci_tools.c */
// Pull these from NFM
#if 0
extern long _NFMget_ci_files __PDMS((long user_id, long i_row, long f_row, MEMptr attr_list, MEMptr data_list, MEMptr file_list, long type));
extern long _NFMmake_fcat_entry __PDMS((char *cat_name, long item_no, long item_ver, long *file_no));
extern long _NFMupd_ci_cat_fcat __PDMS((long user_id, char *c_user, char *c_date, char *c_time, long sa_no, long i_row, long f_row, char *cat_name, long item_no, MEMptr attr_list, MEMptr data_list, MEMptr file_list));
extern long _NFMdel_fcat_fileno __PDMS((int rows, char *cat_name));
extern long _NFMpur_item_files __PDMS((long user_id, char *cat_name, char item_no));
extern long _NFMchk_item __PDMS((char *cat_name, char *item_name, int item_rev, int command));
extern long _NFMchk_pendingflag __PDMS((char *cat_name, char *item_name, char *item_rev, int operation));
#endif

/* ./cicocp/PDMcipart.c */
extern long PDMcheckin_item __PDMS((char *catalog_name, long catalog_no, char *item_name, char *item_revision, char *working_area, struct NFMwf_info wf_info, struct NFMoperation operation));

/* ./cicocp/PDMcopy_f.c */
extern int PDMcopy_assembly_files __PDMS((long user_id, char *catalog, char *part_num, char *revision, MEMptr strg_bufr, MEMptr *attach_bufr));
extern int PDMcopy_atomic_file __PDMS((long user_id, char *catalog, char *part_num, char *revision, MEMptr strg_bufr, int p_seqno, MEMptr *attach_bufr));
extern int PDMprocess_attachments __PDMS((long user_id, char *catalog, char *partnum, char *revision, char *bom, int cit_level, MEMptr *attach_bufr));
extern int PDMsend_files __PDMS((long user_id, MEMptr attach_bufr, MEMptr strg_bufr));

/* ./cicocp/PDMcopy_m.c */
extern int PDMscopy __PDMS((char *catalog, char *part, char *rev, char *filename));
extern int PDMXcopy_attach __PDMS((PDMexec_ptr PDMexec));
extern int PDMdetach __PDMS((MEMptr detach_bufr, MEMptr *delete_list));
extern int PDMXcheck_dup_sa_fname __PDMS((char *filename, char *strg_name));

/* ./cicocp/PDMcp_files.c */
extern long PDMcopy_part_files __PDMS((char *working_area, MEMptr copy_bufr, MEMptr success_bufr, MEMptr failure_bufr));

/* ./cicocp/PDMexp_copy.c */
extern long PDMexp_copy_bufr __PDMS((MEMptr copy_bufr, MEMptr *exp_copy_bufr));

/* ./cicocp/PDMfasttool.c */
extern int PDMload_part_info __PDMS((char *catalog, char *partnum, char *revision));
extern int PDMload_child_info __PDMS((char *catalog, char *partnum, char *revision));
extern int PDMquery_part_info __PDMS((MEMptr *bufr));
extern void _PDMinit_part_struct __PDMS((PDMpart_ptr PDMchild));
extern void _PDMprint_setinfo1_struct __PDMS((char *struct_name, struct set_info1 *set));
extern void _PDMprint_childinfo_struct __PDMS((char *struct_name, struct child_info *set));

/* ./cicocp/PDMfcopy_m.c */
extern int PDMfcopy_attach __PDMS((PDMexec_ptr PDMexec));
extern int PDMcopy_file __PDMS((MEMptr copy_bufr, MEMptr *exp_copy_bufr));

/* ./cicocp/PDMffast.c */
extern int PDMcopy_attach __PDMS((MEMptr copy_bufr, MEMptr *return_buffer));
extern int PDMcopy_atomic __PDMS((long user_id, char *catalog, char *partnum, char *revision, MEMptr strg_bufr, MEMptr *attach_bufr));
extern int PDMfcopy_assembly __PDMS((long user_id, char *catalog, char *partnum, char *revision, MEMptr strg_bufr, MEMptr attach_bufr));
extern int PDMload_copy_buffer __PDMS((MEMptr bufr, MEMptr success_bufr, MEMptr failure_bufr));

/* ./cicocp/PDMfunc1.c */
extern long PDMXget_set_ci_files_info1 __PDMS((struct set_info1 *head, int quantity, MEMptr file_list));
extern long PDMXcheck_and_update_items_status1 __PDMS((char *catalog, struct set_info1 *head_set, int type));
extern long PDMXset_colevel __PDMS((char *cat_name, long *item_no, char *level));
extern long PDMXget_children_info __PDMS((void));

/* ./cicocp/PDMiteminfo.c */
extern long PDMXget_item_data_def_and_values1 __PDMS((long table_no, long ftable_no, char *cat_name, char *item_name, char *item_rev, struct set_info1 **new_set_info));
extern long PDMXget_items_data_def_values1 __PDMS((long cur_cat_no, long cur_fcat_no, char *cur_cat_name, long *item_no_list, long item_num, struct set_info1 **head_set, struct set_info1 **end_set));

/* ./cicocp/PDMn_ci.c */
extern int PDMcheckin_part __PDMS((MEMptr file_bufr, MEMptr child_bufr, MEMptr attach_bufr, MEMptr sv_bufr, MEMptr parm_buffer, MEMptr data_buffers, MEMptr para_ass, MEMptr para_ass_dynamic, struct PDUcat_node *para_cats, MEMptr *delete_list, MEMptr *mul_files));
extern int PDMcheckin_part1 __PDMS((int update_structure, int view_update, MEMptr child_bufr, MEMptr attach_bufr, MEMptr sv_bufr, MEMptr parm_buffer, MEMptr data_buffers, MEMptr para_ass, MEMptr para_ass_dynamic, struct PDUcat_node *para_cats, MEMptr *delete_list, MEMptr *mul_files));
extern int PDMcheckin_case1 __PDMS((char *cat, char *part, char *rev, int pno, MEMptr parm_buffer, MEMptr sv_bufr, MEMptr *file_list, int update_structure, int view_update));
extern int PDMcheckin_case2 __PDMS((char *cat, char *part, char *rev, int pno, MEMptr sv_bufr, MEMptr *file_list, int view_update));
extern int PDMcheckin_case3 __PDMS((char *catalog, char *p_partnum, char *p_revision, int p_partno, MEMptr child_bufr, MEMptr attach_bufr, MEMptr sv_bufr, MEMptr parm_buffer, MEMptr data_buffers, MEMptr para_ass, MEMptr para_ass_dynamic, MEMptr *file_list, int update_structure, int view_update));
extern int PDMcheckin_case4 __PDMS((char *catalog, char *p_partnum, char *p_revision, int p_partno, MEMptr child_bufr, MEMptr attach_bufr, MEMptr sv_bufr, MEMptr parm_buffer, MEMptr data_buffers, MEMptr para_ass, MEMptr para_ass_dynamic, MEMptr *file_list, int view_update));
extern int PDMdelete_local_macros __PDMS((struct PDUcat_node *para_cats1, MEMptr *delete_list));
extern int _PDMupdate_permission_change_bufr __PDMS((int catalog, int itemnum, MEMptr *mul_files, MEMptr *delete_list));

/* ./cicocp/PDMn_co.c */
extern int PDMcheckout_part __PDMS((MEMptr file_bufr, MEMptr *out_file_bufr, MEMptr *attach_bufr));
extern int PDMcheckout_assembly_part __PDMS((MEMptr *attach_bufr, MEMptr *file_bufr));
extern int PDMcheckout_atomic_part __PDMS((MEMptr *file_bufr));
extern int PDMco_set_info_oper_struct __PDMS((struct NFMset_member *head, int nchildren));
extern int PDMXXco_set_oper_struct __PDMS((struct NFMset_member *head, int nchildren));
extern int _PDMchk_in_user __PDMS((MEMptr data_list));
extern int PDMload_cat_part_info __PDMS((char *catalog, char *part_num, char *revision, int ch, struct NFMset_member *head));
extern int PDMco_set_oper_struct __PDMS((struct NFMset_member *head, int nchildren));

// Conflicts with proto earlier in file
//tern int PDMcancel_checkout_part __PDMS((MEMptr *delete_list, MEMptr attach_list, MEMptr child_bufr, struct PDUcat_node *para_cats, MEMptr *mul_files));

extern int PDMload_attach_buffer __PDMS((struct NFMset_member *set_head, struct NFMset_member *set_end, MEMptr *attach_bufr));
extern int PDMundo_part_file_co_changes __PDMS((MEMptr *file_bufr));

/* ./cicocp/PDMsave_part.c */
extern int PDMpost_to_database __PDMS((MEMptr child_bufr, MEMptr sv_bufr, MEMptr parm_buffer, MEMptr data_buffers, MEMptr para_ass));
extern int PDMsave_part_case1 __PDMS((long uid, char *cat, char *part, char *rev, int pno, MEMptr parm_buffer, MEMptr sv_bufr));
extern int PDMsave_part_case2 __PDMS((long uid, char *cat, char *part, char *rev, int pno, MEMptr sv_bufr));
extern int PDMsave_part_case3 __PDMS((long user_id, char *catalog, char *p_partnum, char *p_revision, int p_partno, MEMptr child_bufr, MEMptr sv_bufr, MEMptr parm_buffer, MEMptr data_buffers, MEMptr para_ass));
extern int PDMsave_part_case4 __PDMS((long user_id, char *catalog, char *p_partnum, char *p_revision, int p_partno, MEMptr child_bufr, MEMptr sv_bufr, MEMptr parm_buffer, MEMptr data_buffers, MEMptr para_ass));
extern long PDMload_lfm_for_updatedb __PDMS((char *n_catalogname, int n_sano, int n_catalogno, int n_itemno));

/* ./cicocp/PDMsettools.c */
extern long PDMretrieve_set_members __PDMS((struct NFMmembers *members_list, long count, long level, struct NFMset_member *set_head, struct NFMset_member *set_end, long *num_members));
extern long XPDMget_catalog_names __PDMS((struct NFMset_member *set_head, long num_members));
extern long PDMXXretrieve_set_members __PDMS((struct NFMmembers *members_list, long count, long level, struct NFMset_member *set_head, struct NFMset_member *set_end, long *num_members));
extern long PDMXretrieve_set_members __PDMS((struct NFMmembers *members_list, long count, long level, struct NFMset_member *set_head, struct NFMset_member *set_end, long *num_members));
extern long PDMexp_retrieve_set_members __PDMS((struct NFMmembers *members_list, long count, long level, struct NFMset_member *set_head, struct NFMset_member *set_end, long *num_members));
extern long PDMcheck_and_add_cat __PDMS((char *cat_name));

#if defined(__cplusplus)
}
#endif

#if defined(__STDC__) || defined(__cplusplus)
#ifndef __PDMS
#define __PDMS(args) args
#endif
#else
#ifndef __PDMS
#define __PDMS(args) ()
#endif
#endif

#if defined(__STDC__) || defined(__cplusplus)
#ifndef __PDMS
#define __PDMS(args) args
#endif
#else
#ifndef __PDMS
#define __PDMS(args) ()
#endif
#endif

#if defined(__STDC__) || defined(__cplusplus)
#ifndef __PDMS
#define __PDMS(args) args
#endif
#else
#ifndef __PDMS
#define __PDMS(args) ()
#endif
#endif

#if defined(__STDC__) || defined(__cplusplus)
#ifndef __PDMS
#define __PDMS(args) args
#endif
#else
#ifndef __PDMS
#define __PDMS(args) ()
#endif
#endif

#if defined(__STDC__) || defined(__cplusplus)
#ifndef __PDMS
#define __PDMS(args) args
#endif
#else
#ifndef __PDMS
#define __PDMS(args) ()
#endif
#endif

#endif
