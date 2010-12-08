#ifndef PDM_PARTS_PRO
#define PDM_PARTS_PRO

#if defined(__STDC__) || defined(__cplusplus)
# define __PDM(s) s
#else
# define __PDM(s) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./parts/PDUadd_part.c */
extern int PDUadd_part __PDM((void));
extern int PDUadd_part_to_project __PDM((void));

/* ./parts/PDUchg_part.c */
extern int PDUchange_part __PDM((void));
extern int PDUdelete_files __PDM((void));
extern int PDUdelete_part __PDM((void));

/* ./parts/PDUpart_form.c */
extern void PDUpart_operations_init __PDM((void));
extern void part_operations_notification_routine __PDM((int f_label, int g_label, double value, Form fp));
extern int PDUpart_form __PDM((void));
extern int PDUcancel_modify_part __PDM((void));

/* ./parts/PDUpart_oper.c */
extern int PDUep_proj_fld __PDM((void));
extern int PDUep_cat_fld __PDM((void));
extern int PDUep_part_fld __PDM((void));
extern int PDUep_rev_fld __PDM((void));
extern int PDUep_parttype_fld __PDM((void));
extern int PDUep_desc_fld __PDM((void));
extern int PDUep_desc_btn __PDM((void));
extern int PDUep_parttype_btn __PDM((void));
extern int PDUep_rev_btn __PDM((void));
extern int PDUep_part_btn __PDM((void));
extern int PDUep_cat_btn __PDM((void));
extern int PDUep_proj_btn __PDM((void));
extern int PDUnp_proj_fld __PDM((void));
extern int PDUnp_cat_fld __PDM((void));
extern int PDUnp_part_fld __PDM((void));
extern int PDUnp_rev_fld __PDM((void));
extern int PDUnp_parttype_fld __PDM((void));
extern int PDUnp_desc_fld __PDM((void));
extern int PDUnp_proj_btn __PDM((void));
extern int PDUnp_cat_btn __PDM((void));
extern int PDUnp_part_btn __PDM((void));
extern int PDUnp_parttype_btn __PDM((void));
extern int PDUpull_pn_rev_pt __PDM((void));
extern int PDUpull_pt_desc __PDM((void));
extern int PDUpull_rev_pt_desc __PDM((void));
extern int PDUpull_bufr_info __PDM((void));
extern int PDUpull_bufr_info_for_np __PDM((void));
extern int PDUpart_in_project_test __PDM((void));
extern int PDUacl_workflow_btn __PDM((void));
extern int PDUstg_area_btn __PDM((void));
extern int PDUend_ep_part_fld __PDM((void));
extern int PDUend_ep_desc_fld __PDM((void));
extern int PDUend_stg_area_btn __PDM((void));
extern int PDUend_acl_wf_btn __PDM((void));
extern int PDUend_ep_proj_btn __PDM((void));
extern int PDUend_move_to_state_btn __PDM((void));
extern int PDUget_part_field_info __PDM((void));
extern void PDMcancel_modify __PDM((void));
extern int PDUupdate_part_form_after_select __PDM((void));
extern int PDUcheck_char __PDM((char *filename, char *spec_char));

/* ./parts/PDUseed_file.c */
extern void PDUseed_form_init __PDM((void));
extern void seed_form_notification_routine __PDM((int f_label, int g_label, double value, Form fp));
extern int PDUseed_form __PDM((void));
extern int PDUupdate_seed_form_after_select __PDM((void));
extern int PDUdelete_single_local_file __PDM((char *catalog, char *partnum, char *rev, char *seed_file, char seed_file_path[80 ]));

#if defined(__cplusplus)
}
#endif

#endif
