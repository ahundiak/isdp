#ifndef PDU_PROTO_H
#define PDU_PROTO_H

#if defined(__STDC__) || defined(__cplusplus)
#ifndef __PDU
#define __PDU(args) args
#endif
#else
#ifndef __PDU
#define __PDU(args) ()
#endif
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./assembly/PDUassy_tls.c */
extern int PDUdisplay_review_structure __PDU((MEMptr assy_buffer));
extern int PDUload_assembly_structure __PDU((void));
extern int PDUadd_part_to_assy_structure __PDU((void));
extern int PDUdelete_assy_part __PDU((void));
extern int PDUadd_row_to_assy_mcf __PDU((Form form, int field, int rows, int level, int parent, int child, char *catalog, char *partid, char *revision, char *attach, char *quantity, char *usage));
extern int PDUcreate_assembly_parts_buffer __PDU((Form form, int field, MEMptr *buffer));
extern int PDUcheck_level_no __PDU((Form form, int field, int row));
extern int PDUdefault_usageid __PDU((char *catalog, char *partid, char *revision, int childno, char **usageid));
extern int PDUget_assembly __PDU((short get_level));
extern int PDUfreeze_assy_refresh __PDU((void));
extern int PDUunfreeze_assy_refresh __PDU((void));
extern int PDUget_max_level __PDU((int *level));
extern int PDUfreeze_assy_part_area __PDU((void));
extern int PDUunfreeze_assy_part_area __PDU((void));
extern int PDUgenerate_ng_usageid __PDU((char *catalog, char *partid, char *revision));
extern int PDUplace_ng_assembly __PDU((void));

/* ./assembly/PDUassyapi.c */
extern int PDUget_file_status __PDU((char *catalog, char *partid, char *revision, char **state));

/* ./assembly/PDUdef_assy.c */
extern int define_assy_notification_routine __PDU((int f_label, int g_label, double value, Form fp));
extern int PDUdefine_assy_form __PDU((void));
extern int PDUrefresh_gadgets_init __PDU((void));
extern int PDUassy_gadgets_init __PDU((void));
extern int PDUprint_assy_refresh __PDU((void));
extern int PDUcheck_assy_commands __PDU((void));
extern int PDUrestore_assy_part_selection_area __PDU((void));
extern int PDUsave_assy_part_selection_area __PDU((void));
extern int PDUfreeze_assy_mcf __PDU((void));
extern int PDUunfreeze_assy_mcf __PDU((void));

/* ./assembly/PDUrev_assy.c */
extern int compare_parts __PDU((char *cat1, char *part1, char *rev1, char *cat2, char *part2, char *rev2));
extern long PDUcheck_nesting __PDU((struct PDUrev_assy *assy_ptr, struct PDUrev_assy *working_ptr));
extern void PDUprint_attr_data_buffers __PDU((struct PDUattr_data *attrs));
extern void free_attr_data_buffer __PDU((struct PDUattr_data **attrs));
extern int attr_value_notification_routine __PDU((int f_label, int g_label, double value, Form fp));
extern int rev_assy_notification_routine __PDU((int f_label, int g_label, double value, Form fp));
extern long PDUget_part_bufrs __PDU((char *catalog, char *partid, char *revision, struct PDUattr_data **attr_data, short exist));
extern long PDU_display_attr_in_mcf __PDU((struct PDUattr_data *rev_attr_data));
extern long PDUupdate_revise_assy_form_after_select __PDU((void));
extern int PDUrevise_assembly_form __PDU((void));
extern int PDUget_storage_filename __PDU((char *catalog, char *part, char *rev, char *loc_filename, MEMptr *file_bufr, char **stg_filename));
extern int PDUverify_storage_filename __PDU((char *cat, char *part, char *rev, char *stgfile));
extern void PDUdisplay_status __PDU((long status, Form form));
extern int PDUcheck_attr_for_write_permission __PDU((MEMptr attr_bufr, char *attr));
extern int PDUget_desc __PDU((char *cat, char *part, char *rev, char **desc, char **parttype));
extern int act_part_notification_routine __PDU((int f_label, int g_label, double value, Form fp));
extern void PDUactive_part_form __PDU((char *catalog, char *partid, char *revision, char *desc, char *title));
extern int PDUcheck_if_parametric __PDU((char *catalog, short *parametric, short *exists));
extern int PDUcheck_cyclic_placement_for_rev_assy __PDU((int act_row));
extern int PDUfind_parent_in_mcf __PDU((int act_row, int level, char **parent_cat, char **parent_part, char **parent_rev, int *parent_row, int *parent_level, int *childno, int *pchildno));
extern int PDUreset_revise_assy_form __PDU((void));
extern int PDUget_text __PDU((Form form, int field, int row, int column, char **string));

/* ./assembly/PDUrevasytls.c */
extern int PDUconvert_assy_buffer_to_linklist __PDU((MEMptr assy_bufr, struct PDUrev_assy **assy_list));
extern int PDUprint_assy_linklist __PDU((struct PDUrev_assy *head));
extern int PDUadd_multiple_files_to_linklist __PDU((struct PDUrev_assy **assy_list));
extern int PDUreset_assy_mcf_row_pointers __PDU((void));
extern int PDUload_revise_assembly_form __PDU((struct PDUrev_assy *assy_list, Form form, int field));
extern int PDUfree_assy_linklist __PDU((struct PDUrev_assy **assy_list));
extern int PDUcheck_file_status_for_assy_linklist __PDU((struct PDUrev_assy *assy_list));
extern int PDUadd_blank_row_to_linklist __PDU((struct PDUrev_assy **assy_list, int row, int level));
extern int PDUappend_file_suffix __PDU((char *oldfile, char *suffix, char newfile[15 ]));
extern int PDUcopy_assy_linklist __PDU((struct PDUrev_assy *assy_list, struct PDUrev_assy **copy_list, short backup));
extern int PDUadd_parts_for_revise_assy __PDU((void));
extern int PDUcreate_add_file_buffer __PDU((MEMptr *file_bufr, char *cifile, char *cofile, MEMptr attr_bufr, MEMptr data_bufr, MEMptr list_bufr));
extern int PDUcreate_BOM_assy_list __PDU((struct PDUrev_assy **assy_list, MEMptr assy_bufr));
extern int PDUcheck_assy_list_for_change __PDU((MEMptr assy_bufr, short *change));
extern int PDUprint_parts_list __PDU((struct PDUparts_list *head));
extern int PDUprint_assy_parts_list __PDU((struct PDUassy_parts_list *head));
extern int PDUadd_part_to_list __PDU((char *catalog, char *partid, char *revision, char *description, char *parttype, char *cofilename, char *cifilename, struct PDUparts_list **parts_list));
extern int PDUadd_part_to_assy_list __PDU((int level, int p_childno, int p_pchildno, char *catalog, char *partid, char *revision, struct PDUassy_parts_list **parts_list));
extern int PDUis_part_in_list __PDU((char *catalog, char *partid, char *revision, struct PDUparts_list *parts_list));
extern int PDUis_part_in_assy_list __PDU((int level, int p_childno, int p_pchildno, char *catalog, char *partid, char *revision, struct PDUassy_parts_list *parts_list));
extern int PDUcheck_parent_part_for_revise_assy __PDU((int mcf_row, int current_level, MEMptr assy_bufr));
extern int PDUfree_parts_list __PDU((struct PDUparts_list **list));
extern int PDUfree_assy_parts_list __PDU((struct PDUassy_parts_list **list));
extern int PDUassy_list_to_ASSY_BUFR __PDU((struct PDUrev_assy *list, MEMptr *buffer));
extern void PDUdelete_multiple_occurrences __PDU((char *catalog, char *partid, char *revision, int level, char *parent_cat, char *parent_part, char *parent_rev));
extern void PDUundelete_multiple_occurrences __PDU((char *catalog, char *partid, char *revision, int level, char *parent_cat, char *parent_part, char *parent_rev));
extern void PDUmark_deleted_parts_for_revise_assy __PDU((void));
extern int PDUprocess_rev_assy_form __PDU((MEMptr assy_bufr));
extern int PDUcopy_files_for_revise_assembly __PDU((char newfile_list[10 ][15 ], char exfile_list[10 ][15 ], int file_count));
extern int PDUcheck_assembly_for_file_creation __PDU((void));
extern int PDUcreate_copy_file_lists_for_rev_assy __PDU((char newfile_list[10 ][15 ], char exfile_list[10 ][15 ], int *file_count));
extern int PDUcheckout_part_for_revise_assembly __PDU((char *catalog, char *partid, char *revision, char *desc, char *filename, char *parttype));
extern int PDUcheck_usageid_for_rev_assy __PDU((struct PDUrev_assy *list, char *usageid));
extern int PDUcheck_alttag_for_rev_assy __PDU((struct PDUrev_assy *list, char *alttag));
extern int PDUng_place_part_for_revise_assembly __PDU((int start_row));
extern int PDUgenerate_rev_assy_data __PDU((int parent_level, int start_row));
extern void PDUcleanup_revise_assembly __PDU((void));
extern int PDUget_param_attrs_for_rev_assy __PDU((char *catalog, char *partid, char *revision));
extern int PDUupdate_AttrForm_function_value __PDU((void));
extern void PDUdelete_active_part_form __PDU((void));
extern int PDUadd_parts_to_assy_buffer __PDU((char *assy_catalog, char *assy_partid, char *assy_revision, MEMptr *buffer));
extern int PDUcompare_tagnos __PDU((MEMptr buffer1, MEMptr *buffer2));
extern int PDUcompare_childnos __PDU((MEMptr buffer1, MEMptr *buffer2));
extern int PDUcompare_usageids __PDU((MEMptr buffer1, MEMptr *buffer2));
extern int PDUadd_file_to_list __PDU((char *cofilename, struct PDUfile_list **file_list));
extern int PDUprint_file_linklist __PDU((struct PDUfile_list *head));
extern int PDUis_file_in_list __PDU((char *filename, struct PDUfile_list *file_list));
extern int PDUfree_file_list __PDU((struct PDUfile_list **list));
extern int PDUmodify_assembly_thru_OBJ2 __PDU((MEMptr assy_bufr));
extern int PDUprocess_parent_for_revise_assembly __PDU((int parent_row, int parent_level, MEMptr assy_bufr));
extern int PDUmodify_assembly_thru_database __PDU((int parent_row, int parent_level));
extern int PDUupdate_mult_files_for_rev_assy __PDU((char *field, char *value));
extern int PDUcreate_copy_buffer_for_rev_assy __PDU((MEMptr *file_bufr));

#if defined(__cplusplus)
}
#endif

#if defined(__STDC__) || defined(__cplusplus)
#ifndef __PDU
#define __PDU(args) args
#endif
#else
#ifndef __PDU
#define __PDU(args) ()
#endif
#endif

#if defined(__STDC__) || defined(__cplusplus)
#ifndef __PDU
#define __PDU(args) args
#endif
#else
#ifndef __PDU
#define __PDU(args) ()
#endif
#endif

#if defined(__STDC__) || defined(__cplusplus)
#ifndef __PDU
#define __PDU(args) args
#endif
#else
#ifndef __PDU
#define __PDU(args) ()
#endif
#endif

#if defined(__STDC__) || defined(__cplusplus)
#ifndef __PDU
#define __PDU(args) args
#endif
#else
#ifndef __PDU
#define __PDU(args) ()
#endif
#endif

#if defined(__STDC__) || defined(__cplusplus)
#ifndef __PDU
#define __PDU(args) args
#endif
#else
#ifndef __PDU
#define __PDU(args) ()
#endif
#endif

#endif
