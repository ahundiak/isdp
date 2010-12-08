#ifndef PDU_PARTS_PRO_H
#define PDU_PARTS_PRO_H

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

/* ./parts/PDUadd_part.c */
extern int PDUadd_part __PDU((void));
extern int PDUadd_part_to_project __PDU((void));
extern int PDUget_attachments_for_simmode_copy __PDU((void));
extern int PDUcheck_for_required_attributes __PDU((void));
extern int PDUcheck_for_required_attributes2 __PDU((void));

/* ./parts/PDUchg_part.c */
extern int PDUchange_part __PDU((void));
extern int PDUdelete_files __PDU((void));
extern int PDUdelete_part __PDU((void));
extern int PDUmulti_delete_part __PDU((void));
extern int PDUupdate_form_after_delete_part __PDU((void));
extern int PDUupdate_buffer_after_delete_part __PDU((void));
extern void PDUreset_part_form_after_delete_part __PDU((int ret_stat));
extern int PDUupdate_part_form_change_mode __PDU((void));

/* ./parts/PDUpart_form.c */
extern void PDUpart_operations_init __PDU((void));
extern int part_operations_notification_routine __PDU((int f_label, int g_label, double value, Form fp));
extern int PDUpart_form __PDU((void));
extern int PDUcancel_modify_part __PDU((void));
extern int PDUprocess_valid_catalog_status __PDU((int status));
extern void PDUreset_part_form_flags __PDU((void));
extern void PDUclose_part_form_buffers __PDU((void));

/* ./parts/PDUpart_oper.c */
extern int PDUep_proj_fld __PDU((void));
extern int PDUep_cat_fld __PDU((void));
extern int PDUep_part_fld __PDU((void));
extern int PDUep_rev_fld __PDU((void));
extern int PDUep_parttype_fld __PDU((void));
extern int PDUep_desc_fld __PDU((void));
extern int PDUep_parttype_btn __PDU((void));
extern int PDUep_rev_btn __PDU((void));
extern int PDUep_part_btn __PDU((void));
extern int PDUep_cat_btn __PDU((void));
extern int PDUep_proj_btn __PDU((void));
extern int PDUnp_proj_fld __PDU((void));
extern int PDUnp_cat_fld __PDU((void));
extern int PDUnp_part_fld __PDU((void));
extern int PDUnp_rev_fld __PDU((void));
extern int PDUnp_parttype_fld __PDU((void));
extern int PDUnp_desc_fld __PDU((void));
extern int PDUnp_proj_btn __PDU((void));
extern int PDUnp_cat_btn __PDU((void));
extern int PDUnp_part_btn __PDU((void));
extern int PDUnp_parttype_btn __PDU((void));
extern int PDUpull_pn_rev_pt __PDU((void));
extern int PDUpull_pt_desc __PDU((void));
extern int PDUpull_rev_pt_desc __PDU((void));
extern int PDUpull_bufr_info __PDU((void));
extern int PDUpull_bufr_info_for_np __PDU((void));
extern int PDUpart_in_project_test __PDU((void));
extern int PDUacl_workflow_btn __PDU((void));
extern int PDUstg_area_btn __PDU((void));
extern int PDUend_ep_part_fld __PDU((void));
extern int PDUend_ep_desc_fld __PDU((void));
extern int PDUend_stg_area_btn __PDU((void));
extern int PDUend_acl_wf_btn __PDU((void));
extern int PDUend_ep_proj_btn __PDU((void));
extern int PDUend_move_to_state_btn __PDU((void));
extern int PDUget_part_field_info __PDU((void));
extern void PDMcancel_modify __PDU((void));
extern int PDUupdate_part_form_after_select __PDU((void));
extern int PDUprocess_ep_catalog __PDU((void));
extern int PDUprocess_np_catalog __PDU((void));
extern int PDUprocess_ep_rev_btn __PDU((void));
extern int PDUpull_pt_desc_for_rev __PDU((void));
extern int PDUend_ep_rev_btn __PDU((void));
extern int PDUcheck_for_np_defaults __PDU((MEMptr data_bufr));
extern int PDUcheck_parttype_for_update __PDU((MEMptr attr_bufr));
extern void PDUcleanup_attr_retrieval __PDU((void));

/* ./parts/PDUpart_tls.c */
extern int PDUget_file_info_for_add_part __PDU((void));
extern int PDUextract_file_info __PDU((int row, int n_cofilenm_col, int n_cifilenm_col, int n_filetype_col, int p_filedesc_col));
extern int PDUprocess_catalog_parttype __PDU((void));
extern int PDUchange_file_permissions __PDU((char *file, mode_t mode));
extern int PDUverify_part_data __PDU((Form form));
extern void PDUdisable_gadgets_for_add_part __PDU((void));
extern void PDUenable_gadgets_after_add_part __PDU((void));
extern void PDUdisable_part_form_gadgets __PDU((void));
extern void PDUenable_part_form_gadgets __PDU((void));
extern void PDUdisable_gadgets_for_change_part __PDU((void));
extern void PDUenable_gadgets_after_change_part __PDU((void));
extern int PDUcheck_parttype_privileges __PDU((MEMptr attr_bufr, short *parttype_update, short *parttype_read, short *parttype_write));

/* ./parts/PDUpartsapi.c */
extern int PDUcheck_char __PDU((char *filename, char *spec_char));

/* ./parts/PDUseed_file.c */
extern void PDUseed_form_init __PDU((void));
extern int seed_form_notification_routine __PDU((int f_label, int g_label, double value, Form fp));
extern int PDUseed_form __PDU((void));
extern int PDUupdate_seed_form_after_select __PDU((void));
extern int PDUdelete_single_local_file __PDU((void));
extern int PDUautomatic_seed_file __PDU((void));

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
