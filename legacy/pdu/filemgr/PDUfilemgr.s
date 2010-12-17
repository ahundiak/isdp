	.file	"PDUfilemgr.s"
#
# Begin stubs for:  PDUbufrs.o
#
	.data
.T1:	.byte	80, 100, 117, 0
	.byte	112, 100, 117, 47, 102, 105, 108, 101, 109, 103
	.byte	114, 0
	.align	4
.F1:	.long	0x00000700
	.byte	80, 68, 85, 98, 117, 102, 114, 115, 46, 111
	.byte	0
	.text

	.globl	_PDUinit_stack
_PDUinit_stack:
	movw	$.T1,r2
	movw	$.F1,r3
	call	sp,Rload
	b	_PDUinit_stack

	.globl	_PDUpush_into_stack
_PDUpush_into_stack:
	movw	$.T1,r2
	movw	$.F1,r3
	call	sp,Rload
	b	_PDUpush_into_stack

	.globl	_PDUget_top_of_stack
_PDUget_top_of_stack:
	movw	$.T1,r2
	movw	$.F1,r3
	call	sp,Rload
	b	_PDUget_top_of_stack

	.globl	_PDUdelete_from_stack
_PDUdelete_from_stack:
	movw	$.T1,r2
	movw	$.F1,r3
	call	sp,Rload
	b	_PDUdelete_from_stack

	.globl	_PDUprint_stack
_PDUprint_stack:
	movw	$.T1,r2
	movw	$.F1,r3
	call	sp,Rload
	b	_PDUprint_stack

	.globl	_PDUpull_from_bufr
_PDUpull_from_bufr:
	movw	$.T1,r2
	movw	$.F1,r3
	call	sp,Rload
	b	_PDUpull_from_bufr

	.globl	_PDUremove_data
_PDUremove_data:
	movw	$.T1,r2
	movw	$.F1,r3
	call	sp,Rload
	b	_PDUremove_data

	.globl	_PDUcheck_file_info_privileges
_PDUcheck_file_info_privileges:
	movw	$.T1,r2
	movw	$.F1,r3
	call	sp,Rload
	b	_PDUcheck_file_info_privileges

	.globl	_PDUlist_dmgn_bufr
_PDUlist_dmgn_bufr:
	movw	$.T1,r2
	movw	$.F1,r3
	call	sp,Rload
	b	_PDUlist_dmgn_bufr

	.globl	_PDUlist_pgn_bufr
_PDUlist_pgn_bufr:
	movw	$.T1,r2
	movw	$.F1,r3
	call	sp,Rload
	b	_PDUlist_pgn_bufr

	.globl	_PDUlist_pan_bufr
_PDUlist_pan_bufr:
	movw	$.T1,r2
	movw	$.F1,r3
	call	sp,Rload
	b	_PDUlist_pan_bufr

	.globl	_PDUlist_pag_bufr
_PDUlist_pag_bufr:
	movw	$.T1,r2
	movw	$.F1,r3
	call	sp,Rload
	b	_PDUlist_pag_bufr

	.globl	_PDUlist_gn_bufr
_PDUlist_gn_bufr:
	movw	$.T1,r2
	movw	$.F1,r3
	call	sp,Rload
	b	_PDUlist_gn_bufr

	.globl	_PDUlist_an_bufr
_PDUlist_an_bufr:
	movw	$.T1,r2
	movw	$.F1,r3
	call	sp,Rload
	b	_PDUlist_an_bufr

	.globl	_PDUlist_ag_bufr
_PDUlist_ag_bufr:
	movw	$.T1,r2
	movw	$.F1,r3
	call	sp,Rload
	b	_PDUlist_ag_bufr

	.globl	_PDUremove_col_data
_PDUremove_col_data:
	movw	$.T1,r2
	movw	$.F1,r3
	call	sp,Rload
	b	_PDUremove_col_data

	.globl	_PDUpull_when_diff
_PDUpull_when_diff:
	movw	$.T1,r2
	movw	$.F1,r3
	call	sp,Rload
	b	_PDUpull_when_diff

	.globl	_PDUpull_diff_values
_PDUpull_diff_values:
	movw	$.T1,r2
	movw	$.F1,r3
	call	sp,Rload
	b	_PDUpull_diff_values

	.globl	_PDUsamecat_defaults
_PDUsamecat_defaults:
	movw	$.T1,r2
	movw	$.F1,r3
	call	sp,Rload
	b	_PDUsamecat_defaults

	.globl	_PDUcopy_buffer_format
_PDUcopy_buffer_format:
	movw	$.T1,r2
	movw	$.F1,r3
	call	sp,Rload
	b	_PDUcopy_buffer_format
#
# Begin stubs for:  PDUcheckin.o
#
	.data
	.align	4
.F2:	.long	0x00000700
	.byte	80, 68, 85, 99, 104, 101, 99, 107, 105, 110
	.byte	46, 111, 0
	.text

	.globl	_PDUext_checkin
_PDUext_checkin:
	movw	$.T1,r2
	movw	$.F2,r3
	call	sp,Rload
	b	_PDUext_checkin

	.globl	_PDUcheckin
_PDUcheckin:
	movw	$.T1,r2
	movw	$.F2,r3
	call	sp,Rload
	b	_PDUcheckin

	.globl	_PDUupdate_list_after_deactchkin
_PDUupdate_list_after_deactchkin:
	movw	$.T1,r2
	movw	$.F2,r3
	call	sp,Rload
	b	_PDUupdate_list_after_deactchkin
#
# Begin stubs for:  PDUcheckout.o
#
	.data
	.align	4
.F3:	.long	0x00000700
	.byte	80, 68, 85, 99, 104, 101, 99, 107, 111, 117
	.byte	116, 46, 111, 0
	.text

	.globl	_PDUext_checkout
_PDUext_checkout:
	movw	$.T1,r2
	movw	$.F3,r3
	call	sp,Rload
	b	_PDUext_checkout

	.globl	_PDUupdate_checked_out_parts
_PDUupdate_checked_out_parts:
	movw	$.T1,r2
	movw	$.F3,r3
	call	sp,Rload
	b	_PDUupdate_checked_out_parts

	.globl	_PDUupdate_form_after_checkin_out
_PDUupdate_form_after_checkin_out:
	movw	$.T1,r2
	movw	$.F3,r3
	call	sp,Rload
	b	_PDUupdate_form_after_checkin_out

	.globl	_PDUcheckout
_PDUcheckout:
	movw	$.T1,r2
	movw	$.F3,r3
	call	sp,Rload
	b	_PDUcheckout
#
# Begin stubs for:  PDUfile.o
#
	.data
	.align	4
.F4:	.long	0x00000700
	.byte	80, 68, 85, 102, 105, 108, 101, 46, 111, 0
	.text

	.globl	_PDUdelete_local_files
_PDUdelete_local_files:
	movw	$.T1,r2
	movw	$.F4,r3
	call	sp,Rload
	b	_PDUdelete_local_files

	.globl	_PDUext_cancel_checkout
_PDUext_cancel_checkout:
	movw	$.T1,r2
	movw	$.F4,r3
	call	sp,Rload
	b	_PDUext_cancel_checkout

	.globl	_PDUcancel_checkout
_PDUcancel_checkout:
	movw	$.T1,r2
	movw	$.F4,r3
	call	sp,Rload
	b	_PDUcancel_checkout

	.globl	_PDUdelete_file
_PDUdelete_file:
	movw	$.T1,r2
	movw	$.F4,r3
	call	sp,Rload
	b	_PDUdelete_file

	.globl	_PDUremove_files_locally
_PDUremove_files_locally:
	movw	$.T1,r2
	movw	$.F4,r3
	call	sp,Rload
	b	_PDUremove_files_locally

	.globl	_PDUremove_local_files_after_delete
_PDUremove_local_files_after_delete:
	movw	$.T1,r2
	movw	$.F4,r3
	call	sp,Rload
	b	_PDUremove_local_files_after_delete

	.globl	_PDUdelete_cpio_files
_PDUdelete_cpio_files:
	movw	$.T1,r2
	movw	$.F4,r3
	call	sp,Rload
	b	_PDUdelete_cpio_files

	.globl	_PDUchange_to_read_only
_PDUchange_to_read_only:
	movw	$.T1,r2
	movw	$.F4,r3
	call	sp,Rload
	b	_PDUchange_to_read_only

	.globl	_PDUcopy_attach
_PDUcopy_attach:
	movw	$.T1,r2
	movw	$.F4,r3
	call	sp,Rload
	b	_PDUcopy_attach

	.globl	_PDUcheck_if_file_attached
_PDUcheck_if_file_attached:
	movw	$.T1,r2
	movw	$.F4,r3
	call	sp,Rload
	b	_PDUcheck_if_file_attached

	.globl	_PDUcopy_files_for_refresh_part
_PDUcopy_files_for_refresh_part:
	movw	$.T1,r2
	movw	$.F4,r3
	call	sp,Rload
	b	_PDUcopy_files_for_refresh_part
#
# Begin stubs for:  PDUflag.o
#
	.data
	.align	4
.F5:	.long	0x00000700
	.byte	80, 68, 85, 102, 108, 97, 103, 46, 111, 0
	.text

	.globl	_PDUflag_part
_PDUflag_part:
	movw	$.T1,r2
	movw	$.F5,r3
	call	sp,Rload
	b	_PDUflag_part
#
# Begin stubs for:  PDUlf_form.o
#
	.data
	.align	4
.F6:	.long	0x00000700
	.byte	80, 68, 85, 108, 102, 95, 102, 111, 114, 109
	.byte	46, 111, 0
	.text

	.globl	_PDUsetup_env
_PDUsetup_env:
	movw	$.T1,r2
	movw	$.F6,r3
	call	sp,Rload
	b	_PDUsetup_env

	.globl	_local_files_notification_routine
_local_files_notification_routine:
	movw	$.T1,r2
	movw	$.F6,r3
	call	sp,Rload
	b	_local_files_notification_routine

	.globl	_PDUdismiss_subforms
_PDUdismiss_subforms:
	movw	$.T1,r2
	movw	$.F6,r3
	call	sp,Rload
	b	_PDUdismiss_subforms

	.globl	_PDUreset_local_files_form
_PDUreset_local_files_form:
	movw	$.T1,r2
	movw	$.F6,r3
	call	sp,Rload
	b	_PDUreset_local_files_form

	.globl	_PDUcheck_file_commands
_PDUcheck_file_commands:
	movw	$.T1,r2
	movw	$.F6,r3
	call	sp,Rload
	b	_PDUcheck_file_commands

	.globl	_PDUenable_local_files_gadgets
_PDUenable_local_files_gadgets:
	movw	$.T1,r2
	movw	$.F6,r3
	call	sp,Rload
	b	_PDUenable_local_files_gadgets

	.globl	_PDUdisable_local_files_gadgets
_PDUdisable_local_files_gadgets:
	movw	$.T1,r2
	movw	$.F6,r3
	call	sp,Rload
	b	_PDUdisable_local_files_gadgets

	.globl	_PDUset_edit_assy_toggle_after_select
_PDUset_edit_assy_toggle_after_select:
	movw	$.T1,r2
	movw	$.F6,r3
	call	sp,Rload
	b	_PDUset_edit_assy_toggle_after_select

	.globl	_PDUclear_mcf
_PDUclear_mcf:
	movw	$.T1,r2
	movw	$.F6,r3
	call	sp,Rload
	b	_PDUclear_mcf

	.globl	_PDUload_local_files_form
_PDUload_local_files_form:
	movw	$.T1,r2
	movw	$.F6,r3
	call	sp,Rload
	b	_PDUload_local_files_form

	.globl	_PDUcount_selected_parts
_PDUcount_selected_parts:
	movw	$.T1,r2
	movw	$.F6,r3
	call	sp,Rload
	b	_PDUcount_selected_parts

	.globl	_PDUload_refresh_from_parts_list
_PDUload_refresh_from_parts_list:
	movw	$.T1,r2
	movw	$.F6,r3
	call	sp,Rload
	b	_PDUload_refresh_from_parts_list

	.globl	_PDUcheck_part_data_for_utilities
_PDUcheck_part_data_for_utilities:
	movw	$.T1,r2
	movw	$.F6,r3
	call	sp,Rload
	b	_PDUcheck_part_data_for_utilities

	.globl	_PDUlocal_files_form
_PDUlocal_files_form:
	movw	$.T1,r2
	movw	$.F6,r3
	call	sp,Rload
	b	_PDUlocal_files_form

	.globl	_PDUvalidate_refresh_data
_PDUvalidate_refresh_data:
	movw	$.T1,r2
	movw	$.F6,r3
	call	sp,Rload
	b	_PDUvalidate_refresh_data

	.globl	_PDUload_refresh_at_login
_PDUload_refresh_at_login:
	movw	$.T1,r2
	movw	$.F6,r3
	call	sp,Rload
	b	_PDUload_refresh_at_login

	.globl	_PDUblank_out_multiple_files
_PDUblank_out_multiple_files:
	movw	$.T1,r2
	movw	$.F6,r3
	call	sp,Rload
	b	_PDUblank_out_multiple_files

	.globl	_PDUrefresh_local_files_form
_PDUrefresh_local_files_form:
	movw	$.T1,r2
	movw	$.F6,r3
	call	sp,Rload
	b	_PDUrefresh_local_files_form

	.globl	_PDUcopy_structure_buffer_to_parts_buffer
_PDUcopy_structure_buffer_to_parts_buffer:
	movw	$.T1,r2
	movw	$.F6,r3
	call	sp,Rload
	b	_PDUcopy_structure_buffer_to_parts_buffer

	.globl	_PDURetFromSelect
_PDURetFromSelect:
	movw	$.T1,r2
	movw	$.F6,r3
	call	sp,Rload
	b	_PDURetFromSelect

	.globl	_PDUupdate_local_files_form_after_select
_PDUupdate_local_files_form_after_select:
	movw	$.T1,r2
	movw	$.F6,r3
	call	sp,Rload
	b	_PDUupdate_local_files_form_after_select

	.globl	_PDUupdate_topdown_form_after_select
_PDUupdate_topdown_form_after_select:
	movw	$.T1,r2
	movw	$.F6,r3
	call	sp,Rload
	b	_PDUupdate_topdown_form_after_select

	.globl	_PDUpaint_form
_PDUpaint_form:
	movw	$.T1,r2
	movw	$.F6,r3
	call	sp,Rload
	b	_PDUpaint_form
#
# Begin stubs for:  PDUlist_file.o
#
	.data
	.align	4
.F7:	.long	0x00000700
	.byte	80, 68, 85, 108, 105, 115, 116, 95, 102, 105
	.byte	108, 101, 46, 111, 0
	.text

	.globl	_PDUlist_files
_PDUlist_files:
	movw	$.T1,r2
	movw	$.F7,r3
	call	sp,Rload
	b	_PDUlist_files
#
# Begin stubs for:  PDUlogin.o
#
	.data
	.align	4
.F8:	.long	0x00000700
	.byte	80, 68, 85, 108, 111, 103, 105, 110, 46, 111
	.byte	0
	.text

	.globl	_login_notification_routine
_login_notification_routine:
	movw	$.T1,r2
	movw	$.F8,r3
	call	sp,Rload
	b	_login_notification_routine

	.globl	_PDUprocess_login
_PDUprocess_login:
	movw	$.T1,r2
	movw	$.F8,r3
	call	sp,Rload
	b	_PDUprocess_login

	.globl	_PDUlogin_form
_PDUlogin_form:
	movw	$.T1,r2
	movw	$.F8,r3
	call	sp,Rload
	b	_PDUlogin_form

	.globl	_PDUdefault_env
_PDUdefault_env:
	movw	$.T1,r2
	movw	$.F8,r3
	call	sp,Rload
	b	_PDUdefault_env

	.globl	_get_remote_path
_get_remote_path:
	movw	$.T1,r2
	movw	$.F8,r3
	call	sp,Rload
	b	_get_remote_path

	.globl	_PDUautomatic_login
_PDUautomatic_login:
	movw	$.T1,r2
	movw	$.F8,r3
	call	sp,Rload
	b	_PDUautomatic_login
#
# Begin stubs for:  PDUmcf_list.o
#
	.data
	.align	4
.F9:	.long	0x00000700
	.byte	80, 68, 85, 109, 99, 102, 95, 108, 105, 115
	.byte	116, 46, 111, 0
	.text

	.globl	_mcf_list_notification_routine
_mcf_list_notification_routine:
	movw	$.T1,r2
	movw	$.F9,r3
	call	sp,Rload
	b	_mcf_list_notification_routine

	.globl	_PDUmcf_list_form
_PDUmcf_list_form:
	movw	$.T1,r2
	movw	$.F9,r3
	call	sp,Rload
	b	_PDUmcf_list_form
#
# Begin stubs for:  PDUmisc2.o
#
	.data
	.align	4
.F10:	.long	0x00000700
	.byte	80, 68, 85, 109, 105, 115, 99, 50, 46, 111
	.byte	0
	.text

	.globl	_PDUfree_string
_PDUfree_string:
	movw	$.T1,r2
	movw	$.F10,r3
	call	sp,Rload
	b	_PDUfree_string

	.globl	_PDUfree_string_array
_PDUfree_string_array:
	movw	$.T1,r2
	movw	$.F10,r3
	call	sp,Rload
	b	_PDUfree_string_array
#
# Begin stubs for:  PDUp_login.o
#
	.data
	.align	4
.F11:	.long	0x00000700
	.byte	80, 68, 85, 112, 95, 108, 111, 103, 105, 110
	.byte	46, 111, 0
	.text

	.globl	_PDUcheck_part
_PDUcheck_part:
	movw	$.T1,r2
	movw	$.F11,r3
	call	sp,Rload
	b	_PDUcheck_part

	.globl	_PDUcreate_file_buffer_from_refresh
_PDUcreate_file_buffer_from_refresh:
	movw	$.T1,r2
	movw	$.F11,r3
	call	sp,Rload
	b	_PDUcreate_file_buffer_from_refresh

	.globl	_PDUcreate_file_buffer
_PDUcreate_file_buffer:
	movw	$.T1,r2
	movw	$.F11,r3
	call	sp,Rload
	b	_PDUcreate_file_buffer

	.globl	_PDUupdate_local_column
_PDUupdate_local_column:
	movw	$.T1,r2
	movw	$.F11,r3
	call	sp,Rload
	b	_PDUupdate_local_column

	.globl	_PDUupdate_local_column_for_refresh
_PDUupdate_local_column_for_refresh:
	movw	$.T1,r2
	movw	$.F11,r3
	call	sp,Rload
	b	_PDUupdate_local_column_for_refresh

	.globl	_PDUprint_refresh
_PDUprint_refresh:
	movw	$.T1,r2
	movw	$.F11,r3
	call	sp,Rload
	b	_PDUprint_refresh

	.globl	_PDUcreate_delete_buffer
_PDUcreate_delete_buffer:
	movw	$.T1,r2
	movw	$.F11,r3
	call	sp,Rload
	b	_PDUcreate_delete_buffer

	.globl	_PDUextract_row_from_buffer
_PDUextract_row_from_buffer:
	movw	$.T1,r2
	movw	$.F11,r3
	call	sp,Rload
	b	_PDUextract_row_from_buffer

	.globl	_PDUcheckout_structure
_PDUcheckout_structure:
	movw	$.T1,r2
	movw	$.F11,r3
	call	sp,Rload
	b	_PDUcheckout_structure
#
# Begin stubs for:  PDUsgl_list.o
#
	.data
	.align	4
.F12:	.long	0x00000700
	.byte	80, 68, 85, 115, 103, 108, 95, 108, 105, 115
	.byte	116, 46, 111, 0
	.text

	.globl	_single_list_notification_routine
_single_list_notification_routine:
	movw	$.T1,r2
	movw	$.F12,r3
	call	sp,Rload
	b	_single_list_notification_routine

	.globl	_PDUsingle_list_form
_PDUsingle_list_form:
	movw	$.T1,r2
	movw	$.F12,r3
	call	sp,Rload
	b	_PDUsingle_list_form
#
# Begin stubs for:  PDUsort.o
#
	.data
	.align	4
.F13:	.long	0x00000700
	.byte	80, 68, 85, 115, 111, 114, 116, 46, 111, 0
	.text

	.globl	_PDUdisplay_part_sort_conditions
_PDUdisplay_part_sort_conditions:
	movw	$.T1,r2
	movw	$.F13,r3
	call	sp,Rload
	b	_PDUdisplay_part_sort_conditions
#
# Begin stubs for:  PDUsort_form.o
#
	.data
	.align	4
.F14:	.long	0x00000700
	.byte	80, 68, 85, 115, 111, 114, 116, 95, 102, 111
	.byte	114, 109, 46, 111, 0
	.text

	.globl	_sort_notification_routine
_sort_notification_routine:
	movw	$.T1,r2
	movw	$.F14,r3
	call	sp,Rload
	b	_sort_notification_routine

	.globl	_PDUsort_form
_PDUsort_form:
	movw	$.T1,r2
	movw	$.F14,r3
	call	sp,Rload
	b	_PDUsort_form
#
# Begin stubs for:  PDUstring.o
#
	.data
	.align	4
.F15:	.long	0x00000700
	.byte	80, 68, 85, 115, 116, 114, 105, 110, 103, 46
	.byte	111, 0
	.text

	.globl	_PDUsearch_string_to_arrays
_PDUsearch_string_to_arrays:
	movw	$.T1,r2
	movw	$.F15,r3
	call	sp,Rload
	b	_PDUsearch_string_to_arrays

	.globl	_PDUsearch_arrays_to_form
_PDUsearch_arrays_to_form:
	movw	$.T1,r2
	movw	$.F15,r3
	call	sp,Rload
	b	_PDUsearch_arrays_to_form

	.globl	_PDUtrunc_string
_PDUtrunc_string:
	movw	$.T1,r2
	movw	$.F15,r3
	call	sp,Rload
	b	_PDUtrunc_string

	.globl	_PDUunquote_string
_PDUunquote_string:
	movw	$.T1,r2
	movw	$.F15,r3
	call	sp,Rload
	b	_PDUunquote_string

	.globl	_PDUcheck_column
_PDUcheck_column:
	movw	$.T1,r2
	movw	$.F15,r3
	call	sp,Rload
	b	_PDUcheck_column

	.globl	_PDUget_search_string
_PDUget_search_string:
	movw	$.T1,r2
	movw	$.F15,r3
	call	sp,Rload
	b	_PDUget_search_string

	.globl	_PDUadd_quotes
_PDUadd_quotes:
	movw	$.T1,r2
	movw	$.F15,r3
	call	sp,Rload
	b	_PDUadd_quotes

	.globl	_PDUget_display_attrs
_PDUget_display_attrs:
	movw	$.T1,r2
	movw	$.F15,r3
	call	sp,Rload
	b	_PDUget_display_attrs

	.globl	_PDUadd_tablename
_PDUadd_tablename:
	movw	$.T1,r2
	movw	$.F15,r3
	call	sp,Rload
	b	_PDUadd_tablename

	.globl	_PDUcheck_search_string_syntax
_PDUcheck_search_string_syntax:
	movw	$.T1,r2
	movw	$.F15,r3
	call	sp,Rload
	b	_PDUcheck_search_string_syntax

	.globl	_PDUadd_tablename_to_sort_string
_PDUadd_tablename_to_sort_string:
	movw	$.T1,r2
	movw	$.F15,r3
	call	sp,Rload
	b	_PDUadd_tablename_to_sort_string

	.globl	_PDUtic_it
_PDUtic_it:
	movw	$.T1,r2
	movw	$.F15,r3
	call	sp,Rload
	b	_PDUtic_it

	.globl	_PDUlike_search_string
_PDUlike_search_string:
	movw	$.T1,r2
	movw	$.F15,r3
	call	sp,Rload
	b	_PDUlike_search_string

	.globl	_PDUfind_server_in_string
_PDUfind_server_in_string:
	movw	$.T1,r2
	movw	$.F15,r3
	call	sp,Rload
	b	_PDUfind_server_in_string

	.globl	_PDUfind_env_in_string
_PDUfind_env_in_string:
	movw	$.T1,r2
	movw	$.F15,r3
	call	sp,Rload
	b	_PDUfind_env_in_string

	.globl	_PDUvalidate_criteria
_PDUvalidate_criteria:
	movw	$.T1,r2
	movw	$.F15,r3
	call	sp,Rload
	b	_PDUvalidate_criteria

	.globl	_PDUtrunc_usageid
_PDUtrunc_usageid:
	movw	$.T1,r2
	movw	$.F15,r3
	call	sp,Rload
	b	_PDUtrunc_usageid
#
# Begin stubs for:  PDUvalidate.o
#
	.data
	.align	4
.F16:	.long	0x00000700
	.byte	80, 68, 85, 118, 97, 108, 105, 100, 97, 116
	.byte	101, 46, 111, 0
	.text

	.globl	_PDUvalid_project
_PDUvalid_project:
	movw	$.T1,r2
	movw	$.F16,r3
	call	sp,Rload
	b	_PDUvalid_project

	.globl	_PDUvalid_catalog
_PDUvalid_catalog:
	movw	$.T1,r2
	movw	$.F16,r3
	call	sp,Rload
	b	_PDUvalid_catalog

	.globl	_PDUvalid_partnum
_PDUvalid_partnum:
	movw	$.T1,r2
	movw	$.F16,r3
	call	sp,Rload
	b	_PDUvalid_partnum

	.globl	_PDUvalid_rev
_PDUvalid_rev:
	movw	$.T1,r2
	movw	$.F16,r3
	call	sp,Rload
	b	_PDUvalid_rev

	.globl	_PDUvalid_desc
_PDUvalid_desc:
	movw	$.T1,r2
	movw	$.F16,r3
	call	sp,Rload
	b	_PDUvalid_desc

	.globl	_PDUcheck_partnum
_PDUcheck_partnum:
	movw	$.T1,r2
	movw	$.F16,r3
	call	sp,Rload
	b	_PDUcheck_partnum

	.globl	_PDUget_part_from_desc
_PDUget_part_from_desc:
	movw	$.T1,r2
	movw	$.F16,r3
	call	sp,Rload
	b	_PDUget_part_from_desc
#
# Begin stubs for:  PDUwrkst_mgr.o
#
	.data
	.align	4
.F17:	.long	0x00000700
	.byte	80, 68, 85, 119, 114, 107, 115, 116, 95, 109
	.byte	103, 114, 46, 111, 0
	.text

	.globl	_PDUprocess_wrkst_info
_PDUprocess_wrkst_info:
	movw	$.T1,r2
	movw	$.F17,r3
	call	sp,Rload
	b	_PDUprocess_wrkst_info
#
# Begin stubs for:  PDUbuffers.o
#
	.data
	.align	4
.F18:	.long	0x00000700
	.byte	80, 68, 85, 98, 117, 102, 102, 101, 114, 115
	.byte	46, 111, 0
	.text

	.globl	_PDUsetup_single_buffer
_PDUsetup_single_buffer:
	movw	$.T1,r2
	movw	$.F18,r3
	call	sp,Rload
	b	_PDUsetup_single_buffer

	.globl	_PDUbufr_to_form
_PDUbufr_to_form:
	movw	$.T1,r2
	movw	$.F18,r3
	call	sp,Rload
	b	_PDUbufr_to_form

	.globl	_PDUbufr_to_form_single
_PDUbufr_to_form_single:
	movw	$.T1,r2
	movw	$.F18,r3
	call	sp,Rload
	b	_PDUbufr_to_form_single

	.globl	_PDUbufr_to_form1
_PDUbufr_to_form1:
	movw	$.T1,r2
	movw	$.F18,r3
	call	sp,Rload
	b	_PDUbufr_to_form1

	.globl	_PDUbufr_to_form_fields
_PDUbufr_to_form_fields:
	movw	$.T1,r2
	movw	$.F18,r3
	call	sp,Rload
	b	_PDUbufr_to_form_fields

	.globl	_PDUsetup_popup_list
_PDUsetup_popup_list:
	movw	$.T1,r2
	movw	$.F18,r3
	call	sp,Rload
	b	_PDUsetup_popup_list

	.globl	_PDUsetup_form_fields
_PDUsetup_form_fields:
	movw	$.T1,r2
	movw	$.F18,r3
	call	sp,Rload
	b	_PDUsetup_form_fields

	.globl	_PDUsetup_struct_fields
_PDUsetup_struct_fields:
	movw	$.T1,r2
	movw	$.F18,r3
	call	sp,Rload
	b	_PDUsetup_struct_fields

	.globl	_PDUbufr_to_mcf
_PDUbufr_to_mcf:
	movw	$.T1,r2
	movw	$.F18,r3
	call	sp,Rload
	b	_PDUbufr_to_mcf

	.globl	_PDUadd_catalog_to_buffer
_PDUadd_catalog_to_buffer:
	movw	$.T1,r2
	movw	$.F18,r3
	call	sp,Rload
	b	_PDUadd_catalog_to_buffer
#
# Begin stubs for:  PDUmodes.o
#
	.data
	.align	4
.F19:	.long	0x00000700
	.byte	80, 68, 85, 109, 111, 100, 101, 115, 46, 111
	.byte	0
	.text

	.globl	_PDUnew_mode
_PDUnew_mode:
	movw	$.T1,r2
	movw	$.F19,r3
	call	sp,Rload
	b	_PDUnew_mode

	.globl	_PDUsimilar_mode
_PDUsimilar_mode:
	movw	$.T1,r2
	movw	$.F19,r3
	call	sp,Rload
	b	_PDUsimilar_mode

	.globl	_PDUchange_mode
_PDUchange_mode:
	movw	$.T1,r2
	movw	$.F19,r3
	call	sp,Rload
	b	_PDUchange_mode

	.globl	_PDUreview_mode
_PDUreview_mode:
	movw	$.T1,r2
	movw	$.F19,r3
	call	sp,Rload
	b	_PDUreview_mode
#
# Begin stubs for:  PDUsort_opt.o
#
	.data
	.align	4
.F20:	.long	0x00000700
	.byte	80, 68, 85, 115, 111, 114, 116, 95, 111, 112
	.byte	116, 46, 111, 0
	.text

	.globl	_sort_options_notification_routine
_sort_options_notification_routine:
	movw	$.T1,r2
	movw	$.F20,r3
	call	sp,Rload
	b	_sort_options_notification_routine

	.globl	_PDUreset_part_sort_fields
_PDUreset_part_sort_fields:
	movw	$.T1,r2
	movw	$.F20,r3
	call	sp,Rload
	b	_PDUreset_part_sort_fields

	.globl	_PDUsort_options_form
_PDUsort_options_form:
	movw	$.T1,r2
	movw	$.F20,r3
	call	sp,Rload
	b	_PDUsort_options_form
#
# Begin stubs for:  PDUfile_list.o
#
	.data
	.align	4
.F21:	.long	0x00000700
	.byte	80, 68, 85, 102, 105, 108, 101, 95, 108, 105
	.byte	115, 116, 46, 111, 0
	.text

	.globl	_file_list_notification_routine
_file_list_notification_routine:
	movw	$.T1,r2
	movw	$.F21,r3
	call	sp,Rload
	b	_file_list_notification_routine

	.globl	_PDUfile_list_form
_PDUfile_list_form:
	movw	$.T1,r2
	movw	$.F21,r3
	call	sp,Rload
	b	_PDUfile_list_form

	.globl	_PDUload_file_list
_PDUload_file_list:
	movw	$.T1,r2
	movw	$.F21,r3
	call	sp,Rload
	b	_PDUload_file_list
#
# Begin stubs for:  PDUsv_refrsh.o
#
	.data
	.align	4
.F22:	.long	0x00000700
	.byte	80, 68, 85, 115, 118, 95, 114, 101, 102, 114
	.byte	115, 104, 46, 111, 0
	.text

	.globl	_PDUdefine_refresh
_PDUdefine_refresh:
	movw	$.T1,r2
	movw	$.F22,r3
	call	sp,Rload
	b	_PDUdefine_refresh

	.globl	_PDUwrite_refresh_file
_PDUwrite_refresh_file:
	movw	$.T1,r2
	movw	$.F22,r3
	call	sp,Rload
	b	_PDUwrite_refresh_file

	.globl	_PDUget_refresh
_PDUget_refresh:
	movw	$.T1,r2
	movw	$.F22,r3
	call	sp,Rload
	b	_PDUget_refresh

	.globl	_PDUread_refresh_file
_PDUread_refresh_file:
	movw	$.T1,r2
	movw	$.F22,r3
	call	sp,Rload
	b	_PDUread_refresh_file

	.globl	_myfgets
_myfgets:
	movw	$.T1,r2
	movw	$.F22,r3
	call	sp,Rload
	b	_myfgets

	.globl	_PDUget_login_form_data
_PDUget_login_form_data:
	movw	$.T1,r2
	movw	$.F22,r3
	call	sp,Rload
	b	_PDUget_login_form_data
#
# Begin stubs for:  PDUdate.o
#
	.data
	.align	4
.F23:	.long	0x00000700
	.byte	80, 68, 85, 100, 97, 116, 101, 46, 111, 0
	.text

	.globl	_PDUascii_to_timestamp
_PDUascii_to_timestamp:
	movw	$.T1,r2
	movw	$.F23,r3
	call	sp,Rload
	b	_PDUascii_to_timestamp

	.globl	_PDUget_RISdate
_PDUget_RISdate:
	movw	$.T1,r2
	movw	$.F23,r3
	call	sp,Rload
	b	_PDUget_RISdate

	.globl	_PDUvalidate_American
_PDUvalidate_American:
	movw	$.T1,r2
	movw	$.F23,r3
	call	sp,Rload
	b	_PDUvalidate_American

	.globl	_Ethnic_to_timestamp
_Ethnic_to_timestamp:
	movw	$.T1,r2
	movw	$.F23,r3
	call	sp,Rload
	b	_Ethnic_to_timestamp

	.globl	_TIMEdebug
_TIMEdebug:
	movw	$.T1,r2
	movw	$.F23,r3
	call	sp,Rload
	b	_TIMEdebug

	.globl	__TIMEdebug
__TIMEdebug:
	movw	$.T1,r2
	movw	$.F23,r3
	call	sp,Rload
	b	__TIMEdebug

	.globl	_system_time
_system_time:
	movw	$.T1,r2
	movw	$.F23,r3
	call	sp,Rload
	b	_system_time

	.globl	_call_time
_call_time:
	movw	$.T1,r2
	movw	$.F23,r3
	call	sp,Rload
	b	_call_time
#
# Begin stubs for:  PDUpart_lst.o
#
	.data
	.align	4
.F24:	.long	0x00000700
	.byte	80, 68, 85, 112, 97, 114, 116, 95, 108, 115
	.byte	116, 46, 111, 0
	.text

	.globl	_parts_list_notification_routine
_parts_list_notification_routine:
	movw	$.T1,r2
	movw	$.F24,r3
	call	sp,Rload
	b	_parts_list_notification_routine

	.globl	_PDUparts_list_form
_PDUparts_list_form:
	movw	$.T1,r2
	movw	$.F24,r3
	call	sp,Rload
	b	_PDUparts_list_form
#
# Begin stubs for:  PDUpt_fl_lst.o
#
	.data
	.align	4
.F25:	.long	0x00000700
	.byte	80, 68, 85, 112, 116, 95, 102, 108, 95, 108
	.byte	115, 116, 46, 111, 0
	.text

	.globl	_part_file_list_notification_routine
_part_file_list_notification_routine:
	movw	$.T1,r2
	movw	$.F25,r3
	call	sp,Rload
	b	_part_file_list_notification_routine

	.globl	_PDUpart_file_list_form
_PDUpart_file_list_form:
	movw	$.T1,r2
	movw	$.F25,r3
	call	sp,Rload
	b	_PDUpart_file_list_form

	.globl	_PDUload_file_buffer
_PDUload_file_buffer:
	movw	$.T1,r2
	movw	$.F25,r3
	call	sp,Rload
	b	_PDUload_file_buffer

	.globl	_PDUload_file_buffer_after_copy
_PDUload_file_buffer_after_copy:
	movw	$.T1,r2
	movw	$.F25,r3
	call	sp,Rload
	b	_PDUload_file_buffer_after_copy
#
# Begin stubs for:  PDUcancl_lst.o
#
	.data
	.align	4
.F26:	.long	0x00000700
	.byte	80, 68, 85, 99, 97, 110, 99, 108, 95, 108
	.byte	115, 116, 46, 111, 0
	.text

	.globl	_cancel_list_notification_routine
_cancel_list_notification_routine:
	movw	$.T1,r2
	movw	$.F26,r3
	call	sp,Rload
	b	_cancel_list_notification_routine

	.globl	_PDUcancel_list_form
_PDUcancel_list_form:
	movw	$.T1,r2
	movw	$.F26,r3
	call	sp,Rload
	b	_PDUcancel_list_form
#
# Begin stubs for:  PDUwher_used.o
#
	.data
	.align	4
.F27:	.long	0x00000700
	.byte	80, 68, 85, 119, 104, 101, 114, 95, 117, 115
	.byte	101, 100, 46, 111, 0
	.text

	.globl	_where_used_notification_routine
_where_used_notification_routine:
	movw	$.T1,r2
	movw	$.F27,r3
	call	sp,Rload
	b	_where_used_notification_routine

	.globl	_PDUwhere_used_form
_PDUwhere_used_form:
	movw	$.T1,r2
	movw	$.F27,r3
	call	sp,Rload
	b	_PDUwhere_used_form
#
# Begin stubs for:  PDUgen_valid.o
#
	.data
	.align	4
.F28:	.long	0x00000700
	.byte	80, 68, 85, 103, 101, 110, 95, 118, 97, 108
	.byte	105, 100, 46, 111, 0
	.text

	.globl	_PDUvalidate_project
_PDUvalidate_project:
	movw	$.T1,r2
	movw	$.F28,r3
	call	sp,Rload
	b	_PDUvalidate_project

	.globl	_PDUvalidate_catalog
_PDUvalidate_catalog:
	movw	$.T1,r2
	movw	$.F28,r3
	call	sp,Rload
	b	_PDUvalidate_catalog

	.globl	_PDUcheck_part_syntax
_PDUcheck_part_syntax:
	movw	$.T1,r2
	movw	$.F28,r3
	call	sp,Rload
	b	_PDUcheck_part_syntax

	.globl	_PDUcheck_rev_syntax
_PDUcheck_rev_syntax:
	movw	$.T1,r2
	movw	$.F28,r3
	call	sp,Rload
	b	_PDUcheck_rev_syntax

	.globl	_PDUcheck_part_datatype
_PDUcheck_part_datatype:
	movw	$.T1,r2
	movw	$.F28,r3
	call	sp,Rload
	b	_PDUcheck_part_datatype

	.globl	_PDUcheck_rev_datatype
_PDUcheck_rev_datatype:
	movw	$.T1,r2
	movw	$.F28,r3
	call	sp,Rload
	b	_PDUcheck_rev_datatype

	.globl	_PDUcheck_desc_datatype
_PDUcheck_desc_datatype:
	movw	$.T1,r2
	movw	$.F28,r3
	call	sp,Rload
	b	_PDUcheck_desc_datatype

	.globl	_PDUvalidate_parttype
_PDUvalidate_parttype:
	movw	$.T1,r2
	movw	$.F28,r3
	call	sp,Rload
	b	_PDUvalidate_parttype

	.globl	_PDUverify_file_desc
_PDUverify_file_desc:
	movw	$.T1,r2
	movw	$.F28,r3
	call	sp,Rload
	b	_PDUverify_file_desc

	.globl	_PDUverify_addpart_filename
_PDUverify_addpart_filename:
	movw	$.T1,r2
	movw	$.F28,r3
	call	sp,Rload
	b	_PDUverify_addpart_filename

	.globl	_PDUverify_filetype
_PDUverify_filetype:
	movw	$.T1,r2
	movw	$.F28,r3
	call	sp,Rload
	b	_PDUverify_filetype

	.globl	_PDUverify_aclname
_PDUverify_aclname:
	movw	$.T1,r2
	movw	$.F28,r3
	call	sp,Rload
	b	_PDUverify_aclname

	.globl	_PDUverify_storage_name
_PDUverify_storage_name:
	movw	$.T1,r2
	movw	$.F28,r3
	call	sp,Rload
	b	_PDUverify_storage_name

	.globl	_PDUunlock_item
_PDUunlock_item:
	movw	$.T1,r2
	movw	$.F28,r3
	call	sp,Rload
	b	_PDUunlock_item

	.globl	_PDUget_storage_name
_PDUget_storage_name:
	movw	$.T1,r2
	movw	$.F28,r3
	call	sp,Rload
	b	_PDUget_storage_name

	.globl	_PDUget_acl_name
_PDUget_acl_name:
	movw	$.T1,r2
	movw	$.F28,r3
	call	sp,Rload
	b	_PDUget_acl_name
#
# Begin stubs for:  PDUfileapi.o
#
	.data
	.align	4
.F29:	.long	0x00000700
	.byte	80, 68, 85, 102, 105, 108, 101, 97, 112, 105
	.byte	46, 111, 0
	.text

	.globl	_PDUget_buffer_col
_PDUget_buffer_col:
	movw	$.T1,r2
	movw	$.F29,r3
	call	sp,Rload
	b	_PDUget_buffer_col

	.globl	_PDUsetup_buffer
_PDUsetup_buffer:
	movw	$.T1,r2
	movw	$.F29,r3
	call	sp,Rload
	b	_PDUsetup_buffer

	.globl	_PDUgetcwd
_PDUgetcwd:
	movw	$.T1,r2
	movw	$.F29,r3
	call	sp,Rload
	b	_PDUgetcwd

	.globl	_PDUsetup_buffer_list
_PDUsetup_buffer_list:
	movw	$.T1,r2
	movw	$.F29,r3
	call	sp,Rload
	b	_PDUsetup_buffer_list

	.globl	_PDUget_col_number
_PDUget_col_number:
	movw	$.T1,r2
	movw	$.F29,r3
	call	sp,Rload
	b	_PDUget_col_number

	.globl	_PDUmake_transition
_PDUmake_transition:
	movw	$.T1,r2
	movw	$.F29,r3
	call	sp,Rload
	b	_PDUmake_transition

	.globl	_PDUverify_add_file_list
_PDUverify_add_file_list:
	movw	$.T1,r2
	movw	$.F29,r3
	call	sp,Rload
	b	_PDUverify_add_file_list

	.globl	_PDUverify_attr_list
_PDUverify_attr_list:
	movw	$.T1,r2
	movw	$.F29,r3
	call	sp,Rload
	b	_PDUverify_attr_list

	.globl	_PDUverify_PDUattr_list
_PDUverify_PDUattr_list:
	movw	$.T1,r2
	movw	$.F29,r3
	call	sp,Rload
	b	_PDUverify_PDUattr_list

	.globl	_PDUprint_file_list
_PDUprint_file_list:
	movw	$.T1,r2
	movw	$.F29,r3
	call	sp,Rload
	b	_PDUprint_file_list

	.globl	_PDUprint_change_list
_PDUprint_change_list:
	movw	$.T1,r2
	movw	$.F29,r3
	call	sp,Rload
	b	_PDUprint_change_list

	.globl	_PDUadd_files_to_buffer
_PDUadd_files_to_buffer:
	movw	$.T1,r2
	movw	$.F29,r3
	call	sp,Rload
	b	_PDUadd_files_to_buffer

	.globl	_PDUchange_files_in_buffer
_PDUchange_files_in_buffer:
	movw	$.T1,r2
	movw	$.F29,r3
	call	sp,Rload
	b	_PDUchange_files_in_buffer

	.globl	_PDUmark_files_for_delete
_PDUmark_files_for_delete:
	movw	$.T1,r2
	movw	$.F29,r3
	call	sp,Rload
	b	_PDUmark_files_for_delete

	.globl	_PDUverify_change_file_list
_PDUverify_change_file_list:
	movw	$.T1,r2
	movw	$.F29,r3
	call	sp,Rload
	b	_PDUverify_change_file_list

	.globl	_PDUcleanup_change_part
_PDUcleanup_change_part:
	movw	$.T1,r2
	movw	$.F29,r3
	call	sp,Rload
	b	_PDUcleanup_change_part

	.globl	_PDUprint_PDUattr_list
_PDUprint_PDUattr_list:
	movw	$.T1,r2
	movw	$.F29,r3
	call	sp,Rload
	b	_PDUprint_PDUattr_list
#
# Begin stubs for:  PDUckin_tls.o
#
	.data
	.align	4
.F30:	.long	0x00000700
	.byte	80, 68, 85, 99, 107, 105, 110, 95, 116, 108
	.byte	115, 46, 111, 0
	.text

	.globl	_PDUverify_files_exist_locally
_PDUverify_files_exist_locally:
	movw	$.T1,r2
	movw	$.F30,r3
	call	sp,Rload
	b	_PDUverify_files_exist_locally
#
# Begin stubs for:  PDUflag_form.o
#
	.data
	.align	4
.F31:	.long	0x00000700
	.byte	80, 68, 85, 102, 108, 97, 103, 95, 102, 111
	.byte	114, 109, 46, 111, 0
	.text

	.globl	_flag_notification_routine
_flag_notification_routine:
	movw	$.T1,r2
	movw	$.F31,r3
	call	sp,Rload
	b	_flag_notification_routine

	.globl	_PDUflag_form
_PDUflag_form:
	movw	$.T1,r2
	movw	$.F31,r3
	call	sp,Rload
	b	_PDUflag_form
#
# Begin stubs for:  PDUstate_frm.o
#
	.data
	.align	4
.F32:	.long	0x00000700
	.byte	80, 68, 85, 115, 116, 97, 116, 101, 95, 102
	.byte	114, 109, 46, 111, 0
	.text

	.globl	_state_notification_routine
_state_notification_routine:
	movw	$.T1,r2
	movw	$.F32,r3
	call	sp,Rload
	b	_state_notification_routine

	.globl	_PDUfree_acl_structure
_PDUfree_acl_structure:
	movw	$.T1,r2
	movw	$.F32,r3
	call	sp,Rload
	b	_PDUfree_acl_structure

	.globl	_PDUremove_node_from_group_list
_PDUremove_node_from_group_list:
	movw	$.T1,r2
	movw	$.F32,r3
	call	sp,Rload
	b	_PDUremove_node_from_group_list

	.globl	_PDUmulti_move_state
_PDUmulti_move_state:
	movw	$.T1,r2
	movw	$.F32,r3
	call	sp,Rload
	b	_PDUmulti_move_state

	.globl	_PDUgroup_parts_for_transition
_PDUgroup_parts_for_transition:
	movw	$.T1,r2
	movw	$.F32,r3
	call	sp,Rload
	b	_PDUgroup_parts_for_transition

	.globl	_PDUload_move_state_form
_PDUload_move_state_form:
	movw	$.T1,r2
	movw	$.F32,r3
	call	sp,Rload
	b	_PDUload_move_state_form

	.globl	_PDUselect_row_in_list_mcf
_PDUselect_row_in_list_mcf:
	movw	$.T1,r2
	movw	$.F32,r3
	call	sp,Rload
	b	_PDUselect_row_in_list_mcf

	.globl	_PDUstate_form
_PDUstate_form:
	movw	$.T1,r2
	movw	$.F32,r3
	call	sp,Rload
	b	_PDUstate_form

	.globl	_PDUprocess_state_form_parts
_PDUprocess_state_form_parts:
	movw	$.T1,r2
	movw	$.F32,r3
	call	sp,Rload
	b	_PDUprocess_state_form_parts

	.globl	_PDUprocess_individual_state_form_part
_PDUprocess_individual_state_form_part:
	movw	$.T1,r2
	movw	$.F32,r3
	call	sp,Rload
	b	_PDUprocess_individual_state_form_part

	.globl	_PDUupdate_state_form_after_move_state
_PDUupdate_state_form_after_move_state:
	movw	$.T1,r2
	movw	$.F32,r3
	call	sp,Rload
	b	_PDUupdate_state_form_after_move_state

	.globl	_PDUadd_node_to_acl_list
_PDUadd_node_to_acl_list:
	movw	$.T1,r2
	movw	$.F32,r3
	call	sp,Rload
	b	_PDUadd_node_to_acl_list

	.globl	_PDUprint_acl_list
_PDUprint_acl_list:
	movw	$.T1,r2
	movw	$.F32,r3
	call	sp,Rload
	b	_PDUprint_acl_list

	.globl	_PDUdelete_node_from_acl_list
_PDUdelete_node_from_acl_list:
	movw	$.T1,r2
	movw	$.F32,r3
	call	sp,Rload
	b	_PDUdelete_node_from_acl_list

	.globl	_PDUdelete_current_state_from_states_buffer
_PDUdelete_current_state_from_states_buffer:
	movw	$.T1,r2
	movw	$.F32,r3
	call	sp,Rload
	b	_PDUdelete_current_state_from_states_buffer

	.globl	_PDUload_acl_parts_mcf
_PDUload_acl_parts_mcf:
	movw	$.T1,r2
	movw	$.F32,r3
	call	sp,Rload
	b	_PDUload_acl_parts_mcf

	.comm	_ethnic,20
	.globl	_PDUep_parttype_fld
	.globl	_PDUnp_parttype_fld
	.globl	_PDU_save_revision
	.globl	_PDUfinish_parametric_move_to_next_state
	.globl	_PDUmulti_delete_part
	.globl	_PDU_state_perm_window
	.globl	_Help_topic
	.globl	_np_catalog
	.globl	_pdu_ep_stg_bufr_flag
	.globl	_end_np_parttype_btn_flag
	.globl	_PDU_disable_filetype_col
	.globl	_PDU_struct_fields
	.globl	_FIf_erase
	.globl	_PDU_active_list
	.globl	_PDUselect_row_in_list_mcf
	.globl	_PDUprocess_wrkst_info
	.globl	_PDUunlock_item
	.globl	_PDU_sort_options_created
	.globl	_pdu_hold_stg_bufr_flag
	.globl	_end_ep_desc_btn_flag
	.globl	_PDUcheck_parttype_privileges
	.globl	_PDMflag_part_delete
	.globl	_PDUext_cancel_checkout
	.globl	_end_ep_desc_fld_flag
	.globl	_MEMopen
	.globl	_PDU_attr_label
	.globl	_PDUpart_file_list_form
	.globl	_PDU_parts_index
	.globl	_PDU_file_data_bufr
	.globl	_PDMverify_partnum
	.globl	_strcpy
	.globl	_change_mode
	.globl	_FIf_set_size
	.globl	_close
	.globl	_user
	.globl	_bufr_flag
	.globl	_PDMvalidate_criteria_name
	.globl	_execlp
	.globl	_PDUupdate_form_after_checkin_out
	.globl	_PDUprepare_queue
	.globl	_FIfld_get_row_offset
	.globl	_PDUint_checkin
	.globl	_PDMUnflag_part_backup
	.globl	_PDU_attr_col
	.globl	_PDU_part_displayed
	.globl	_PDUget_criteria_string
	.globl	_FIf_paint_area
	.globl	_PDU_disable_filedesc_col
	.globl	_signal
	.globl	_PDUpost_to_database
	.globl	_FIf_set_location
	.globl	_PDU_data_bufr
	.globl	_PDUep_proj_fld
	.globl	_PDUvalid_filename
	.globl	_PDUdelete_file
	.globl	_PDM_debug_on
	.globl	_PDUvalid_catalog
	.globl	_PDU_list_bufr
	.globl	_PDUlist_report_buffer
	.globl	_strncpy
	.globl	_PDU_param_cat
	.globl	_PDUep_part_btn
	.globl	_PDU_part_file_list_created
	.globl	_SelectOrPlacePart
	.globl	_PDU_stg_col
	.globl	_PDUget_login_form_data
	.globl	_PDU_cancel_list_displayed
	.globl	_PDU_func_buffer
	.globl	_FIg_set_state_off
	.globl	_PDU_acl_bufr
	.globl	_PDU_part_sort_rows
	.globl	_PDU_part_sort_string
	.globl	_states_bufr
	.globl	_clock_ansi
	.globl	_PDU_form_id
	.globl	_PDMvalidate_user_access
	.globl	_FIg_get_location
	.globl	_PDU_where_used_displayed
	.globl	_PDU_add_data_bufr
	.globl	_PDUis_part_in_buffer
	.globl	_PDMcheck_delete_part
	.globl	_malloc
	.globl	_PDMget_assembly_structure
	.globl	_PDUget_child_attach_bufrs
	.globl	_ep_parttype
	.globl	_PDU_assy_perm_window
	.globl	_FIfld_set_max_num_rows
	.globl	_PDU_sort_created
	.globl	_PDUep_cat_fld
	.globl	_PDMrcheck_part_status
	.globl	_get_remote_path
	.globl	_PDU_sort_options_displayed
	.globl	_free
	.globl	_FIfld_delete_rows
	.globl	_MEMwrite
	.globl	_PDU_param_cat_list
	.globl	_PDMUnflag_part_archive
	.globl	_PDUcheck_part
	.globl	_GRproc_pull_down_list
	.globl	_PDMterminate
	.globl	_PDU_ep_data_bufr
	.globl	_PDMflag_part_archive
	.globl	_PDUupdate_parametric_catalog_form
	.globl	_PDUsetup_buffer_list
	.globl	_PDU_apiflag
	.globl	_PDMget_state
	.globl	_PDMrmake_transition
	.globl	_PDUend_move_to_state_btn
	.globl	_PDU_local_perm_window
	.globl	_PDU_search_type
	.globl	_FIfld_get_select
	.globl	_PDUbufr_to_form
	.globl	_end_ep_rev_btn_flag
	.globl	_PDU_load_file_buffer
	.globl	_getuid
	.globl	_en_itemname
	.globl	_pdu_hold_acl_bufr_flag
	.globl	_PDU_filetype_newfiles_disable
	.globl	_end_stg_area_btn_flag
	.globl	_PDU_save_filename
	.globl	_PDU_refresh_loaded
	.globl	_SQLstmt
	.globl	_PDUpull_pt_desc_for_rev
	.globl	_PDMquery_catalog_type
	.globl	_PDMpart_in_project
	.globl	_PDU_chkout_single
	.globl	_errno
	.globl	_PDU_never_checked_in
	.globl	_PDU_ep_bufr
	.globl	_PDU_apimessage
	.globl	_PDUupdate_part_form_change_mode
	.globl	_PDU_attr_row
	.globl	_PDU_display_column
	.globl	_PDU_part_attr_pulldown
	.globl	_PDU_parts_list_created
	.globl	_putenv
	.globl	_PDMrcheck_dup_sa_fname
	.globl	_end_ep_parttype_btn_flag
	.globl	_PDUfind_attr_in_buffer
	.globl	_PDMget_trans
	.globl	_PDU_save_parttype
	.globl	_PDUsetup_struct_fields
	.globl	_strtok
	.globl	_PDUcheck_catalog_template
	.globl	_FIg_display
	.globl	_PDUdisplay_part_sort_conditions
	.globl	_FIf_new
	.globl	_PDU_delete_buffer
	.globl	_PDU_cat_list_created
	.globl	_PDUcopy
	.globl	_PDUget_templatetype
	.globl	_PDUmessage_trans
	.globl	_PDUtranslate_message_and_vars
	.globl	_dup
	.globl	_stat
	.globl	_NFMls_nodes
	.globl	_PDU_default_env
	.globl	__iob
	.globl	_PDU_list_files
	.globl	_PDUverify_addpart_filename
	.globl	_PDUcheckout_structure
	.globl	_PDU_simmode_checkin
	.globl	_PDU_where_used_created
	.globl	_PDMcancel_modify
	.globl	_PDU_selected_rows
	.globl	_PDUdelete_local_files
	.globl	_end_ep_part_fld_flag
	.globl	_ModifyPartForm
	.globl	_PDU_struct_type
	.globl	_PDUupdate_report_form
	.globl	_PDUbufr_to_mcf
	.globl	_MEMwrite_format
	.globl	_PDU_buffer_columns
	.globl	_PDUverify_file_desc
	.globl	_PDMget_filenames
	.globl	_PDU_read_only_file
	.globl	_PDUend_ep_rev_btn
	.globl	_PDUupdate_local_column
	.globl	_PDU_data_row
	.globl	_GRchange_pull_down_text
	.globl	_exitdel
	.globl	_PDU_DEBUG_FILE
	.globl	_PDMdebug_on
	.globl	_PDUinitialize_help
	.globl	_PDU_command
	.globl	_similar_mode
	.globl	_strncmp
	.globl	_PDUupdate_local_column_for_refresh
	.globl	_PDU_flag_perm_window
	.globl	_PDU_auto_login
	.globl	_storage
	.globl	_PDU_cat_list_displayed
	.globl	_getpwuid
	.globl	_PDUpull_bufr_info
	.globl	_PDUsort_options_form
	.globl	_PDU_param_buffer
	.globl	_PDUget_col_number
	.globl	_catalog_flag
	.globl	_FIg_set_state_on
	.globl	_PDUend_ep_part_fld
	.globl	_end_acl_wf_btn_flag
	.globl	_PDU_storagefn_newfiles_disable
	.globl	_PDU_filedesc_newfiles_disable
	.globl	_PDU_cancel_list_created
	.globl	_PDMflag_part_backup
	.globl	_MEMsplit_copy_buffer
	.globl	_PDUep_proj_btn
	.globl	_PDUcheck_bom_mapping_commands
	.globl	_PDUadd_buffer_string
	.globl	_PDU_where_used_bufr
	.globl	_MEMreset_buffer_no
	.globl	_PDUcheck_topdown_files
	.globl	_PDUnp_part_fld
	.globl	_PDUcheck_file_commands
	.globl	_PDMrlogin
	.globl	_PDUep_part_fld
	.globl	_end_np_part_btn_flag
	.globl	_PDU_simmode_copy
	.globl	_PDUget_buffer_col
	.globl	_PDUcreate_delete_buffer
	.globl	_PDUupdate_revise_assy_form_after_select
	.globl	_PDUget_max_level
	.globl	_PDMcheck_partnum
	.globl	_PDU_acl_format
	.globl	_FIf_cvrt_to_perm_win
	.globl	_strlen
	.globl	_PDU_calling_form
	.globl	_PDUdisplay_review_structure
	.globl	_PDMrget_cit_parents
	.globl	_PDMUnflag_part_delete
	.globl	_PDU_attr_bufr
	.globl	_PDU_save_project
	.globl	_strcat
	.globl	_end_np_cat_btn_flag
	.globl	_PDU_form_type
	.globl	_place_part_f
	.globl	_GRdelete_pull_down_list
	.globl	__ctype
	.globl	_PDU_view_buffer
	.globl	_PDMUnflag_part_restore
	.globl	_PDUload_file_buffer_after_copy
	.globl	_FIfld_set_mode
	.globl	_PDU_assy_parts_bufr
	.globl	_PDU_dyn_attr_bufr
	.globl	_PDU_localfn_newfiles_disable
	.globl	_PDUfill_attribute_list
	.globl	_PDUvalidate_value
	.globl	_PDMrverify_init
	.globl	__pdm_status
	.globl	_PDUsingle_list_form
	.globl	_NumAttribs
	.globl	_PDUupdate_buffer_after_delete_part
	.globl	_PDMrverify_catalog
	.globl	_PDU_save_description
	.globl	_review_mode
	.globl	_PDUep_cat_btn
	.globl	_PDU_part_flagged
	.globl	_PDU_assy_description
	.globl	_PDUlocal_files_form
	.globl	_strcmp
	.globl	_UI_prompt
	.globl	_PDMrget_imm_parents
	.globl	_string_len
	.globl	_sleep
	.globl	_FIfld_set_active_row
	.globl	_forms
	.globl	_PDMverify_project
	.globl	_localtime
	.globl	_PDU_file_list_created
	.globl	_pt_flag
	.globl	_time
	.globl	_PDUcreate_file_buffer_from_refresh
	.globl	_PDU_assy_catalog
	.globl	_PDU_part_sort_list
	.globl	_PDUdismiss_subforms
	.globl	_FIg_disable
	.globl	_PDU_checkout_type
	.globl	_PDU_flag_form_displayed
	.globl	_PDUdesign_form
	.globl	_PDU_file_bufr
	.globl	_AttrSynonym
	.globl	_PDUload_local_files_form
	.globl	_PDUflag_part
	.globl	_memset
	.globl	_PDUdefine_criteria_string
	.globl	_FIfld_pos_cursor
	.globl	_PDMquery_part_type
	.globl	_PDU_data_col
	.globl	_PDUsetup_popup_list
	.globl	_PDU_func_bufr_exists
	.globl	_PDMlist_checkedin_files
	.globl	_FIg_set_location
	.globl	_strchr
	.globl	_PDUdefine_support_update
	.globl	_PDU_use_suffix
	.globl	_attr_rows
	.globl	_PDU_part_file_list_displayed
	.globl	_PDU_acl_group_list
	.globl	_end_move_to_state_btn_flag
	.globl	_PDU_login_displayed
	.globl	_PDU_hold_bufr
	.globl	_FIg_set_text
	.globl	_ep_catalog
	.globl	_FIfld_get_num_rows
	.globl	_PDMget_part_from_desc
	.globl	_PDU_state_form_displayed
	.globl	_FIg_erase
	.globl	_PDUget_file_status
	.globl	_PDUconvert_file_before_review
	.globl	_fclose
	.globl	_PDUreports_form
	.globl	_PDU_main_form_cat
	.globl	_PDUsetup_single_buffer
	.globl	_PDU_files_deleted
	.globl	_PDU_popup_list_type
	.globl	_WaitForEvent
	.globl	_PDU_disable_storagefn_col
	.globl	_isdigit
	.globl	_atoi
	.globl	_PDU_acl_col
	.globl	_pdu_ep_acl_bufr_flag
	.globl	_uname
	.globl	_PDUchange_review_file_permissions
	.globl	_vfork
	.globl	_PDUconvert_form_to_win
	.globl	_PDUmake_transition
	.globl	_sscanf
	.globl	_PDUcatalog_name_form
	.globl	_PDMexpand_parts_list
	.globl	_PDUcheck_catalog_commands
	.globl	_PDUset_default_file
	.globl	_PDUget_refresh
	.globl	_PDU_ep_stg_bufr
	.globl	_PDU_num_of_part_rows
	.globl	_PDU_file_rows
	.globl	_PDUfill_in_string1
	.globl	_PDU_gadget_labels
	.globl	_pipe
	.globl	_PDU_second_row
	.globl	_PDMcancel_modify_part
	.globl	_PDU_disable_move_state_btn
	.globl	_PDU_copyof_ret_bufr
	.globl	_PDUchild_dyn_buffer
	.globl	_PDUverify_part_data
	.globl	_PDU_data_format
	.globl	_PDU_states_bufr
	.globl	_PDU_activate_copy
	.globl	_FIf_is_displayed
	.globl	_read
	.globl	_PDU_search_format
	.globl	_new_mode
	.globl	_PDUep_rev_fld
	.globl	_PDU_dyn_part_search
	.globl	_MEMbuild_array
	.globl	_PDUdefault_env
	.globl	_PDUfill_in_string
	.globl	_FIf_delete
	.globl	_PDU_sort_perm_window
	.globl	_PDUbufr_to_form_fields
	.globl	_PDU_save_partid
	.globl	_MEMclose
	.globl	_PDU_edit_display
	.globl	_PDMset_to_state
	.globl	_PDUupdate_seed_form_after_select
	.globl	_PDU_list_filenames
	.globl	_PDUcheck_for_np_defaults
	.globl	_PDUext_checkout
	.globl	_FIf_get_size
	.globl	_PDUvalid_project
	.globl	_single_flag
	.globl	_PDUprocess_ep_catalog
	.globl	_PDUprocess_np_catalog
	.globl	_PDU_file_suffix
	.globl	_PDUvalidate_criteria
	.globl	_PDUstring_to_attributes
	.globl	_fprintf
	.globl	_PDU_sav_file_data_bufr
	.globl	_FIfld_set_num_rows
	.globl	_PDU_ep_acl_bufr
	.globl	_PDU_check_filename
	.globl	_PDUcheckout
	.globl	_PDU_dyn_cat_search
	.globl	_PDU_parts_list_bufr
	.globl	_FIf_get_location
	.globl	_PDU_acl_row
	.globl	_PDUend_stg_area_btn
	.globl	_PDU_part_row
	.globl	_PDMrdelete_local_files
	.globl	_PDU_extadmin
	.globl	_PDUep_rev_btn
	.globl	_PDUend_ep_desc_fld
	.globl	_refresh
	.globl	_PDU_attr_format
	.globl	_PDU_perm_window
	.globl	_ep_rev
	.globl	_PDMGetPartInfoGivenFileName
	.globl	_PDU_save_sort_mode
	.globl	_PDU_ret_bufr
	.globl	_PDUverify_filetype
	.globl	_FIfld_get_text
	.globl	_PDUfree_string_array
	.globl	_PDUcancel_list_form
	.globl	_PDU_dyn_data_bufr
	.globl	_PDU_single_list_created
	.globl	_PDU_assy_partid
	.globl	__pdm_debug
	.globl	_PDU_part_sort_pulldown
	.globl	_PDUend_acl_wf_btn
	.globl	_PDUclear_mcf
	.globl	_MEMwrite_data
	.globl	_FIg_get_state
	.globl	_PDUpart_form
	.globl	_PDU_part_file_buffer
	.globl	_sprintf
	.globl	_PDUcheck_reportname
	.globl	_PDU_mcf_list_created
	.globl	_PDU_single_list_displayed
	.globl	_PDMrcancel_checkout_part
	.globl	_unlink
	.globl	_PDU_assy_revision
	.globl	_FIg_enable
	.globl	_PDU_structure_list
	.globl	_FImcf_set_select
	.globl	_PDUsetup_buffer
	.globl	_PDUget_keyin
	.globl	_PDMgetacl_info
	.globl	_end_ep_cat_btn_flag
	.globl	_PDUverify_file
	.globl	_PDUcheck_char
	.globl	_FIfld_get_text_length
	.globl	_FIfld_get_active_row
	.globl	_PDUparametric_part_form
	.globl	_GRcreate_pull_down_list
	.globl	_PDU_stg_format
	.globl	_PDMflag_part_restore
	.globl	_PDU_check_file_refresh
	.globl	_PDU_topdown_perm_window
	.globl	_PDUfree_string
	.globl	_PDU_refresh_gadgets
	.globl	_PDU_sort_displayed
	.globl	_PDU_hold_stg_bufr
	.globl	_PDUmessage
	.globl	_PDUload_storage_area
	.globl	_FIf_display
	.globl	_np_parttype
	.globl	_PDUformat_buffer
	.globl	_PDUrevise_assembly_form
	.globl	_PDMrget_cit_children
	.globl	_PDMcopy
	.globl	_PDMlist_checkedout_files
	.globl	_PDUvalid_partnum
	.globl	_PDUload_file_buffer
	.globl	_PDUtranslate_message
	.globl	_FIfld_get_num_vis_rows
	.globl	_FIg_reset
	.globl	_PDMrlist_local_files
	.globl	_PDU_part_sort_conds
	.globl	_PDMrecreate_validated_dyn_databufr
	.globl	_PDU_part_checked_in
	.globl	_PDU_part_sort_attr
	.globl	_PDU_mcf_list
	.globl	_PDU_sort_opt_perm_window
	.globl	_MEMprint_buffer
	.globl	_MEMprint_buffers
	.globl	_PDU_update_struct
	.globl	_PDU_where_used_perm_window
	.globl	_fgets
	.globl	_PDUload_parametric_parts_after_select
	.globl	_PDUstate_form
	.globl	_PDUcopy_file
	.globl	_AttrList
	.globl	_printf
	.globl	_FIfld_set_text
	.globl	_PDU_list_cat
	.globl	_FImcf_set_active_col
	.globl	_PDU_multiple_revs
	.globl	_PDU_dyn_index
	.globl	_PDUflag_form
	.globl	_PDU_file_list
	.globl	_ep_project
	.globl	_getenv
	.globl	_PDU_login_created
	.globl	_PDU_local_files_created
	.globl	_ep_desc
	.globl	_PDMsearch_parts_in_catalog
	.globl	_PDUread_refresh_file
	.globl	_PDU_acl_list
	.globl	_PDU_add_bufr
	.globl	_PDU_hold_acl_bufr
	.globl	_PDU_child_buffer
	.globl	_PDU_stg_row
	.globl	_PDMmove_functions
	.globl	_PDUprocess_ex_file_form_after_login
	.globl	_PDU_parts_list_displayed
	.globl	_PDU_mcf_list_displayed
	.globl	_fputs
	.globl	_PDUcancel_checkout
	.globl	_PDU_flag_form_created
	.globl	_PDUprocess_ex_file_form_after_select
	.globl	_PDUactivate
	.globl	_PDU_active_button
	.globl	_PDUend_ep_proj_btn
	.globl	_PDUsearch_part_list
	.globl	_PDU_file_list_displayed
	.globl	_PDU_save_catalog
	.globl	_fopen
	.globl	_PDU_local_files_displayed
	.globl	_PDMrcheckout_part
	.globl	_PDU_attach_bufr
	.globl	_PDU_stg_bufr
	.globl	_end_ep_proj_btn_flag
	.globl	_PDU_disable_localfn_col
	.globl	_PDUupdate_part_form_after_select
	.globl	_PDUext_checkin
	.globl	_PDU_prev_part_sort
	.globl	_PDMrcheckin_part
	.globl	_end_ep_part_btn_flag
	.globl	_exitadd
	.globl	_PDUcheckout_part
	.globl	_PDUremove_data
	.globl	_PDU_state_form_created
	.globl	_PDUsetup_form_fields
	.globl	_MEMappend
	.globl	_PDUchmod
	.globl	_PDU_login
	.globl	_PDUvalidate_api_data_value
	.globl	_PDUep_desc_fld
	.globl	_new_part_flag
	.globl	_PDU_pdm_initialized
