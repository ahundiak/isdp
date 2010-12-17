	.file	"PDUassembly.s"
#
# Begin stubs for:  PDUdef_assy.o
#
	.data
.T1:	.byte	80, 100, 117, 0
	.byte	112, 100, 117, 47, 97, 115, 115, 101, 109, 98
	.byte	108, 121, 0
	.align	4
.F1:	.long	0x00000700
	.byte	80, 68, 85, 100, 101, 102, 95, 97, 115, 115
	.byte	121, 46, 111, 0
	.text

	.globl	_define_assy_notification_routine
_define_assy_notification_routine:
	movw	$.T1,r2
	movw	$.F1,r3
	call	sp,Rload
	b	_define_assy_notification_routine

	.globl	_PDUfreeze_assy_mcf
_PDUfreeze_assy_mcf:
	movw	$.T1,r2
	movw	$.F1,r3
	call	sp,Rload
	b	_PDUfreeze_assy_mcf

	.globl	_PDUrefresh_gadgets_init
_PDUrefresh_gadgets_init:
	movw	$.T1,r2
	movw	$.F1,r3
	call	sp,Rload
	b	_PDUrefresh_gadgets_init

	.globl	_PDUsave_assy_part_selection_area
_PDUsave_assy_part_selection_area:
	movw	$.T1,r2
	movw	$.F1,r3
	call	sp,Rload
	b	_PDUsave_assy_part_selection_area

	.globl	_PDUrestore_assy_part_selection_area
_PDUrestore_assy_part_selection_area:
	movw	$.T1,r2
	movw	$.F1,r3
	call	sp,Rload
	b	_PDUrestore_assy_part_selection_area

	.globl	_PDUcheck_assy_commands
_PDUcheck_assy_commands:
	movw	$.T1,r2
	movw	$.F1,r3
	call	sp,Rload
	b	_PDUcheck_assy_commands

	.globl	_PDUassy_gadgets_init
_PDUassy_gadgets_init:
	movw	$.T1,r2
	movw	$.F1,r3
	call	sp,Rload
	b	_PDUassy_gadgets_init

	.globl	_PDUprint_assy_refresh
_PDUprint_assy_refresh:
	movw	$.T1,r2
	movw	$.F1,r3
	call	sp,Rload
	b	_PDUprint_assy_refresh

	.globl	_PDUdefine_assy_form
_PDUdefine_assy_form:
	movw	$.T1,r2
	movw	$.F1,r3
	call	sp,Rload
	b	_PDUdefine_assy_form

	.globl	_PDUunfreeze_assy_mcf
_PDUunfreeze_assy_mcf:
	movw	$.T1,r2
	movw	$.F1,r3
	call	sp,Rload
	b	_PDUunfreeze_assy_mcf
#
# Begin stubs for:  PDUassy_tls.o
#
	.data
	.align	4
.F2:	.long	0x00000700
	.byte	80, 68, 85, 97, 115, 115, 121, 95, 116, 108
	.byte	115, 46, 111, 0
	.text

	.globl	_PDUdisplay_review_structure
_PDUdisplay_review_structure:
	movw	$.T1,r2
	movw	$.F2,r3
	call	sp,Rload
	b	_PDUdisplay_review_structure

	.globl	_PDUload_assembly_structure
_PDUload_assembly_structure:
	movw	$.T1,r2
	movw	$.F2,r3
	call	sp,Rload
	b	_PDUload_assembly_structure

	.globl	_PDUadd_part_to_assy_structure
_PDUadd_part_to_assy_structure:
	movw	$.T1,r2
	movw	$.F2,r3
	call	sp,Rload
	b	_PDUadd_part_to_assy_structure

	.globl	_PDUgenerate_ng_usageid
_PDUgenerate_ng_usageid:
	movw	$.T1,r2
	movw	$.F2,r3
	call	sp,Rload
	b	_PDUgenerate_ng_usageid

	.globl	_PDUplace_ng_assembly
_PDUplace_ng_assembly:
	movw	$.T1,r2
	movw	$.F2,r3
	call	sp,Rload
	b	_PDUplace_ng_assembly

	.globl	_PDUdelete_assy_part
_PDUdelete_assy_part:
	movw	$.T1,r2
	movw	$.F2,r3
	call	sp,Rload
	b	_PDUdelete_assy_part

	.globl	_PDUcheck_level_no
_PDUcheck_level_no:
	movw	$.T1,r2
	movw	$.F2,r3
	call	sp,Rload
	b	_PDUcheck_level_no

	.globl	_PDUadd_row_to_assy_mcf
_PDUadd_row_to_assy_mcf:
	movw	$.T1,r2
	movw	$.F2,r3
	call	sp,Rload
	b	_PDUadd_row_to_assy_mcf

	.globl	_PDUcreate_assembly_parts_buffer
_PDUcreate_assembly_parts_buffer:
	movw	$.T1,r2
	movw	$.F2,r3
	call	sp,Rload
	b	_PDUcreate_assembly_parts_buffer

	.globl	_PDUdefault_usageid
_PDUdefault_usageid:
	movw	$.T1,r2
	movw	$.F2,r3
	call	sp,Rload
	b	_PDUdefault_usageid

	.globl	_PDUget_assembly
_PDUget_assembly:
	movw	$.T1,r2
	movw	$.F2,r3
	call	sp,Rload
	b	_PDUget_assembly

	.globl	_PDUget_max_level
_PDUget_max_level:
	movw	$.T1,r2
	movw	$.F2,r3
	call	sp,Rload
	b	_PDUget_max_level

	.globl	_PDUfreeze_assy_refresh
_PDUfreeze_assy_refresh:
	movw	$.T1,r2
	movw	$.F2,r3
	call	sp,Rload
	b	_PDUfreeze_assy_refresh

	.globl	_PDUunfreeze_assy_part_area
_PDUunfreeze_assy_part_area:
	movw	$.T1,r2
	movw	$.F2,r3
	call	sp,Rload
	b	_PDUunfreeze_assy_part_area

	.globl	_PDUfreeze_assy_part_area
_PDUfreeze_assy_part_area:
	movw	$.T1,r2
	movw	$.F2,r3
	call	sp,Rload
	b	_PDUfreeze_assy_part_area

	.globl	_PDUunfreeze_assy_refresh
_PDUunfreeze_assy_refresh:
	movw	$.T1,r2
	movw	$.F2,r3
	call	sp,Rload
	b	_PDUunfreeze_assy_refresh
#
# Begin stubs for:  PDUassyapi.o
#
	.data
	.align	4
.F3:	.long	0x00000700
	.byte	80, 68, 85, 97, 115, 115, 121, 97, 112, 105
	.byte	46, 111, 0
	.text

	.globl	_PDUget_file_status
_PDUget_file_status:
	movw	$.T1,r2
	movw	$.F3,r3
	call	sp,Rload
	b	_PDUget_file_status
#
# Begin stubs for:  PDUrev_assy.o
#
	.data
	.align	4
.F4:	.long	0x00000700
	.byte	80, 68, 85, 114, 101, 118, 95, 97, 115, 115
	.byte	121, 46, 111, 0
	.text

	.globl	_compare_parts
_compare_parts:
	movw	$.T1,r2
	movw	$.F4,r3
	call	sp,Rload
	b	_compare_parts

	.globl	_PDUcheck_nesting
_PDUcheck_nesting:
	movw	$.T1,r2
	movw	$.F4,r3
	call	sp,Rload
	b	_PDUcheck_nesting

	.globl	_PDUprint_attr_data_buffers
_PDUprint_attr_data_buffers:
	movw	$.T1,r2
	movw	$.F4,r3
	call	sp,Rload
	b	_PDUprint_attr_data_buffers

	.globl	_free_attr_data_buffer
_free_attr_data_buffer:
	movw	$.T1,r2
	movw	$.F4,r3
	call	sp,Rload
	b	_free_attr_data_buffer

	.globl	_attr_value_notification_routine
_attr_value_notification_routine:
	movw	$.T1,r2
	movw	$.F4,r3
	call	sp,Rload
	b	_attr_value_notification_routine

	.globl	_PDU_display_attr_in_mcf
_PDU_display_attr_in_mcf:
	movw	$.T1,r2
	movw	$.F4,r3
	call	sp,Rload
	b	_PDU_display_attr_in_mcf

	.globl	_PDUdisplay_status
_PDUdisplay_status:
	movw	$.T1,r2
	movw	$.F4,r3
	call	sp,Rload
	b	_PDUdisplay_status

	.globl	_rev_assy_notification_routine
_rev_assy_notification_routine:
	movw	$.T1,r2
	movw	$.F4,r3
	call	sp,Rload
	b	_rev_assy_notification_routine

	.globl	_PDUfind_parent_in_mcf
_PDUfind_parent_in_mcf:
	movw	$.T1,r2
	movw	$.F4,r3
	call	sp,Rload
	b	_PDUfind_parent_in_mcf

	.globl	_PDUcheck_cyclic_placement_for_rev_assy
_PDUcheck_cyclic_placement_for_rev_assy:
	movw	$.T1,r2
	movw	$.F4,r3
	call	sp,Rload
	b	_PDUcheck_cyclic_placement_for_rev_assy

	.globl	_PDUget_storage_filename
_PDUget_storage_filename:
	movw	$.T1,r2
	movw	$.F4,r3
	call	sp,Rload
	b	_PDUget_storage_filename

	.globl	_PDUget_part_bufrs
_PDUget_part_bufrs:
	movw	$.T1,r2
	movw	$.F4,r3
	call	sp,Rload
	b	_PDUget_part_bufrs

	.globl	_PDUcheck_if_parametric
_PDUcheck_if_parametric:
	movw	$.T1,r2
	movw	$.F4,r3
	call	sp,Rload
	b	_PDUcheck_if_parametric

	.globl	_PDUget_desc
_PDUget_desc:
	movw	$.T1,r2
	movw	$.F4,r3
	call	sp,Rload
	b	_PDUget_desc

	.globl	_PDUcheck_attr_for_write_permission
_PDUcheck_attr_for_write_permission:
	movw	$.T1,r2
	movw	$.F4,r3
	call	sp,Rload
	b	_PDUcheck_attr_for_write_permission

	.globl	_PDUverify_storage_filename
_PDUverify_storage_filename:
	movw	$.T1,r2
	movw	$.F4,r3
	call	sp,Rload
	b	_PDUverify_storage_filename

	.globl	_PDUupdate_revise_assy_form_after_select
_PDUupdate_revise_assy_form_after_select:
	movw	$.T1,r2
	movw	$.F4,r3
	call	sp,Rload
	b	_PDUupdate_revise_assy_form_after_select

	.globl	_PDUrevise_assembly_form
_PDUrevise_assembly_form:
	movw	$.T1,r2
	movw	$.F4,r3
	call	sp,Rload
	b	_PDUrevise_assembly_form

	.globl	_act_part_notification_routine
_act_part_notification_routine:
	movw	$.T1,r2
	movw	$.F4,r3
	call	sp,Rload
	b	_act_part_notification_routine

	.globl	_PDUactive_part_form
_PDUactive_part_form:
	movw	$.T1,r2
	movw	$.F4,r3
	call	sp,Rload
	b	_PDUactive_part_form
#
# Begin stubs for:  PDUrevasytls.o
#
	.data
	.align	4
.F5:	.long	0x00000700
	.byte	80, 68, 85, 114, 101, 118, 97, 115, 121, 116
	.byte	108, 115, 46, 111, 0
	.text

	.globl	_PDUconvert_assy_buffer_to_linklist
_PDUconvert_assy_buffer_to_linklist:
	movw	$.T1,r2
	movw	$.F5,r3
	call	sp,Rload
	b	_PDUconvert_assy_buffer_to_linklist

	.globl	_PDUprint_assy_linklist
_PDUprint_assy_linklist:
	movw	$.T1,r2
	movw	$.F5,r3
	call	sp,Rload
	b	_PDUprint_assy_linklist

	.globl	_PDUadd_multiple_files_to_linklist
_PDUadd_multiple_files_to_linklist:
	movw	$.T1,r2
	movw	$.F5,r3
	call	sp,Rload
	b	_PDUadd_multiple_files_to_linklist

	.globl	_PDUreset_assy_mcf_row_pointers
_PDUreset_assy_mcf_row_pointers:
	movw	$.T1,r2
	movw	$.F5,r3
	call	sp,Rload
	b	_PDUreset_assy_mcf_row_pointers

	.globl	_PDUload_revise_assembly_form
_PDUload_revise_assembly_form:
	movw	$.T1,r2
	movw	$.F5,r3
	call	sp,Rload
	b	_PDUload_revise_assembly_form

	.globl	_PDUappend_file_suffix
_PDUappend_file_suffix:
	movw	$.T1,r2
	movw	$.F5,r3
	call	sp,Rload
	b	_PDUappend_file_suffix

	.globl	_PDUfree_assy_linklist
_PDUfree_assy_linklist:
	movw	$.T1,r2
	movw	$.F5,r3
	call	sp,Rload
	b	_PDUfree_assy_linklist

	.globl	_PDUcheck_file_status_for_assy_linklist
_PDUcheck_file_status_for_assy_linklist:
	movw	$.T1,r2
	movw	$.F5,r3
	call	sp,Rload
	b	_PDUcheck_file_status_for_assy_linklist

	.globl	_PDUadd_blank_row_to_linklist
_PDUadd_blank_row_to_linklist:
	movw	$.T1,r2
	movw	$.F5,r3
	call	sp,Rload
	b	_PDUadd_blank_row_to_linklist

	.globl	_PDUcopy_assy_linklist
_PDUcopy_assy_linklist:
	movw	$.T1,r2
	movw	$.F5,r3
	call	sp,Rload
	b	_PDUcopy_assy_linklist

	.globl	_PDUadd_parts_for_revise_assy
_PDUadd_parts_for_revise_assy:
	movw	$.T1,r2
	movw	$.F5,r3
	call	sp,Rload
	b	_PDUadd_parts_for_revise_assy

	.globl	_PDUdelete_active_part_form
_PDUdelete_active_part_form:
	movw	$.T1,r2
	movw	$.F5,r3
	call	sp,Rload
	b	_PDUdelete_active_part_form

	.globl	_PDUcreate_add_file_buffer
_PDUcreate_add_file_buffer:
	movw	$.T1,r2
	movw	$.F5,r3
	call	sp,Rload
	b	_PDUcreate_add_file_buffer

	.globl	_PDUupdate_mult_files_for_rev_assy
_PDUupdate_mult_files_for_rev_assy:
	movw	$.T1,r2
	movw	$.F5,r3
	call	sp,Rload
	b	_PDUupdate_mult_files_for_rev_assy

	.globl	_PDUcreate_BOM_assy_list
_PDUcreate_BOM_assy_list:
	movw	$.T1,r2
	movw	$.F5,r3
	call	sp,Rload
	b	_PDUcreate_BOM_assy_list

	.globl	_PDUcheck_assy_list_for_change
_PDUcheck_assy_list_for_change:
	movw	$.T1,r2
	movw	$.F5,r3
	call	sp,Rload
	b	_PDUcheck_assy_list_for_change

	.globl	_PDUcheck_parent_part_for_revise_assy
_PDUcheck_parent_part_for_revise_assy:
	movw	$.T1,r2
	movw	$.F5,r3
	call	sp,Rload
	b	_PDUcheck_parent_part_for_revise_assy

	.globl	_PDUprint_parts_list
_PDUprint_parts_list:
	movw	$.T1,r2
	movw	$.F5,r3
	call	sp,Rload
	b	_PDUprint_parts_list

	.globl	_PDUprint_assy_parts_list
_PDUprint_assy_parts_list:
	movw	$.T1,r2
	movw	$.F5,r3
	call	sp,Rload
	b	_PDUprint_assy_parts_list

	.globl	_PDUadd_part_to_list
_PDUadd_part_to_list:
	movw	$.T1,r2
	movw	$.F5,r3
	call	sp,Rload
	b	_PDUadd_part_to_list

	.globl	_PDUadd_part_to_assy_list
_PDUadd_part_to_assy_list:
	movw	$.T1,r2
	movw	$.F5,r3
	call	sp,Rload
	b	_PDUadd_part_to_assy_list

	.globl	_PDUis_part_in_list
_PDUis_part_in_list:
	movw	$.T1,r2
	movw	$.F5,r3
	call	sp,Rload
	b	_PDUis_part_in_list

	.globl	_PDUis_part_in_assy_list
_PDUis_part_in_assy_list:
	movw	$.T1,r2
	movw	$.F5,r3
	call	sp,Rload
	b	_PDUis_part_in_assy_list

	.globl	_PDUfree_parts_list
_PDUfree_parts_list:
	movw	$.T1,r2
	movw	$.F5,r3
	call	sp,Rload
	b	_PDUfree_parts_list

	.globl	_PDUfree_assy_parts_list
_PDUfree_assy_parts_list:
	movw	$.T1,r2
	movw	$.F5,r3
	call	sp,Rload
	b	_PDUfree_assy_parts_list

	.globl	_PDUassy_list_to_ASSY_BUFR
_PDUassy_list_to_ASSY_BUFR:
	movw	$.T1,r2
	movw	$.F5,r3
	call	sp,Rload
	b	_PDUassy_list_to_ASSY_BUFR

	.globl	_PDUdelete_multiple_occurrences
_PDUdelete_multiple_occurrences:
	movw	$.T1,r2
	movw	$.F5,r3
	call	sp,Rload
	b	_PDUdelete_multiple_occurrences

	.globl	_PDUundelete_multiple_occurrences
_PDUundelete_multiple_occurrences:
	movw	$.T1,r2
	movw	$.F5,r3
	call	sp,Rload
	b	_PDUundelete_multiple_occurrences

	.globl	_PDUmark_deleted_parts_for_revise_assy
_PDUmark_deleted_parts_for_revise_assy:
	movw	$.T1,r2
	movw	$.F5,r3
	call	sp,Rload
	b	_PDUmark_deleted_parts_for_revise_assy

	.globl	_PDUprocess_rev_assy_form
_PDUprocess_rev_assy_form:
	movw	$.T1,r2
	movw	$.F5,r3
	call	sp,Rload
	b	_PDUprocess_rev_assy_form

	.globl	_PDUcheck_assembly_for_file_creation
_PDUcheck_assembly_for_file_creation:
	movw	$.T1,r2
	movw	$.F5,r3
	call	sp,Rload
	b	_PDUcheck_assembly_for_file_creation

	.globl	_PDUmodify_assembly_thru_OBJ2
_PDUmodify_assembly_thru_OBJ2:
	movw	$.T1,r2
	movw	$.F5,r3
	call	sp,Rload
	b	_PDUmodify_assembly_thru_OBJ2

	.globl	_PDUcopy_files_for_revise_assembly
_PDUcopy_files_for_revise_assembly:
	movw	$.T1,r2
	movw	$.F5,r3
	call	sp,Rload
	b	_PDUcopy_files_for_revise_assembly

	.globl	_PDUadd_file_to_list
_PDUadd_file_to_list:
	movw	$.T1,r2
	movw	$.F5,r3
	call	sp,Rload
	b	_PDUadd_file_to_list

	.globl	_PDUcreate_copy_buffer_for_rev_assy
_PDUcreate_copy_buffer_for_rev_assy:
	movw	$.T1,r2
	movw	$.F5,r3
	call	sp,Rload
	b	_PDUcreate_copy_buffer_for_rev_assy

	.globl	_PDUis_file_in_list
_PDUis_file_in_list:
	movw	$.T1,r2
	movw	$.F5,r3
	call	sp,Rload
	b	_PDUis_file_in_list

	.globl	_PDUcreate_copy_file_lists_for_rev_assy
_PDUcreate_copy_file_lists_for_rev_assy:
	movw	$.T1,r2
	movw	$.F5,r3
	call	sp,Rload
	b	_PDUcreate_copy_file_lists_for_rev_assy

	.globl	_PDUcheckout_part_for_revise_assembly
_PDUcheckout_part_for_revise_assembly:
	movw	$.T1,r2
	movw	$.F5,r3
	call	sp,Rload
	b	_PDUcheckout_part_for_revise_assembly

	.globl	_PDUcheck_usageid_for_rev_assy
_PDUcheck_usageid_for_rev_assy:
	movw	$.T1,r2
	movw	$.F5,r3
	call	sp,Rload
	b	_PDUcheck_usageid_for_rev_assy

	.globl	_PDUcheck_alttag_for_rev_assy
_PDUcheck_alttag_for_rev_assy:
	movw	$.T1,r2
	movw	$.F5,r3
	call	sp,Rload
	b	_PDUcheck_alttag_for_rev_assy

	.globl	_PDUng_place_part_for_revise_assembly
_PDUng_place_part_for_revise_assembly:
	movw	$.T1,r2
	movw	$.F5,r3
	call	sp,Rload
	b	_PDUng_place_part_for_revise_assembly

	.globl	_PDUgenerate_rev_assy_data
_PDUgenerate_rev_assy_data:
	movw	$.T1,r2
	movw	$.F5,r3
	call	sp,Rload
	b	_PDUgenerate_rev_assy_data

	.globl	_PDUcleanup_revise_assembly
_PDUcleanup_revise_assembly:
	movw	$.T1,r2
	movw	$.F5,r3
	call	sp,Rload
	b	_PDUcleanup_revise_assembly

	.globl	_PDUget_param_attrs_for_rev_assy
_PDUget_param_attrs_for_rev_assy:
	movw	$.T1,r2
	movw	$.F5,r3
	call	sp,Rload
	b	_PDUget_param_attrs_for_rev_assy

	.globl	_PDUupdate_AttrForm_function_value
_PDUupdate_AttrForm_function_value:
	movw	$.T1,r2
	movw	$.F5,r3
	call	sp,Rload
	b	_PDUupdate_AttrForm_function_value

	.globl	_PDUadd_parts_to_assy_buffer
_PDUadd_parts_to_assy_buffer:
	movw	$.T1,r2
	movw	$.F5,r3
	call	sp,Rload
	b	_PDUadd_parts_to_assy_buffer

	.globl	_PDUcompare_childnos
_PDUcompare_childnos:
	movw	$.T1,r2
	movw	$.F5,r3
	call	sp,Rload
	b	_PDUcompare_childnos

	.globl	_PDUcompare_tagnos
_PDUcompare_tagnos:
	movw	$.T1,r2
	movw	$.F5,r3
	call	sp,Rload
	b	_PDUcompare_tagnos

	.globl	_PDUcompare_usageids
_PDUcompare_usageids:
	movw	$.T1,r2
	movw	$.F5,r3
	call	sp,Rload
	b	_PDUcompare_usageids

	.globl	_PDUprint_file_linklist
_PDUprint_file_linklist:
	movw	$.T1,r2
	movw	$.F5,r3
	call	sp,Rload
	b	_PDUprint_file_linklist

	.globl	_PDUfree_file_list
_PDUfree_file_list:
	movw	$.T1,r2
	movw	$.F5,r3
	call	sp,Rload
	b	_PDUfree_file_list

	.globl	_PDUprocess_parent_for_revise_assembly
_PDUprocess_parent_for_revise_assembly:
	movw	$.T1,r2
	movw	$.F5,r3
	call	sp,Rload
	b	_PDUprocess_parent_for_revise_assembly

	.globl	_PDUmodify_assembly_thru_database
_PDUmodify_assembly_thru_database:
	movw	$.T1,r2
	movw	$.F5,r3
	call	sp,Rload
	b	_PDUmodify_assembly_thru_database

	.globl	_PDUprint_linklist
	.globl	_PDU_incl_BOM
	.globl	_PDU_alt_tagno
	.globl	_PDU_save_revision
	.globl	_SQLquery
	.globl	_PDUis_file_open
	.globl	_PDUunfreeze_assy_mcf
	.globl	_Help_topic
	.globl	_PDU_save_ptr
	.globl	_PDMget_existing_data
	.globl	_PDUcreate_BOM_assy_list
	.globl	_PDUadd_node_to_linklist
	.globl	_FIf_erase
	.globl	_PDU_define_assy_displayed
	.globl	_PDUunlock_item
	.globl	_PDUfree_file_list
	.globl	_PDUcheck_part_syntax
	.globl	_PDUcheck_display_dynamic_attr
	.globl	_PDUundelete_multiple_occurrences
	.globl	_PDUext_cancel_checkout
	.globl	_PDU_parts_index
	.globl	_PDUfree_parts_list
	.globl	_change_mode
	.globl	_strcpy
	.globl	_PDUget_part_bufrs
	.globl	_close
	.globl	_bufr_flag
	.globl	_execlp
	.globl	_PDUchange_file_permissions
	.globl	_PDMget_stg_filename
	.globl	_execl
	.globl	_PDUprocess_rev_assy_form
	.globl	_PDUcheck_assy_list_for_change
	.globl	_PDMsql_query
	.globl	_PDUverify_storage_name
	.globl	_PDU_data_bufr
	.globl	_FImcf_get_select
	.globl	_PDUep_proj_fld
	.globl	_PDUdisplay_status
	.globl	_PDUvalid_filename
	.globl	_PDM_debug_on
	.globl	_PDU_list_bufr
	.globl	_strncpy
	.globl	_PDUep_part_btn
	.globl	_SelectOrPlacePart
	.globl	_PDU_func_buffer
	.globl	_FIg_set_state_off
	.globl	_PDMget_pt_desc
	.globl	_PDU_quantity
	.globl	_PDUvalidate_data_value
	.globl	_PDUload_revise_assembly_form
	.globl	_PDUprocess_pulldown_list
	.globl	_PDU_form_id
	.globl	_PDMvalidate_user_access
	.globl	_PDUfreeze_assy_part_area
	.globl	_PDU_display_buffer
	.globl	_pdmfree_part_occurrence
	.globl	_malloc
	.globl	_PDMget_assembly_structure
	.globl	_PDUdrop_node_from_linklist
	.globl	_FIfld_set_max_num_rows
	.globl	_PDU_assy_perm_window
	.globl	_PDUep_cat_fld
	.globl	_PDMrcheck_part_status
	.globl	_PDU_save_part_list
	.globl	_PDUcheck_rev_syntax
	.globl	_free
	.globl	_FIfld_delete_rows
	.globl	_PDUgenerate_tagno_from_linklist
	.globl	_FImcf_get_active_col
	.globl	_MEMwrite
	.globl	_PDUsetup_buffer_list
	.globl	_PDU_explode_depth
	.globl	_PDU_search_type
	.globl	_FIfld_get_select
	.globl	_PDUappend_file_suffix
	.globl	_PDU_save_filename
	.globl	_PDUcopy_assy_linklist
	.globl	_SQLstmt
	.globl	_PDMquery_catalog_type
	.globl	_PDU_chkout_single
	.globl	_PDU_save_level
	.globl	_PDU_attach
	.globl	_PDMrcheck_dup_sa_fname
	.globl	_PDUfind_attr_in_buffer
	.globl	_PDU_act_row
	.globl	_PDU_save_parttype
	.globl	_FIg_display
	.globl	_FImcf_get_num_cols
	.globl	_FIf_new
	.globl	_PDU_display_dyn_attr
	.globl	_PDUtranslate_message_and_vars
	.globl	_dup
	.globl	_FIf_reset
	.globl	_PDMquery_dynamic_attrs
	.globl	__iob
	.globl	_PDUverify_addpart_filename
	.globl	_PDU_value_pulldown
	.globl	_PDU_childno
	.globl	_PDU_selected_rows
	.globl	_PDUcleanup_revise_assembly
	.globl	_PDUwf_check
	.globl	_PDUbufr_to_mcf
	.globl	_PDMget_filenames
	.globl	_PDU_read_only_file
	.globl	_PDMget_list_for_modify
	.globl	_PDUupdate_ref_files_for_rev_assy
	.globl	_PDU_DEBUG_FILE
	.globl	_PDMdebug_on
	.globl	_PDU_command
	.globl	_PDUis_part_in_assy_list
	.globl	_PDU_assy_head
	.globl	_PDUcheck_for_required_attributes2
	.globl	_PDUfind_childno_in_linklist
	.globl	_storage
	.globl	_FIg_set_state_on
	.globl	_PDUdynamic_attr_form
	.globl	_MEMsplit_copy_buffer
	.globl	_PDUassy_linklist_to_buffer
	.globl	_PDUep_proj_btn
	.globl	_PDUadd_buffer_string
	.globl	_MEMreset_buffer_no
	.globl	_PDUadd_part_to_assy_list
	.globl	_FIfld_erase_cursor
	.globl	_PDUep_part_fld
	.globl	_PDUget_buffer_col
	.globl	_PDUget_max_level
	.globl	_PDMcheck_partnum
	.globl	_FIf_cvrt_to_perm_win
	.globl	_strlen
	.globl	_PDUget_param_attrs_for_rev_assy
	.globl	_PDU_calling_form
	.globl	_PDU_attr_bufr
	.globl	_PDU_save_project
	.globl	_strcat
	.globl	_PDU_incl_ASM
	.globl	_PDU_form_type
	.globl	_PDU_explode_BOM
	.globl	_GRdelete_pull_down_list
	.globl	_PDUadd_part_to_assy_structure
	.globl	_FIfld_set_mode
	.globl	_PDU_assy_parttype
	.globl	_PDU_parm_attr_bufr
	.globl	_PDU_assy_parts_bufr
	.globl	_PDUvalidate_catalog
	.globl	_PDU_dyn_attr_bufr
	.globl	_PDU_define_assy_created
	.globl	__pdm_status
	.globl	_PDUprint_assy_linklist
	.globl	_PDUget_exnuc_path
	.globl	_PDMrverify_catalog
	.globl	_PDU_save_description
	.globl	_review_mode
	.globl	_PDUep_cat_btn
	.globl	_PDU_assy_description
	.globl	_strcmp
	.globl	_PDUcheck_rev_datatype
	.globl	_UI_prompt
	.globl	_PDUunfreeze_assy_part_area
	.globl	_PDU_attr_value
	.globl	_sleep
	.globl	_FIfld_set_active_row
	.globl	_forms
	.globl	_FIg_call_notification_routine
	.globl	_PDU_assy_catalog
	.globl	_PDUdismiss_subforms
	.globl	_FIg_disable
	.globl	_PDU_checkout_type
	.globl	_PDU_ng_placement
	.globl	_PDUdelete_multiple_occurrences
	.globl	_strstr
	.globl	_PDU_get_assy
	.globl	_memset
	.globl	_FIfld_pos_cursor
	.globl	_PDMquery_part_type
	.globl	_PDUsetup_popup_list
	.globl	_PDU_func_bufr_exists
	.globl	_PDUcheckin
	.globl	_PDU_use_suffix
	.globl	_PDU_hold_bufr
	.globl	_FIg_set_text
	.globl	_FIfld_get_num_rows
	.globl	_PDU_assy_ptr
	.globl	_PDUcheck_if_graphic
	.globl	_PDMget_usageid_cat
	.globl	_FIg_erase
	.globl	_PDUget_file_status
	.globl	_fclose
	.globl	_PDU_main_form_cat
	.globl	_free_attr_data_buffer
	.globl	_PDUsetup_single_buffer
	.globl	_WaitForEvent
	.globl	_atoi
	.globl	_PDUload_exec_structure
	.globl	_vfork
	.globl	_sscanf
	.globl	_PDMdefine_assembly_structure
	.globl	_PDMradd_part
	.globl	_PDMsget_table_attributes
	.globl	_PDU_value_list
	.globl	_PDUfind_instanceno_in_linklist
	.globl	_PDUfree_assy_linklist
	.globl	_pipe
	.globl	_PDUget_parttype
	.globl	_PDUget_assembly
	.globl	_PDU_second_row
	.globl	_PDU_usage_id
	.globl	_PDMcancel_modify_part
	.globl	_PDUmark_deleted_parts_for_revise_assy
	.globl	_PDUep_rev_fld
	.globl	_PDUfreeze_assy_refresh
	.globl	_MEMbuild_array
	.globl	_PDUfill_in_string
	.globl	_FIf_delete
	.globl	_PDUfree_assy_parts_list
	.globl	_PDU_save_partid
	.globl	_MEMclose
	.globl	_PDMget_catno_partno
	.globl	_PDUupdate_mult_files_for_rev_assy
	.globl	_PDMset_to_state
	.globl	_PDU_parm_data_bufr
	.globl	_PDUext_checkout
	.globl	_PDUadd_parts_for_revise_assy
	.globl	_PDU_file_suffix
	.globl	_fprintf
	.globl	_PDUdesign_options_form
	.globl	_FIfld_set_num_rows
	.globl	_PDUcheck_part_datatype
	.globl	_PDU_level_no
	.globl	_PDUrestore_assy_part_selection_area
	.globl	_PDU_load_assy
	.globl	_PDU_assembly_list
	.globl	_PDUassy_buffer_to_linklist
	.globl	_PDMrdelete_local_files
	.globl	_PDU_copied_files
	.globl	_FIfld_insert_blank_row
	.globl	_PDUadd_blank_row_to_linklist
	.globl	_PDUep_rev_btn
	.globl	_PDUcleanup_attr_retrieval
	.globl	_refresh
	.globl	_PDU_new_assembly
	.globl	_PDUdelete_assy_part
	.globl	_PDU_ret_bufr
	.globl	_FIg_set_state
	.globl	_FIfld_get_text
	.globl	_PDUfree_string_array
	.globl	_PDU_dyn_data_bufr
	.globl	_PDU_load_search_data
	.globl	_PDU_assy_partid
	.globl	__pdm_debug
	.globl	_MEMwrite_data
	.globl	_FIg_get_state
	.globl	_sprintf
	.globl	_PDU_def_assy_bufr
	.globl	_prev_value
	.globl	_PDU_struct_bufr
	.globl	_PDUformat_update_parm_parts_bufr
	.globl	_PDU_assy_revision
	.globl	_FIg_enable
	.globl	_PDU_structure_list
	.globl	_FImcf_set_select
	.globl	_PDUsetup_buffer
	.globl	_PDU_select_area
	.globl	_PDUget_keyin
	.globl	_PDU_os_modified
	.globl	_current_rev_assy
	.globl	_PDUconvert_assy_buffer_to_linklist
	.globl	_PDUverify_file
	.globl	_PDUcheck_char
	.globl	_PDU_parm_list_bufr
	.globl	_FIfld_get_text_length
	.globl	_FIfld_get_active_row
	.globl	_GRcreate_pull_down_list
	.globl	_strrchr
	.globl	_PDUadd_multiple_files_to_linklist
	.globl	_PDU_refresh_gadgets
	.globl	_PDUmessage
	.globl	_FIf_display
	.globl	_PDUformat_buffer
	.globl	_prev_row
	.globl	_PDUload_assembly_structure
	.globl	_PDMcopy
	.globl	_PDU_pchildno
	.globl	_PDUtranslate_message
	.globl	_FIg_reset
	.globl	_PDUplace_part_for_revise_assembly
	.globl	_MEMprint_buffer
	.globl	_MEMprint_buffers
	.globl	_printf
	.globl	_FIfld_set_text
	.globl	_FImcf_set_active_col
	.globl	_PDUdelete_part_for_revise_assembly
	.globl	_PDU_keyin_area
	.globl	_PDUunfreeze_assy_refresh
	.globl	_PDUreplace_part_for_revise_assembly
	.globl	_FIfld_set_select
	.globl	_PDUcheck_file_permissions
	.globl	_PDUvalidate_parttype
	.globl	_PDUcheck_desc_datatype
	.globl	_part_occur_list
	.globl	_PDMmove_functions
	.globl	_PDU_modified_parts_list
	.globl	_PDUis_cyclic_placement
	.globl	_PDU_dyn_value_bufr
	.globl	_PDU_active_button
	.globl	_PDUsearch_part_list
	.globl	_PDU_save_catalog
	.globl	_PDUactive_part_form
	.globl	_fopen
	.globl	_PDU_local_files_displayed
	.globl	_PDUget_storage_filename
	.globl	_PDUrefresh_local_files_form
	.globl	_PDU_checked_out_parts
	.globl	_PDUassy_list_to_ASSY_BUFR
	.globl	_waitpid
	.globl	_PDU_tagno
	.globl	_PDUep_desc_fld
