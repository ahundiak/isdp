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

/* ./fmgr/PDMco_lfm.c */
extern int PDMget_fmgr_values __PDM((char *catalog, char *part, char *rev, int cat_no, int part_no, int sano, int nchildren, struct NFMset_member *link_head, struct NFMset_member *link_end, MEMptr *out_bufr));
extern int PDMall_files_moved __PDM((struct NFMset_member *head, struct NFMset_member *end));
extern int PDMmark_files_to_be_moved __PDM((int cat_no, int item_no, MEMptr list, struct NFMset_member *head, struct NFMset_member *end));
extern int PDMget_children_fmgr_entries __PDM((int cat_no, int part_no, char *catalog, char *part, char *rev, struct NFMset_member *head, struct NFMset_member *end, int nchildren, MEMptr *out_bufr));
extern void _PDMprint_setmember __PDM((char *name, struct NFMset_member *mem));
extern void _PDMprint_fileentry __PDM((char *name, struct NFMfile_entry *mem));
extern void _PDMprint_itementry __PDM((char *name, struct NFMitem_entry *mem));
extern void _PDMprint_all_setmember __PDM((char *name, struct NFMset_member *mem));

/* ./fmgr/PDMco_updlfm.c */
extern int PDMco_update_filemanager __PDM((char *n_catalogname, char *n_itemname, char *n_itemrev, int pcat_no, int pitem_no, struct NFMset_member *set_head, struct NFMset_member *set_end, MEMptr out_bufr, MEMptr *file_bufr));
extern int PDMco_item_update_filemanager __PDM((char *n_catalogname, char *n_itemname, char *n_itemrev, int cat_no, int part_no, int sano, MEMptr *file_bufr));
extern int PDMcancel_co_update_filemanager __PDM((int cat_no, int part_no, char *catalog, char *part, char *rev, struct NFMset_member *head, struct NFMset_member *end, int nchildren, MEMptr *delete_list));

/* ./fmgr/PDMffilemgr.c */
extern int PDMXchkout_file_transfers __PDM((MEMptr data_bufr, MEMptr storage_buffer, MEMptr new_files, int parent_row));
extern int PDMXupdate_filemanager __PDM((MEMptr file_list, MEMptr storage_buffer, char *type));
extern int PDMXload_fmgrentry __PDM((int n_sano, char *p_catno, char *n_itemno, char *p_filename, char *p_mdate, char *p_mtime, int p_mtype, int attach_count));
extern int PDMXupdate_fmgrentry __PDM((int n_sano, char *p_catno, char *n_itemno, char *p_filename, char *p_mdate, char *p_mtime, int p_mtype, int attach_count));
extern int PDMXupdate_fmgrdates __PDM((int n_sano, char *p_catno, char *n_itemno, char *p_filename, char *p_mdate, char *p_mtime, int p_mtype, int attach_count));

/* ./fmgr/PDMffmgr_out.c */
extern int PDMload_fmgr_ris __PDM((int n_itemname, int p_catno, int n_itemno, int n_sano, char *p_filename, int attach_count, int p_mtype));
extern int PDMfmgr_increment __PDM((int n_itemname, int n_sano, int p_mtype, int attach_count, int p_ref2));
extern int PDMfmgr_decrement __PDM((int n_itemname, int n_sano, int attach_count));

/* ./fmgr/PDMfmgr_cpy.c */
extern int PDMcopy_file_transfers __PDM((MEMptr copy_files, MEMptr storage_buffer, MEMptr *new_files));
extern int PDMupdate_fmgr_copy __PDM((int sano, MEMptr fmgr_bufr));
extern int PDMcheck_fmgr_copy __PDM((int n_sano, char *n_cofilename, int n_catalogno, int n_itemno, int n_filenum, int n_fileversion));
extern int PDMcheck_fmgr_attach __PDM((int n_sano, char *n_cofilename, int n_catalogno, int n_itemno, int n_filenum, int n_fileversion));
extern long PDMcreate_fmgr_bufr __PDM((MEMptr *attr_list));
extern int PDMupdate_fmgr_copy_file __PDM((int sano, MEMptr fmgr_bufr));
extern int PDMupdate_fmgr_delete __PDM((int sano, char *n_cofilename, int n_catalogno, int n_itemno));
extern long PDMcreate_delete_bufr __PDM((MEMptr *attr_list));
extern int PDMdelete_filelist_pdu __PDM((MEMptr file_list, MEMptr *delete_list));

/* ./fmgr/PDMfmgr_f.c */
extern int PDMi_get_file_list __PDM((MEMptr storage_buffer, MEMptr *bufr));
extern int PDMasses_move_type __PDM((char *cat, char *part, char *rev, int n_sano, char **movetype));
extern int PDMi_set_fileco __PDM((char *cat, char *part, char *rev, char *date1, char *time1, char *n_fileco));
extern int PDMi_update_bufr_column __PDM((MEMptr bufr, int r1, int n1, int n2, int n3, char *val));
extern int PDMi_find_storageno __PDM((MEMptr storage_buffer, int *n_sano));
extern int PDMi_find_storageno_name __PDM((int *n_sano, char *n_saname));
extern int PDMshow_file_list __PDM((MEMptr *file_list));
extern int PDMdelete_file_list __PDM((MEMptr storage_buffer, MEMptr *file_list));
extern int PDMshow_chkout_files __PDM((MEMptr *file_list));
extern int PDMlogin_find_sainfo __PDM((int *n_sano, char *n_saname));
extern void PDMprint_storage_area __PDM((void));

/* ./fmgr/PDMfmgr_in.c */
extern int PDMchkin_file_transfers __PDM((int n_pcatalogno, int n_pitemno, char *n_cofilename, MEMptr attach_bufr, MEMptr fmgr_bufr));
extern int PDMprocess_parametric_files __PDM((MEMptr attr_bufr, MEMptr data_bufr, int parent_row, int parent_row_offset));
extern int PDMupdate_fmgr_chkin __PDM((int sano, MEMptr fmgr_bufr));
extern int PDMcheck_fmgr_chkin __PDM((int n_sano, int n_catalogno, int n_itemno, char *n_cofilename, MEMptr fmgr_bufr));
extern int PDMfmgr_dereferencing __PDM((int n_sano, int n_catalogno, int n_itemno, MEMptr fmgr_bufr));
extern int PDMcr_chkin_fmgrbufr __PDM((MEMptr *attr_list));
extern long PDMpdu_delete_filelist __PDM((MEMptr fmgr_bufr, MEMptr *attr_list));

/* ./fmgr/PDMfmgr_m.c */
extern int PDMlist_local_files __PDM((MEMptr *file_list));
extern int PDMdelete_local_files __PDM((MEMptr file_list, MEMptr *return_buffer));
extern int PDMchkin_files_of_user __PDM((MEMptr *file_list));
extern int PDMlist_chkout_files __PDM((MEMptr *file_list));

/* ./fmgr/PDMfmgr_out.c */
extern int PDMchkout_file_transfers __PDM((MEMptr attr_bufr, MEMptr data_bufr, MEMptr storage_buffer, MEMptr *out_bufr, MEMptr *new_files, int parent_row, int parent_row_offset));
extern int PDMupdate_filemanager __PDM((char *n_catalogname, char *n_itemname, char *n_itemrev, MEMptr file_list, MEMptr storage_buffer, char *type));
extern int PDMload_fmgrentry __PDM((int n_sano, char *p_catno, char *n_itemno, char *p_filename, char *p_mdate, char *p_mtime, int p_mtype, int attach_count));
extern int PDMupdate_fmgrentry __PDM((int n_sano, char *p_catno, char *n_itemno, char *p_filename, char *p_mdate, char *p_mtime, int p_mtype, int attach_count));
extern int PDMupdate_fmgrdates __PDM((int n_sano, char *p_catno, char *n_itemno, char *p_filename, char *p_mdate, char *p_mtime, int p_mtype, int attach_count));

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
