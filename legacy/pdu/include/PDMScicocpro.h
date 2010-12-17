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

/* ./cicocp/PDMassy_mem.c */
extern long PDMXXget_set_members __PDM((long cat_no, long *item_no_list, long num_item, long level));
extern long PDMXXsort_linked_list __PDM((struct child_info *sorting_list));
extern long PDMXXfree_linked_list __PDM((void));
extern int _PDMprint_childinfo_struct1 __PDM((char *struct_name, struct child_info *set));
extern int PDMget_assy_members __PDM((int catno, int partno, int level, struct NFMset_member **set_head, struct NFMset_member **set_end, int *nch));
extern int PDMsort_set_member_list __PDM((struct NFMset_member *sorting_list));
extern int PDMget_assy_members_for_cancel_part_co __PDM((int catno, int partno, int level, struct NFMset_member **set_head, struct NFMset_member **set_end, int *nch, MEMptr attach_list));

/* ./cicocp/PDMchkin_i.c */
extern int PDMcomplete_item_checkin __PDM((PDMexec_ptr PDMexec));
extern int PDMprepare_item_checkin __PDM((PDMexec_ptr PDMexec));
extern int PDMcancel_item_checkin __PDM((PDMexec_ptr PDMexec));

/* ./cicocp/PDMchkout_i.c */
extern int PDMcomplete_item_checkout __PDM((PDMexec_ptr PDMexec));
extern int PDMprepare_item_checkout __PDM((PDMexec_ptr PDMexec));
extern int PDMcancel_item_checkout __PDM((PDMexec_ptr PDMexec));

/* ./cicocp/PDMci_set.c */
extern long PDMXprepare_set_checkin __PDM((char *cat_name, char *item_name, char *item_rev, long level, MEMptr *data_list));
extern long PDMXXcancel_set_checkin __PDM((long user_id, MEMptr attr_list, MEMptr data_list));

/* ./cicocp/PDMci_tools.c */
extern long _NFMget_ci_files __PDM((long user_id, long i_row, long f_row, MEMptr attr_list, MEMptr data_list, MEMptr file_list, long type));
extern long _NFMmake_fcat_entry __PDM((char *cat_name, long item_no, long item_ver, long *file_no));
extern long _NFMupd_ci_cat_fcat __PDM((long user_id, char *c_user, char *c_date, char *c_time, long sa_no, long i_row, long f_row, char *cat_name, long item_no, MEMptr attr_list, MEMptr data_list, MEMptr file_list));
extern long _NFMdel_fcat_fileno __PDM((int rows, char *cat_name));
extern long _NFMpur_item_files __PDM((long user_id, char *cat_name, char item_no));
extern long _NFMchk_item __PDM((char *cat_name, char *item_name, int item_rev, int command));
extern long _NFMchk_pendingflag __PDM((char *cat_name, char *item_name, char *item_rev, int operation));

/* ./cicocp/PDMcopy_f.c */
extern int PDMcopy_assembly_files __PDM((long user_id, char *catalog, char *part_num, char *revision, MEMptr strg_bufr, MEMptr *attach_bufr));
extern int PDMcopy_atomic_file __PDM((long user_id, char *catalog, char *part_num, char *revision, MEMptr strg_bufr, int p_seqno, MEMptr *attach_bufr));
extern int PDMprocess_attachments __PDM((long user_id, char *catalog, char *partnum, char *revision, char *bom, int cit_level, MEMptr *attach_bufr));
extern int PDMsend_files __PDM((long user_id, MEMptr attach_bufr, MEMptr strg_bufr));
extern int PDMi_prepare_buffer1 __PDM((MEMptr *attach_bufr));

/* ./cicocp/PDMcopy_m.c */
extern int PDMscopy __PDM((char *catalog, char *part, char *rev, char *filename));
extern int PDMXcopy_attach __PDM((PDMexec_ptr PDMexec));
extern int PDMdetach __PDM((MEMptr detach_bufr, MEMptr *delete_list));

/* ./cicocp/PDMcp_files.c */
extern long PDMcopy_part_files __PDM((char *working_area, MEMptr copy_bufr, MEMptr success_bufr, MEMptr failure_bufr));

/* ./cicocp/PDMexp_copy.c */
extern long PDMexp_copy_bufr __PDM((MEMptr copy_bufr, MEMptr *exp_copy_bufr));
extern int PDMquery_catalog_part_rev_type __PDM((int n_catalogno, int n_itemno, char *catalog, char *part_num, char *part_rev, char *part_type));
extern int PDMget_mul_file __PDM((char *catalog, int itemno, MEMptr *temp_bufr1));
extern int PDMget_new_files __PDM((char *catalog, int itemno, MEMptr *temp_bufr1));

/* ./cicocp/PDMfasttool.c */
extern int PDMload_part_info __PDM((char *catalog, char *partnum, char *revision));
extern int PDMload_child_info __PDM((char *catalog, char *partnum, char *revision));
extern int PDMquery_part_info __PDM((MEMptr *bufr));
extern void _PDMinit_part_struct __PDM((PDMpart_ptr PDMchild));
extern void _PDMprint_setinfo1_struct __PDM((char *struct_name, struct set_info1 *set));
extern void _PDMprint_childinfo_struct __PDM((char *struct_name, struct child_info *set));

/* ./cicocp/PDMfcopy_m.c */
extern int PDMfcopy_attach __PDM((PDMexec_ptr PDMexec));
extern int PDMcopy_file __PDM((MEMptr copy_bufr, MEMptr *exp_copy_bufr));

/* ./cicocp/PDMffast.c */
extern int PDMcopy_attach __PDM((MEMptr copy_bufr, MEMptr *return_buffer));
extern int PDMcopy_atomic __PDM((long user_id, char *catalog, char *partnum, char *revision, MEMptr strg_bufr, MEMptr *attach_bufr));
extern int PDMXXsa_info __PDM((int sa_no));
extern int PDMfcopy_assembly __PDM((long user_id, char *catalog, char *partnum, char *revision, MEMptr strg_bufr, MEMptr attach_bufr));
extern int PDMget_file_list __PDM((long user_id, char *catalog, char *partnum, char *revision, MEMptr *list));
extern int PDMmake_data_buffer __PDM((MEMptr *list));
extern int PDMXmake_file_buffer __PDM((MEMptr *list));
extern int PDMXload_sano_info __PDM((int user_id, MEMptr *list));
extern int PDMload_copy_buffer __PDM((MEMptr bufr, MEMptr success_bufr, MEMptr failure_bufr));

/* ./cicocp/PDMfunc1.c */
extern long PDMXget_set_ci_files_info1 __PDM((struct set_info1 *head, int quantity, MEMptr file_list));
extern long PDMXcheck_and_update_items_status1 __PDM((char *catalog, struct set_info1 *head_set, int type));
extern long PDMXset_colevel __PDM((char *cat_name, long *item_no, char *level));
extern long PDMXget_children_info __PDM((void));

/* ./cicocp/PDMiteminfo.c */
extern long PDMXget_item_data_def_and_values1 __PDM((long table_no, long ftable_no, char *cat_name, char *item_name, char *item_rev, struct set_info1 **new_set_info));
extern long PDMXget_items_data_def_values1 __PDM((long cur_cat_no, long cur_fcat_no, char *cur_cat_name, long *item_no_list, long item_num, struct set_info1 **head_set, struct set_info1 **end_set));

/* ./cicocp/PDMn_ci.c */
extern int PDMcheckin_part __PDM((MEMptr file_bufr, MEMptr child_bufr, MEMptr attach_bufr, MEMptr sv_bufr, MEMptr parm_buffer, MEMptr data_buffers, MEMptr para_ass, MEMptr *delete_list));
extern int PDMcheckin_case1 __PDM((long uid, char *cat, char *part, char *rev, int pno, int file_bufr, MEMptr parm_buffer, MEMptr sv_bufr, MEMptr *file_list));
extern int PDMcheckin_case2 __PDM((long uid, char *cat, char *part, char *rev, int pno, MEMptr file_bufr, MEMptr sv_bufr, MEMptr *file_list));
extern int PDMcheckin_case3 __PDM((long user_id, char *catalog, char *p_partnum, char *p_revision, int p_partno, MEMptr file_bufr, MEMptr child_bufr, MEMptr attach_bufr, MEMptr sv_bufr, MEMptr parm_buffer, MEMptr data_buffers, MEMptr para_ass, MEMptr *file_list));
extern int PDMcheckin_case4 __PDM((long user_id, char *catalog, char *p_partnum, char *p_revision, int p_partno, MEMptr file_bufr, MEMptr child_bufr, MEMptr attach_bufr, MEMptr sv_bufr, MEMptr parm_buffer, MEMptr data_buffers, MEMptr para_ass, MEMptr *file_list));
extern int PDMdelete_local_macros __PDM((MEMptr parm_buffer, MEMptr strg_bufr));
extern int PDMset_info_oper_struct __PDM((char *catalog, char *p_partnum, char *p_revision));
extern int PDMset_oper_struct __PDM((char *catalog, char *p_partnum, char *p_revision));
extern int PDMupdate_ncoout __PDM((char *catalog, int itemno, char *upd_str));
extern int PDMreset_ncoout __PDM((char *catalog, int itemno, char *old_coout));
extern int PDMupdate_dots __PDM((void));
extern int PDMreset_dots __PDM((void));

/* ./cicocp/PDMn_co.c */
extern int PDMcheckout_part __PDM((MEMptr file_bufr, MEMptr *out_file_bufr, MEMptr *attach_bufr));
extern int PDMcheckout_assembly_part __PDM((MEMptr *attach_bufr, MEMptr *file_bufr));
extern int PDMcheckout_atomic_part __PDM((MEMptr *file_bufr));
extern int PDMco_set_info_oper_struct __PDM((struct NFMset_member *head, int nchildren));
extern int PDMXXco_set_oper_struct __PDM((struct NFMset_member *head, int nchildren));
extern int _PDMchk_in_user __PDM((MEMptr data_list));
extern int PDMload_cat_part_info __PDM((char *catalog, char *part_num, char *revision, int ch, struct NFMset_member *head));
extern int PDMco_set_oper_struct __PDM((struct NFMset_member *head, int nchildren));
extern int PDMcancel_checkout_part __PDM((MEMptr *delete_list, MEMptr attach_list));
extern int PDMload_attach_buffer __PDM((struct NFMset_member *set_head, struct NFMset_member *set_end, MEMptr *attach_bufr));

/* ./cicocp/PDMsave_part.c */
extern int PDMpost_to_database __PDM((MEMptr child_bufr, MEMptr sv_bufr, MEMptr parm_buffer, MEMptr data_buffers, MEMptr para_ass));
extern int PDMsave_part_case1 __PDM((long uid, char *cat, char *part, char *rev, int pno, MEMptr parm_buffer, MEMptr sv_bufr));
extern int PDMsave_part_case2 __PDM((long uid, char *cat, char *part, char *rev, int pno, MEMptr sv_bufr));
extern int PDMsave_part_case3 __PDM((long user_id, char *catalog, char *p_partnum, char *p_revision, int p_partno, MEMptr child_bufr, MEMptr sv_bufr, MEMptr parm_buffer, MEMptr data_buffers, MEMptr para_ass));
extern int PDMsave_part_case4 __PDM((long user_id, char *catalog, char *p_partnum, char *p_revision, int p_partno, MEMptr child_bufr, MEMptr sv_bufr, MEMptr parm_buffer, MEMptr data_buffers, MEMptr para_ass));

/* ./cicocp/PDMsettools.c */
extern long PDMretrieve_set_members __PDM((struct NFMmembers *members_list, long count, long level, struct NFMset_member *set_head, struct NFMset_member *set_end, long *num_members));
extern long XPDMget_catalog_names __PDM((struct NFMset_member *set_head, long num_members));
extern long PDMXXretrieve_set_members __PDM((struct NFMmembers *members_list, long count, long level, struct NFMset_member *set_head, struct NFMset_member *set_end, long *num_members));
extern long PDMXretrieve_set_members __PDM((struct NFMmembers *members_list, long count, long level, struct NFMset_member *set_head, struct NFMset_member *set_end, long *num_members));
extern long PDMexp_retrieve_set_members __PDM((struct NFMmembers *members_list, long count, long level, struct NFMset_member *set_head, struct NFMset_member *set_end, long *num_members));

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
