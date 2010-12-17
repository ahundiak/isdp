#ifndef PDU_PROTO_H
#define PDU_PROTO_H

#if defined(__STDC__) || defined(__cplusplus)
# define __PDU(s) s
#else
# define __PDU(s) ()
#endif


/* ./parts/PDUadd_part.c */
extern int PDUadd_part __PDU((void));
extern int PDUadd_part_to_project __PDU((void));

/* ./parts/PDUchg_part.c */
extern int PDUchange_part __PDU((void));
extern int PDUdelete_files __PDU((void));
extern int PDUdelete_part __PDU((void));

/* ./parts/PDUpart_form.c */
extern void PDUpart_operations_init __PDU((void));
extern int part_operations_notification_routine __PDU((int f_label, int g_label, double value, Form fp));
extern int PDUpart_form __PDU((void));
extern int PDUcancel_modify_part __PDU((void));

/* ./parts/PDUpart_oper.c */
extern int PDUep_proj_fld __PDU((void));
extern int PDUep_cat_fld __PDU((void));
extern int PDUep_part_fld __PDU((void));
extern int PDUep_rev_fld __PDU((void));
extern int PDUep_parttype_fld __PDU((void));
extern int PDUep_desc_fld __PDU((void));
extern int PDUep_desc_btn __PDU((void));
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
extern int PDUcheck_char __PDU((char *filename, char *spec_char));

/* ./parts/PDUseed_file.c */
extern void PDUseed_form_init __PDU((void));
extern int seed_form_notification_routine __PDU((int f_label, int g_label, double value, Form fp));
extern int PDUseed_form __PDU((void));
extern int PDUupdate_seed_form_after_select __PDU((void));
extern int PDUdelete_single_local_file __PDU((void));

#undef __PDU
#if defined(__STDC__) || defined(__cplusplus)
# define __PDU(s) s
#else
# define __PDU(s) ()
#endif

#if defined(__STDC__) || defined(__cplusplus)
# define __PDU(s) s
#else
# define __PDU(s) ()
#endif

#if defined(__STDC__) || defined(__cplusplus)
# define __PDU(s) s
#else
# define __PDU(s) ()
#endif

#endif
