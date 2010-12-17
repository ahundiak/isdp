	.file	"PDUreports.s"
#
# Begin stubs for:  PDUsort_name.o
#
	.data
.T1:	.byte	80, 100, 117, 0
	.byte	112, 100, 117, 47, 114, 101, 112, 111, 114, 116
	.byte	115, 0
	.align	4
.F1:	.long	0x00000700
	.byte	80, 68, 85, 115, 111, 114, 116, 95, 110, 97
	.byte	109, 101, 46, 111, 0
	.text

	.globl	_PDUget_loc_sort_names
_PDUget_loc_sort_names:
	movw	$.T1,r2
	movw	$.F1,r3
	call	sp,Rload
	b	_PDUget_loc_sort_names

	.globl	_PDUget_cat_sort_names
_PDUget_cat_sort_names:
	movw	$.T1,r2
	movw	$.F1,r3
	call	sp,Rload
	b	_PDUget_cat_sort_names
#
# Begin stubs for:  PDUcrt_buff.o
#
	.data
	.align	4
.F2:	.long	0x00000700
	.byte	80, 68, 85, 99, 114, 116, 95, 98, 117, 102
	.byte	102, 46, 111, 0
	.text

	.globl	_PDUcreate_table_group_search_sort_buffers
_PDUcreate_table_group_search_sort_buffers:
	movw	$.T1,r2
	movw	$.F2,r3
	call	sp,Rload
	b	_PDUcreate_table_group_search_sort_buffers
#
# Begin stubs for:  PDUdef_crit.o
#
	.data
	.align	4
.F3:	.long	0x00000700
	.byte	80, 68, 85, 100, 101, 102, 95, 99, 114, 105
	.byte	116, 46, 111, 0
	.text

	.globl	_PDUdefine_criteria_string
_PDUdefine_criteria_string:
	movw	$.T1,r2
	movw	$.F3,r3
	call	sp,Rload
	b	_PDUdefine_criteria_string
#
# Begin stubs for:  PDUsrchname.o
#
	.data
	.align	4
.F4:	.long	0x00000700
	.byte	80, 68, 85, 115, 114, 99, 104, 110, 97, 109
	.byte	101, 46, 111, 0
	.text

	.globl	_PDUget_cat_search_names
_PDUget_cat_search_names:
	movw	$.T1,r2
	movw	$.F4,r3
	call	sp,Rload
	b	_PDUget_cat_search_names

	.globl	_PDUget_loc_search_names
_PDUget_loc_search_names:
	movw	$.T1,r2
	movw	$.F4,r3
	call	sp,Rload
	b	_PDUget_loc_search_names

	.globl	_PDUget_search_criteria_names
_PDUget_search_criteria_names:
	movw	$.T1,r2
	movw	$.F4,r3
	call	sp,Rload
	b	_PDUget_search_criteria_names
#
# Begin stubs for:  PDUget_strin.o
#
	.data
	.align	4
.F5:	.long	0x00000700
	.byte	80, 68, 85, 103, 101, 116, 95, 115, 116, 114
	.byte	105, 110, 46, 111, 0
	.text

	.globl	_PDUget_criteria_string
_PDUget_criteria_string:
	movw	$.T1,r2
	movw	$.F5,r3
	call	sp,Rload
	b	_PDUget_criteria_string
#
# Begin stubs for:  PDUsearch.o
#
	.data
	.align	4
.F6:	.long	0x00000700
	.byte	80, 68, 85, 115, 101, 97, 114, 99, 104, 46
	.byte	111, 0
	.text

	.globl	_PDUsearch_on_off
_PDUsearch_on_off:
	movw	$.T1,r2
	movw	$.F6,r3
	call	sp,Rload
	b	_PDUsearch_on_off
#
# Begin stubs for:  PDUdef_sort.o
#
	.data
	.align	4
.F7:	.long	0x00000700
	.byte	80, 68, 85, 100, 101, 102, 95, 115, 111, 114
	.byte	116, 46, 111, 0
	.text

	.globl	_PDUsort_criteria_on_off
_PDUsort_criteria_on_off:
	movw	$.T1,r2
	movw	$.F7,r3
	call	sp,Rload
	b	_PDUsort_criteria_on_off
#
# Begin stubs for:  PDUlist_rpts.o
#
	.data
	.align	4
.F8:	.long	0x00000700
	.byte	80, 68, 85, 108, 105, 115, 116, 95, 114, 112
	.byte	116, 115, 46, 111, 0
	.text

	.globl	_PDUlist_reports
_PDUlist_reports:
	movw	$.T1,r2
	movw	$.F8,r3
	call	sp,Rload
	b	_PDUlist_reports

	.globl	_PDUlist_report_buffer
_PDUlist_report_buffer:
	movw	$.T1,r2
	movw	$.F8,r3
	call	sp,Rload
	b	_PDUlist_report_buffer
#
# Begin stubs for:  PDUsetup_def.o
#
	.data
	.align	4
.F9:	.long	0x00000700
	.byte	80, 68, 85, 115, 101, 116, 117, 112, 95, 100
	.byte	101, 102, 46, 111, 0
	.text

	.globl	_PDUsetup_report_definition
_PDUsetup_report_definition:
	movw	$.T1,r2
	movw	$.F9,r3
	call	sp,Rload
	b	_PDUsetup_report_definition
#
# Begin stubs for:  PDUrpt_form.o
#
	.data
	.align	4
.F10:	.long	0x00000700
	.byte	80, 68, 85, 114, 112, 116, 95, 102, 111, 114
	.byte	109, 46, 111, 0
	.text

	.globl	_reports_notification_routine
_reports_notification_routine:
	movw	$.T1,r2
	movw	$.F10,r3
	call	sp,Rload
	b	_reports_notification_routine

	.globl	_PDUget_templatetype
_PDUget_templatetype:
	movw	$.T1,r2
	movw	$.F10,r3
	call	sp,Rload
	b	_PDUget_templatetype

	.globl	_PDUcheck_reportname
_PDUcheck_reportname:
	movw	$.T1,r2
	movw	$.F10,r3
	call	sp,Rload
	b	_PDUcheck_reportname

	.globl	_PDUcheck_output_filename
_PDUcheck_output_filename:
	movw	$.T1,r2
	movw	$.F10,r3
	call	sp,Rload
	b	_PDUcheck_output_filename

	.globl	_PDUdisplay_local_report_file
_PDUdisplay_local_report_file:
	movw	$.T1,r2
	movw	$.F10,r3
	call	sp,Rload
	b	_PDUdisplay_local_report_file

	.globl	_PDUload_bom_list
_PDUload_bom_list:
	movw	$.T1,r2
	movw	$.F10,r3
	call	sp,Rload
	b	_PDUload_bom_list

	.globl	_PDUupdate_report_form
_PDUupdate_report_form:
	movw	$.T1,r2
	movw	$.F10,r3
	call	sp,Rload
	b	_PDUupdate_report_form

	.globl	_reports_form
_reports_form:
	movw	$.T1,r2
	movw	$.F10,r3
	call	sp,Rload
	b	_reports_form

	.globl	_PDUreports_form
_PDUreports_form:
	movw	$.T1,r2
	movw	$.F10,r3
	call	sp,Rload
	b	_PDUreports_form

	.globl	_PDUsetup_report_struct
_PDUsetup_report_struct:
	movw	$.T1,r2
	movw	$.F10,r3
	call	sp,Rload
	b	_PDUsetup_report_struct

	.globl	_PDUdelete_report_from_field
_PDUdelete_report_from_field:
	movw	$.T1,r2
	movw	$.F10,r3
	call	sp,Rload
	b	_PDUdelete_report_from_field

	.globl	_PDUdelete_boms
_PDUdelete_boms:
	movw	$.T1,r2
	movw	$.F10,r3
	call	sp,Rload
	b	_PDUdelete_boms
#
# Begin stubs for:  PDUbom_cnts.o
#
	.data
	.align	4
.F11:	.long	0x00000700
	.byte	80, 68, 85, 98, 111, 109, 95, 99, 110, 116
	.byte	115, 46, 111, 0
	.text

	.globl	_bom_contents_notification_routine
_bom_contents_notification_routine:
	movw	$.T1,r2
	movw	$.F11,r3
	call	sp,Rload
	b	_bom_contents_notification_routine

	.globl	_PDUload_attributes_for_mapping
_PDUload_attributes_for_mapping:
	movw	$.T1,r2
	movw	$.F11,r3
	call	sp,Rload
	b	_PDUload_attributes_for_mapping

	.globl	_PDUcheck_bom_mapping_commands
_PDUcheck_bom_mapping_commands:
	movw	$.T1,r2
	movw	$.F11,r3
	call	sp,Rload
	b	_PDUcheck_bom_mapping_commands

	.globl	_PDUmerge_cat_and_dyn_attr
_PDUmerge_cat_and_dyn_attr:
	movw	$.T1,r2
	movw	$.F11,r3
	call	sp,Rload
	b	_PDUmerge_cat_and_dyn_attr

	.globl	_PDUmap_attribute
_PDUmap_attribute:
	movw	$.T1,r2
	movw	$.F11,r3
	call	sp,Rload
	b	_PDUmap_attribute

	.globl	_PDUadd_to_contents
_PDUadd_to_contents:
	movw	$.T1,r2
	movw	$.F11,r3
	call	sp,Rload
	b	_PDUadd_to_contents

	.globl	_bom_contents_form
_bom_contents_form:
	movw	$.T1,r2
	movw	$.F11,r3
	call	sp,Rload
	b	_bom_contents_form

	.globl	_PDUbom_contents_form
_PDUbom_contents_form:
	movw	$.T1,r2
	movw	$.F11,r3
	call	sp,Rload
	b	_PDUbom_contents_form
#
# Begin stubs for:  PDUdef_rpt.o
#
	.data
	.align	4
.F12:	.long	0x00000700
	.byte	80, 68, 85, 100, 101, 102, 95, 114, 112, 116
	.byte	46, 111, 0
	.text

	.globl	_PDUdefine_report_attributes
_PDUdefine_report_attributes:
	movw	$.T1,r2
	movw	$.F12,r3
	call	sp,Rload
	b	_PDUdefine_report_attributes

	.globl	_PDUdefine_report_format
_PDUdefine_report_format:
	movw	$.T1,r2
	movw	$.F12,r3
	call	sp,Rload
	b	_PDUdefine_report_format

	.globl	_PDUfinish_define_format
_PDUfinish_define_format:
	movw	$.T1,r2
	movw	$.F12,r3
	call	sp,Rload
	b	_PDUfinish_define_format

	.globl	_PDUimport_ris_report
_PDUimport_ris_report:
	movw	$.T1,r2
	movw	$.F12,r3
	call	sp,Rload
	b	_PDUimport_ris_report
#
# Begin stubs for:  PDUdsp_rpt.o
#
	.data
	.align	4
.F13:	.long	0x00000700
	.byte	80, 68, 85, 100, 115, 112, 95, 114, 112, 116
	.byte	46, 111, 0
	.text

	.globl	_PDUdisplay_report
_PDUdisplay_report:
	movw	$.T1,r2
	movw	$.F13,r3
	call	sp,Rload
	b	_PDUdisplay_report
#
# Begin stubs for:  PDUdel_rpt.o
#
	.data
	.align	4
.F14:	.long	0x00000700
	.byte	80, 68, 85, 100, 101, 108, 95, 114, 112, 116
	.byte	46, 111, 0
	.text

	.globl	_PDUdelete_report
_PDUdelete_report:
	movw	$.T1,r2
	movw	$.F14,r3
	call	sp,Rload
	b	_PDUdelete_report
#
# Begin stubs for:  PDUrpt_tools.o
#
	.data
	.align	4
.F15:	.long	0x00000700
	.byte	80, 68, 85, 114, 112, 116, 95, 116, 111, 111
	.byte	108, 115, 46, 111, 0
	.text

	.globl	_PDUload_PSUattr_struct
_PDUload_PSUattr_struct:
	movw	$.T1,r2
	movw	$.F15,r3
	call	sp,Rload
	b	_PDUload_PSUattr_struct

	.globl	_PDUformat_report_buffers
_PDUformat_report_buffers:
	movw	$.T1,r2
	movw	$.F15,r3
	call	sp,Rload
	b	_PDUformat_report_buffers

	.globl	_PDUfrom_bufrs_to_structures
_PDUfrom_bufrs_to_structures:
	movw	$.T1,r2
	movw	$.F15,r3
	call	sp,Rload
	b	_PDUfrom_bufrs_to_structures

	.globl	_PDUfrom_struct_to_buffers
_PDUfrom_struct_to_buffers:
	movw	$.T1,r2
	movw	$.F15,r3
	call	sp,Rload
	b	_PDUfrom_struct_to_buffers

	.globl	_PDUformat_delete_report_bufr
_PDUformat_delete_report_bufr:
	movw	$.T1,r2
	movw	$.F15,r3
	call	sp,Rload
	b	_PDUformat_delete_report_bufr

	.globl	_PDUdelete_report_locally
_PDUdelete_report_locally:
	movw	$.T1,r2
	movw	$.F15,r3
	call	sp,Rload
	b	_PDUdelete_report_locally

	.globl	_PDUformat_bom_map_bufr
_PDUformat_bom_map_bufr:
	movw	$.T1,r2
	movw	$.F15,r3
	call	sp,Rload
	b	_PDUformat_bom_map_bufr

	.comm	_errmsg,132
	.globl	_PDU_attr_name
	.globl	_PDMprepare_explode_summary_bom
	.globl	_Help_topic
	.globl	_PDUformat_bom_map_bufr
	.globl	_FIf_erase
	.globl	_PDMgen_loc_report
	.globl	_PDU_datatype
	.globl	_PDMquery_table_definition
	.globl	_PDUlist_reports
	.globl	_PDUformat_delete_report_bufr
	.globl	_PDMquery_report_type
	.globl	_MEMopen
	.globl	_strcpy
	.globl	_user
	.globl	_PDUprepare_queue
	.globl	_PDU_report_exists
	.globl	_PDUload_PSUattr_struct
	.globl	_PDMsql_query
	.globl	_PDM_debug_on
	.globl	_PSUalloc_rpt
	.globl	_PDUep_part_btn
	.globl	_SelectOrPlacePart
	.globl	_PDU_attr_datatype
	.globl	_PDUformat_report_buffers
	.globl	_bom_attr
	.globl	_FIg_set_state_off
	.globl	_PDMget_pt_desc
	.globl	_PDU_output_file
	.globl	_PDU_cat_attr_bufr
	.globl	_PDU_form_id
	.globl	_PDUupdate_data_buffer
	.globl	_PDUvalid_attr
	.globl	_malloc
	.globl	_PDMopen_report_buffer
	.globl	_PDMadd_criteria
	.globl	_PDUep_cat_fld
	.globl	_free
	.globl	_FIfld_delete_rows
	.globl	_MEMwrite
	.globl	_PDU_report_title
	.globl	_FIfld_get_select
	.globl	_PDUsetup_report_definition
	.globl	_PDU_report_name
	.globl	_PDMIndentReportFile
	.globl	_PDMprepare_bomparts_list
	.globl	_PDU_bom_attr_bufr
	.globl	_PDUfind_attr_in_buffer
	.globl	_PDMread_report_format
	.globl	_PDUcreate_list_of_cat_attributes
	.globl	_PDU_bom_map_bufr
	.globl	_PDUsetup_struct_fields
	.globl	_FIg_display
	.globl	_PSUload_list_format
	.globl	_FIf_new
	.globl	_PDU_pdurpt
	.globl	_PDUget_templatetype
	.globl	_PDUmessage_trans
	.globl	_PDU_store_row
	.globl	__iob
	.globl	_PDU_selected_rows
	.globl	_PDUvalid_synonym
	.globl	_PDMget_dynamic_attributes
	.globl	_PDUupdate_report_form
	.globl	_PDUbufr_to_mcf
	.globl	_MEMwrite_format
	.globl	_catalog_attr
	.globl	_MRP_debug_on
	.globl	_PDU_store_catalog
	.globl	_PDU_synonym
	.globl	_PDU_select_catattr
	.globl	_PDUfrom_bufrs_to_structures
	.globl	_PDU_DEBUG_FILE
	.globl	_PDUinitialize_help
	.globl	_PDU_command
	.globl	_PDMget_table_attributes
	.globl	_strncmp
	.globl	_storage
	.globl	_PDUvalid_datatype
	.globl	_FIg_set_state_on
	.globl	_MEMsplit_copy_buffer
	.globl	_PDUadd_buffer_string
	.globl	_rMRPdbg_fileptr
	.globl	_PDUep_part_fld
	.globl	_PDUget_buffer_col
	.globl	_FIf_cvrt_to_perm_win
	.globl	_strlen
	.globl	_PDU_calling_form
	.globl	_PDMshow_boms
	.globl	_strcat
	.globl	_PDMgen_where_used_imm
	.globl	_PDUdefine_report_format
	.globl	__pdm_status
	.globl	_PDUsingle_list_form
	.globl	_PDUep_cat_btn
	.globl	_MRPcalc_width
	.globl	_strcmp
	.globl	_UI_prompt
	.globl	_FIfld_set_active_row
	.globl	_forms
	.globl	_FIf_set_orig_coord
	.globl	_rMRPalloc_var
	.globl	_PDUalloc_rpt
	.globl	_PDUdismiss_subforms
	.globl	_FIg_disable
	.globl	_memset
	.globl	_FIfld_pos_cursor
	.globl	_PDUsetup_popup_list
	.globl	_FIg_set_text
	.globl	_FIfld_get_num_rows
	.globl	_FIg_erase
	.globl	_PDUsetup_single_buffer
	.globl	_isdigit
	.globl	_PDMgen_where_used_top
	.globl	_PDUfrom_struct_to_buffers
	.globl	_PDUcreate_dynamic_attr_buffr
	.globl	_sscanf
	.globl	_PDU_gadget_labels
	.globl	_PDMrdelete_bom
	.globl	_PDMimport_ris_rpt
	.globl	_PDUbom_contents_form
	.globl	_PDUep_rev_fld
	.globl	_MEMbuild_array
	.globl	_PDUfill_in_string
	.globl	_FIf_delete
	.globl	_MEMclose
	.globl	_PDUfind_attr_by_synonym
	.globl	_PDMlist_reports
	.globl	_PDU_select_bomattr
	.globl	_PDUcheck_for_reserved_words
	.globl	_FIfld_set_num_rows
	.globl	_PDUdelete_report_locally
	.globl	_PDUdelete_report_from_field
	.globl	_PDUep_rev_btn
	.globl	_refresh
	.globl	_PDU_perm_window
	.globl	_PDU_ret_bufr
	.globl	_FIfld_get_text
	.globl	_PDUfree_string_array
	.globl	_PDU_delete_reports
	.globl	_PDMread_criteria
	.globl	__pdm_debug
	.globl	_FIg_get_state
	.globl	_sprintf
	.globl	_PDUcheck_reportname
	.globl	_unlink
	.globl	_FIg_enable
	.globl	_PDUsetup_buffer
	.globl	_PDU_bom_list_bufr
	.globl	_PDU_bom_datatype
	.globl	_PDMvalidate_report_name
	.globl	_PDUverify_file
	.globl	_PDMgen_bom_report
	.globl	_FIfld_get_text_length
	.globl	_FIfld_get_active_row
	.globl	_MRPalloc_var
	.globl	_PDU_refresh_gadgets
	.globl	_PDUmessage
	.globl	_FIf_display
	.globl	_PDUformat_buffer
	.globl	_PDU_bom_data_bufr
	.globl	_PDUtranslate_message
	.globl	_PDMprepare_summary_bom
	.globl	_PDMadd_report
	.globl	_MEMprint_buffer
	.globl	_PDUsetup_design_struct
	.globl	_PDU_update_struct
	.globl	_PDMmodify_bom_content
	.globl	_FIfld_set_text
	.globl	_FImcf_set_active_col
	.globl	_PDMrupdate_bom
	.globl	_PDUsetup_report_struct
	.globl	_PDMgen_parts_in_catalog
	.globl	_PSUdisplay_rpt
	.globl	_PDU_active_button
	.globl	_PDMdelete_report
	.globl	_rMRPfree_pdurpt
	.globl	_PDUrefresh_local_files_form
	.globl	_PDUsetup_form_fields
	.globl	_PDUep_desc_fld
