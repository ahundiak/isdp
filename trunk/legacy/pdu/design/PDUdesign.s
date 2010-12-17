	.file	"PDUdesign.s"
#
# Begin stubs for:  PDUtopdown.o
#
	.data
.T1:	.byte	80, 100, 117, 0
	.byte	112, 100, 117, 47, 100, 101, 115, 105, 103, 110
	.byte	0
	.align	4
.F1:	.long	0x00000700
	.byte	80, 68, 85, 116, 111, 112, 100, 111, 119, 110
	.byte	46, 111, 0
	.text

	.globl	_topdown_notification_routine
_topdown_notification_routine:
	movw	$.T1,r2
	movw	$.F1,r3
	call	sp,Rload
	b	_topdown_notification_routine

	.globl	_PDUcheck_topdown_files
_PDUcheck_topdown_files:
	movw	$.T1,r2
	movw	$.F1,r3
	call	sp,Rload
	b	_PDUcheck_topdown_files

	.globl	_PDUtopdown_form
_PDUtopdown_form:
	movw	$.T1,r2
	movw	$.F1,r3
	call	sp,Rload
	b	_PDUtopdown_form

	.globl	_PDUload_parts_list
_PDUload_parts_list:
	movw	$.T1,r2
	movw	$.F1,r3
	call	sp,Rload
	b	_PDUload_parts_list
#
# Begin stubs for:  PDUplpart.o
#
	.data
	.align	4
.F2:	.long	0x00000700
	.byte	80, 68, 85, 112, 108, 112, 97, 114, 116, 46
	.byte	111, 0
	.text

	.globl	_PDUconvert_dir_to_exp
_PDUconvert_dir_to_exp:
	movw	$.T1,r2
	movw	$.F2,r3
	call	sp,Rload
	b	_PDUconvert_dir_to_exp
#
# Begin stubs for:  PDUverify.o
#
	.data
	.align	4
.F3:	.long	0x00000700
	.byte	80, 68, 85, 118, 101, 114, 105, 102, 121, 46
	.byte	111, 0
	.text

	.globl	_PDUverify_login
_PDUverify_login:
	movw	$.T1,r2
	movw	$.F3,r3
	call	sp,Rload
	b	_PDUverify_login

	.globl	_PDUverify_command
_PDUverify_command:
	movw	$.T1,r2
	movw	$.F3,r3
	call	sp,Rload
	b	_PDUverify_command

	.globl	_PDUverify_part
_PDUverify_part:
	movw	$.T1,r2
	movw	$.F3,r3
	call	sp,Rload
	b	_PDUverify_part

	.globl	_PDUverify_file
_PDUverify_file:
	movw	$.T1,r2
	movw	$.F3,r3
	call	sp,Rload
	b	_PDUverify_file

	.globl	_PDUtopdown_terminate
_PDUtopdown_terminate:
	movw	$.T1,r2
	movw	$.F3,r3
	call	sp,Rload
	b	_PDUtopdown_terminate
#
# Begin stubs for:  PDUexec.o
#
	.data
	.align	4
.F4:	.long	0x00000700
	.byte	80, 68, 85, 101, 120, 101, 99, 46, 111, 0
	.text

	.globl	_PDUinternal
_PDUinternal:
	movw	$.T1,r2
	movw	$.F4,r3
	call	sp,Rload
	b	_PDUinternal

	.globl	_PDUexternal
_PDUexternal:
	movw	$.T1,r2
	movw	$.F4,r3
	call	sp,Rload
	b	_PDUexternal
#
# Begin stubs for:  PDUextern.o
#
	.data
	.align	4
.F5:	.long	0x00000700
	.byte	80, 68, 85, 101, 120, 116, 101, 114, 110, 46
	.byte	111, 0
	.text

	.globl	_PDUext_get_children
_PDUext_get_children:
	movw	$.T1,r2
	movw	$.F5,r3
	call	sp,Rload
	b	_PDUext_get_children

	.globl	_PDUext_list_saved_views
_PDUext_list_saved_views:
	movw	$.T1,r2
	movw	$.F5,r3
	call	sp,Rload
	b	_PDUext_list_saved_views

	.globl	_PDUcopy
_PDUcopy:
	movw	$.T1,r2
	movw	$.F5,r3
	call	sp,Rload
	b	_PDUcopy

	.globl	_PDUcopy_file
_PDUcopy_file:
	movw	$.T1,r2
	movw	$.F5,r3
	call	sp,Rload
	b	_PDUcopy_file

	.globl	_PDUlogout
_PDUlogout:
	movw	$.T1,r2
	movw	$.F5,r3
	call	sp,Rload
	b	_PDUlogout

	.globl	_PDUconnect
_PDUconnect:
	movw	$.T1,r2
	movw	$.F5,r3
	call	sp,Rload
	b	_PDUconnect
#
# Begin stubs for:  PDUglobal.o
#
	.data
	.align	4
.F6:	.long	0x00000700
	.byte	80, 68, 85, 103, 108, 111, 98, 97, 108, 46
	.byte	111, 0
	.text

	.globl	_PDUnfs_toggle
_PDUnfs_toggle:
	movw	$.T1,r2
	movw	$.F6,r3
	call	sp,Rload
	b	_PDUnfs_toggle

	.globl	_PDUtree_toggle
_PDUtree_toggle:
	movw	$.T1,r2
	movw	$.F6,r3
	call	sp,Rload
	b	_PDUtree_toggle
#
# Begin stubs for:  PDUmath.o
#
	.data
	.align	4
.F7:	.long	0x00000700
	.byte	80, 68, 85, 109, 97, 116, 104, 46, 111, 0
	.text

	.globl	_PDUfix_orientation
_PDUfix_orientation:
	movw	$.T1,r2
	movw	$.F7,r3
	call	sp,Rload
	b	_PDUfix_orientation

	.globl	_PDUstring_to_point
_PDUstring_to_point:
	movw	$.T1,r2
	movw	$.F7,r3
	call	sp,Rload
	b	_PDUstring_to_point

	.globl	_PDUdump_point
_PDUdump_point:
	movw	$.T1,r2
	movw	$.F7,r3
	call	sp,Rload
	b	_PDUdump_point
#
# Begin stubs for:  PDUrefresh.o
#
	.data
	.align	4
.F8:	.long	0x00000700
	.byte	80, 68, 85, 114, 101, 102, 114, 101, 115, 104
	.byte	46, 111, 0
	.text

	.globl	_PDUalloc_refresh
_PDUalloc_refresh:
	movw	$.T1,r2
	movw	$.F8,r3
	call	sp,Rload
	b	_PDUalloc_refresh

	.globl	_PDUdealloc_refresh
_PDUdealloc_refresh:
	movw	$.T1,r2
	movw	$.F8,r3
	call	sp,Rload
	b	_PDUdealloc_refresh

	.globl	_PDUread_refresh
_PDUread_refresh:
	movw	$.T1,r2
	movw	$.F8,r3
	call	sp,Rload
	b	_PDUread_refresh

	.globl	_PDUwrite_refresh
_PDUwrite_refresh:
	movw	$.T1,r2
	movw	$.F8,r3
	call	sp,Rload
	b	_PDUwrite_refresh

	.globl	_PDUload_refresh
_PDUload_refresh:
	movw	$.T1,r2
	movw	$.F8,r3
	call	sp,Rload
	b	_PDUload_refresh

	.globl	_PDUunload_refresh
_PDUunload_refresh:
	movw	$.T1,r2
	movw	$.F8,r3
	call	sp,Rload
	b	_PDUunload_refresh
#
# Begin stubs for:  PDUtools.o
#
	.data
	.align	4
.F9:	.long	0x00000700
	.byte	80, 68, 85, 116, 111, 111, 108, 115, 46, 111
	.byte	0
	.text

	.globl	_PDUget_search_path
_PDUget_search_path:
	movw	$.T1,r2
	movw	$.F9,r3
	call	sp,Rload
	b	_PDUget_search_path

	.globl	_PDUunquote
_PDUunquote:
	movw	$.T1,r2
	movw	$.F9,r3
	call	sp,Rload
	b	_PDUunquote

	.globl	_PDUlstrcmp
_PDUlstrcmp:
	movw	$.T1,r2
	movw	$.F9,r3
	call	sp,Rload
	b	_PDUlstrcmp

	.globl	_PDUget_date
_PDUget_date:
	movw	$.T1,r2
	movw	$.F9,r3
	call	sp,Rload
	b	_PDUget_date

	.globl	_PDUsetlevels
_PDUsetlevels:
	movw	$.T1,r2
	movw	$.F9,r3
	call	sp,Rload
	b	_PDUsetlevels

	.globl	_PDUextract_dir_value
_PDUextract_dir_value:
	movw	$.T1,r2
	movw	$.F9,r3
	call	sp,Rload
	b	_PDUextract_dir_value

	.globl	_PDUcheck_expression_value
_PDUcheck_expression_value:
	movw	$.T1,r2
	movw	$.F9,r3
	call	sp,Rload
	b	_PDUcheck_expression_value

	.globl	_PDUmodify_assy_entry
_PDUmodify_assy_entry:
	movw	$.T1,r2
	movw	$.F9,r3
	call	sp,Rload
	b	_PDUmodify_assy_entry

	.globl	_PDUprocess_pulldown_list
_PDUprocess_pulldown_list:
	movw	$.T1,r2
	movw	$.F9,r3
	call	sp,Rload
	b	_PDUprocess_pulldown_list

	.globl	_PDUprocess_dyn_pulldown_list
_PDUprocess_dyn_pulldown_list:
	movw	$.T1,r2
	movw	$.F9,r3
	call	sp,Rload
	b	_PDUprocess_dyn_pulldown_list

	.globl	_PDUfill_attribute_list
_PDUfill_attribute_list:
	movw	$.T1,r2
	movw	$.F9,r3
	call	sp,Rload
	b	_PDUfill_attribute_list

	.globl	_PDUfill_attribute_list1
_PDUfill_attribute_list1:
	movw	$.T1,r2
	movw	$.F9,r3
	call	sp,Rload
	b	_PDUfill_attribute_list1

	.globl	_PDUvalidate_data_value
_PDUvalidate_data_value:
	movw	$.T1,r2
	movw	$.F9,r3
	call	sp,Rload
	b	_PDUvalidate_data_value

	.globl	_PDUvalidate_dyn_data_value
_PDUvalidate_dyn_data_value:
	movw	$.T1,r2
	movw	$.F9,r3
	call	sp,Rload
	b	_PDUvalidate_dyn_data_value

	.globl	_PDUcheck_file_permissions
_PDUcheck_file_permissions:
	movw	$.T1,r2
	movw	$.F9,r3
	call	sp,Rload
	b	_PDUcheck_file_permissions

	.globl	_PDUget_param_data
_PDUget_param_data:
	movw	$.T1,r2
	movw	$.F9,r3
	call	sp,Rload
	b	_PDUget_param_data

	.globl	_PDUstrip_dir_entry
_PDUstrip_dir_entry:
	movw	$.T1,r2
	movw	$.F9,r3
	call	sp,Rload
	b	_PDUstrip_dir_entry

	.globl	_convert_tolower
_convert_tolower:
	movw	$.T1,r2
	movw	$.F9,r3
	call	sp,Rload
	b	_convert_tolower

	.globl	_PDUchmod
_PDUchmod:
	movw	$.T1,r2
	movw	$.F9,r3
	call	sp,Rload
	b	_PDUchmod

	.globl	_PDUget_seed_file
_PDUget_seed_file:
	movw	$.T1,r2
	movw	$.F9,r3
	call	sp,Rload
	b	_PDUget_seed_file

	.globl	_PDUcopyOS_file
_PDUcopyOS_file:
	movw	$.T1,r2
	movw	$.F9,r3
	call	sp,Rload
	b	_PDUcopyOS_file

	.globl	_PDUconvert_form_to_win
_PDUconvert_form_to_win:
	movw	$.T1,r2
	movw	$.F9,r3
	call	sp,Rload
	b	_PDUconvert_form_to_win

	.globl	_PDUcheck_PDU_form_display
_PDUcheck_PDU_form_display:
	movw	$.T1,r2
	movw	$.F9,r3
	call	sp,Rload
	b	_PDUcheck_PDU_form_display

	.globl	_Check_displayed_forms
_Check_displayed_forms:
	movw	$.T1,r2
	movw	$.F9,r3
	call	sp,Rload
	b	_Check_displayed_forms

	.globl	_PDUis_part_in_buffer
_PDUis_part_in_buffer:
	movw	$.T1,r2
	movw	$.F9,r3
	call	sp,Rload
	b	_PDUis_part_in_buffer
#
# Begin stubs for:  PDUdsgn_frm.o
#
	.data
	.align	4
.F10:	.long	0x00000700
	.byte	80, 68, 85, 100, 115, 103, 110, 95, 102, 114
	.byte	109, 46, 111, 0
	.text

	.globl	_design_form_notification_routine
_design_form_notification_routine:
	movw	$.T1,r2
	movw	$.F10,r3
	call	sp,Rload
	b	_design_form_notification_routine

	.globl	_PDUcheck_file_for_origins
_PDUcheck_file_for_origins:
	movw	$.T1,r2
	movw	$.F10,r3
	call	sp,Rload
	b	_PDUcheck_file_for_origins

	.globl	_PDUcheck_file_for_parts
_PDUcheck_file_for_parts:
	movw	$.T1,r2
	movw	$.F10,r3
	call	sp,Rload
	b	_PDUcheck_file_for_parts

	.globl	_PDUcheck_if_file_an_assembly
_PDUcheck_if_file_an_assembly:
	movw	$.T1,r2
	movw	$.F10,r3
	call	sp,Rload
	b	_PDUcheck_if_file_an_assembly

	.globl	_design_form
_design_form:
	movw	$.T1,r2
	movw	$.F10,r3
	call	sp,Rload
	b	_design_form

	.globl	_PDUdesign_form
_PDUdesign_form:
	movw	$.T1,r2
	movw	$.F10,r3
	call	sp,Rload
	b	_PDUdesign_form

	.globl	_PDUupdate_design_form
_PDUupdate_design_form:
	movw	$.T1,r2
	movw	$.F10,r3
	call	sp,Rload
	b	_PDUupdate_design_form

	.globl	_PDUsetup_design_struct
_PDUsetup_design_struct:
	movw	$.T1,r2
	movw	$.F10,r3
	call	sp,Rload
	b	_PDUsetup_design_struct

	.globl	_PDUdisplay_design_form
_PDUdisplay_design_form:
	movw	$.T1,r2
	movw	$.F10,r3
	call	sp,Rload
	b	_PDUdisplay_design_form

	.globl	_PDUupdate_active_part_info
_PDUupdate_active_part_info:
	movw	$.T1,r2
	movw	$.F10,r3
	call	sp,Rload
	b	_PDUupdate_active_part_info
#
# Begin stubs for:  PDUdyn_form.o
#
	.data
	.align	4
.F11:	.long	0x00000700
	.byte	80, 68, 85, 100, 121, 110, 95, 102, 111, 114
	.byte	109, 46, 111, 0
	.text

	.globl	_dynamic_attr_notification_routine
_dynamic_attr_notification_routine:
	movw	$.T1,r2
	movw	$.F11,r3
	call	sp,Rload
	b	_dynamic_attr_notification_routine

	.globl	_PDUcheck_for_required_data
_PDUcheck_for_required_data:
	movw	$.T1,r2
	movw	$.F11,r3
	call	sp,Rload
	b	_PDUcheck_for_required_data

	.globl	_PDUadd_static_dyn_attributes
_PDUadd_static_dyn_attributes:
	movw	$.T1,r2
	movw	$.F11,r3
	call	sp,Rload
	b	_PDUadd_static_dyn_attributes

	.globl	_PDUadd_dyn_data
_PDUadd_dyn_data:
	movw	$.T1,r2
	movw	$.F11,r3
	call	sp,Rload
	b	_PDUadd_dyn_data

	.globl	_dynamic_attr_form
_dynamic_attr_form:
	movw	$.T1,r2
	movw	$.F11,r3
	call	sp,Rload
	b	_dynamic_attr_form

	.globl	_PDUdynamic_attr_form
_PDUdynamic_attr_form:
	movw	$.T1,r2
	movw	$.F11,r3
	call	sp,Rload
	b	_PDUdynamic_attr_form

	.globl	_PDUdisplay_dynamic_form
_PDUdisplay_dynamic_form:
	movw	$.T1,r2
	movw	$.F11,r3
	call	sp,Rload
	b	_PDUdisplay_dynamic_form

	.globl	_PDUdynamics_for_part
_PDUdynamics_for_part:
	movw	$.T1,r2
	movw	$.F11,r3
	call	sp,Rload
	b	_PDUdynamics_for_part

	.globl	_PDUmerge_dynamic_attribute_bufrs
_PDUmerge_dynamic_attribute_bufrs:
	movw	$.T1,r2
	movw	$.F11,r3
	call	sp,Rload
	b	_PDUmerge_dynamic_attribute_bufrs

	.globl	_PDUfilter_dynamic_attribute_bufrs
_PDUfilter_dynamic_attribute_bufrs:
	movw	$.T1,r2
	movw	$.F11,r3
	call	sp,Rload
	b	_PDUfilter_dynamic_attribute_bufrs

	.globl	_PDUdefault_values_for_copy_parametric_part
_PDUdefault_values_for_copy_parametric_part:
	movw	$.T1,r2
	movw	$.F11,r3
	call	sp,Rload
	b	_PDUdefault_values_for_copy_parametric_part

	.globl	_PDUcheck_display_dynamic_attr
_PDUcheck_display_dynamic_attr:
	movw	$.T1,r2
	movw	$.F11,r3
	call	sp,Rload
	b	_PDUcheck_display_dynamic_attr

	.globl	_PDUupdate_dynamics
_PDUupdate_dynamics:
	movw	$.T1,r2
	movw	$.F11,r3
	call	sp,Rload
	b	_PDUupdate_dynamics
#
# Begin stubs for:  PDUvalid.o
#
	.data
	.align	4
.F12:	.long	0x00000700
	.byte	80, 68, 85, 118, 97, 108, 105, 100, 46, 111
	.byte	0
	.text

	.globl	_PDUvalidate_quantity
_PDUvalidate_quantity:
	movw	$.T1,r2
	movw	$.F12,r3
	call	sp,Rload
	b	_PDUvalidate_quantity

	.globl	_PDUvalid_filename
_PDUvalid_filename:
	movw	$.T1,r2
	movw	$.F12,r3
	call	sp,Rload
	b	_PDUvalid_filename
#
# Begin stubs for:  PDUopt_form.o
#
	.data
	.align	4
.F13:	.long	0x00000700
	.byte	80, 68, 85, 111, 112, 116, 95, 102, 111, 114
	.byte	109, 46, 111, 0
	.text

	.globl	_design_options_notification_routine
_design_options_notification_routine:
	movw	$.T1,r2
	movw	$.F13,r3
	call	sp,Rload
	b	_design_options_notification_routine

	.globl	_design_options_form
_design_options_form:
	movw	$.T1,r2
	movw	$.F13,r3
	call	sp,Rload
	b	_design_options_form

	.globl	_PDUdesign_options_form
_PDUdesign_options_form:
	movw	$.T1,r2
	movw	$.F13,r3
	call	sp,Rload
	b	_PDUdesign_options_form
#
# Begin stubs for:  PDUdsp_att.o
#
	.data
	.align	4
.F14:	.long	0x00000700
	.byte	80, 68, 85, 100, 115, 112, 95, 97, 116, 116
	.byte	46, 111, 0
	.text

	.globl	_PDUdisplay_views
_PDUdisplay_views:
	movw	$.T1,r2
	movw	$.F14,r3
	call	sp,Rload
	b	_PDUdisplay_views

	.globl	_PDUdisplay_views_single
_PDUdisplay_views_single:
	movw	$.T1,r2
	movw	$.F14,r3
	call	sp,Rload
	b	_PDUdisplay_views_single

	.globl	_PDUdisplay_files
_PDUdisplay_files:
	movw	$.T1,r2
	movw	$.F14,r3
	call	sp,Rload
	b	_PDUdisplay_files

	.globl	_PDUdisplay_checkin_files
_PDUdisplay_checkin_files:
	movw	$.T1,r2
	movw	$.F14,r3
	call	sp,Rload
	b	_PDUdisplay_checkin_files
#
# Begin stubs for:  PDUatt_list.o
#
	.data
	.align	4
.F15:	.long	0x00000700
	.byte	80, 68, 85, 97, 116, 116, 95, 108, 105, 115
	.byte	116, 46, 111, 0
	.text

	.globl	_attach_single_list_notification_routine
_attach_single_list_notification_routine:
	movw	$.T1,r2
	movw	$.F15,r3
	call	sp,Rload
	b	_attach_single_list_notification_routine

	.globl	_PDUattach_single_list_form
_PDUattach_single_list_form:
	movw	$.T1,r2
	movw	$.F15,r3
	call	sp,Rload
	b	_PDUattach_single_list_form

	.globl	_PDUattach_single_list_form_single
_PDUattach_single_list_form_single:
	movw	$.T1,r2
	movw	$.F15,r3
	call	sp,Rload
	b	_PDUattach_single_list_form_single
#
# Begin stubs for:  PDUdebug.o
#
	.data
	.align	4
.F16:	.long	0x00000700
	.byte	80, 68, 85, 100, 101, 98, 117, 103, 46, 111
	.byte	0
	.text

	.globl	__pdm_debug
__pdm_debug:
	movw	$.T1,r2
	movw	$.F16,r3
	call	sp,Rload
	b	__pdm_debug

	.globl	__pdm_rstatus
__pdm_rstatus:
	movw	$.T1,r2
	movw	$.F16,r3
	call	sp,Rload
	b	__pdm_rstatus

	.globl	__pdm_rstatus2
__pdm_rstatus2:
	movw	$.T1,r2
	movw	$.F16,r3
	call	sp,Rload
	b	__pdm_rstatus2

	.globl	__pdm_status
__pdm_status:
	movw	$.T1,r2
	movw	$.F16,r3
	call	sp,Rload
	b	__pdm_status

	.globl	__pdm_status2
__pdm_status2:
	movw	$.T1,r2
	movw	$.F16,r3
	call	sp,Rload
	b	__pdm_status2

	.globl	__pdm_debug_list
__pdm_debug_list:
	movw	$.T1,r2
	movw	$.F16,r3
	call	sp,Rload
	b	__pdm_debug_list

	.globl	__pdm_colptr
__pdm_colptr:
	movw	$.T1,r2
	movw	$.F16,r3
	call	sp,Rload
	b	__pdm_colptr

	.globl	_PDUnullstr
_PDUnullstr:
	movw	$.T1,r2
	movw	$.F16,r3
	call	sp,Rload
	b	_PDUnullstr
#
# Begin stubs for:  PDUdsgn_list.o
#
	.data
	.align	4
.F17:	.long	0x00000700
	.byte	80, 68, 85, 100, 115, 103, 110, 95, 108, 105
	.byte	115, 116, 46, 111, 0
	.text

	.globl	_design_parts_notification_routine
_design_parts_notification_routine:
	movw	$.T1,r2
	movw	$.F17,r3
	call	sp,Rload
	b	_design_parts_notification_routine

	.globl	_PDUload_list_parts_info
_PDUload_list_parts_info:
	movw	$.T1,r2
	movw	$.F17,r3
	call	sp,Rload
	b	_PDUload_list_parts_info

	.globl	_design_parts_listing_form
_design_parts_listing_form:
	movw	$.T1,r2
	movw	$.F17,r3
	call	sp,Rload
	b	_design_parts_listing_form

	.globl	_PDUload_design_parts_listing_form
_PDUload_design_parts_listing_form:
	movw	$.T1,r2
	movw	$.F17,r3
	call	sp,Rload
	b	_PDUload_design_parts_listing_form

	.globl	_PDUdesign_parts_listing_form
_PDUdesign_parts_listing_form:
	movw	$.T1,r2
	movw	$.F17,r3
	call	sp,Rload
	b	_PDUdesign_parts_listing_form

	.globl	_PDUupdate_design_parts_listing_form
_PDUupdate_design_parts_listing_form:
	movw	$.T1,r2
	movw	$.F17,r3
	call	sp,Rload
	b	_PDUupdate_design_parts_listing_form
#
# Begin stubs for:  PDUatt_orig.o
#
	.data
	.align	4
.F18:	.long	0x00000700
	.byte	80, 68, 85, 97, 116, 116, 95, 111, 114, 105
	.byte	103, 46, 111, 0
	.text

	.globl	_origin_list_notification_routine
_origin_list_notification_routine:
	movw	$.T1,r2
	movw	$.F18,r3
	call	sp,Rload
	b	_origin_list_notification_routine

	.globl	_PDUload_origins
_PDUload_origins:
	movw	$.T1,r2
	movw	$.F18,r3
	call	sp,Rload
	b	_PDUload_origins

	.globl	_PDUdisplay_origins
_PDUdisplay_origins:
	movw	$.T1,r2
	movw	$.F18,r3
	call	sp,Rload
	b	_PDUdisplay_origins
#
# Begin stubs for:  PDUdsgnapi.o
#
	.data
	.align	4
.F19:	.long	0x00000700
	.byte	80, 68, 85, 100, 115, 103, 110, 97, 112, 105
	.byte	46, 111, 0
	.text

	.globl	_PDUformat_buffer
_PDUformat_buffer:
	movw	$.T1,r2
	movw	$.F19,r3
	call	sp,Rload
	b	_PDUformat_buffer

	.globl	_PDUdealloc
_PDUdealloc:
	movw	$.T1,r2
	movw	$.F19,r3
	call	sp,Rload
	b	_PDUdealloc

	.globl	_PDUstrcpy
_PDUstrcpy:
	movw	$.T1,r2
	movw	$.F19,r3
	call	sp,Rload
	b	_PDUstrcpy

	.globl	_PDUset_debug
_PDUset_debug:
	movw	$.T1,r2
	movw	$.F19,r3
	call	sp,Rload
	b	_PDUset_debug

	.globl	_PDUwork_controller
_PDUwork_controller:
	movw	$.T1,r2
	movw	$.F19,r3
	call	sp,Rload
	b	_PDUwork_controller

	.globl	_PDUvalidate_api_data_value
_PDUvalidate_api_data_value:
	movw	$.T1,r2
	movw	$.F19,r3
	call	sp,Rload
	b	_PDUvalidate_api_data_value

	.globl	_PDUcheck_for_function
_PDUcheck_for_function:
	movw	$.T1,r2
	movw	$.F19,r3
	call	sp,Rload
	b	_PDUcheck_for_function

	.globl	_PDUis_cyclic_placement
_PDUis_cyclic_placement:
	movw	$.T1,r2
	movw	$.F19,r3
	call	sp,Rload
	b	_PDUis_cyclic_placement
#
# Begin stubs for:  PDUexfrm_tls.o
#
	.data
	.align	4
.F20:	.long	0x00000700
	.byte	80, 68, 85, 101, 120, 102, 114, 109, 95, 116
	.byte	108, 115, 46, 111, 0
	.text

	.globl	_PDUprocess_ex_file_form
_PDUprocess_ex_file_form:
	movw	$.T1,r2
	movw	$.F20,r3
	call	sp,Rload
	b	_PDUprocess_ex_file_form

	.globl	_PDUprocess_ex_file_form_after_select
_PDUprocess_ex_file_form_after_select:
	movw	$.T1,r2
	movw	$.F20,r3
	call	sp,Rload
	b	_PDUprocess_ex_file_form_after_select

	.globl	_PDUprocess_ex_file_form_after_login
_PDUprocess_ex_file_form_after_login:
	movw	$.T1,r2
	movw	$.F20,r3
	call	sp,Rload
	b	_PDUprocess_ex_file_form_after_login

	.globl	_PDUprocess_ex_file_form_after_seed_file
_PDUprocess_ex_file_form_after_seed_file:
	movw	$.T1,r2
	movw	$.F20,r3
	call	sp,Rload
	b	_PDUprocess_ex_file_form_after_seed_file
#
# Begin stubs for:  PDUtdseed.o
#
	.data
	.align	4
.F21:	.long	0x00000700
	.byte	80, 68, 85, 116, 100, 115, 101, 101, 100, 46
	.byte	111, 0
	.text

	.globl	_PDUtopdown_seed_form_init
_PDUtopdown_seed_form_init:
	movw	$.T1,r2
	movw	$.F21,r3
	call	sp,Rload
	b	_PDUtopdown_seed_form_init

	.globl	_PDUtopdown_cancel_seedfile_form
_PDUtopdown_cancel_seedfile_form:
	movw	$.T1,r2
	movw	$.F21,r3
	call	sp,Rload
	b	_PDUtopdown_cancel_seedfile_form

	.globl	_PDUtopdown_accept_seed_file_form
_PDUtopdown_accept_seed_file_form:
	movw	$.T1,r2
	movw	$.F21,r3
	call	sp,Rload
	b	_PDUtopdown_accept_seed_file_form

	.globl	_PDUtopdown_seed_file_toggle
_PDUtopdown_seed_file_toggle:
	movw	$.T1,r2
	movw	$.F21,r3
	call	sp,Rload
	b	_PDUtopdown_seed_file_toggle

	.globl	_PDUtopdown_catalog_field
_PDUtopdown_catalog_field:
	movw	$.T1,r2
	movw	$.F21,r3
	call	sp,Rload
	b	_PDUtopdown_catalog_field

	.globl	_PDUtopdown_part_field
_PDUtopdown_part_field:
	movw	$.T1,r2
	movw	$.F21,r3
	call	sp,Rload
	b	_PDUtopdown_part_field

	.globl	_PDUtopdown_revision_field
_PDUtopdown_revision_field:
	movw	$.T1,r2
	movw	$.F21,r3
	call	sp,Rload
	b	_PDUtopdown_revision_field

	.globl	_PDUtopdown_filename_field
_PDUtopdown_filename_field:
	movw	$.T1,r2
	movw	$.F21,r3
	call	sp,Rload
	b	_PDUtopdown_filename_field

	.globl	_PDUtopdown_desc_field
_PDUtopdown_desc_field:
	movw	$.T1,r2
	movw	$.F21,r3
	call	sp,Rload
	b	_PDUtopdown_desc_field

	.globl	_PDUtopdown_catalog_btn
_PDUtopdown_catalog_btn:
	movw	$.T1,r2
	movw	$.F21,r3
	call	sp,Rload
	b	_PDUtopdown_catalog_btn

	.globl	_PDUtopdown_part_btn
_PDUtopdown_part_btn:
	movw	$.T1,r2
	movw	$.F21,r3
	call	sp,Rload
	b	_PDUtopdown_part_btn

	.globl	_PDUtopdown_revision_btn
_PDUtopdown_revision_btn:
	movw	$.T1,r2
	movw	$.F21,r3
	call	sp,Rload
	b	_PDUtopdown_revision_btn

	.globl	_PDUtopdown_filename_btn
_PDUtopdown_filename_btn:
	movw	$.T1,r2
	movw	$.F21,r3
	call	sp,Rload
	b	_PDUtopdown_filename_btn

	.globl	_PDUtopdown_search_btn
_PDUtopdown_search_btn:
	movw	$.T1,r2
	movw	$.F21,r3
	call	sp,Rload
	b	_PDUtopdown_search_btn
#
# Begin stubs for:  PDUactdeact.o
#
	.data
	.align	4
.F22:	.long	0x00000700
	.byte	80, 68, 85, 97, 99, 116, 100, 101, 97, 99
	.byte	116, 46, 111, 0
	.text

	.globl	_PDUactivate
_PDUactivate:
	movw	$.T1,r2
	movw	$.F22,r3
	call	sp,Rload
	b	_PDUactivate

	.globl	_PDUfree_attach_mac_list
_PDUfree_attach_mac_list:
	movw	$.T1,r2
	movw	$.F22,r3
	call	sp,Rload
	b	_PDUfree_attach_mac_list

	.globl	_PDUprepare_queue
_PDUprepare_queue:
	movw	$.T1,r2
	movw	$.F22,r3
	call	sp,Rload
	b	_PDUprepare_queue

	.globl	_PDUcheck_os_tag_count
_PDUcheck_os_tag_count:
	movw	$.T1,r2
	movw	$.F22,r3
	call	sp,Rload
	b	_PDUcheck_os_tag_count

	.globl	_PDUcheck_os_tag_count_for_create_graphics
_PDUcheck_os_tag_count_for_create_graphics:
	movw	$.T1,r2
	movw	$.F22,r3
	call	sp,Rload
	b	_PDUcheck_os_tag_count_for_create_graphics

	.globl	_PDUdeactivate
_PDUdeactivate:
	movw	$.T1,r2
	movw	$.F22,r3
	call	sp,Rload
	b	_PDUdeactivate

	.globl	_PDUput_queue
_PDUput_queue:
	movw	$.T1,r2
	movw	$.F22,r3
	call	sp,Rload
	b	_PDUput_queue

	.globl	_PDUfinish_activate
_PDUfinish_activate:
	movw	$.T1,r2
	movw	$.F22,r3
	call	sp,Rload
	b	_PDUfinish_activate

	.globl	_PDUchange_review_file_permissions
_PDUchange_review_file_permissions:
	movw	$.T1,r2
	movw	$.F22,r3
	call	sp,Rload
	b	_PDUchange_review_file_permissions
#
# Begin stubs for:  PDUmessage.o
#
	.data
	.align	4
.F23:	.long	0x00000700
	.byte	80, 68, 85, 109, 101, 115, 115, 97, 103, 101
	.byte	46, 111, 0
	.text

	.globl	_PDUmessage_trans
_PDUmessage_trans:
	movw	$.T1,r2
	movw	$.F23,r3
	call	sp,Rload
	b	_PDUmessage_trans

	.globl	_PDUwf_check
_PDUwf_check:
	movw	$.T1,r2
	movw	$.F23,r3
	call	sp,Rload
	b	_PDUwf_check

	.globl	_PDUmessage
_PDUmessage:
	movw	$.T1,r2
	movw	$.F23,r3
	call	sp,Rload
	b	_PDUmessage

	.globl	_PDUget_var
_PDUget_var:
	movw	$.T1,r2
	movw	$.F23,r3
	call	sp,Rload
	b	_PDUget_var
#
# Begin stubs for:  PDUdsgnmsg.o
#
	.data
	.align	4
.F24:	.long	0x00000700
	.byte	80, 68, 85, 100, 115, 103, 110, 109, 115, 103
	.byte	46, 111, 0
	.text

	.globl	_PDUtranslate_message
_PDUtranslate_message:
	movw	$.T1,r2
	movw	$.F24,r3
	call	sp,Rload
	b	_PDUtranslate_message

	.globl	_PDUtranslate_UMS_message
_PDUtranslate_UMS_message:
	movw	$.T1,r2
	movw	$.F24,r3
	call	sp,Rload
	b	_PDUtranslate_UMS_message

	.globl	_PDUmsgs_to_attrs
_PDUmsgs_to_attrs:
	movw	$.T1,r2
	movw	$.F24,r3
	call	sp,Rload
	b	_PDUmsgs_to_attrs

	.globl	_PDUmsgs_to_cols
_PDUmsgs_to_cols:
	movw	$.T1,r2
	movw	$.F24,r3
	call	sp,Rload
	b	_PDUmsgs_to_cols

	.globl	_PDUpercent_complete
_PDUpercent_complete:
	movw	$.T1,r2
	movw	$.F24,r3
	call	sp,Rload
	b	_PDUpercent_complete

	.globl	_PDUtranslate_message_and_vars
_PDUtranslate_message_and_vars:
	movw	$.T1,r2
	movw	$.F24,r3
	call	sp,Rload
	b	_PDUtranslate_message_and_vars

	.globl	_PDUinitialize_help
_PDUinitialize_help:
	movw	$.T1,r2
	movw	$.F24,r3
	call	sp,Rload
	b	_PDUinitialize_help
#
# Begin stubs for:  PDUm_view_pt.o
#
	.data
	.align	4
.F25:	.long	0x00000700
	.byte	80, 68, 85, 109, 95, 118, 105, 101, 119, 95
	.byte	112, 116, 46, 111, 0
	.text

	.globl	_PDUm_review_pt
_PDUm_review_pt:
	movw	$.T1,r2
	movw	$.F25,r3
	call	sp,Rload
	b	_PDUm_review_pt
#
# Begin stubs for:  PDUmlibutil.o
#
	.data
	.align	4
.F26:	.long	0x00000700
	.byte	80, 68, 85, 109, 108, 105, 98, 117, 116, 105
	.byte	108, 46, 111, 0
	.text

	.globl	_PDUis_maclib_writable
_PDUis_maclib_writable:
	movw	$.T1,r2
	movw	$.F26,r3
	call	sp,Rload
	b	_PDUis_maclib_writable
#
# Begin stubs for:  PDUdirectory.o
#
	.data
	.align	4
.F27:	.long	0x00000700
	.byte	80, 68, 85, 100, 105, 114, 101, 99, 116, 111
	.byte	114, 121, 46, 111, 0
	.text

	.globl	_PDUcheck_uniqueness
_PDUcheck_uniqueness:
	movw	$.T1,r2
	movw	$.F27,r3
	call	sp,Rload
	b	_PDUcheck_uniqueness

	.globl	_PDUget_dyn_attr_value
_PDUget_dyn_attr_value:
	movw	$.T1,r2
	movw	$.F27,r3
	call	sp,Rload
	b	_PDUget_dyn_attr_value

	.globl	_PDUupdate_dir_value
_PDUupdate_dir_value:
	movw	$.T1,r2
	movw	$.F27,r3
	call	sp,Rload
	b	_PDUupdate_dir_value

	.globl	_PDUget_tag_no
_PDUget_tag_no:
	movw	$.T1,r2
	movw	$.F27,r3
	call	sp,Rload
	b	_PDUget_tag_no

	.globl	_PDUget_alttag_no
_PDUget_alttag_no:
	movw	$.T1,r2
	movw	$.F27,r3
	call	sp,Rload
	b	_PDUget_alttag_no

	.globl	_PDUcheck_tag_count
_PDUcheck_tag_count:
	movw	$.T1,r2
	movw	$.F27,r3
	call	sp,Rload
	b	_PDUcheck_tag_count

	.globl	_PDUget_incbom
_PDUget_incbom:
	movw	$.T1,r2
	movw	$.F27,r3
	call	sp,Rload
	b	_PDUget_incbom

	.globl	_PDUget_incasm
_PDUget_incasm:
	movw	$.T1,r2
	movw	$.F27,r3
	call	sp,Rload
	b	_PDUget_incasm

	.globl	_PDUget_explodebom
_PDUget_explodebom:
	movw	$.T1,r2
	movw	$.F27,r3
	call	sp,Rload
	b	_PDUget_explodebom

	.globl	_PDUremove_tree
_PDUremove_tree:
	movw	$.T1,r2
	movw	$.F27,r3
	call	sp,Rload
	b	_PDUremove_tree

	.globl	_PDUget_exp_objects
_PDUget_exp_objects:
	movw	$.T1,r2
	movw	$.F27,r3
	call	sp,Rload
	b	_PDUget_exp_objects

	.globl	_PDUevaluate_dyn_attr_expression
_PDUevaluate_dyn_attr_expression:
	movw	$.T1,r2
	movw	$.F27,r3
	call	sp,Rload
	b	_PDUevaluate_dyn_attr_expression

	.globl	_PDUconvert_dyn_attrs
_PDUconvert_dyn_attrs:
	movw	$.T1,r2
	movw	$.F27,r3
	call	sp,Rload
	b	_PDUconvert_dyn_attrs

	.globl	_PDUextract_catpartrev_entries
_PDUextract_catpartrev_entries:
	movw	$.T1,r2
	movw	$.F27,r3
	call	sp,Rload
	b	_PDUextract_catpartrev_entries

	.globl	_PDUcheck_if_need_conversion
_PDUcheck_if_need_conversion:
	movw	$.T1,r2
	movw	$.F27,r3
	call	sp,Rload
	b	_PDUcheck_if_need_conversion

	.globl	_PDUflag_object_space
_PDUflag_object_space:
	movw	$.T1,r2
	movw	$.F27,r3
	call	sp,Rload
	b	_PDUflag_object_space

	.globl	_PDU_remove_dir_tree
_PDU_remove_dir_tree:
	movw	$.T1,r2
	movw	$.F27,r3
	call	sp,Rload
	b	_PDU_remove_dir_tree
#
# Begin stubs for:  PDUpointer.o
#
	.data
	.align	4
.F28:	.long	0x00000700
	.byte	80, 68, 85, 112, 111, 105, 110, 116, 101, 114
	.byte	46, 111, 0
	.text

	.globl	_PDUset_invis_vwname
_PDUset_invis_vwname:
	movw	$.T1,r2
	movw	$.F28,r3
	call	sp,Rload
	b	_PDUset_invis_vwname

	.globl	_PDUget_attr
_PDUget_attr:
	movw	$.T1,r2
	movw	$.F28,r3
	call	sp,Rload
	b	_PDUget_attr

	.globl	_PDUdump_matrix
_PDUdump_matrix:
	movw	$.T1,r2
	movw	$.F28,r3
	call	sp,Rload
	b	_PDUdump_matrix

	.globl	_PDUmatrix_to_string
_PDUmatrix_to_string:
	movw	$.T1,r2
	movw	$.F28,r3
	call	sp,Rload
	b	_PDUmatrix_to_string

	.globl	_PDUset_default_file
_PDUset_default_file:
	movw	$.T1,r2
	movw	$.F28,r3
	call	sp,Rload
	b	_PDUset_default_file

	.globl	_PDUvalidate_alt_tag
_PDUvalidate_alt_tag:
	movw	$.T1,r2
	movw	$.F28,r3
	call	sp,Rload
	b	_PDUvalidate_alt_tag

	.globl	_PDUextract_dyn_attr_value
_PDUextract_dyn_attr_value:
	movw	$.T1,r2
	movw	$.F28,r3
	call	sp,Rload
	b	_PDUextract_dyn_attr_value

	.globl	_PDUcreate_expression
_PDUcreate_expression:
	movw	$.T1,r2
	movw	$.F28,r3
	call	sp,Rload
	b	_PDUcreate_expression

	.globl	_PDUmodify_expression
_PDUmodify_expression:
	movw	$.T1,r2
	movw	$.F28,r3
	call	sp,Rload
	b	_PDUmodify_expression

	.globl	_PDUdelete_expression
_PDUdelete_expression:
	movw	$.T1,r2
	movw	$.F28,r3
	call	sp,Rload
	b	_PDUdelete_expression

	.globl	_PDUevaluate_expression
_PDUevaluate_expression:
	movw	$.T1,r2
	movw	$.F28,r3
	call	sp,Rload
	b	_PDUevaluate_expression

	.globl	_PDUextract_expression_RHS
_PDUextract_expression_RHS:
	movw	$.T1,r2
	movw	$.F28,r3
	call	sp,Rload
	b	_PDUextract_expression_RHS

	.globl	_PDUcopy_expression
_PDUcopy_expression:
	movw	$.T1,r2
	movw	$.F28,r3
	call	sp,Rload
	b	_PDUcopy_expression

	.globl	_PDUapoint_to_matrix
_PDUapoint_to_matrix:
	movw	$.T1,r2
	movw	$.F28,r3
	call	sp,Rload
	b	_PDUapoint_to_matrix

	.globl	_PDUmatrix_to_point
_PDUmatrix_to_point:
	movw	$.T1,r2
	movw	$.F28,r3
	call	sp,Rload
	b	_PDUmatrix_to_point

	.globl	_PDUadd_points
_PDUadd_points:
	movw	$.T1,r2
	movw	$.F28,r3
	call	sp,Rload
	b	_PDUadd_points

	.globl	_PDUxform_string
_PDUxform_string:
	movw	$.T1,r2
	movw	$.F28,r3
	call	sp,Rload
	b	_PDUxform_string

	.globl	_PDUstring_to_matrix
_PDUstring_to_matrix:
	movw	$.T1,r2
	movw	$.F28,r3
	call	sp,Rload
	b	_PDUstring_to_matrix

	.globl	_PDUpoint_to_string
_PDUpoint_to_string:
	movw	$.T1,r2
	movw	$.F28,r3
	call	sp,Rload
	b	_PDUpoint_to_string
#
# Begin stubs for:  PDUbuffer.o
#
	.data
	.align	4
.F29:	.long	0x00000700
	.byte	80, 68, 85, 98, 117, 102, 102, 101, 114, 46
	.byte	111, 0
	.text

	.globl	_PDUbuffer_data
_PDUbuffer_data:
	movw	$.T1,r2
	movw	$.F29,r3
	call	sp,Rload
	b	_PDUbuffer_data

	.globl	_PDUwrite_data
_PDUwrite_data:
	movw	$.T1,r2
	movw	$.F29,r3
	call	sp,Rload
	b	_PDUwrite_data

	.globl	_PDUget_keyin
_PDUget_keyin:
	movw	$.T1,r2
	movw	$.F29,r3
	call	sp,Rload
	b	_PDUget_keyin
#
# Begin stubs for:  PDUcheckin.o
#
	.data
	.align	4
.F30:	.long	0x00000700
	.byte	80, 68, 85, 99, 104, 101, 99, 107, 105, 110
	.byte	46, 111, 0
	.text

	.globl	_PDUint_checkin
_PDUint_checkin:
	movw	$.T1,r2
	movw	$.F30,r3
	call	sp,Rload
	b	_PDUint_checkin

	.globl	_PDUprepare_param_cats_list
_PDUprepare_param_cats_list:
	movw	$.T1,r2
	movw	$.F30,r3
	call	sp,Rload
	b	_PDUprepare_param_cats_list

	.globl	_PDUload_dynamic_attrs
_PDUload_dynamic_attrs:
	movw	$.T1,r2
	movw	$.F30,r3
	call	sp,Rload
	b	_PDUload_dynamic_attrs

	.globl	_PDUextract_reffile_desc
_PDUextract_reffile_desc:
	movw	$.T1,r2
	movw	$.F30,r3
	call	sp,Rload
	b	_PDUextract_reffile_desc

	.globl	_PDUfind_PDU_design_file
_PDUfind_PDU_design_file:
	movw	$.T1,r2
	movw	$.F30,r3
	call	sp,Rload
	b	_PDUfind_PDU_design_file

	.globl	_PDUget_child_attach_bufrs
_PDUget_child_attach_bufrs:
	movw	$.T1,r2
	movw	$.F30,r3
	call	sp,Rload
	b	_PDUget_child_attach_bufrs

	.globl	_PDUprocess_part_dyn_attrs
_PDUprocess_part_dyn_attrs:
	movw	$.T1,r2
	movw	$.F30,r3
	call	sp,Rload
	b	_PDUprocess_part_dyn_attrs

	.globl	_PDUcleanup_local_filemgr
_PDUcleanup_local_filemgr:
	movw	$.T1,r2
	movw	$.F30,r3
	call	sp,Rload
	b	_PDUcleanup_local_filemgr

	.globl	_PDUclear_checkin_buffers
_PDUclear_checkin_buffers:
	movw	$.T1,r2
	movw	$.F30,r3
	call	sp,Rload
	b	_PDUclear_checkin_buffers

	.globl	_PDUload_active_checkin_info
_PDUload_active_checkin_info:
	movw	$.T1,r2
	movw	$.F30,r3
	call	sp,Rload
	b	_PDUload_active_checkin_info

	.globl	_PDUselect_PDU_file
_PDUselect_PDU_file:
	movw	$.T1,r2
	movw	$.F30,r3
	call	sp,Rload
	b	_PDUselect_PDU_file

	.globl	_PDUcheck_if_graphic
_PDUcheck_if_graphic:
	movw	$.T1,r2
	movw	$.F30,r3
	call	sp,Rload
	b	_PDUcheck_if_graphic

	.globl	_PDUload_inactive_checkin_info
_PDUload_inactive_checkin_info:
	movw	$.T1,r2
	movw	$.F30,r3
	call	sp,Rload
	b	_PDUload_inactive_checkin_info

	.globl	_PDUis_checkin_file_attached
_PDUis_checkin_file_attached:
	movw	$.T1,r2
	movw	$.F30,r3
	call	sp,Rload
	b	_PDUis_checkin_file_attached
#
# Begin stubs for:  PDUparm_part.o
#
	.data
	.align	4
.F31:	.long	0x00000700
	.byte	80, 68, 85, 112, 97, 114, 109, 95, 112, 97
	.byte	114, 116, 46, 111, 0
	.text

	.globl	_PDUget_module_env
_PDUget_module_env:
	movw	$.T1,r2
	movw	$.F31,r3
	call	sp,Rload
	b	_PDUget_module_env

	.globl	_PDUedit_macro_library
_PDUedit_macro_library:
	movw	$.T1,r2
	movw	$.F31,r3
	call	sp,Rload
	b	_PDUedit_macro_library

	.globl	_PDUcvt_macro_library
_PDUcvt_macro_library:
	movw	$.T1,r2
	movw	$.F31,r3
	call	sp,Rload
	b	_PDUcvt_macro_library

	.globl	_PDUattach_macro_library
_PDUattach_macro_library:
	movw	$.T1,r2
	movw	$.F31,r3
	call	sp,Rload
	b	_PDUattach_macro_library

	.globl	_PDUvalidate_expression
_PDUvalidate_expression:
	movw	$.T1,r2
	movw	$.F31,r3
	call	sp,Rload
	b	_PDUvalidate_expression

	.globl	_PDUrun_ppl
_PDUrun_ppl:
	movw	$.T1,r2
	movw	$.F31,r3
	call	sp,Rload
	b	_PDUrun_ppl

	.globl	_PDUis_macro_library
_PDUis_macro_library:
	movw	$.T1,r2
	movw	$.F31,r3
	call	sp,Rload
	b	_PDUis_macro_library

	.globl	_PDUis_cell_library
_PDUis_cell_library:
	movw	$.T1,r2
	movw	$.F31,r3
	call	sp,Rload
	b	_PDUis_cell_library

	.globl	_PDUis_grraster
_PDUis_grraster:
	movw	$.T1,r2
	movw	$.F31,r3
	call	sp,Rload
	b	_PDUis_grraster

	.globl	_PDUexecute_ppl
_PDUexecute_ppl:
	movw	$.T1,r2
	movw	$.F31,r3
	call	sp,Rload
	b	_PDUexecute_ppl

	.globl	_PDUupdate_ref_files_for_rev_assy
_PDUupdate_ref_files_for_rev_assy:
	movw	$.T1,r2
	movw	$.F31,r3
	call	sp,Rload
	b	_PDUupdate_ref_files_for_rev_assy
#
# Begin stubs for:  PDUtext.o
#
	.data
	.align	4
.F32:	.long	0x00000700
	.byte	80, 68, 85, 116, 101, 120, 116, 46, 111, 0
	.text

	.globl	_PDUmake_text
_PDUmake_text:
	movw	$.T1,r2
	movw	$.F32,r3
	call	sp,Rload
	b	_PDUmake_text

	.globl	_PDUextract_text
_PDUextract_text:
	movw	$.T1,r2
	movw	$.F32,r3
	call	sp,Rload
	b	_PDUextract_text

	.globl	_PDUexamine_string
_PDUexamine_string:
	movw	$.T1,r2
	movw	$.F32,r3
	call	sp,Rload
	b	_PDUexamine_string
#
# Begin stubs for:  PDUcregra.o
#
	.data
	.align	4
.F33:	.long	0x00000700
	.byte	80, 68, 85, 99, 114, 101, 103, 114, 97, 46
	.byte	111, 0
	.text

	.globl	_PDUclose_invis_file
_PDUclose_invis_file:
	movw	$.T1,r2
	movw	$.F33,r3
	call	sp,Rload
	b	_PDUclose_invis_file

	.globl	_PDUretrieve_invis_file
_PDUretrieve_invis_file:
	movw	$.T1,r2
	movw	$.F33,r3
	call	sp,Rload
	b	_PDUretrieve_invis_file
#
# Begin stubs for:  PDUpart.o
#
	.data
	.align	4
.F34:	.long	0x00000700
	.byte	80, 68, 85, 112, 97, 114, 116, 46, 111, 0
	.text

	.globl	_PDUget_objects
_PDUget_objects:
	movw	$.T1,r2
	movw	$.F34,r3
	call	sp,Rload
	b	_PDUget_objects

	.globl	_PDUprocess_selected_parts_in_os
_PDUprocess_selected_parts_in_os:
	movw	$.T1,r2
	movw	$.F34,r3
	call	sp,Rload
	b	_PDUprocess_selected_parts_in_os

	.globl	_PDUprocess_selected_origins_in_os
_PDUprocess_selected_origins_in_os:
	movw	$.T1,r2
	movw	$.F34,r3
	call	sp,Rload
	b	_PDUprocess_selected_origins_in_os

	.globl	_PDUget_exnuc_path
_PDUget_exnuc_path:
	movw	$.T1,r2
	movw	$.F34,r3
	call	sp,Rload
	b	_PDUget_exnuc_path

	.globl	_PDUget_ems_path
_PDUget_ems_path:
	movw	$.T1,r2
	movw	$.F34,r3
	call	sp,Rload
	b	_PDUget_ems_path

	.globl	_PDUget_model_path
_PDUget_model_path:
	movw	$.T1,r2
	movw	$.F34,r3
	call	sp,Rload
	b	_PDUget_model_path

	.globl	_PDUget_pdu_path
_PDUget_pdu_path:
	movw	$.T1,r2
	movw	$.F34,r3
	call	sp,Rload
	b	_PDUget_pdu_path

	.globl	_PDUget_grnuc_path
_PDUget_grnuc_path:
	movw	$.T1,r2
	movw	$.F34,r3
	call	sp,Rload
	b	_PDUget_grnuc_path

	.globl	_PDUdeactivate_stop_sign
_PDUdeactivate_stop_sign:
	movw	$.T1,r2
	movw	$.F34,r3
	call	sp,Rload
	b	_PDUdeactivate_stop_sign

	.globl	_PDUactivate_stop_sign
_PDUactivate_stop_sign:
	movw	$.T1,r2
	movw	$.F34,r3
	call	sp,Rload
	b	_PDUactivate_stop_sign
#
# Begin stubs for:  PDUassembly.o
#
	.data
	.align	4
.F35:	.long	0x00000700
	.byte	80, 68, 85, 97, 115, 115, 101, 109, 98, 108
	.byte	121, 46, 111, 0
	.text

	.globl	_PDUadd_assy_struct_from_buffer
_PDUadd_assy_struct_from_buffer:
	movw	$.T1,r2
	movw	$.F35,r3
	call	sp,Rload
	b	_PDUadd_assy_struct_from_buffer

	.globl	_PDUremove_assembly
_PDUremove_assembly:
	movw	$.T1,r2
	movw	$.F35,r3
	call	sp,Rload
	b	_PDUremove_assembly

	.globl	_PDUupdate_display_in_assembly
_PDUupdate_display_in_assembly:
	movw	$.T1,r2
	movw	$.F35,r3
	call	sp,Rload
	b	_PDUupdate_display_in_assembly

	.globl	_PDUload_assy_struct_buffer
_PDUload_assy_struct_buffer:
	movw	$.T1,r2
	movw	$.F35,r3
	call	sp,Rload
	b	_PDUload_assy_struct_buffer

	.globl	_PDUload_copy_attach_buffer
_PDUload_copy_attach_buffer:
	movw	$.T1,r2
	movw	$.F35,r3
	call	sp,Rload
	b	_PDUload_copy_attach_buffer

	.globl	_PDUload_local_file_buffer
_PDUload_local_file_buffer:
	movw	$.T1,r2
	movw	$.F35,r3
	call	sp,Rload
	b	_PDUload_local_file_buffer

	.globl	_PDUload_detach_buffer
_PDUload_detach_buffer:
	movw	$.T1,r2
	movw	$.F35,r3
	call	sp,Rload
	b	_PDUload_detach_buffer

	.globl	_PDUload_delete_buffer
_PDUload_delete_buffer:
	movw	$.T1,r2
	movw	$.F35,r3
	call	sp,Rload
	b	_PDUload_delete_buffer

	.globl	_PDUflag_local_parts_in_assembly
_PDUflag_local_parts_in_assembly:
	movw	$.T1,r2
	movw	$.F35,r3
	call	sp,Rload
	b	_PDUflag_local_parts_in_assembly

	.globl	_PDUunflag_local_parts_in_assembly
_PDUunflag_local_parts_in_assembly:
	movw	$.T1,r2
	movw	$.F35,r3
	call	sp,Rload
	b	_PDUunflag_local_parts_in_assembly

	.globl	_PDUflag_deleted_parts_in_assembly
_PDUflag_deleted_parts_in_assembly:
	movw	$.T1,r2
	movw	$.F35,r3
	call	sp,Rload
	b	_PDUflag_deleted_parts_in_assembly

	.globl	_PDUdelete_flagged_parts_in_assembly
_PDUdelete_flagged_parts_in_assembly:
	movw	$.T1,r2
	movw	$.F35,r3
	call	sp,Rload
	b	_PDUdelete_flagged_parts_in_assembly

	.globl	_PDUflag_local_parts_for_save_in_assembly
_PDUflag_local_parts_for_save_in_assembly:
	movw	$.T1,r2
	movw	$.F35,r3
	call	sp,Rload
	b	_PDUflag_local_parts_for_save_in_assembly

	.globl	_PDUload_child_buffer
_PDUload_child_buffer:
	movw	$.T1,r2
	movw	$.F35,r3
	call	sp,Rload
	b	_PDUload_child_buffer

	.globl	_PDUload_attach_buffer
_PDUload_attach_buffer:
	movw	$.T1,r2
	movw	$.F35,r3
	call	sp,Rload
	b	_PDUload_attach_buffer

	.globl	_PDUappend_attach_list
_PDUappend_attach_list:
	movw	$.T1,r2
	movw	$.F35,r3
	call	sp,Rload
	b	_PDUappend_attach_list

	.globl	_PDUextract_auto_assy_toggle
_PDUextract_auto_assy_toggle:
	movw	$.T1,r2
	movw	$.F35,r3
	call	sp,Rload
	b	_PDUextract_auto_assy_toggle

	.globl	_PDUupdate_auto_assy_toggle
_PDUupdate_auto_assy_toggle:
	movw	$.T1,r2
	movw	$.F35,r3
	call	sp,Rload
	b	_PDUupdate_auto_assy_toggle

	.globl	_PDUload_macrolibrary_copy_buffer
_PDUload_macrolibrary_copy_buffer:
	movw	$.T1,r2
	movw	$.F35,r3
	call	sp,Rload
	b	_PDUload_macrolibrary_copy_buffer

	.globl	_PDUupdate_attach_info
_PDUupdate_attach_info:
	movw	$.T1,r2
	movw	$.F35,r3
	call	sp,Rload
	b	_PDUupdate_attach_info

	.globl	_PDUcreate_attach_info_buffer
_PDUcreate_attach_info_buffer:
	movw	$.T1,r2
	movw	$.F35,r3
	call	sp,Rload
	b	_PDUcreate_attach_info_buffer

	.globl	_PDUupdate_assembly_structure
_PDUupdate_assembly_structure:
	movw	$.T1,r2
	movw	$.F35,r3
	call	sp,Rload
	b	_PDUupdate_assembly_structure

	.globl	_PDUgenerate_display_list
_PDUgenerate_display_list:
	movw	$.T1,r2
	movw	$.F35,r3
	call	sp,Rload
	b	_PDUgenerate_display_list

	.globl	_PDUupdate_display_info
_PDUupdate_display_info:
	movw	$.T1,r2
	movw	$.F35,r3
	call	sp,Rload
	b	_PDUupdate_display_info
#
# Begin stubs for:  PDUexp.o
#
	.data
	.align	4
.F36:	.long	0x00000700
	.byte	80, 68, 85, 101, 120, 112, 46, 111, 0
	.text

	.globl	_PDUcreate_exp
_PDUcreate_exp:
	movw	$.T1,r2
	movw	$.F36,r3
	call	sp,Rload
	b	_PDUcreate_exp

	.globl	_PDUmodify_exp
_PDUmodify_exp:
	movw	$.T1,r2
	movw	$.F36,r3
	call	sp,Rload
	b	_PDUmodify_exp

	.globl	_PDUdelete_exp
_PDUdelete_exp:
	movw	$.T1,r2
	movw	$.F36,r3
	call	sp,Rload
	b	_PDUdelete_exp

	.globl	_PDUevaluate_exp
_PDUevaluate_exp:
	movw	$.T1,r2
	movw	$.F36,r3
	call	sp,Rload
	b	_PDUevaluate_exp

	.globl	_PDUextract_exp_RHS
_PDUextract_exp_RHS:
	movw	$.T1,r2
	movw	$.F36,r3
	call	sp,Rload
	b	_PDUextract_exp_RHS

	.globl	_PDUget_exp_type
_PDUget_exp_type:
	movw	$.T1,r2
	movw	$.F36,r3
	call	sp,Rload
	b	_PDUget_exp_type
#
# Begin stubs for:  PDUgrpart.o
#
	.data
	.align	4
.F37:	.long	0x00000700
	.byte	80, 68, 85, 103, 114, 112, 97, 114, 116, 46
	.byte	111, 0
	.text

	.globl	_PDUcreate_GRpart
_PDUcreate_GRpart:
	movw	$.T1,r2
	movw	$.F37,r3
	call	sp,Rload
	b	_PDUcreate_GRpart

	.globl	_PDUgenerate_tag_no
_PDUgenerate_tag_no:
	movw	$.T1,r2
	movw	$.F37,r3
	call	sp,Rload
	b	_PDUgenerate_tag_no

	.globl	_PDUgenerate_child_no
_PDUgenerate_child_no:
	movw	$.T1,r2
	movw	$.F37,r3
	call	sp,Rload
	b	_PDUgenerate_child_no

	.globl	_PDUgenerate_instance_number
_PDUgenerate_instance_number:
	movw	$.T1,r2
	movw	$.F37,r3
	call	sp,Rload
	b	_PDUgenerate_instance_number

	.globl	_PDUincrement_tag_no
_PDUincrement_tag_no:
	movw	$.T1,r2
	movw	$.F37,r3
	call	sp,Rload
	b	_PDUincrement_tag_no

	.globl	_PDUget_GRpart
_PDUget_GRpart:
	movw	$.T1,r2
	movw	$.F37,r3
	call	sp,Rload
	b	_PDUget_GRpart

	.globl	_PDUmodify_GRpart
_PDUmodify_GRpart:
	movw	$.T1,r2
	movw	$.F37,r3
	call	sp,Rload
	b	_PDUmodify_GRpart

	.globl	_PDUremove_GRpart_attr
_PDUremove_GRpart_attr:
	movw	$.T1,r2
	movw	$.F37,r3
	call	sp,Rload
	b	_PDUremove_GRpart_attr

	.globl	_PDUextract_GRpart_attr_value
_PDUextract_GRpart_attr_value:
	movw	$.T1,r2
	movw	$.F37,r3
	call	sp,Rload
	b	_PDUextract_GRpart_attr_value

	.globl	_PDUget_GRpart_all_attrs
_PDUget_GRpart_all_attrs:
	movw	$.T1,r2
	movw	$.F37,r3
	call	sp,Rload
	b	_PDUget_GRpart_all_attrs

	.globl	_PDUget_GRparts
_PDUget_GRparts:
	movw	$.T1,r2
	movw	$.F37,r3
	call	sp,Rload
	b	_PDUget_GRparts

	.globl	_PDUpass_GRparts
_PDUpass_GRparts:
	movw	$.T1,r2
	movw	$.F37,r3
	call	sp,Rload
	b	_PDUpass_GRparts

	.globl	_PDUget_GRparts_ids
_PDUget_GRparts_ids:
	movw	$.T1,r2
	movw	$.F37,r3
	call	sp,Rload
	b	_PDUget_GRparts_ids

	.globl	_PDUincrement_child_no
_PDUincrement_child_no:
	movw	$.T1,r2
	movw	$.F37,r3
	call	sp,Rload
	b	_PDUincrement_child_no

	.globl	_PDUdisplay_GRpart
_PDUdisplay_GRpart:
	movw	$.T1,r2
	movw	$.F37,r3
	call	sp,Rload
	b	_PDUdisplay_GRpart

	.globl	_PDUattach_ref_to_GRpart
_PDUattach_ref_to_GRpart:
	movw	$.T1,r2
	movw	$.F37,r3
	call	sp,Rload
	b	_PDUattach_ref_to_GRpart

	.globl	_PDUget_reffile_objects
_PDUget_reffile_objects:
	movw	$.T1,r2
	movw	$.F37,r3
	call	sp,Rload
	b	_PDUget_reffile_objects

	.globl	_PDUalign_GRpart
_PDUalign_GRpart:
	movw	$.T1,r2
	movw	$.F37,r3
	call	sp,Rload
	b	_PDUalign_GRpart

	.globl	_PDUget_all_reffile_objects
_PDUget_all_reffile_objects:
	movw	$.T1,r2
	movw	$.F37,r3
	call	sp,Rload
	b	_PDUget_all_reffile_objects

	.globl	_PDUget_coordsys_objects
_PDUget_coordsys_objects:
	movw	$.T1,r2
	movw	$.F37,r3
	call	sp,Rload
	b	_PDUget_coordsys_objects

	.globl	_PDUturn_off_part_pointers
_PDUturn_off_part_pointers:
	movw	$.T1,r2
	movw	$.F37,r3
	call	sp,Rload
	b	_PDUturn_off_part_pointers

	.globl	_PDUis_usage_unique
_PDUis_usage_unique:
	movw	$.T1,r2
	movw	$.F37,r3
	call	sp,Rload
	b	_PDUis_usage_unique

	.globl	_PDUget_all_GRpart_ids
_PDUget_all_GRpart_ids:
	movw	$.T1,r2
	movw	$.F37,r3
	call	sp,Rload
	b	_PDUget_all_GRpart_ids

	.globl	_PDUget_all_parametric_ids
_PDUget_all_parametric_ids:
	movw	$.T1,r2
	movw	$.F37,r3
	call	sp,Rload
	b	_PDUget_all_parametric_ids

	.globl	_PDUis_alt_tag_unique
_PDUis_alt_tag_unique:
	movw	$.T1,r2
	movw	$.F37,r3
	call	sp,Rload
	b	_PDUis_alt_tag_unique

	.globl	_PDUis_PDU_file
_PDUis_PDU_file:
	movw	$.T1,r2
	movw	$.F37,r3
	call	sp,Rload
	b	_PDUis_PDU_file

	.globl	_PDUdo_parts_exist
_PDUdo_parts_exist:
	movw	$.T1,r2
	movw	$.F37,r3
	call	sp,Rload
	b	_PDUdo_parts_exist

	.globl	_PDUextract_coord_orientation
_PDUextract_coord_orientation:
	movw	$.T1,r2
	movw	$.F37,r3
	call	sp,Rload
	b	_PDUextract_coord_orientation

	.globl	_PDUgenerate_coord_orientation
_PDUgenerate_coord_orientation:
	movw	$.T1,r2
	movw	$.F37,r3
	call	sp,Rload
	b	_PDUgenerate_coord_orientation

	.globl	_PDUcheck_assembly_consistency
_PDUcheck_assembly_consistency:
	movw	$.T1,r2
	movw	$.F37,r3
	call	sp,Rload
	b	_PDUcheck_assembly_consistency

	.globl	_PDUload_local_file_info
_PDUload_local_file_info:
	movw	$.T1,r2
	movw	$.F37,r3
	call	sp,Rload
	b	_PDUload_local_file_info

	.globl	_PDUis_parametric_part
_PDUis_parametric_part:
	movw	$.T1,r2
	movw	$.F37,r3
	call	sp,Rload
	b	_PDUis_parametric_part

	.globl	_PDUget_all_ref_file_names
_PDUget_all_ref_file_names:
	movw	$.T1,r2
	movw	$.F37,r3
	call	sp,Rload
	b	_PDUget_all_ref_file_names

	.globl	_PDUprocess_ref_files
_PDUprocess_ref_files:
	movw	$.T1,r2
	movw	$.F37,r3
	call	sp,Rload
	b	_PDUprocess_ref_files

	.globl	_PDUget_all_catalogno_itemno_pairs
_PDUget_all_catalogno_itemno_pairs:
	movw	$.T1,r2
	movw	$.F37,r3
	call	sp,Rload
	b	_PDUget_all_catalogno_itemno_pairs

	.globl	_PDUextract_ref_file_description
_PDUextract_ref_file_description:
	movw	$.T1,r2
	movw	$.F37,r3
	call	sp,Rload
	b	_PDUextract_ref_file_description

	.globl	_PDUdoes_part_exist
_PDUdoes_part_exist:
	movw	$.T1,r2
	movw	$.F37,r3
	call	sp,Rload
	b	_PDUdoes_part_exist

	.globl	_PDUdo_positionless_parts_exist
_PDUdo_positionless_parts_exist:
	movw	$.T1,r2
	movw	$.F37,r3
	call	sp,Rload
	b	_PDUdo_positionless_parts_exist

	.globl	_PDUinitialize_replace_pointers
_PDUinitialize_replace_pointers:
	movw	$.T1,r2
	movw	$.F37,r3
	call	sp,Rload
	b	_PDUinitialize_replace_pointers

	.globl	_PDUlist_catalogs_in_obj_space
_PDUlist_catalogs_in_obj_space:
	movw	$.T1,r2
	movw	$.F37,r3
	call	sp,Rload
	b	_PDUlist_catalogs_in_obj_space

	.globl	_PDUlist_parts_in_obj_space
_PDUlist_parts_in_obj_space:
	movw	$.T1,r2
	movw	$.F37,r3
	call	sp,Rload
	b	_PDUlist_parts_in_obj_space

	.globl	_PDUlist_revisions_in_obj_space
_PDUlist_revisions_in_obj_space:
	movw	$.T1,r2
	movw	$.F37,r3
	call	sp,Rload
	b	_PDUlist_revisions_in_obj_space

	.globl	_PDUlist_usage_ids_in_obj_space
_PDUlist_usage_ids_in_obj_space:
	movw	$.T1,r2
	movw	$.F37,r3
	call	sp,Rload
	b	_PDUlist_usage_ids_in_obj_space

	.globl	_PDUlist_part_usage_ids_in_obj_space
_PDUlist_part_usage_ids_in_obj_space:
	movw	$.T1,r2
	movw	$.F37,r3
	call	sp,Rload
	b	_PDUlist_part_usage_ids_in_obj_space

	.globl	_PDUextract_part_type_from_obj_space
_PDUextract_part_type_from_obj_space:
	movw	$.T1,r2
	movw	$.F37,r3
	call	sp,Rload
	b	_PDUextract_part_type_from_obj_space

	.globl	_PDUremove_non_existent_parts_from_assy_struct
_PDUremove_non_existent_parts_from_assy_struct:
	movw	$.T1,r2
	movw	$.F37,r3
	call	sp,Rload
	b	_PDUremove_non_existent_parts_from_assy_struct

	.globl	_PDUremove_PDU_file_stamp
_PDUremove_PDU_file_stamp:
	movw	$.T1,r2
	movw	$.F37,r3
	call	sp,Rload
	b	_PDUremove_PDU_file_stamp

	.globl	_PDUstamp_PDU_design_file
_PDUstamp_PDU_design_file:
	movw	$.T1,r2
	movw	$.F37,r3
	call	sp,Rload
	b	_PDUstamp_PDU_design_file

	.globl	_PDUget_ref_instance_data
_PDUget_ref_instance_data:
	movw	$.T1,r2
	movw	$.F37,r3
	call	sp,Rload
	b	_PDUget_ref_instance_data

	.globl	_PDUlist_all_parts_in_os
_PDUlist_all_parts_in_os:
	movw	$.T1,r2
	movw	$.F37,r3
	call	sp,Rload
	b	_PDUlist_all_parts_in_os

	.globl	_PDUlist_all_origins_in_os
_PDUlist_all_origins_in_os:
	movw	$.T1,r2
	movw	$.F37,r3
	call	sp,Rload
	b	_PDUlist_all_origins_in_os

	.globl	_PDUdelete_part_placement
_PDUdelete_part_placement:
	movw	$.T1,r2
	movw	$.F37,r3
	call	sp,Rload
	b	_PDUdelete_part_placement

	.globl	_PDUget_PDU_part_id
_PDUget_PDU_part_id:
	movw	$.T1,r2
	movw	$.F37,r3
	call	sp,Rload
	b	_PDUget_PDU_part_id

	.globl	_PDUdelete_PDU_GRpart
_PDUdelete_PDU_GRpart:
	movw	$.T1,r2
	movw	$.F37,r3
	call	sp,Rload
	b	_PDUdelete_PDU_GRpart

	.globl	_PDUupdate_parametric_tag
_PDUupdate_parametric_tag:
	movw	$.T1,r2
	movw	$.F37,r3
	call	sp,Rload
	b	_PDUupdate_parametric_tag

	.globl	_PDUis_PDU_part
_PDUis_PDU_part:
	movw	$.T1,r2
	movw	$.F37,r3
	call	sp,Rload
	b	_PDUis_PDU_part

	.globl	_PDUextract_GRpart_modify_info
_PDUextract_GRpart_modify_info:
	movw	$.T1,r2
	movw	$.F37,r3
	call	sp,Rload
	b	_PDUextract_GRpart_modify_info

	.globl	_PDUupdate_active_object_space
_PDUupdate_active_object_space:
	movw	$.T1,r2
	movw	$.F37,r3
	call	sp,Rload
	b	_PDUupdate_active_object_space

	.globl	_PDUretrieve_placement_attrs
_PDUretrieve_placement_attrs:
	movw	$.T1,r2
	movw	$.F37,r3
	call	sp,Rload
	b	_PDUretrieve_placement_attrs

	.globl	_PDUget_default_usage_id
_PDUget_default_usage_id:
	movw	$.T1,r2
	movw	$.F37,r3
	call	sp,Rload
	b	_PDUget_default_usage_id

	.globl	_PDUget_ref_file_name
_PDUget_ref_file_name:
	movw	$.T1,r2
	movw	$.F37,r3
	call	sp,Rload
	b	_PDUget_ref_file_name

	.globl	_PDUgenerate_instance_number_cvt
_PDUgenerate_instance_number_cvt:
	movw	$.T1,r2
	movw	$.F37,r3
	call	sp,Rload
	b	_PDUgenerate_instance_number_cvt

	.globl	_PDUis_background
_PDUis_background:
	movw	$.T1,r2
	movw	$.F37,r3
	call	sp,Rload
	b	_PDUis_background

	.globl	_PDUdisplay_files_and_origins
_PDUdisplay_files_and_origins:
	movw	$.T1,r2
	movw	$.F37,r3
	call	sp,Rload
	b	_PDUdisplay_files_and_origins

	.globl	_PDUis_active_file_a_part
_PDUis_active_file_a_part:
	movw	$.T1,r2
	movw	$.F37,r3
	call	sp,Rload
	b	_PDUis_active_file_a_part

	.globl	_PDUis_part_positionless
_PDUis_part_positionless:
	movw	$.T1,r2
	movw	$.F37,r3
	call	sp,Rload
	b	_PDUis_part_positionless

	.globl	_PDUis_file_open
_PDUis_file_open:
	movw	$.T1,r2
	movw	$.F37,r3
	call	sp,Rload
	b	_PDUis_file_open
#
# Begin stubs for:  PDUcoorsys.o
#
	.data
	.align	4
.F38:	.long	0x00000700
	.byte	80, 68, 85, 99, 111, 111, 114, 115, 121, 115
	.byte	46, 111, 0
	.text

	.globl	_PDUcreate_coorsys
_PDUcreate_coorsys:
	movw	$.T1,r2
	movw	$.F38,r3
	call	sp,Rload
	b	_PDUcreate_coorsys

	.globl	_PDUget_coord_sys_id
_PDUget_coord_sys_id:
	movw	$.T1,r2
	movw	$.F38,r3
	call	sp,Rload
	b	_PDUget_coord_sys_id

	.globl	_PDUload_view_info
_PDUload_view_info:
	movw	$.T1,r2
	movw	$.F38,r3
	call	sp,Rload
	b	_PDUload_view_info

	.globl	_PDUcheck_default_view
_PDUcheck_default_view:
	movw	$.T1,r2
	movw	$.F38,r3
	call	sp,Rload
	b	_PDUcheck_default_view

	.globl	_PDUdo_origins_exist
_PDUdo_origins_exist:
	movw	$.T1,r2
	movw	$.F38,r3
	call	sp,Rload
	b	_PDUdo_origins_exist

	.globl	_PDUdelete_origins
_PDUdelete_origins:
	movw	$.T1,r2
	movw	$.F38,r3
	call	sp,Rload
	b	_PDUdelete_origins

	.globl	_PDUcreate_origin
_PDUcreate_origin:
	movw	$.T1,r2
	movw	$.F38,r3
	call	sp,Rload
	b	_PDUcreate_origin

	.globl	_PDUcreate_part_pointer
_PDUcreate_part_pointer:
	movw	$.T1,r2
	movw	$.F38,r3
	call	sp,Rload
	b	_PDUcreate_part_pointer

	.globl	_PDUdefine_origin
_PDUdefine_origin:
	movw	$.T1,r2
	movw	$.F38,r3
	call	sp,Rload
	b	_PDUdefine_origin

	.globl	_PDUdelete_svview
_PDUdelete_svview:
	movw	$.T1,r2
	movw	$.F38,r3
	call	sp,Rload
	b	_PDUdelete_svview

	.globl	_PDUrm_name
_PDUrm_name:
	movw	$.T1,r2
	movw	$.F38,r3
	call	sp,Rload
	b	_PDUrm_name

	.globl	_PDUrmdir
_PDUrmdir:
	movw	$.T1,r2
	movw	$.F38,r3
	call	sp,Rload
	b	_PDUrmdir
#
# Begin stubs for:  PDUconvert.o
#
	.data
	.align	4
.F39:	.long	0x00000700
	.byte	80, 68, 85, 99, 111, 110, 118, 101, 114, 116
	.byte	46, 111, 0
	.text

	.globl	_PDUconvert_part_pointers
_PDUconvert_part_pointers:
	movw	$.T1,r2
	movw	$.F39,r3
	call	sp,Rload
	b	_PDUconvert_part_pointers

	.globl	_PDUreplace_commas
_PDUreplace_commas:
	movw	$.T1,r2
	movw	$.F39,r3
	call	sp,Rload
	b	_PDUreplace_commas

	.globl	_PDUconvert_part_origins
_PDUconvert_part_origins:
	movw	$.T1,r2
	movw	$.F39,r3
	call	sp,Rload
	b	_PDUconvert_part_origins

	.globl	_PDUprocess_BOM_attachments
_PDUprocess_BOM_attachments:
	movw	$.T1,r2
	movw	$.F39,r3
	call	sp,Rload
	b	_PDUprocess_BOM_attachments

	.globl	_PDUadd_BOM_attachments_to_linklist
_PDUadd_BOM_attachments_to_linklist:
	movw	$.T1,r2
	movw	$.F39,r3
	call	sp,Rload
	b	_PDUadd_BOM_attachments_to_linklist

	.globl	_PDUcvt_20objspace
_PDUcvt_20objspace:
	movw	$.T1,r2
	movw	$.F39,r3
	call	sp,Rload
	b	_PDUcvt_20objspace

	.globl	_PDUconvert_file_for_similar_mode
_PDUconvert_file_for_similar_mode:
	movw	$.T1,r2
	movw	$.F39,r3
	call	sp,Rload
	b	_PDUconvert_file_for_similar_mode

	.globl	_PDUcvt_20objspace_for_checkout
_PDUcvt_20objspace_for_checkout:
	movw	$.T1,r2
	movw	$.F39,r3
	call	sp,Rload
	b	_PDUcvt_20objspace_for_checkout
#
# Begin stubs for:  PMdlprto.o
#
	.data
	.align	4
.F40:	.long	0x00000700
	.byte	80, 77, 100, 108, 112, 114, 116, 111, 46, 111
	.byte	0
	.text

	.globl	_pdmoDeleteMacroLibraryEntry
_pdmoDeleteMacroLibraryEntry:
	movw	$.T1,r2
	movw	$.F40,r3
	call	sp,Rload
	b	_pdmoDeleteMacroLibraryEntry

	.globl	_pdmoDeletePartOccurrence
_pdmoDeletePartOccurrence:
	movw	$.T1,r2
	movw	$.F40,r3
	call	sp,Rload
	b	_pdmoDeletePartOccurrence

	.globl	_PDMDeletePartOccurrence
_PDMDeletePartOccurrence:
	movw	$.T1,r2
	movw	$.F40,r3
	call	sp,Rload
	b	_PDMDeletePartOccurrence

	.globl	_pdmoDetachParametricPart
_pdmoDetachParametricPart:
	movw	$.T1,r2
	movw	$.F40,r3
	call	sp,Rload
	b	_pdmoDetachParametricPart

	.globl	_pdmoDetachPart
_pdmoDetachPart:
	movw	$.T1,r2
	movw	$.F40,r3
	call	sp,Rload
	b	_pdmoDetachPart

	.globl	_pdmoGetPartidGivenUsageid
_pdmoGetPartidGivenUsageid:
	movw	$.T1,r2
	movw	$.F40,r3
	call	sp,Rload
	b	_pdmoGetPartidGivenUsageid

	.globl	_pdmoCleanupMacroLibraryAttachment
_pdmoCleanupMacroLibraryAttachment:
	movw	$.T1,r2
	movw	$.F40,r3
	call	sp,Rload
	b	_pdmoCleanupMacroLibraryAttachment
#
# Begin stubs for:  PMplprto.o
#
	.data
	.align	4
.F41:	.long	0x00000700
	.byte	80, 77, 112, 108, 112, 114, 116, 111, 46, 111
	.byte	0
	.text

	.globl	_PDUget_description_for_part
_PDUget_description_for_part:
	movw	$.T1,r2
	movw	$.F41,r3
	call	sp,Rload
	b	_PDUget_description_for_part

	.globl	_PDUvalidate_usageid
_PDUvalidate_usageid:
	movw	$.T1,r2
	movw	$.F41,r3
	call	sp,Rload
	b	_PDUvalidate_usageid

	.globl	_PDUapi_default_usageid
_PDUapi_default_usageid:
	movw	$.T1,r2
	movw	$.F41,r3
	call	sp,Rload
	b	_PDUapi_default_usageid

	.globl	_PDUvalidate_alttagno
_PDUvalidate_alttagno:
	movw	$.T1,r2
	movw	$.F41,r3
	call	sp,Rload
	b	_PDUvalidate_alttagno

	.globl	_PDUvalidate_viewname
_PDUvalidate_viewname:
	movw	$.T1,r2
	movw	$.F41,r3
	call	sp,Rload
	b	_PDUvalidate_viewname

	.globl	_pdmoAttachPart
_pdmoAttachPart:
	movw	$.T1,r2
	movw	$.F41,r3
	call	sp,Rload
	b	_pdmoAttachPart

	.globl	_PDUfind_dynloc_name
_PDUfind_dynloc_name:
	movw	$.T1,r2
	movw	$.F41,r3
	call	sp,Rload
	b	_PDUfind_dynloc_name

	.globl	_pdmoPlacePart
_pdmoPlacePart:
	movw	$.T1,r2
	movw	$.F41,r3
	call	sp,Rload
	b	_pdmoPlacePart

	.globl	_PDUreplace_part_for_revise_assembly
_PDUreplace_part_for_revise_assembly:
	movw	$.T1,r2
	movw	$.F41,r3
	call	sp,Rload
	b	_PDUreplace_part_for_revise_assembly

	.globl	_PDUget_dynamic_data_for_rev_assy
_PDUget_dynamic_data_for_rev_assy:
	movw	$.T1,r2
	movw	$.F41,r3
	call	sp,Rload
	b	_PDUget_dynamic_data_for_rev_assy

	.globl	_PDUplace_part_for_revise_assembly
_PDUplace_part_for_revise_assembly:
	movw	$.T1,r2
	movw	$.F41,r3
	call	sp,Rload
	b	_PDUplace_part_for_revise_assembly

	.globl	_PDUcheck_part_files_for_PDU_parts
_PDUcheck_part_files_for_PDU_parts:
	movw	$.T1,r2
	movw	$.F41,r3
	call	sp,Rload
	b	_PDUcheck_part_files_for_PDU_parts

	.globl	_PDUdelete_part_for_revise_assembly
_PDUdelete_part_for_revise_assembly:
	movw	$.T1,r2
	movw	$.F41,r3
	call	sp,Rload
	b	_PDUdelete_part_for_revise_assembly
#
# Begin stubs for:  PDUpost_db.o
#
	.data
	.align	4
.F42:	.long	0x00000700
	.byte	80, 68, 85, 112, 111, 115, 116, 95, 100, 98
	.byte	46, 111, 0
	.text

	.globl	_PDUpost_to_database
_PDUpost_to_database:
	movw	$.T1,r2
	movw	$.F42,r3
	call	sp,Rload
	b	_PDUpost_to_database

	.globl	_PDUis_PDU_design_file
_PDUis_PDU_design_file:
	movw	$.T1,r2
	movw	$.F42,r3
	call	sp,Rload
	b	_PDUis_PDU_design_file

	.globl	_PDUfind_PDU_stamp_files
_PDUfind_PDU_stamp_files:
	movw	$.T1,r2
	movw	$.F42,r3
	call	sp,Rload
	b	_PDUfind_PDU_stamp_files

	.globl	_PDUopen_design_file_invisibly
_PDUopen_design_file_invisibly:
	movw	$.T1,r2
	movw	$.F42,r3
	call	sp,Rload
	b	_PDUopen_design_file_invisibly

	.globl	_PDUdisplay_list_of_om_files
_PDUdisplay_list_of_om_files:
	movw	$.T1,r2
	movw	$.F42,r3
	call	sp,Rload
	b	_PDUdisplay_list_of_om_files

	.globl	_PDUload_file_assembly_information
_PDUload_file_assembly_information:
	movw	$.T1,r2
	movw	$.F42,r3
	call	sp,Rload
	b	_PDUload_file_assembly_information
#
# Begin stubs for:  PDUloadhooks.o
#
	.data
	.align	4
.F43:	.long	0x00000700
	.byte	80, 68, 85, 108, 111, 97, 100, 104, 111, 111
	.byte	107, 115, 46, 111, 0
	.text

	.globl	_PDUload_PDUexit_save
_PDUload_PDUexit_save:
	movw	$.T1,r2
	movw	$.F43,r3
	call	sp,Rload
	b	_PDUload_PDUexit_save

	.globl	_PDUload_PDUexit_nosave
_PDUload_PDUexit_nosave:
	movw	$.T1,r2
	movw	$.F43,r3
	call	sp,Rload
	b	_PDUload_PDUexit_nosave
#
# Begin stubs for:  PDUemshooks.o
#
	.data
	.align	4
.F44:	.long	0x00000700
	.byte	80, 68, 85, 101, 109, 115, 104, 111, 111, 107
	.byte	115, 46, 111, 0
	.text

	.globl	_PDUexit_save
_PDUexit_save:
	movw	$.T1,r2
	movw	$.F44,r3
	call	sp,Rload
	b	_PDUexit_save

	.globl	_PDUexit_nosave
_PDUexit_nosave:
	movw	$.T1,r2
	movw	$.F44,r3
	call	sp,Rload
	b	_PDUexit_nosave

	.globl	_PDMloaded
_PDMloaded:
	movw	$.T1,r2
	movw	$.F44,r3
	call	sp,Rload
	b	_PDMloaded

	.globl	_PDMpre_delete
_PDMpre_delete:
	movw	$.T1,r2
	movw	$.F44,r3
	call	sp,Rload
	b	_PDMpre_delete

	.globl	_PDMpost_copy
_PDMpost_copy:
	movw	$.T1,r2
	movw	$.F44,r3
	call	sp,Rload
	b	_PDMpost_copy
#
# Begin stubs for:  PDUasmfrm.o
#
	.data
	.align	4
.F45:	.long	0x00000700
	.byte	80, 68, 85, 97, 115, 109, 102, 114, 109, 46
	.byte	111, 0
	.text

	.globl	_assembly_display_notification_routine
_assembly_display_notification_routine:
	movw	$.T1,r2
	movw	$.F45,r3
	call	sp,Rload
	b	_assembly_display_notification_routine

	.globl	_PDUload_assembly_display_mcf
_PDUload_assembly_display_mcf:
	movw	$.T1,r2
	movw	$.F45,r3
	call	sp,Rload
	b	_PDUload_assembly_display_mcf

	.globl	_PDUhighlight_assembly_rows
_PDUhighlight_assembly_rows:
	movw	$.T1,r2
	movw	$.F45,r3
	call	sp,Rload
	b	_PDUhighlight_assembly_rows

	.globl	_PDUprocess_assembly_display_information
_PDUprocess_assembly_display_information:
	movw	$.T1,r2
	movw	$.F45,r3
	call	sp,Rload
	b	_PDUprocess_assembly_display_information

	.globl	_PDUprocess_assembly_mcf
_PDUprocess_assembly_mcf:
	movw	$.T1,r2
	movw	$.F45,r3
	call	sp,Rload
	b	_PDUprocess_assembly_mcf

	.globl	_PDUtoggle_assembly_display
_PDUtoggle_assembly_display:
	movw	$.T1,r2
	movw	$.F45,r3
	call	sp,Rload
	b	_PDUtoggle_assembly_display

	.globl	_PDUassembly_display_form
_PDUassembly_display_form:
	movw	$.T1,r2
	movw	$.F45,r3
	call	sp,Rload
	b	_PDUassembly_display_form

	.globl	_PDUfind_display_level
_PDUfind_display_level:
	movw	$.T1,r2
	movw	$.F45,r3
	call	sp,Rload
	b	_PDUfind_display_level

	.globl	_PDUfind_nested_assemblies
_PDUfind_nested_assemblies:
	movw	$.T1,r2
	movw	$.F45,r3
	call	sp,Rload
	b	_PDUfind_nested_assemblies

	.globl	_PDUfind_matching_refids
_PDUfind_matching_refids:
	movw	$.T1,r2
	movw	$.F45,r3
	call	sp,Rload
	b	_PDUfind_matching_refids

	.globl	_PDUmanage_assembly_on_located_part
_PDUmanage_assembly_on_located_part:
	movw	$.T1,r2
	movw	$.F45,r3
	call	sp,Rload
	b	_PDUmanage_assembly_on_located_part
#
# Begin stubs for:  PDUdispasm.o
#
	.data
	.align	4
.F46:	.long	0x00000700
	.byte	80, 68, 85, 100, 105, 115, 112, 97, 115, 109
	.byte	46, 111, 0
	.text

	.globl	_PDUupdate_load_in_assembly
_PDUupdate_load_in_assembly:
	movw	$.T1,r2
	movw	$.F46,r3
	call	sp,Rload
	b	_PDUupdate_load_in_assembly

	.globl	_PDUadd_path_node
_PDUadd_path_node:
	movw	$.T1,r2
	movw	$.F46,r3
	call	sp,Rload
	b	_PDUadd_path_node

	.globl	_PDUupdate_part_display
_PDUupdate_part_display:
	movw	$.T1,r2
	movw	$.F46,r3
	call	sp,Rload
	b	_PDUupdate_part_display

	.globl	_PDUupdate_1st_level_detached_parts_display
_PDUupdate_1st_level_detached_parts_display:
	movw	$.T1,r2
	movw	$.F46,r3
	call	sp,Rload
	b	_PDUupdate_1st_level_detached_parts_display

	.globl	_PDUread_refid_string
_PDUread_refid_string:
	movw	$.T1,r2
	movw	$.F46,r3
	call	sp,Rload
	b	_PDUread_refid_string

	.globl	_PDUget_GRpart_from_refid
_PDUget_GRpart_from_refid:
	movw	$.T1,r2
	movw	$.F46,r3
	call	sp,Rload
	b	_PDUget_GRpart_from_refid

	.globl	_PDUadd_refid_node
_PDUadd_refid_node:
	movw	$.T1,r2
	movw	$.F46,r3
	call	sp,Rload
	b	_PDUadd_refid_node

	.globl	_PDUconstruct_refid_string
_PDUconstruct_refid_string:
	movw	$.T1,r2
	movw	$.F46,r3
	call	sp,Rload
	b	_PDUconstruct_refid_string

	.globl	_PDMset_reffile_display
_PDMset_reffile_display:
	movw	$.T1,r2
	movw	$.F46,r3
	call	sp,Rload
	b	_PDMset_reffile_display

	.globl	_PDUprint_parent_child_list
_PDUprint_parent_child_list:
	movw	$.T1,r2
	movw	$.F46,r3
	call	sp,Rload
	b	_PDUprint_parent_child_list

	.globl	_PDUmap_refid_to_assembly
_PDUmap_refid_to_assembly:
	movw	$.T1,r2
	movw	$.F46,r3
	call	sp,Rload
	b	_PDUmap_refid_to_assembly

	.globl	_PDUfind_refid_parent
_PDUfind_refid_parent:
	movw	$.T1,r2
	movw	$.F46,r3
	call	sp,Rload
	b	_PDUfind_refid_parent

	.globl	_PDUfind_next_parent
_PDUfind_next_parent:
	movw	$.T1,r2
	movw	$.F46,r3
	call	sp,Rload
	b	_PDUfind_next_parent

	.globl	_PDUis_filename_to_be_loaded
_PDUis_filename_to_be_loaded:
	movw	$.T1,r2
	movw	$.F46,r3
	call	sp,Rload
	b	_PDUis_filename_to_be_loaded

	.globl	_PDUfree_path_list
_PDUfree_path_list:
	movw	$.T1,r2
	movw	$.F46,r3
	call	sp,Rload
	b	_PDUfree_path_list

	.globl	_PDUfree_refid_list
_PDUfree_refid_list:
	movw	$.T1,r2
	movw	$.F46,r3
	call	sp,Rload
	b	_PDUfree_refid_list

	.globl	_PDUprocess_assembly_display
_PDUprocess_assembly_display:
	movw	$.T1,r2
	movw	$.F46,r3
	call	sp,Rload
	b	_PDUprocess_assembly_display

	.globl	_PDUupdate_local_flag_in_assembly
_PDUupdate_local_flag_in_assembly:
	movw	$.T1,r2
	movw	$.F46,r3
	call	sp,Rload
	b	_PDUupdate_local_flag_in_assembly

	.globl	_PDUget_context_from_refid
_PDUget_context_from_refid:
	movw	$.T1,r2
	movw	$.F46,r3
	call	sp,Rload
	b	_PDUget_context_from_refid

	.globl	_PDUconstruct_asm_mgr_object
_PDUconstruct_asm_mgr_object:
	movw	$.T1,r2
	movw	$.F46,r3
	call	sp,Rload
	b	_PDUconstruct_asm_mgr_object

	.globl	_PDUdetect_assembly_change
_PDUdetect_assembly_change:
	movw	$.T1,r2
	movw	$.F46,r3
	call	sp,Rload
	b	_PDUdetect_assembly_change

	.globl	_PDUupdate_refids_in_assembly
_PDUupdate_refids_in_assembly:
	movw	$.T1,r2
	movw	$.F46,r3
	call	sp,Rload
	b	_PDUupdate_refids_in_assembly

	.globl	_PDUchange_parentid_of_refid
_PDUchange_parentid_of_refid:
	movw	$.T1,r2
	movw	$.F46,r3
	call	sp,Rload
	b	_PDUchange_parentid_of_refid
#
# Begin stubs for:  PDUcheckout.o
#
	.data
	.align	4
.F47:	.long	0x00000700
	.byte	80, 68, 85, 99, 104, 101, 99, 107, 111, 117
	.byte	116, 46, 111, 0
	.text

	.globl	_PDUcheckout_part
_PDUcheckout_part:
	movw	$.T1,r2
	movw	$.F47,r3
	call	sp,Rload
	b	_PDUcheckout_part

	.globl	_PDUdisplay_assembly_before_retrieve
_PDUdisplay_assembly_before_retrieve:
	movw	$.T1,r2
	movw	$.F47,r3
	call	sp,Rload
	b	_PDUdisplay_assembly_before_retrieve

	.globl	_PDUconvert_file_before_review
_PDUconvert_file_before_review:
	movw	$.T1,r2
	movw	$.F47,r3
	call	sp,Rload
	b	_PDUconvert_file_before_review
#
# Begin stubs for:  PDUasmmgri.o
#
	.data
	.align	4
.F48:	.long	0x00000700
	.byte	80, 68, 85, 97, 115, 109, 109, 103, 114, 105
	.byte	46, 111, 0
	.text

	.globl	_PDUasmmgr_global_class_sleep_method
_PDUasmmgr_global_class_sleep_method:
	movw	$.T1,r2
	movw	$.F48,r3
	call	sp,Rload
	b	_PDUasmmgr_global_class_sleep_method

	.globl	_PDUexecute_upon_save
_PDUexecute_upon_save:
	movw	$.T1,r2
	movw	$.F48,r3
	call	sp,Rload
	b	_PDUexecute_upon_save

	.globl	_PDUasmmgr_global_class_wake_up_method
_PDUasmmgr_global_class_wake_up_method:
	movw	$.T1,r2
	movw	$.F48,r3
	call	sp,Rload
	b	_PDUasmmgr_global_class_wake_up_method

	.globl	_PDUcleanup_detached_parts_after_save
_PDUcleanup_detached_parts_after_save:
	movw	$.T1,r2
	movw	$.F48,r3
	call	sp,Rload
	b	_PDUcleanup_detached_parts_after_save

	.globl	_PDUexecute_upon_save_for_rev_assy
_PDUexecute_upon_save_for_rev_assy:
	movw	$.T1,r2
	movw	$.F48,r3
	call	sp,Rload
	b	_PDUexecute_upon_save_for_rev_assy

	.globl	_PDUcleanup_detached_parts_after_save_for_rev_assy
_PDUcleanup_detached_parts_after_save_for_rev_assy:
	movw	$.T1,r2
	movw	$.F48,r3
	call	sp,Rload
	b	_PDUcleanup_detached_parts_after_save_for_rev_assy
#
# Begin stubs for:  PDUpath.o
#
	.data
	.align	4
.F49:	.long	0x00000700
	.byte	80, 68, 85, 112, 97, 116, 104, 46, 111, 0
	.text

	.globl	_PDUprocess_function
_PDUprocess_function:
	movw	$.T1,r2
	movw	$.F49,r3
	call	sp,Rload
	b	_PDUprocess_function

	.comm	_PDU_parts_id_list,4
	.comm	_PDU_origins_id_list,4
	.comm	_default_orientation,100
	.comm	_ModuleInfo,144
	.comm	_PDU_dst_part_id,4
	.comm	_PDU_ref_filenames,4
	.comm	_ORIENTATION,4
	.comm	_PDU_src_part_id,4
	.comm	_PDU_macro_temp,4
	.comm	_PDU_attach_info,4
	.comm	_PDU_part_id,4
	.comm	_coordsys_orientation,528
	.comm	_PDU_origin_id,4
	.comm	_PDU_macro_feet,4
	.comm	_PDU_topdown_flag,4
	.comm	_PDU_invis_newmod,8
	.comm	_PDU_queue_info,4
	.globl	_PDUadd_part
	.globl	_PDU_incl_BOM
	.globl	_PDU_connection
	.globl	_PDMtime_value
	.globl	_PDU_alt_tagno
	.globl	_PDU_attr_name
	.globl	_FIf_set_window_level
	.globl	_PDU_save_revision
	.globl	_PDUfill_attribute_list1
	.globl	_PDUmacro_lib_list
	.globl	_GRforce_writable
	.globl	_PDUincrement_child_no
	.globl	_PDUupdate_local_flag_in_assembly
	.globl	_PDUis_file_open
	.globl	_PDUget_GRparts_ids
	.globl	_PDU_review_file_permissions
	.globl	_Help_topic
	.globl	_DIrm_objid
	.globl	_OPP_GRcoords_class_id
	.globl	_PDU_save_act_partid
	.globl	_PDUflag_local_parts_in_assembly
	.globl	_PDMget_existing_data
	.globl	_PDUclear_checkin_buffers
	.globl	_SetDynTemp
	.globl	_PDUcvt_20objspace
	.globl	_blkmv
	.globl	_FIf_erase
	.globl	_PDU_delete_checkin
	.globl	_PDUis_macro_edited
	.globl	_som_construct_object
	.globl	_PDUunlock_item
	.globl	_GRgencs_OPP_GRgetmatrix_method_index
	.globl	_MA3protmx
	.globl	_PDMupdate_set_members
	.globl	_DImkpath
	.globl	_PDMtime_enabled
	.globl	_PDU_viewname
	.globl	_PDUexternal
	.globl	_PDU_default_style
	.globl	__pdm_debug_list
	.globl	__pdm_rstatus
	.globl	_PDU_align_part_by
	.globl	_PDUcheck_display_dynamic_attr
	.globl	_PDU_checkin_file
	.globl	_PDUnullstr
	.globl	_PDUcheck_if_need_conversion
	.globl	_MEMopen
	.globl	_som_convert_os_number_to_name
	.globl	_PDU_attr_label
	.globl	_PDUpart_file_list_form
	.globl	_PDUselect_PDU_file
	.globl	_PDU_parts_index
	.globl	_PDU_default_layer
	.globl	_MS_init
	.globl	_PDUdelete_exp
	.globl	_DIrmdir
	.globl	_OPP_GRgraphics_class_id
	.globl	_PDUprint_PDUattr_list
	.globl	_PDU_default_weight
	.globl	_MAtypemx
	.globl	_PDU_topdown_flag
	.globl	_ACconstruct_wd
	.globl	_change_mode
	.globl	_strcpy
	.globl	_FIf_set_size
	.globl	_PDUreset_local_files_form
	.globl	_PDMdetach_part
	.globl	_PDUget_exp_type
	.globl	_user
	.globl	_PDUget_incasm
	.globl	_PDUget_all_reffile_objects
	.globl	_PALcopy_part
	.globl	_execlp
	.globl	_PDUchange_file_permissions
	.globl	_get_mod_info
	.globl	_PDUprepare_queue
	.globl	_FIfld_get_row_offset
	.globl	_expression_OPP_create_method_index
	.globl	_GRreffile_OPP_GRchglevels_method_index
	.globl	_DIpwd
	.globl	_PDUload_attach_buffer
	.globl	_PDUextract_text
	.globl	_PDUpost_to_database
	.globl	_GRreffile_OPP_GRgetenvironment_method_index
	.globl	_PDUdisplay_files_and_origins
	.globl	_PDUdo_parts_exist
	.globl	_grid_list
	.globl	_PDUep_proj_fld
	.globl	_PDUvalid_filename
	.globl	_FIg_delete
	.globl	_PDUdelete_file
	.globl	_ModifyPart
	.globl	_PDM_debug_on
	.globl	_GRcsmgr_OPP_GRcstoggle_display_method_index
	.globl	_PDU_is_om_file
	.globl	_PDMcheck_item
	.globl	_PDUread_refresh
	.globl	_COpart_construct_func
	.globl	_PDU_ref_filenames
	.globl	_strncpy
	.globl	_PDUep_part_btn
	.globl	_DIuntranslate
	.globl	_SelectOrPlacePart
	.globl	_PDUtree_toggle
	.globl	_PDUcreate_new_dynamic_attr_buffr
	.globl	_PDUretrieve_placement_attrs
	.globl	_module_OPP_mod_info_method_index
	.globl	_PALdel_part
	.globl	_PDU_func_buffer
	.globl	_FIg_set_state_off
	.globl	_PDMget_pt_desc
	.globl	_LoadLib_N_PrepareAttribs
	.globl	_get_parameter_values
	.globl	_PDU_quantity
	.globl	_PDUfilter_dynamic_attribute_bufrs
	.globl	_PDUchange_part
	.globl	_PDUget_all_GRpart_ids
	.globl	_PDUincrement_tag_no
	.globl	_EXputq2
	.globl	_PDUdisplay_design_form
	.globl	_PDUrmdir
	.globl	_OPP_module_class_id
	.globl	_PDU_form_id
	.globl	_PDUedit_macro
	.globl	_PDU_exit_case
	.globl	_UMSInitMsg
	.globl	_PDUflag_local_parts_for_save_in_assembly
	.globl	_PDMvalidate_user_access
	.globl	_EXP_create
	.globl	_PDUget_alttag_no
	.globl	_PDUset_debug
	.globl	_GetMacroHeaderGivenName
	.globl	_LCget_channel_objects
	.globl	_PDU_design_perm_window
	.globl	_PDMrterminate
	.globl	_PDUmodify_catalog
	.globl	_pdmfree_part_occurrence
	.globl	_DIfind
	.globl	_malloc
	.globl	_EXP_modify_by_objid
	.globl	_DIcd
	.globl	_PDMget_assembly_structure
	.globl	_PDUpoint_to_string
	.globl	_DIrename
	.globl	_PDU_msg_path
	.globl	_GRowner_OPP_GRget_number_components_method_index
	.globl	_NULL_CHANNUM
	.globl	_PDUadd_points
	.globl	_GRcoords_OPP_GRinitialize_method_index
	.globl	_PDUis_PDU_part
	.globl	_PDU_macro_call
	.globl	_PDU_origins_id_list
	.globl	_FIfld_set_max_num_rows
	.globl	_PDU_design_opt_create
	.globl	_PDUcreate_origin
	.globl	_PDU_auto_part_selection
	.globl	_OPP_GRreffile_class_id
	.globl	_DPgetggid
	.globl	_PDUep_cat_fld
	.globl	_PDMrcheck_part_status
	.globl	_GRreffile_OPP_GRchgrfprops_method_index
	.globl	_free
	.globl	_FImcf_get_active_col
	.globl	_MEMwrite
	.globl	_PDUupdate_design_form
	.globl	_PDU_param_cat_list
	.globl	_PDUcheck_part
	.globl	_GRproc_pull_down_list
	.globl	_PDMterminate
	.globl	_PDU_window_id
	.globl	_PDUsetup_buffer_list
	.globl	_PDUmatrix_to_point
	.globl	_PDU_apiflag
	.globl	_PDUsetlevels
	.globl	_PDU_macro_dyn_list
	.globl	_ACopen_init
	.globl	_PDU_explode_depth
	.globl	_som_get_classid
	.globl	_PDUcreate_exp
	.globl	_PDUstring_to_matrix
	.globl	_OM_GS_NULL_NEIGHBOR
	.globl	_PDU_local_perm_window
	.globl	_PDU_search_type
	.globl	_FIfld_get_select
	.globl	_PDUbufr_to_form
	.globl	_GRgraphics_OPP_GRdelete_method_index
	.globl	_expression_OPP_give_formula_method_index
	.globl	_PDUget_explodebom
	.globl	_PDMupdate_os_necessary
	.globl	_PDUgetcwd
	.globl	_system
	.globl	_PDU_save_filename
	.globl	_PDUadd_static_dyn_attributes
	.globl	_PDU_attach_info
	.globl	_PDUvalidate_access
	.globl	_PDMquery_catalog_type
	.globl	_PDUformat_macrolib_copy_bufr
	.globl	_PDUfree_refid_list
	.globl	_PDU_part_path_list
	.globl	_DIstrcat
	.globl	_PDUcheck_uniqueness
	.globl	_errno
	.globl	_GRowner_OPP_GRget_components_method_index
	.globl	_ci_exec
	.globl	_PDMscopy
	.globl	_PDU_save_level
	.globl	_PDU_attach
	.globl	_PDMget_dyn_attr_names
	.globl	_GRcsmgr_OPP_GRset_active_cs_method_index
	.globl	_DIstmocpy
	.globl	_EXP_modify_by_name
	.globl	_PDUfind_attr_in_buffer
	.globl	_MAinvmx
	.globl	_PALusage_id_unique
	.globl	_PDUflag_deleted_parts_in_assembly
	.globl	_PDU_save_parttype
	.globl	_pdmoAttachPart
	.globl	_ctime
	.globl	_PDUdebug_off
	.globl	_PDUsetup_struct_fields
	.globl	_filterbuf
	.globl	_strtok
	.globl	_PDU_save
	.globl	_FIg_display
	.globl	_PDUis_alt_tag_unique
	.globl	_MS_fix_type
	.globl	_MAidmx
	.globl	_PDU_queue_info
	.globl	_FIf_new
	.globl	_GRgetrefinfo
	.globl	_PDU_place_part_by
	.globl	_GRcsget_mgr
	.globl	_PDU_path_list
	.globl	_som_report_error
	.globl	_COpart_get_parts_func
	.globl	_PDU_activate_delete
	.globl	_PDU_display_dyn_attr
	.globl	_PDUcheck_tag_count
	.globl	_PDUseed_form
	.globl	_PDUlogout
	.globl	_PDUmessage_trans
	.globl	_PDUtranslate_message_and_vars
	.globl	_OPP_IGEgragad_class_id
	.globl	_stat
	.globl	_parse_exp_and_get_value
	.globl	_PDMquery_dynamic_attrs
	.globl	_PDUget_all_parametric_ids
	.globl	_GRconstruct_dv
	.globl	_PDUremove_tree
	.globl	_new_exp_Parse
	.globl	_PDUattach_macro_library
	.globl	_IGEactivate_stop_sign
	.globl	_GRgraphics_OPP_GRconstruct_method_index
	.globl	_PDU_value_pulldown
	.globl	_PDU_selected_rows
	.globl	_PDMDeletePartOccurrence
	.globl	_PDUformat_os_parts_bufr
	.globl	_GRreffile_OPP_GRgetdescription_method_index
	.globl	_PDUcleanup_revise_assembly
	.globl	__pdm_rstatus2
	.globl	_GRreffile_OPP_GRrfload_method_index
	.globl	_PDU_nfs_flag
	.globl	_ModifyPartForm
	.globl	_PDU_struct_type
	.globl	_PDUgenerate_instance_number
	.globl	_PDUload_child_buffer
	.globl	_PDUremove_assembly
	.globl	_MEMwrite_format
	.globl	_RISquery
	.globl	_PDUbufr_to_mcf
	.globl	_PDMRetrieveAssyFiles
	.globl	_PDMassembly_attributes
	.globl	_PDUformat_macro_bufr
	.globl	_OPP_GRpart_class_id
	.globl	_PDU_display_pointers
	.globl	_PDUbuffer_data
	.globl	_PDUexit_save
	.globl	_PDMget_filenames
	.globl	_PDU_part_id
	.globl	_PDUget_storage_buffer
	.globl	_OM_Gp_NULL_MESSAGE
	.globl	_PDUload_active_checkin_info
	.globl	_GRvg_OPP_GRgenabsg_method_index
	.globl	_labels
	.globl	_PDUwrite_refresh
	.globl	_PDUupdate_local_column
	.globl	_PDUdisplay_checkin_files
	.globl	_GRchange_pull_down_text
	.globl	_PDUload_file_structure
	.globl	_PDUconvert_dir_to_exp
	.globl	_exitdel
	.globl	_PDUdeactivate
	.globl	_EX_findmod
	.globl	_PDU_DEBUG_FILE
	.globl	_PDMdebug_on
	.globl	_PDU_viewnames
	.globl	_GRsmplmat
	.globl	_PDUinitialize_help
	.globl	_PDUextract_dyn_attr_value
	.globl	_PDU_command
	.globl	_PDUdealloc
	.globl	_PDUget_objects
	.globl	_similar_mode
	.globl	_strncmp
	.globl	_PDUupdate_local_column_for_refresh
	.globl	_PDU_auto_login
	.globl	_PDUsort_criteria_on_off
	.globl	_storage
	.globl	_EX_get_oid_nodname
	.globl	_PDUget_filename_for_part
	.globl	_som_send_foreign
	.globl	_PDU_param_buffer
	.globl	_PDUget_col_number
	.globl	_PDUdelete_files
	.globl	_FIg_set_state_on
	.globl	_PDU_tree_attach
	.globl	_PDUfree_list
	.globl	_PDUis_checkin_file_attached
	.globl	_PDUdynamic_attr_form
	.globl	_PDUcheck_for_function
	.globl	_PDUconstruct_refid_string
	.globl	_EX_help_init
	.globl	_GRgraphics_OPP_GRgetprops_method_index
	.globl	_PDU_to_usageid
	.globl	_EX_exit_function_no_save
	.globl	_MEMsplit_copy_buffer
	.globl	_PDUep_proj_btn
	.globl	_PDUadd_buffer_string
	.globl	_MSmessage
	.globl	_MEMreset_buffer_no
	.globl	_PDUextract_dir_value
	.globl	_PDUget_ref_file_name
	.globl	_PDUattach_ref_to_GRpart
	.globl	_GRowner_OPP_GRremove_components_method_index
	.globl	_PDUcheck_file_commands
	.globl	_PDUep_part_fld
	.globl	_PDUdelete_part
	.globl	_find_file
	.globl	_EX_getpath
	.globl	_PDU_srch_catalog
	.globl	_PDUload_local_file_buffer
	.globl	_PDUget_buffer_col
	.globl	_PDUlist_all_origins_in_os
	.globl	_PDUget_max_level
	.globl	_FIf_cvrt_to_perm_win
	.globl	_strlen
	.globl	_PDU_calling_form
	.globl	_PDUload_macrolibrary_copy_buffer
	.globl	_PDUcheck_alttag_for_rev_assy
	.globl	_EX_is_file_open
	.globl	_PDU_save_project
	.globl	_PDUlist_files
	.globl	_strcat
	.globl	_PDUupdate_dyn_data_buffer
	.globl	_EX_retrieve_os
	.globl	_PDUdelete_active_part_form
	.globl	_PDUprocess_assembly_display
	.globl	_PDU_incl_ASM
	.globl	_PDUis_PDU_design_file
	.globl	_PDU_form_type
	.globl	_PDU_explode_BOM
	.globl	_place_part_f
	.globl	_GRdelete_pull_down_list
	.globl	__ctype
	.globl	_PDUdefine_report_format
	.globl	_PDU_view_buffer
	.globl	_DPmacupdate
	.globl	_FIfld_set_mode
	.globl	_PDU_dyn_attr_bufr
	.globl	_PDUconvert_dyn_attrs
	.globl	_PDU_storage_area
	.globl	_PDUvalidate_value
	.globl	_OPP_expression_class_id
	.globl	_PDMpost_to_database
	.globl	__pdm_status
	.globl	_som_send_channel
	.globl	__pdm_status2
	.globl	_EX_save1
	.globl	_PDUget_dyn_attr_value
	.globl	_PDUsingle_list_form
	.globl	_delete_prpart
	.globl	_COpart_pass_func
	.globl	_PDUattach_single_list_form
	.globl	_PDUget_exnuc_path
	.globl	_PDU_activate_reffile_display
	.globl	_EXP_delete_by_objid
	.globl	_PDUget_exp_objects
	.globl	_PDMrverify_catalog
	.globl	_PDUdefine_refresh
	.globl	_PDUget_all_ref_file_names
	.globl	_PDU_save_description
	.globl	_PDU_design_listing_form_displayed
	.globl	_FIg_set_value
	.globl	_review_mode
	.globl	_som_make_chanselect
	.globl	_GRgetevent
	.globl	_PDUep_cat_btn
	.globl	_PDUextract_coord_orientation
	.globl	_convert_tolower
	.globl	_PDUlocal_files_form
	.globl	_PDUverify_files_exist_locally
	.globl	_PDUstrcpy
	.globl	_strcmp
	.globl	_UI_prompt
	.globl	_pdmoDeletePartOccurrence
	.globl	_PDUdelete_report
	.globl	_PDUstamp_PDU_design_file
	.globl	_PDU_attr_value
	.globl	_sleep
	.globl	_PDUput_queue
	.globl	_FIfld_set_active_row
	.globl	_PDU_last_file
	.globl	_forms
	.globl	_PDU_macro_catalog
	.globl	_FIf_set_orig_coord
	.globl	_time
	.globl	_PDUcreate_file_buffer_from_refresh
	.globl	_PDUexecute_upon_save_for_rev_assy
	.globl	_FIg_call_notification_routine
	.globl	_PDU_assy_catalog
	.globl	_GRcheckref
	.globl	_PDUattach_single_list_form_single
	.globl	_PDUdismiss_subforms
	.globl	_PDU_save_act_description
	.globl	_OPP_GRgencs_class_id
	.globl	_FIg_disable
	.globl	_GRtext_OPP_GRfield_inquire_method_index
	.globl	_PDU_checkout_type
	.globl	_PDU_ng_placement
	.globl	_PDU_active_part
	.globl	_DPsetinqsavvw
	.globl	_tolower
	.globl	_PDUdo_positionless_parts_exist
	.globl	_PDU_file_bufr
	.globl	_strstr
	.globl	_OPP_GRvg_class_id
	.globl	_DIgive_osnum
	.globl	_PDU_list_origins
	.globl	_PALdyn_bufr
	.globl	_PDUload_detach_buffer
	.globl	_PDUflag_part
	.globl	_memset
	.globl	_EXP_gen_name
	.globl	_GRrfshwrclip
	.globl	_FIfld_pos_cursor
	.globl	_PDUload_delete_buffer
	.globl	_PDU_macro_name
	.globl	_PDMquery_part_type
	.globl	_PDUsetup_popup_list
	.globl	_PDU_delete_local_buffer
	.globl	_PDUunquote
	.globl	_FIg_set_location
	.globl	_UI_status
	.globl	_strchr
	.globl	_PDUget_GRpart_all_attrs
	.globl	_PALchekin
	.globl	_PDMset_update_os_flag
	.globl	_PDU_topdown_created
	.globl	_PDUcheckin
	.globl	_PDU_dynamics_on
	.globl	_PDUassembly_display_form
	.globl	_PDUprocess_dyn_pulldown_list
	.globl	_UMSGetByNum
	.globl	_OPP_GRcsmgr_class_id
	.globl	_PDU_list_parts
	.globl	_FIg_set_text
	.globl	_Check_displayed_forms
	.globl	_FIfld_get_num_rows
	.globl	_UI_echo
	.globl	_PDU_assy_ptr
	.globl	_PDUcheck_if_graphic
	.globl	_PDMget_usageid_cat
	.globl	_FIg_erase
	.globl	_PDUget_file_status
	.globl	_fclose
	.globl	_PDUreports_form
	.globl	_DIstmcat
	.globl	_PDUsetup_single_buffer
	.globl	_PDU_validate_access
	.globl	_strpbrk
	.globl	_PDU_popup_list_type
	.globl	_WaitForEvent
	.globl	_PDUcreate_GRpart
	.globl	_atoi
	.globl	_UI_error
	.globl	_GRreffile_OPP_GRgetrfprops_method_index
	.globl	_DIstrcpy
	.globl	_EXP_delete_by_name
	.globl	_COmn_align
	.globl	_PDU_attach_macro_lib
	.globl	_Close_OS
	.globl	_PDUload_exec_structure
	.globl	_PDUchange_review_file_permissions
	.globl	_PDUupdate_display_in_assembly
	.globl	_vfork
	.globl	_PDUconvert_form_to_win
	.globl	_sscanf
	.globl	_COpart_attr_func
	.globl	_GRgraphics_OPP_GRchgprops_method_index
	.globl	_PDUupdate_copy_macro_lib_bufr
	.globl	_PDU_value_list
	.globl	_FIg_set_high_value
	.globl	_PDUremove_non_existent_parts_from_assy_struct
	.globl	_PDUupdate_dyn_data_buffer1
	.globl	_PDUfill_in_string1
	.globl	_PDUupdate_active_part_info
	.globl	_OPP_GRowner_class_id
	.globl	_PDU_gadget_labels
	.globl	_PDUevaluate_exp
	.globl	_PDUget_parttype
	.globl	_PDU_second_row
	.globl	_PDU_detach_macro_lib
	.globl	_EXP_translate_exp
	.globl	_PDU_usage_id
	.globl	_PDMplacement_attributes
	.globl	_PDU_design_form_display
	.globl	_PDUcreate_expression
	.globl	_PDUupdate_parametric_tag
	.globl	_PDUget_context_from_refid
	.globl	_GRreffile_OPP_GRputdescription_method_index
	.globl	_OPP_ACconst_class_id
	.globl	_PDMopen_buffer
	.globl	_PDUcheck_assembly_consistency
	.globl	_PDUvalidate_dyn_data_value
	.globl	_PDU_attach_buffer
	.globl	_PDU_review_file
	.globl	_PDUchild_dyn_buffer
	.globl	_PDUis_usage_unique
	.globl	_som_get_channel_objects
	.globl	_GRreffile_OPP_GRinquireref_method_index
	.globl	_fields
	.globl	_PDU_activate_copy
	.globl	_PDUextract_catpartrev_entries
	.globl	_FIf_is_displayed
	.globl	_PDUmerge_dynamic_attribute_bufrs
	.globl	_part
	.globl	_new_mode
	.globl	_EX_is_invis
	.globl	_PDMinsert_citinfo
	.globl	_PDUep_rev_fld
	.globl	_PDUcheck_expression_value
	.globl	_PDUgenerate_coord_orientation
	.globl	_PDMshow_saved_views
	.globl	_PDU_parts_list_buffer
	.globl	_MEMbuild_array
	.globl	_PDU_list_parts_info
	.globl	_PDUfill_in_string
	.globl	_NDnode_OPP_NDgive_structure_method_index
	.globl	_FIf_delete
	.globl	_PDUbufr_to_form_single
	.globl	_PDUlist_all_parts_in_os
	.globl	_som_is_om_file
	.globl	_PDUbufr_to_form_fields
	.globl	_PDU_save_partid
	.globl	_MEMclose
	.globl	_PDMget_catno_partno
	.globl	_PDU_edit_display
	.globl	_PDUfind_attr_by_synonym
	.globl	_PDUcvt_20objspace_for_checkout
	.globl	_PDMrcopy_attach
	.globl	_OM_Gw_current_OS
	.globl	_PDMset_to_state
	.globl	_OPP_NDnode_class_id
	.globl	_PDU_list_filenames
	.globl	_PDMcopy_macro_library
	.globl	_PDUext_checkout
	.globl	_PDUdisplay_report
	.globl	_PDUget_default_usage_id
	.globl	_fprintf
	.globl	_AClib_dir
	.globl	_PDUextract_expression_RHS
	.globl	_BreakLocAndNonLocDYn
	.globl	_FIf_is_collapsed
	.globl	_MS_out_msg
	.globl	_PDUdesign_options_form
	.globl	_MAmulmx
	.globl	_FIfld_set_num_rows
	.globl	_DIfrees
	.globl	_tmpnam
	.globl	_PDUdelete_catalog
	.globl	_PDUfix_orientation
	.globl	_ACconstruct_path
	.globl	_PDUcheckout
	.globl	_PDUload_dynamic_attrs
	.globl	_PDUevaluate_expression
	.globl	_PDU_macro_dyn_num
	.globl	_PDU_level_no
	.globl	_PDU_parts_list_bufr
	.globl	_OPP_Root_class_id
	.globl	_PDU_ref_parent_child_list
	.globl	_PDUdo_origins_exist
	.globl	_PDUdump_matrix
	.globl	_DIgive_pathname
	.globl	_PDMrdelete_local_files
	.globl	_DPsavevw_cons
	.globl	_PDUwork_controller
	.globl	_PDU_extadmin
	.globl	_PDUgenerate_tag_no
	.globl	_PDUadd_assy_struct_from_buffer
	.globl	_PDUep_rev_btn
	.globl	_IGEdeactivate_stop_sign
	.globl	_PDMdetach_macro_library
	.globl	_PDUext_get_children
	.globl	_refresh
	.globl	_PDUis_PDU_file
	.globl	_topdown_user_seed_file
	.globl	_PDUdelete_single_local_file
	.globl	_PDUcreate_attach_info_buffer
	.globl	_PDUsearch_on_off
	.globl	_PDU_perm_window
	.globl	_PDMGetPartInfoGivenFileName
	.globl	_PDUget_pdu_path
	.globl	_PDU_ret_bufr
	.globl	_FIfld_get_text
	.globl	_PDU_align
	.globl	_PDUfree_string_array
	.globl	_PDU_macro_library
	.globl	_PDUget_incbom
	.globl	_PDU_dyn_data_bufr
	.globl	_PDU_single_list_created
	.globl	_PDUfind_dyn_attr_by_synonym
	.globl	_PDUadd_part_to_project
	.globl	_GRgraphics_OPP_GRxform_method_index
	.globl	_OM_Gw_TransOSnum_0
	.globl	_EX_get_invis_info_by_index
	.globl	_PDMcopy_attach
	.globl	_PDU_assy_partid
	.globl	_PDUis_part_positionless
	.globl	__pdm_debug
	.globl	_MEMwrite_data
	.globl	_FIg_get_state
	.globl	_PDUget_coord_sys_id
	.globl	_PDUcreate_catalog
	.globl	_PDU_part_file_buffer
	.globl	_sprintf
	.globl	_GRowner_OPP_GRadd_components_method_index
	.globl	_ACconstruct_save
	.globl	_OPP_nci_macro_class_id
	.globl	_PDU_detach_buffer
	.globl	_PDU_single_list_displayed
	.globl	_PDMrcancel_checkout_part
	.globl	_unlink
	.globl	_PDMreset_transfer_status
	.globl	_PDUgenerate_instance_number_cvt
	.globl	_PDU_assy_revision
	.globl	_FIg_enable
	.globl	_PDMcheck_if_checkedin
	.globl	_FImcf_set_select
	.globl	_PDUget_date
	.globl	_pdmoGetPartidGivenUsageid
	.globl	_NULL_OBJID
	.globl	_DImain
	.globl	_PDUload_copy_attach_buffer
	.globl	_PDUsetup_buffer
	.globl	_PDU_parts_id_list
	.globl	_PDUcheck_partnum
	.globl	_PDUget_keyin
	.globl	_PDUcreate_like_catalog
	.globl	_PDU_default_color
	.globl	_current_rev_assy
	.globl	_PDUupdate_attach_info
	.globl	_PDU_topdown_displayed
	.globl	_PDUget_attr
	.globl	_PDUstring_to_point
	.globl	_PDUverify_file
	.globl	_PDUprocess_function
	.globl	_PDUcreate_dynamic_arrays
	.globl	_OPP_GRdvattach_class_id
	.globl	_FIfld_get_text_length
	.globl	_FIfld_get_active_row
	.globl	_chmod
	.globl	_DItranslate
	.globl	_PDUprepare_load_attribute_structure
	.globl	_OPP_GRtext_class_id
	.globl	_GRcreate_pull_down_list
	.globl	_PDUuser_init
	.globl	_strrchr
	.globl	_PDUload_assy_struct_buffer
	.globl	_PDUis_active_file_a_part
	.globl	_PDUmodify_exp
	.globl	_PDU_check_file_refresh
	.globl	_PDU_topdown_perm_window
	.globl	_PDUautomatic_seed_file
	.globl	_PDUdebug_on
	.globl	_PDUfind_PDU_stamp_files
	.globl	_PDU_refresh_gadgets
	.globl	_get_nblines_in_dir
	.globl	_som_convert_os_name_to_number
	.globl	_PDUxform_string
	.globl	_PDUmessage
	.globl	_FIf_display
	.globl	_PDUpart_init
	.globl	_PDUgenerate_child_no
	.globl	_PDUformat_buffer
	.globl	_PDU_save_act_filename
	.globl	_som_get_channel_count
	.globl	_PDUremove_local_files_after_delete
	.globl	_PDUlogin_form
	.globl	_GRcsmgr_OPP_GRget_acs_info_method_index
	.globl	_PDMcopy
	.globl	_GRgraphics_OPP_GRchgname_method_index
	.globl	_Root_OPP_delete_method_index
	.globl	_EX_exit_function
	.globl	_AClib_name
	.globl	_PDUtranslate_message
	.globl	_PDU_origin_id
	.globl	_PDUparts_list_form
	.globl	_FIg_reset
	.globl	_PDUexecute_upon_save
	.globl	_PDUdump_point
	.globl	_PDMrecreate_validated_dyn_databufr
	.globl	_PDU_filename
	.globl	_PDU_mcf_list
	.globl	_MEMprint_buffer
	.globl	_GRdpb_get
	.globl	_PDUsetup_design_struct
	.globl	_PDUupdate_assembly_structure
	.globl	_MEMprint_buffers
	.globl	_PDU_update_struct
	.globl	_fgets
	.globl	_PDUload_view_info
	.globl	_PDUcopy_file
	.globl	_PDUload_inactive_checkin_info
	.globl	_PDU_active_part_create
	.globl	_printf
	.globl	_IGEgragad_OPP_DPinrot_method_index
	.globl	_FIfld_set_text
	.globl	_PDUdisplay_views
	.globl	_PDUvalidate_quantity
	.globl	_PDUdelete_boms
	.globl	_FImcf_set_active_col
	.globl	_PDUdelete_flagged_parts_in_assembly
	.globl	_DPdisbyoid
	.globl	_PDUprepare_param_cats_list
	.globl	_PDUdisplay_files
	.globl	_PDU_dyn_index
	.globl	_PDUcreate_part_pointer
	.globl	__PDMtime_commit
	.globl	_PDUcheck_usageid_for_rev_assy
	.globl	_FIfld_set_select
	.globl	_som_get_classname
	.globl	_PDUinitialize_replace_pointers
	.globl	_getenv
	.globl	_PDUcheck_file_permissions
	.globl	_PDU_local_files_created
	.globl	_PDU_save_act_revision
	.globl	_PDUread_refresh_file
	.globl	_PDU_child_buffer
	.globl	_PDUstrip_dir_entry
	.globl	_part_occur_list
	.globl	_PDMmove_functions
	.globl	_PDUdelete_expression
	.globl	_PDMget_children
	.globl	_PDU_parts_list_displayed
	.globl	_PDUcancel_checkout
	.globl	_PDMget_part_attach_info
	.globl	_PDUactivate
	.globl	_PDUis_cyclic_placement
	.globl	_PDUautomatic_login
	.globl	_PDU_dyn_value_bufr
	.globl	_PDU_active_button
	.globl	_PDUis_parametric_part
	.globl	_PDU_save_catalog
	.globl	_PDUactive_part_form
	.globl	__PDMtime_data
	.globl	_PDU_design_parts_bufr
	.globl	_fopen
	.globl	_PDU_local_files_displayed
	.globl	_PDU_clipping_on
	.globl	_PDU_attach_bufr
	.globl	_DIfast_trans
	.globl	_PDUnfs_toggle
	.globl	_refresh_init
	.globl	_PDU_list_origins_info
	.globl	_PDUext_checkin
	.globl	_PDMget_list_buffer
	.globl	_PDU_macro_partrev
	.globl	_PDUrefresh_local_files_form
	.globl	_topdown_seed_form_created
	.globl	_PDUverify_part
	.globl	_PDUget_grnuc_path
	.globl	_PDUexit_nosave
	.globl	_PDUsetup_form_fields
	.globl	_MEMappend
	.globl	_PDU_checkin_lib
	.globl	_PDUchmod
	.globl	_waitpid
	.globl	_topdown_seed_form_displayed
	.globl	_PDU_tagno
	.globl	_EX_get_super
	.globl	_PDU_login
	.globl	_PDUcleanup_detached_parts_after_save
	.globl	_PDU_save_act_catalog
	.globl	_PDUep_desc_fld
	.globl	_Instance_Macro
	.globl	_OPP_text_exp_class_id
	.globl	_PDU_macro_partid
	.globl	_DIreport_error
	.globl	_PDU_pdm_initialized
	.globl	_PDU_ex_help_init
