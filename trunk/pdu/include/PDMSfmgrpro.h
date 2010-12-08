#ifndef PDMSfmgrpro_h
#define PDMSfmgrpro_h

#include "NFMitems.h"

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

/* ./fmgr/PDMco_lfm.c */
extern int PDMget_fmgr_values __PDMS((char *catalog, char *part, char *rev, int cat_no, int part_no, int sano, int nchildren, struct NFMset_member *link_head, struct NFMset_member *link_end, MEMptr *out_bufr));
extern int PDMall_files_moved __PDMS((struct NFMset_member *head, struct NFMset_member *end));
extern int PDMmark_files_to_be_moved __PDMS((int cat_no, int item_no, MEMptr list, struct NFMset_member *head, struct NFMset_member *end));
extern int PDMget_children_fmgr_entries __PDMS((int cat_no, int part_no, int sano, char *catalog, char *part, char *rev, struct NFMset_member *head, struct NFMset_member *end, int nchildren, MEMptr *out_bufr));
extern int PDMget_children_fmgr_entries_for_cancelco __PDMS((int cat_no, int part_no, char *catalog, char *part, char *rev, int sano, struct NFMset_member *head, struct NFMset_member *end, int nchildren, MEMptr local_bufr, MEMptr *out_bufr));

/* ./fmgr/PDMco_updlfm.c */
extern int PDMco_update_filemanager __PDMS((char *n_catalogname, char *n_itemname, char *n_itemrev, int pcat_no, int pitem_no, struct NFMset_member *set_head, struct NFMset_member *set_end, MEMptr out_bufr, MEMptr *file_bufr));
extern int PDMco_item_update_filemanager __PDMS((char *n_catalogname, char *n_itemname, char *n_itemrev, int cat_no, int part_no, int sano, MEMptr *file_bufr));
extern int PDMcancel_co_update_filemanager __PDMS((int cat_no, int part_no, char *catalog, char *part, char *rev, int sano, struct NFMset_member *head, struct NFMset_member *end, int nchildren, MEMptr *delete_list, MEMptr attach_bufr));
extern int PDMCoUpdateFilemgrForPart __PDMS((char *n_catalogname, char *n_itemname, char *n_itemrev, int cat_no, int part_no, int sano, MEMptr *file_bufr));
extern int PDMCancelCoUpdateFilemgrForPart __PDMS((char *n_catalogname, char *n_itemname, char *n_itemrev, int cat_no, int part_no, int sano, MEMptr *file_bufr));
extern int PDMCancelCoUpdateFilemgrForAssy __PDMS((char *n_catalogname, char *n_itemname, char *n_itemrev, int cat_no, int part_no, int sano, MEMptr attach_list, MEMptr *file_bufr));

/* ./fmgr/PDMffilemgr.c */
extern int PDMXchkout_file_transfers __PDMS((MEMptr data_bufr, MEMptr storage_buffer, MEMptr new_files, int parent_row));
extern int PDMXupdate_filemanager __PDMS((MEMptr file_list, MEMptr storage_buffer, char *type));
extern int PDMXload_fmgrentry __PDMS((int n_sano, char *p_catno, char *n_itemno, char *p_filename, char *p_mdate, char *p_mtime, int p_mtype, int attach_count));
extern int PDMXupdate_fmgrentry __PDMS((int n_sano, char *p_catno, char *n_itemno, char *p_filename, char *p_mdate, char *p_mtime, int p_mtype, int attach_count));
extern int PDMXupdate_fmgrdates __PDMS((int n_sano, char *p_catno, char *n_itemno, char *p_filename, char *p_mdate, char *p_mtime, int p_mtype, int attach_count));

/* ./fmgr/PDMffmgr_out.c */
extern int PDMload_fmgr_ris __PDMS((int n_itemname, int p_catno, int n_itemno, int n_sano, char *p_filename, int attach_count, int p_mtype));
extern int PDMfmgr_increment __PDMS((int n_itemname, int n_sano, int p_mtype, int attach_count, int p_ref2));
extern int PDMfmgr_decrement __PDMS((int n_itemname, int n_sano, int attach_count));

/* ./fmgr/PDMfmgr_cpy.c */
extern int PDMcopy_file_transfers __PDMS((MEMptr copy_files, MEMptr storage_buffer, MEMptr *new_files));
extern int PDMupdate_fmgr_copy __PDMS((int sano, MEMptr fmgr_bufr));
extern int PDMcheck_fmgr_copy __PDMS((int n_sano, char *n_cofilename, int n_catalogno, int n_itemno, int n_filenum, int n_fileversion));
extern int PDMcheck_fmgr_attach __PDMS((int n_sano, char *n_cofilename, int n_catalogno, int n_itemno, int n_filenum, int n_fileversion));
extern long PDMcreate_fmgr_bufr __PDMS((MEMptr *attr_list));
extern int PDMupdate_fmgr_copy_file __PDMS((int sano, MEMptr fmgr_bufr, MEMptr copy_bufr));
extern int PDMupdate_fmgr_delete __PDMS((int sano, char *n_cofilename, int n_catalogno, int n_itemno, MEMptr delete_bufr));
extern long PDMcreate_delete_bufr __PDMS((MEMptr *attr_list));
extern int PDMdelete_filelist_pdu __PDMS((MEMptr file_list, MEMptr *delete_list));
extern int _PDMRetrySqlStmt __PDMS((char *sql_str));
extern int PDMcheck_if_child_before_fmgr_update __PDMS((MEMptr orig_bufr, int catno, int itemno, int sano, short get_ref, short *child, int *ref_count, short *insert));
extern int PDMcheck_if_child_before_fmgr_delete __PDMS((MEMptr orig_bufr, int catno, int itemno, int sano, short *child));

/* ./fmgr/PDMfmgr_f.c */
extern int PDMi_get_file_list __PDMS((MEMptr storage_buffer, MEMptr *bufr));
extern int PDMasses_move_type __PDMS((char *cat, char *part, char *rev, int n_sano, char **movetype));
extern int PDMi_set_fileco __PDMS((char *cat, char *part, char *rev, char *date1, char *time1, char *n_fileco));
extern int PDMi_update_bufr_column __PDMS((MEMptr bufr, int r1, int n1, int n2, int n3, char *val));
extern int PDMshow_file_list __PDMS((MEMptr *file_list));
extern int PDMdelete_file_list __PDMS((MEMptr storage_buffer, MEMptr *file_list));
extern int PDMshow_chkout_files __PDMS((MEMptr *file_list));
extern int PDMsort_local_buffer __PDMS((MEMptr *unsorted_bufr));
extern int _PDMclean_lfm_bufr __PDMS((MEMptr file_bufr, MEMptr *new_file_bufr));
extern int PDMsort_checkout_buffer __PDMS((MEMptr *unsorted_bufr));

/* ./fmgr/PDMfmgr_fns.c */
extern int PDMi_find_storageno __PDMS((MEMptr storage_buffer, int *n_sano));

/* ./fmgr/PDMfmgr_in.c */
extern int PDMchkin_file_transfers __PDMS((int n_pcatalogno, int n_pitemno, char *n_cofilename, MEMptr attach_bufr, MEMptr fmgr_bufr));
extern int PDMprocess_parametric_files __PDMS((MEMptr attr_bufr, MEMptr data_bufr, int parent_row, int parent_row_offset));
extern int PDMupdate_fmgr_chkin __PDMS((int sano, MEMptr fmgr_bufr));
extern int PDMcheck_fmgr_chkin __PDMS((int n_sano, int n_catalogno, int n_itemno, char *n_cofilename, MEMptr fmgr_bufr));
extern int PDMfmgr_dereferencing __PDMS((int n_sano, int n_catalogno, int n_itemno, MEMptr fmgr_bufr));
extern int PDMcr_chkin_fmgrbufr __PDMS((MEMptr *attr_list));
extern long PDMpdu_delete_filelist __PDMS((MEMptr fmgr_bufr, MEMptr *attr_list));

/* ./fmgr/PDMfmgr_m.c */
extern int PDMlist_local_files __PDMS((MEMptr *file_list));
extern int PDMdelete_local_files __PDMS((MEMptr pdu_file_list, MEMptr *return_buffer));
extern int PDMchkin_files_of_user __PDMS((MEMptr *file_list));
extern int PDMlist_chkout_files __PDMS((MEMptr *file_list));

/* ./fmgr/PDMfmgr_out.c */
extern int PDMchkout_file_transfers __PDMS((MEMptr attr_bufr, MEMptr data_bufr, MEMptr storage_buffer, MEMptr *out_bufr, MEMptr *new_files, int parent_row, int parent_row_offset));
extern int PDMupdate_filemanager __PDMS((char *n_catalogname, char *n_itemname, char *n_itemrev, MEMptr file_list, MEMptr storage_buffer, char *type));
extern int PDMload_fmgrentry __PDMS((int n_sano, char *p_catno, char *n_itemno, char *p_filename, char *p_mdate, char *p_mtime, int p_mtype, int attach_count));
extern int PDMupdate_fmgrentry __PDMS((int n_sano, char *p_catno, char *n_itemno, char *p_filename, char *p_mdate, char *p_mtime, int p_mtype, int attach_count));
extern int PDMupdate_fmgrdates __PDMS((int n_sano, char *p_catno, char *n_itemno, char *p_filename, char *p_mdate, char *p_mtime, int p_mtype, int attach_count));

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
