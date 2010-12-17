	.file	"PDUparts.s"
#
# Begin stubs for:  PDUadd_part.o
#
	.data
.T1:	.byte	80, 100, 117, 0
	.byte	112, 100, 117, 47, 112, 97, 114, 116, 115, 0
	.align	4
.F1:	.long	0x00000700
	.byte	80, 68, 85, 97, 100, 100, 95, 112, 97, 114
	.byte	116, 46, 111, 0
	.text

	.globl	_PDUadd_part
_PDUadd_part:
	movw	$.T1,r2
	movw	$.F1,r3
	call	sp,Rload
	b	_PDUadd_part

	.globl	_PDUcheck_for_required_attributes
_PDUcheck_for_required_attributes:
	movw	$.T1,r2
	movw	$.F1,r3
	call	sp,Rload
	b	_PDUcheck_for_required_attributes

	.globl	_PDUadd_part_to_project
_PDUadd_part_to_project:
	movw	$.T1,r2
	movw	$.F1,r3
	call	sp,Rload
	b	_PDUadd_part_to_project

	.globl	_PDUget_attachments_for_simmode_copy
_PDUget_attachments_for_simmode_copy:
	movw	$.T1,r2
	movw	$.F1,r3
	call	sp,Rload
	b	_PDUget_attachments_for_simmode_copy

	.globl	_PDUcheck_for_required_attributes2
_PDUcheck_for_required_attributes2:
	movw	$.T1,r2
	movw	$.F1,r3
	call	sp,Rload
	b	_PDUcheck_for_required_attributes2
#
# Begin stubs for:  PDUpart_form.o
#
	.data
	.align	4
.F2:	.long	0x00000700
	.byte	80, 68, 85, 112, 97, 114, 116, 95, 102, 111
	.byte	114, 109, 46, 111, 0
	.text

	.globl	_PDUpart_operations_init
_PDUpart_operations_init:
	movw	$.T1,r2
	movw	$.F2,r3
	call	sp,Rload
	b	_PDUpart_operations_init

	.globl	_part_operations_notification_routine
_part_operations_notification_routine:
	movw	$.T1,r2
	movw	$.F2,r3
	call	sp,Rload
	b	_part_operations_notification_routine

	.globl	_PDUreset_part_form_flags
_PDUreset_part_form_flags:
	movw	$.T1,r2
	movw	$.F2,r3
	call	sp,Rload
	b	_PDUreset_part_form_flags

	.globl	_PDUclose_part_form_buffers
_PDUclose_part_form_buffers:
	movw	$.T1,r2
	movw	$.F2,r3
	call	sp,Rload
	b	_PDUclose_part_form_buffers

	.globl	_PDUprocess_valid_catalog_status
_PDUprocess_valid_catalog_status:
	movw	$.T1,r2
	movw	$.F2,r3
	call	sp,Rload
	b	_PDUprocess_valid_catalog_status

	.globl	_PDUpart_form
_PDUpart_form:
	movw	$.T1,r2
	movw	$.F2,r3
	call	sp,Rload
	b	_PDUpart_form

	.globl	_PDUcancel_modify_part
_PDUcancel_modify_part:
	movw	$.T1,r2
	movw	$.F2,r3
	call	sp,Rload
	b	_PDUcancel_modify_part
#
# Begin stubs for:  PDUpart_oper.o
#
	.data
	.align	4
.F3:	.long	0x00000700
	.byte	80, 68, 85, 112, 97, 114, 116, 95, 111, 112
	.byte	101, 114, 46, 111, 0
	.text

	.globl	_PDUep_proj_fld
_PDUep_proj_fld:
	movw	$.T1,r2
	movw	$.F3,r3
	call	sp,Rload
	b	_PDUep_proj_fld

	.globl	_PDUep_cat_fld
_PDUep_cat_fld:
	movw	$.T1,r2
	movw	$.F3,r3
	call	sp,Rload
	b	_PDUep_cat_fld

	.globl	_PDUprocess_ep_catalog
_PDUprocess_ep_catalog:
	movw	$.T1,r2
	movw	$.F3,r3
	call	sp,Rload
	b	_PDUprocess_ep_catalog

	.globl	_PDUep_part_fld
_PDUep_part_fld:
	movw	$.T1,r2
	movw	$.F3,r3
	call	sp,Rload
	b	_PDUep_part_fld

	.globl	_PDUpull_bufr_info
_PDUpull_bufr_info:
	movw	$.T1,r2
	movw	$.F3,r3
	call	sp,Rload
	b	_PDUpull_bufr_info

	.globl	_PDUprocess_ep_rev_btn
_PDUprocess_ep_rev_btn:
	movw	$.T1,r2
	movw	$.F3,r3
	call	sp,Rload
	b	_PDUprocess_ep_rev_btn

	.globl	_PDUpull_rev_pt_desc
_PDUpull_rev_pt_desc:
	movw	$.T1,r2
	movw	$.F3,r3
	call	sp,Rload
	b	_PDUpull_rev_pt_desc

	.globl	_PDUep_rev_fld
_PDUep_rev_fld:
	movw	$.T1,r2
	movw	$.F3,r3
	call	sp,Rload
	b	_PDUep_rev_fld

	.globl	_PDUpull_pt_desc
_PDUpull_pt_desc:
	movw	$.T1,r2
	movw	$.F3,r3
	call	sp,Rload
	b	_PDUpull_pt_desc

	.globl	_PDUep_parttype_fld
_PDUep_parttype_fld:
	movw	$.T1,r2
	movw	$.F3,r3
	call	sp,Rload
	b	_PDUep_parttype_fld

	.globl	_PDUep_desc_fld
_PDUep_desc_fld:
	movw	$.T1,r2
	movw	$.F3,r3
	call	sp,Rload
	b	_PDUep_desc_fld

	.globl	_PDUpull_pn_rev_pt
_PDUpull_pn_rev_pt:
	movw	$.T1,r2
	movw	$.F3,r3
	call	sp,Rload
	b	_PDUpull_pn_rev_pt

	.globl	_PDUep_parttype_btn
_PDUep_parttype_btn:
	movw	$.T1,r2
	movw	$.F3,r3
	call	sp,Rload
	b	_PDUep_parttype_btn

	.globl	_PDUep_rev_btn
_PDUep_rev_btn:
	movw	$.T1,r2
	movw	$.F3,r3
	call	sp,Rload
	b	_PDUep_rev_btn

	.globl	_PDUep_part_btn
_PDUep_part_btn:
	movw	$.T1,r2
	movw	$.F3,r3
	call	sp,Rload
	b	_PDUep_part_btn

	.globl	_PDUep_cat_btn
_PDUep_cat_btn:
	movw	$.T1,r2
	movw	$.F3,r3
	call	sp,Rload
	b	_PDUep_cat_btn

	.globl	_PDUep_proj_btn
_PDUep_proj_btn:
	movw	$.T1,r2
	movw	$.F3,r3
	call	sp,Rload
	b	_PDUep_proj_btn

	.globl	_PDUnp_proj_fld
_PDUnp_proj_fld:
	movw	$.T1,r2
	movw	$.F3,r3
	call	sp,Rload
	b	_PDUnp_proj_fld

	.globl	_PDUnp_cat_fld
_PDUnp_cat_fld:
	movw	$.T1,r2
	movw	$.F3,r3
	call	sp,Rload
	b	_PDUnp_cat_fld

	.globl	_PDUprocess_np_catalog
_PDUprocess_np_catalog:
	movw	$.T1,r2
	movw	$.F3,r3
	call	sp,Rload
	b	_PDUprocess_np_catalog

	.globl	_PDUnp_part_fld
_PDUnp_part_fld:
	movw	$.T1,r2
	movw	$.F3,r3
	call	sp,Rload
	b	_PDUnp_part_fld

	.globl	_PDUnp_rev_fld
_PDUnp_rev_fld:
	movw	$.T1,r2
	movw	$.F3,r3
	call	sp,Rload
	b	_PDUnp_rev_fld

	.globl	_PDUnp_parttype_fld
_PDUnp_parttype_fld:
	movw	$.T1,r2
	movw	$.F3,r3
	call	sp,Rload
	b	_PDUnp_parttype_fld

	.globl	_PDUnp_desc_fld
_PDUnp_desc_fld:
	movw	$.T1,r2
	movw	$.F3,r3
	call	sp,Rload
	b	_PDUnp_desc_fld

	.globl	_PDUnp_proj_btn
_PDUnp_proj_btn:
	movw	$.T1,r2
	movw	$.F3,r3
	call	sp,Rload
	b	_PDUnp_proj_btn

	.globl	_PDUnp_cat_btn
_PDUnp_cat_btn:
	movw	$.T1,r2
	movw	$.F3,r3
	call	sp,Rload
	b	_PDUnp_cat_btn

	.globl	_PDUnp_part_btn
_PDUnp_part_btn:
	movw	$.T1,r2
	movw	$.F3,r3
	call	sp,Rload
	b	_PDUnp_part_btn

	.globl	_PDUnp_parttype_btn
_PDUnp_parttype_btn:
	movw	$.T1,r2
	movw	$.F3,r3
	call	sp,Rload
	b	_PDUnp_parttype_btn

	.globl	_PDUcleanup_attr_retrieval
_PDUcleanup_attr_retrieval:
	movw	$.T1,r2
	movw	$.F3,r3
	call	sp,Rload
	b	_PDUcleanup_attr_retrieval

	.globl	_PDUpull_bufr_info_for_np
_PDUpull_bufr_info_for_np:
	movw	$.T1,r2
	movw	$.F3,r3
	call	sp,Rload
	b	_PDUpull_bufr_info_for_np

	.globl	_PDUpart_in_project_test
_PDUpart_in_project_test:
	movw	$.T1,r2
	movw	$.F3,r3
	call	sp,Rload
	b	_PDUpart_in_project_test

	.globl	_PDUacl_workflow_btn
_PDUacl_workflow_btn:
	movw	$.T1,r2
	movw	$.F3,r3
	call	sp,Rload
	b	_PDUacl_workflow_btn

	.globl	_PDUstg_area_btn
_PDUstg_area_btn:
	movw	$.T1,r2
	movw	$.F3,r3
	call	sp,Rload
	b	_PDUstg_area_btn

	.globl	_PDUend_ep_part_fld
_PDUend_ep_part_fld:
	movw	$.T1,r2
	movw	$.F3,r3
	call	sp,Rload
	b	_PDUend_ep_part_fld

	.globl	_PDUend_ep_desc_fld
_PDUend_ep_desc_fld:
	movw	$.T1,r2
	movw	$.F3,r3
	call	sp,Rload
	b	_PDUend_ep_desc_fld

	.globl	_PDUend_stg_area_btn
_PDUend_stg_area_btn:
	movw	$.T1,r2
	movw	$.F3,r3
	call	sp,Rload
	b	_PDUend_stg_area_btn

	.globl	_PDUend_acl_wf_btn
_PDUend_acl_wf_btn:
	movw	$.T1,r2
	movw	$.F3,r3
	call	sp,Rload
	b	_PDUend_acl_wf_btn

	.globl	_PDUend_ep_proj_btn
_PDUend_ep_proj_btn:
	movw	$.T1,r2
	movw	$.F3,r3
	call	sp,Rload
	b	_PDUend_ep_proj_btn

	.globl	_PDUend_move_to_state_btn
_PDUend_move_to_state_btn:
	movw	$.T1,r2
	movw	$.F3,r3
	call	sp,Rload
	b	_PDUend_move_to_state_btn

	.globl	_PDMcancel_modify
_PDMcancel_modify:
	movw	$.T1,r2
	movw	$.F3,r3
	call	sp,Rload
	b	_PDMcancel_modify

	.globl	_PDUget_part_field_info
_PDUget_part_field_info:
	movw	$.T1,r2
	movw	$.F3,r3
	call	sp,Rload
	b	_PDUget_part_field_info

	.globl	_PDUupdate_part_form_after_select
_PDUupdate_part_form_after_select:
	movw	$.T1,r2
	movw	$.F3,r3
	call	sp,Rload
	b	_PDUupdate_part_form_after_select

	.globl	_PDUcheck_for_np_defaults
_PDUcheck_for_np_defaults:
	movw	$.T1,r2
	movw	$.F3,r3
	call	sp,Rload
	b	_PDUcheck_for_np_defaults

	.globl	_PDUpull_pt_desc_for_rev
_PDUpull_pt_desc_for_rev:
	movw	$.T1,r2
	movw	$.F3,r3
	call	sp,Rload
	b	_PDUpull_pt_desc_for_rev

	.globl	_PDUend_ep_rev_btn
_PDUend_ep_rev_btn:
	movw	$.T1,r2
	movw	$.F3,r3
	call	sp,Rload
	b	_PDUend_ep_rev_btn

	.globl	_PDUcheck_parttype_for_update
_PDUcheck_parttype_for_update:
	movw	$.T1,r2
	movw	$.F3,r3
	call	sp,Rload
	b	_PDUcheck_parttype_for_update
#
# Begin stubs for:  PDUchg_part.o
#
	.data
	.align	4
.F4:	.long	0x00000700
	.byte	80, 68, 85, 99, 104, 103, 95, 112, 97, 114
	.byte	116, 46, 111, 0
	.text

	.globl	_PDUchange_part
_PDUchange_part:
	movw	$.T1,r2
	movw	$.F4,r3
	call	sp,Rload
	b	_PDUchange_part

	.globl	_PDUupdate_part_form_change_mode
_PDUupdate_part_form_change_mode:
	movw	$.T1,r2
	movw	$.F4,r3
	call	sp,Rload
	b	_PDUupdate_part_form_change_mode

	.globl	_PDUdelete_files
_PDUdelete_files:
	movw	$.T1,r2
	movw	$.F4,r3
	call	sp,Rload
	b	_PDUdelete_files

	.globl	_PDUdelete_part
_PDUdelete_part:
	movw	$.T1,r2
	movw	$.F4,r3
	call	sp,Rload
	b	_PDUdelete_part

	.globl	_PDUreset_part_form_after_delete_part
_PDUreset_part_form_after_delete_part:
	movw	$.T1,r2
	movw	$.F4,r3
	call	sp,Rload
	b	_PDUreset_part_form_after_delete_part

	.globl	_PDUmulti_delete_part
_PDUmulti_delete_part:
	movw	$.T1,r2
	movw	$.F4,r3
	call	sp,Rload
	b	_PDUmulti_delete_part

	.globl	_PDUupdate_form_after_delete_part
_PDUupdate_form_after_delete_part:
	movw	$.T1,r2
	movw	$.F4,r3
	call	sp,Rload
	b	_PDUupdate_form_after_delete_part

	.globl	_PDUupdate_buffer_after_delete_part
_PDUupdate_buffer_after_delete_part:
	movw	$.T1,r2
	movw	$.F4,r3
	call	sp,Rload
	b	_PDUupdate_buffer_after_delete_part
#
# Begin stubs for:  PDUseed_file.o
#
	.data
	.align	4
.F5:	.long	0x00000700
	.byte	80, 68, 85, 115, 101, 101, 100, 95, 102, 105
	.byte	108, 101, 46, 111, 0
	.text

	.globl	_PDUseed_form_init
_PDUseed_form_init:
	movw	$.T1,r2
	movw	$.F5,r3
	call	sp,Rload
	b	_PDUseed_form_init

	.globl	_seed_form_notification_routine
_seed_form_notification_routine:
	movw	$.T1,r2
	movw	$.F5,r3
	call	sp,Rload
	b	_seed_form_notification_routine

	.globl	_PDUdelete_single_local_file
_PDUdelete_single_local_file:
	movw	$.T1,r2
	movw	$.F5,r3
	call	sp,Rload
	b	_PDUdelete_single_local_file

	.globl	_PDUseed_form
_PDUseed_form:
	movw	$.T1,r2
	movw	$.F5,r3
	call	sp,Rload
	b	_PDUseed_form

	.globl	_PDUupdate_seed_form_after_select
_PDUupdate_seed_form_after_select:
	movw	$.T1,r2
	movw	$.F5,r3
	call	sp,Rload
	b	_PDUupdate_seed_form_after_select

	.globl	_PDUautomatic_seed_file
_PDUautomatic_seed_file:
	movw	$.T1,r2
	movw	$.F5,r3
	call	sp,Rload
	b	_PDUautomatic_seed_file
#
# Begin stubs for:  PDUpart_tls.o
#
	.data
	.align	4
.F6:	.long	0x00000700
	.byte	80, 68, 85, 112, 97, 114, 116, 95, 116, 108
	.byte	115, 46, 111, 0
	.text

	.globl	_PDUget_file_info_for_add_part
_PDUget_file_info_for_add_part:
	movw	$.T1,r2
	movw	$.F6,r3
	call	sp,Rload
	b	_PDUget_file_info_for_add_part

	.globl	_PDUextract_file_info
_PDUextract_file_info:
	movw	$.T1,r2
	movw	$.F6,r3
	call	sp,Rload
	b	_PDUextract_file_info

	.globl	_PDUchange_file_permissions
_PDUchange_file_permissions:
	movw	$.T1,r2
	movw	$.F6,r3
	call	sp,Rload
	b	_PDUchange_file_permissions

	.globl	_PDUprocess_catalog_parttype
_PDUprocess_catalog_parttype:
	movw	$.T1,r2
	movw	$.F6,r3
	call	sp,Rload
	b	_PDUprocess_catalog_parttype

	.globl	_PDUverify_part_data
_PDUverify_part_data:
	movw	$.T1,r2
	movw	$.F6,r3
	call	sp,Rload
	b	_PDUverify_part_data

	.globl	_PDUdisable_gadgets_for_add_part
_PDUdisable_gadgets_for_add_part:
	movw	$.T1,r2
	movw	$.F6,r3
	call	sp,Rload
	b	_PDUdisable_gadgets_for_add_part

	.globl	_PDUenable_gadgets_after_add_part
_PDUenable_gadgets_after_add_part:
	movw	$.T1,r2
	movw	$.F6,r3
	call	sp,Rload
	b	_PDUenable_gadgets_after_add_part

	.globl	_PDUdisable_part_form_gadgets
_PDUdisable_part_form_gadgets:
	movw	$.T1,r2
	movw	$.F6,r3
	call	sp,Rload
	b	_PDUdisable_part_form_gadgets

	.globl	_PDUenable_part_form_gadgets
_PDUenable_part_form_gadgets:
	movw	$.T1,r2
	movw	$.F6,r3
	call	sp,Rload
	b	_PDUenable_part_form_gadgets

	.globl	_PDUdisable_gadgets_for_change_part
_PDUdisable_gadgets_for_change_part:
	movw	$.T1,r2
	movw	$.F6,r3
	call	sp,Rload
	b	_PDUdisable_gadgets_for_change_part

	.globl	_PDUenable_gadgets_after_change_part
_PDUenable_gadgets_after_change_part:
	movw	$.T1,r2
	movw	$.F6,r3
	call	sp,Rload
	b	_PDUenable_gadgets_after_change_part

	.globl	_PDUcheck_parttype_privileges
_PDUcheck_parttype_privileges:
	movw	$.T1,r2
	movw	$.F6,r3
	call	sp,Rload
	b	_PDUcheck_parttype_privileges
#
# Begin stubs for:  PDUpartsapi.o
#
	.data
	.align	4
.F7:	.long	0x00000700
	.byte	80, 68, 85, 112, 97, 114, 116, 115, 97, 112
	.byte	105, 46, 111, 0
	.text

	.globl	_PDUcheck_char
_PDUcheck_char:
	movw	$.T1,r2
	movw	$.F7,r3
	call	sp,Rload
	b	_PDUcheck_char

	.globl	_PDUep_parttype_fld
	.globl	_PDUnp_parttype_fld
	.globl	_PDU_attr_name
	.globl	_PDU_save_revision
	.globl	_PDUdelete_from_stack
	.globl	_workflow_flag
	.globl	_PDUis_file_open
	.globl	_Help_topic
	.globl	_ep_rev_btn_flag
	.globl	_np_catalog
	.globl	_pdu_ep_stg_bufr_flag
	.globl	_PDU_save_act_partid
	.globl	_end_np_parttype_btn_flag
	.globl	_PDMget_existing_data
	.globl	_PDU_part_frm_search_bufr
	.globl	_part_operations_created
	.globl	_PDU_disable_filetype_col
	.globl	_PDUenable_gadgets_after_add_part
	.globl	_FIf_erase
	.globl	_checked_in
	.globl	_PDUunlock_item
	.globl	_PDMdelete_files
	.globl	_pdu_hold_stg_bufr_flag
	.globl	_PDUdelete_current_state_from_states_buffer
	.globl	_PDUmcf_list_form
	.globl	_end_ep_desc_btn_flag
	.globl	_PDUcheck_parttype_privileges
	.globl	_end_ep_desc_fld_flag
	.globl	_MEMopen
	.globl	_PDU_parts_index
	.globl	_PDU_file_data_bufr
	.globl	_PDUenable_gadgets_after_change_part
	.globl	_change_mode
	.globl	_strcpy
	.globl	_close
	.globl	_user
	.globl	_bufr_flag
	.globl	_execlp
	.globl	_PDUprepare_queue
	.globl	_execl
	.globl	_PDUcheck_for_required_attributes
	.globl	_PDU_disable_filedesc_col
	.globl	_PDMcheck_partnum_without_rev
	.globl	_PDUpull_bufr_info_for_np
	.globl	_FIf_set_location
	.globl	_PDUnp_proj_fld
	.globl	_PDU_data_bufr
	.globl	_FImcf_get_select
	.globl	_change_stat
	.globl	_PDUep_proj_fld
	.globl	_PDUvalid_filename
	.globl	_PDM_debug_on
	.globl	_PDUvalid_catalog
	.globl	_PDU_list_bufr
	.globl	_PDUnp_part_btn
	.globl	_PDUget_part_from_desc
	.globl	_PDUep_part_btn
	.globl	_SelectOrPlacePart
	.globl	_all_flag
	.globl	_PDUnew_mode
	.globl	_FIg_set_state_off
	.globl	_PDMget_pt_desc
	.globl	_PDU_acl_bufr
	.globl	_PDUvalidate_data_value
	.globl	_PDUprocess_pulldown_list
	.globl	_states_bufr
	.globl	_PDU_form_id
	.globl	_user_seed_file
	.globl	_PDUpull_from_bufr
	.globl	_PDU_display_buffer
	.globl	_np_cat_btn_flag
	.globl	_PDU_add_data_bufr
	.globl	_PDUfinish_activate
	.globl	_PDMcheck_delete_part
	.globl	_PDUenable_part_form_gadgets
	.globl	_malloc
	.globl	_PDMget_assembly_structure
	.globl	_PDUget_top_of_stack
	.globl	_ep_parttype
	.globl	_FIfld_set_max_num_rows
	.globl	_PDMget_part_data
	.globl	_PDUep_cat_fld
	.globl	_PDMrcheck_part_status
	.globl	_PDUnp_cat_fld
	.globl	_free
	.globl	_FIfld_delete_rows
	.globl	_FImcf_get_active_col
	.globl	_MEMwrite
	.globl	_PDU_ep_data_bufr
	.globl	_PDUsetup_buffer_list
	.globl	_search_str
	.globl	_PDUcreate_class_and_catalog_bufr
	.globl	_PDU_search_type
	.globl	_FIfld_get_select
	.globl	_PDUsimilar_mode
	.globl	_end_ep_rev_btn_flag
	.globl	_PDUprint_stack
	.globl	_PDUstg_area_btn
	.globl	_en_itemname
	.globl	_pdu_hold_acl_bufr_flag
	.globl	_PDU_filetype_newfiles_disable
	.globl	_end_stg_area_btn_flag
	.globl	_PDU_save_filename
	.globl	_PDUprocess_ex_file_form_after_seed_file
	.globl	_PDMquery_catalog_type
	.globl	_PDMpart_in_project
	.globl	_FImcf_set_attr
	.globl	_PDU_never_checked_in
	.globl	_PDUvalid_desc
	.globl	_PDU_ep_bufr
	.globl	_PDUupdate_part_form_change_mode
	.globl	_PDMscopy
	.globl	_PDMrcheck_dup_sa_fname
	.globl	_end_ep_parttype_btn_flag
	.globl	_PDUfind_attr_in_buffer
	.globl	_mode_change_flag
	.globl	_PDMget_trans
	.globl	_PDU_save_parttype
	.globl	_PDUsetup_struct_fields
	.globl	_PDMparts_listing
	.globl	_PDMproject_catalog_listing
	.globl	_FIg_display
	.globl	_PDMrmodify_part
	.globl	_FIf_new
	.globl	_PDUmessage_trans
	.globl	_PDMadd_part_to_project
	.globl	_PDUtranslate_message_and_vars
	.globl	_np_rev
	.globl	_dup
	.globl	_stat
	.globl	__iob
	.globl	_PDU_simmode_checkin
	.globl	_PDMcancel_modify
	.globl	_PDU_value_pulldown
	.globl	_PDU_selected_rows
	.globl	_PDU_cat_class_bufr
	.globl	_PDUdelete_local_files
	.globl	_ep_desc_flag
	.globl	_PDUep_parttype_btn
	.globl	_PDUnp_parttype_btn
	.globl	_end_ep_part_fld_flag
	.globl	_ModifyPartForm
	.globl	_PDUlist_pgn_bufr
	.globl	_no_headings
	.globl	_MEMwrite_format
	.globl	_enter_part
	.globl	_PDUlist_dmgn_bufr
	.globl	_PDMget_filenames
	.globl	_PDUchange_mode
	.globl	_PDU_read_only_file
	.globl	_PDUacl_workflow_btn
	.globl	_PDU_data_row
	.globl	_exitdel
	.globl	_PDMdebug_on
	.globl	_PDU_DEBUG_FILE
	.globl	_PDUinitialize_help
	.globl	_PDU_command
	.globl	_PDMget_table_attributes
	.globl	_similar_mode
	.globl	_FImcf_get_attr
	.globl	_PDUpull_bufr_info
	.globl	_PDUget_col_number
	.globl	_NFMRtic_it
	.globl	_FIg_set_state_on
	.globl	_PDU_storagefn_newfiles_disable
	.globl	_end_acl_wf_btn_flag
	.globl	_PDU_filedesc_newfiles_disable
	.globl	_MEMsplit_copy_buffer
	.globl	_PDUnp_proj_btn
	.globl	_PDUep_proj_btn
	.globl	_PDUadd_buffer_string
	.globl	_PDU_save_act_parttype
	.globl	_MEMreset_buffer_no
	.globl	_PDUnp_part_fld
	.globl	_PDUcheck_file_commands
	.globl	_PDUep_part_fld
	.globl	_end_np_part_btn_flag
	.globl	_PDU_simmode_copy
	.globl	_PDUget_buffer_col
	.globl	_PDUsamecat_defaults
	.globl	_part_operations_displayed
	.globl	_FIf_cvrt_to_perm_win
	.globl	_strlen
	.globl	_PDU_calling_form
	.globl	_PDU_attr_bufr
	.globl	_PDU_save_project
	.globl	_strcat
	.globl	_end_np_cat_btn_flag
	.globl	_PDUclass_cat_list_form
	.globl	_PDU_form_type
	.globl	_place_part_f
	.globl	_GRdelete_pull_down_list
	.globl	_FIfld_set_mode
	.globl	_PDU_localfn_newfiles_disable
	.globl	_np_project
	.globl	__pdm_status
	.globl	_PDUsingle_list_form
	.globl	_PDUget_exnuc_path
	.globl	_np_desc
	.globl	_PDUdisable_gadgets_for_change_part
	.globl	_change_files_flag
	.globl	_PDU_save_description
	.globl	_review_mode
	.globl	_PDUnp_cat_btn
	.globl	_PDMquery_classification
	.globl	_PDUep_cat_btn
	.globl	_PDU_part_flagged
	.globl	_PDUprocess_catalog_parttype
	.globl	_strcmp
	.globl	_UI_prompt
	.globl	_PDMrget_imm_parents
	.globl	_sleep
	.globl	_FIfld_set_active_row
	.globl	_forms
	.globl	_add_files_flag
	.globl	_pt_flag
	.globl	_PDUcreate_file_buffer_from_refresh
	.globl	_PDUdismiss_subforms
	.globl	_PDU_save_act_description
	.globl	_FIg_disable
	.globl	_strstr
	.globl	_memset
	.globl	_FIfld_pos_cursor
	.globl	_PDUsetup_popup_list
	.globl	_end_move_to_state_btn_flag
	.globl	_PDU_hold_bufr
	.globl	_FIg_set_text
	.globl	_ep_catalog
	.globl	_FIfld_get_num_rows
	.globl	_PDUcheck_if_graphic
	.globl	_FIg_erase
	.globl	_PDUget_file_status
	.globl	_PDUreports_form
	.globl	_change_part
	.globl	_PDUsetup_single_buffer
	.globl	_PDU_files_deleted
	.globl	_PDU_disable_storagefn_col
	.globl	_atoi
	.globl	_pdu_ep_acl_bufr_flag
	.globl	_PDUload_exec_structure
	.globl	_vfork
	.globl	_PDUmake_transition
	.globl	_sscanf
	.globl	_PDMradd_part
	.globl	_PDU_ep_stg_bufr
	.globl	_PDU_value_list
	.globl	_PDUfill_in_string1
	.globl	_PDU_gadget_labels
	.globl	_pipe
	.globl	_PDMcancel_modify_part
	.globl	_PDU_disable_move_state_btn
	.globl	_PDMopen_buffer
	.globl	_PDU_copyof_ret_bufr
	.globl	_PDUverify_part_data
	.globl	_PDU_states_bufr
	.globl	_new_mode
	.globl	_PDUep_rev_fld
	.globl	_PDUnp_rev_fld
	.globl	_MEMbuild_array
	.globl	_PDUfill_in_string
	.globl	_FIf_delete
	.globl	_PDUformat_classification_buffer
	.globl	_new_file
	.globl	_seed_form_created
	.globl	_PDU_save_partid
	.globl	_MEMclose
	.globl	_PDUfind_attr_by_synonym
	.globl	_PDMset_to_state
	.globl	_PDU_list_filenames
	.globl	_PDUcheck_for_np_defaults
	.globl	_PDUvalid_project
	.globl	_single_flag
	.globl	_PDUreview_mode
	.globl	_PDU_sav_file_data_bufr
	.globl	_PDUpull_pt_desc
	.globl	_existing_file
	.globl	_FIfld_set_num_rows
	.globl	_PDU_ep_acl_bufr
	.globl	_PDU_parts_list_bufr
	.globl	_PDUvalid_rev
	.globl	_FIfld_set_num_vis_rows
	.globl	_PDU_delete_files
	.globl	_PDU_class_level
	.globl	_PDUep_rev_btn
	.globl	_acl_flag
	.globl	_refresh
	.globl	_PDUdelete_single_local_file
	.globl	_ep_rev
	.globl	_ep_part_btn_flag
	.globl	_PDU_ret_bufr
	.globl	_FIg_set_state
	.globl	_FIfld_get_text
	.globl	_PDU_template_catalog
	.globl	_PDUpush_into_stack
	.globl	_PDUfree_string_array
	.globl	_PDMcopy_attach
	.globl	__pdm_debug
	.globl	_MEMwrite_data
	.globl	_FIg_get_state
	.globl	_PDUconvert_file_for_similar_mode
	.globl	_sprintf
	.globl	_PDMcatalog_list
	.globl	_unlink
	.globl	_FIg_enable
	.globl	_FImcf_set_select
	.globl	_PDUsetup_buffer
	.globl	_nn_itemname
	.globl	_PDUcheck_partnum
	.globl	_PDUget_keyin
	.globl	_PDUget_file_info_for_add_part
	.globl	_end_ep_cat_btn_flag
	.globl	_PDUverify_file
	.globl	_ep_part_fld_flag
	.globl	_PDUcheck_char
	.globl	_FIfld_get_text_length
	.globl	_FIfld_get_active_row
	.globl	_PDUparametric_part_form
	.globl	_GRcreate_pull_down_list
	.globl	_strrchr
	.globl	_PDU_check_file_refresh
	.globl	_PDUcheck_file_info_privileges
	.globl	_FIg_activate
	.globl	_PDMget_add_buffer
	.globl	_PDUfree_string
	.globl	_PDU_refresh_gadgets
	.globl	_PDU_hold_stg_bufr
	.globl	_PDUmessage
	.globl	_PDMrev_listing
	.globl	_FIf_display
	.globl	_np_parttype
	.globl	_PDUpull_when_diff
	.globl	_PDUformat_buffer
	.globl	_PDU_save_act_filename
	.globl	_add_data_bufr
	.globl	_PDUvalid_partnum
	.globl	_PDUdisable_part_form_gadgets
	.globl	_PDUtranslate_message
	.globl	_FIg_reset
	.globl	_PDU_part_checked_in
	.globl	_PDUget_part_field_info
	.globl	_PDU_mcf_list
	.globl	_MEMprint_buffer
	.globl	_seed_form_displayed
	.globl	_MEMprint_buffers
	.globl	_PDU_update_struct
	.globl	_FIfld_set_text
	.globl	_PDU_list_cat
	.globl	_PDU_add_files
	.globl	_PDU_stack
	.globl	_FImcf_set_active_col
	.globl	_headings
	.globl	_PDU_multiple_revs
	.globl	_PDU_file_list
	.globl	_ep_project
	.globl	_FIfld_set_select
	.globl	_PDUcheck_file_permissions
	.globl	_PDMrdelete_part
	.globl	_PDU_save_act_revision
	.globl	_ep_desc
	.globl	_PDU_hold_acl_bufr
	.globl	_PDU_simmode_cat_bufr
	.globl	_PDU_active_button
	.globl	_PDU_save_catalog
	.globl	_PDU_design_parts_bufr
	.globl	_PDU_stg_bufr
	.globl	_end_ep_proj_btn_flag
	.globl	_PDU_disable_localfn_col
	.globl	_PDUrefresh_local_files_form
	.globl	_end_ep_part_btn_flag
	.globl	_PDUremove_data
	.globl	_PDUsetup_form_fields
	.globl	_PDUdisable_gadgets_for_add_part
	.globl	_PDUchmod
	.globl	_waitpid
	.globl	_PDU_save_act_catalog
	.globl	_PDUnp_desc_fld
	.globl	_PDUep_desc_fld
	.globl	_new_part_flag
