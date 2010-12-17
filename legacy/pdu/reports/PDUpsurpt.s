	.file	"PDUpsurpt.s"
#
# Begin stubs for:  MRPinit_var.o
#
	.data
.T1:	.byte	80, 100, 117, 0
	.byte	112, 100, 117, 47, 114, 101, 112, 111, 114, 116
	.byte	115, 0
	.align	4
.F1:	.long	0x00000700
	.byte	77, 82, 80, 105, 110, 105, 116, 95, 118, 97
	.byte	114, 46, 111, 0
	.text

	.globl	_MRPalloc_var
_MRPalloc_var:
	movw	$.T1,r2
	movw	$.F1,r3
	call	sp,Rload
	b	_MRPalloc_var
#
# Begin stubs for:  rMRPinit_var.o
#
	.data
	.align	4
.F2:	.long	0x00000700
	.byte	114, 77, 82, 80, 105, 110, 105, 116, 95, 118
	.byte	97, 114, 46, 111, 0
	.text

	.globl	_rMRPalloc_var
_rMRPalloc_var:
	movw	$.T1,r2
	movw	$.F2,r3
	call	sp,Rload
	b	_rMRPalloc_var

	.globl	_PDUalloc_rpt
_PDUalloc_rpt:
	movw	$.T1,r2
	movw	$.F2,r3
	call	sp,Rload
	b	_PDUalloc_rpt

	.globl	_PSUalloc_rpt
_PSUalloc_rpt:
	movw	$.T1,r2
	movw	$.F2,r3
	call	sp,Rload
	b	_PSUalloc_rpt
#
# Begin stubs for:  PSUtools.o
#
	.data
	.align	4
.F3:	.long	0x00000700
	.byte	80, 83, 85, 116, 111, 111, 108, 115, 46, 111
	.byte	0
	.text

	.globl	_MRPcalc_width
_MRPcalc_width:
	movw	$.T1,r2
	movw	$.F3,r3
	call	sp,Rload
	b	_MRPcalc_width

	.globl	_MRPmatch_attr_row
_MRPmatch_attr_row:
	movw	$.T1,r2
	movw	$.F3,r3
	call	sp,Rload
	b	_MRPmatch_attr_row

	.globl	_MRPmatch_attr_rpt_row
_MRPmatch_attr_rpt_row:
	movw	$.T1,r2
	movw	$.F3,r3
	call	sp,Rload
	b	_MRPmatch_attr_rpt_row

	.globl	_MRPcheck_position
_MRPcheck_position:
	movw	$.T1,r2
	movw	$.F3,r3
	call	sp,Rload
	b	_MRPcheck_position

	.globl	_PSUplace_attr_fmt
_PSUplace_attr_fmt:
	movw	$.T1,r2
	movw	$.F3,r3
	call	sp,Rload
	b	_PSUplace_attr_fmt

	.globl	_PSUget_datestamp
_PSUget_datestamp:
	movw	$.T1,r2
	movw	$.F3,r3
	call	sp,Rload
	b	_PSUget_datestamp

	.globl	_MRPget_time
_MRPget_time:
	movw	$.T1,r2
	movw	$.F3,r3
	call	sp,Rload
	b	_MRPget_time

	.globl	_MRPget_date
_MRPget_date:
	movw	$.T1,r2
	movw	$.F3,r3
	call	sp,Rload
	b	_MRPget_date

	.globl	_PSUdisplay_rpt
_PSUdisplay_rpt:
	movw	$.T1,r2
	movw	$.F3,r3
	call	sp,Rload
	b	_PSUdisplay_rpt

	.globl	_rMRPget_fsize
_rMRPget_fsize:
	movw	$.T1,r2
	movw	$.F3,r3
	call	sp,Rload
	b	_rMRPget_fsize

	.globl	_rMRPfree_lev_val_struct
_rMRPfree_lev_val_struct:
	movw	$.T1,r2
	movw	$.F3,r3
	call	sp,Rload
	b	_rMRPfree_lev_val_struct

	.globl	_rMRPfree_index_slot
_rMRPfree_index_slot:
	movw	$.T1,r2
	movw	$.F3,r3
	call	sp,Rload
	b	_rMRPfree_index_slot

	.globl	_rMRPfree_struct_list
_rMRPfree_struct_list:
	movw	$.T1,r2
	movw	$.F3,r3
	call	sp,Rload
	b	_rMRPfree_struct_list
#
# Begin stubs for:  PSUformat.o
#
	.data
	.align	4
.F4:	.long	0x00000700
	.byte	80, 83, 85, 102, 111, 114, 109, 97, 116, 46
	.byte	111, 0
	.text

	.globl	_MRPdelete_form
_MRPdelete_form:
	movw	$.T1,r2
	movw	$.F4,r3
	call	sp,Rload
	b	_MRPdelete_form

	.globl	_MRPGet_form_text
_MRPGet_form_text:
	movw	$.T1,r2
	movw	$.F4,r3
	call	sp,Rload
	b	_MRPGet_form_text

	.globl	_pformat_notify_routine
_pformat_notify_routine:
	movw	$.T1,r2
	movw	$.F4,r3
	call	sp,Rload
	b	_pformat_notify_routine

	.globl	_PSUdelete_attr_from_pulldown
_PSUdelete_attr_from_pulldown:
	movw	$.T1,r2
	movw	$.F4,r3
	call	sp,Rload
	b	_PSUdelete_attr_from_pulldown

	.globl	_PSUadd_attr_to_pulldown
_PSUadd_attr_to_pulldown:
	movw	$.T1,r2
	movw	$.F4,r3
	call	sp,Rload
	b	_PSUadd_attr_to_pulldown

	.globl	_PSUfind_attr
_PSUfind_attr:
	movw	$.T1,r2
	movw	$.F4,r3
	call	sp,Rload
	b	_PSUfind_attr

	.globl	_PSUload_list_format
_PSUload_list_format:
	movw	$.T1,r2
	movw	$.F4,r3
	call	sp,Rload
	b	_PSUload_list_format
#
# Begin stubs for:  MRPdyn_gad.o
#
	.data
	.align	4
.F5:	.long	0x00000700
	.byte	77, 82, 80, 100, 121, 110, 95, 103, 97, 100
	.byte	46, 111, 0
	.text

	.globl	_MRPdyn_text
_MRPdyn_text:
	movw	$.T1,r2
	movw	$.F5,r3
	call	sp,Rload
	b	_MRPdyn_text

	.globl	_MRPdyn_rect
_MRPdyn_rect:
	movw	$.T1,r2
	movw	$.F5,r3
	call	sp,Rload
	b	_MRPdyn_rect
#
# Begin stubs for:  MRPforms_tls.o
#
	.data
	.align	4
.F6:	.long	0x00000700
	.byte	77, 82, 80, 102, 111, 114, 109, 115, 95, 116
	.byte	108, 115, 46, 111, 0
	.text

	.globl	_MRPdyn_gadget_init
_MRPdyn_gadget_init:
	movw	$.T1,r2
	movw	$.F6,r3
	call	sp,Rload
	b	_MRPdyn_gadget_init
#
# Begin stubs for:  PSUcom_tls.o
#
	.data
	.align	4
.F7:	.long	0x00000700
	.byte	80, 83, 85, 99, 111, 109, 95, 116, 108, 115
	.byte	46, 111, 0
	.text

	.globl	_rMRPfree_pdurpt
_rMRPfree_pdurpt:
	movw	$.T1,r2
	movw	$.F7,r3
	call	sp,Rload
	b	_rMRPfree_pdurpt

	.globl	_rMRPfree_psurpt
_rMRPfree_psurpt:
	movw	$.T1,r2
	movw	$.F7,r3
	call	sp,Rload
	b	_rMRPfree_psurpt

	.globl	_rMRPfree_psuattr
_rMRPfree_psuattr:
	movw	$.T1,r2
	movw	$.F7,r3
	call	sp,Rload
	b	_rMRPfree_psuattr

	.globl	_MRPstrcpy
_MRPstrcpy:
	movw	$.T1,r2
	movw	$.F7,r3
	call	sp,Rload
	b	_MRPstrcpy

	.globl	_MRPstrcpy2
_MRPstrcpy2:
	movw	$.T1,r2
	movw	$.F7,r3
	call	sp,Rload
	b	_MRPstrcpy2

	.globl	_MRPdealloc
_MRPdealloc:
	movw	$.T1,r2
	movw	$.F7,r3
	call	sp,Rload
	b	_MRPdealloc

	.globl	_PSUfree_list
_PSUfree_list:
	movw	$.T1,r2
	movw	$.F7,r3
	call	sp,Rload
	b	_PSUfree_list
#
# Begin stubs for:  rMRPmessage.o
#
	.data
	.align	4
.F8:	.long	0x00000700
	.byte	114, 77, 82, 80, 109, 101, 115, 115, 97, 103
	.byte	101, 46, 111, 0
	.text

	.globl	_MRPinterpret_message
_MRPinterpret_message:
	movw	$.T1,r2
	movw	$.F8,r3
	call	sp,Rload
	b	_MRPinterpret_message
#
# Begin stubs for:  display_rpt.o
#
	.data
	.align	4
.F9:	.long	0x00000700
	.byte	100, 105, 115, 112, 108, 97, 121, 95, 114, 112
	.byte	116, 46, 111, 0
	.text

	.globl	_PDUdba_display_report
_PDUdba_display_report:
	movw	$.T1,r2
	movw	$.F9,r3
	call	sp,Rload
	b	_PDUdba_display_report

	.globl	_PDUdba_list_output
_PDUdba_list_output:
	movw	$.T1,r2
	movw	$.F9,r3
	call	sp,Rload
	b	_PDUdba_list_output

	.globl	_PDUdba_notify
_PDUdba_notify:
	movw	$.T1,r2
	movw	$.F9,r3
	call	sp,Rload
	b	_PDUdba_notify

	.globl	_PDUdba_add_output
_PDUdba_add_output:
	movw	$.T1,r2
	movw	$.F9,r3
	call	sp,Rload
	b	_PDUdba_add_output

	.globl	_PDUdba_get_msg
_PDUdba_get_msg:
	movw	$.T1,r2
	movw	$.F9,r3
	call	sp,Rload
	b	_PDUdba_get_msg

	.globl	_PDUdba_set_text_size
_PDUdba_set_text_size:
	movw	$.T1,r2
	movw	$.F9,r3
	call	sp,Rload
	b	_PDUdba_set_text_size

	.globl	_PDUdba_text_size_form
_PDUdba_text_size_form:
	movw	$.T1,r2
	movw	$.F9,r3
	call	sp,Rload
	b	_PDUdba_text_size_form

	.globl	_PDUdba_print_msg
_PDUdba_print_msg:
	movw	$.T1,r2
	movw	$.F9,r3
	call	sp,Rload
	b	_PDUdba_print_msg
#
# Begin stubs for:  PDUblk_frm.o
#
	.data
	.align	4
.F10:	.long	0x00000700
	.byte	80, 68, 85, 98, 108, 107, 95, 102, 114, 109
	.byte	46, 111, 0
	.text

	.globl	_blank_form_notification_routine
_blank_form_notification_routine:
	movw	$.T1,r2
	movw	$.F10,r3
	call	sp,Rload
	b	_blank_form_notification_routine

	.globl	_PDUblank_report_form
_PDUblank_report_form:
	movw	$.T1,r2
	movw	$.F10,r3
	call	sp,Rload
	b	_PDUblank_report_form

	.comm	_PDU_blank_report_form_id,4
	.comm	_errmsg,132
	.comm	_TITLE,4
	.comm	_rMRPadd_flag,4
	.globl	_FIf_erase
	.globl	_psuattr
	.globl	_FIfld_set_value
	.globl	_strcpy
	.globl	_PSU_attr_total
	.globl	_FIg_set_standard_variables
	.globl	_PDUfinish_define_format
	.globl	_MRPmatch_attr_row
	.globl	_psu_format_id
	.globl	_FIg_delete
	.globl	_strncpy
	.globl	_PSU_list_size
	.globl	_psu_master_id
	.globl	_FIg_get_location
	.globl	_MRPmatch_attr_rpt_row
	.globl	_ps_current_form_num
	.globl	_PDUdba_display_report
	.globl	_malloc
	.globl	_PSUjustification
	.globl	_PDUdba_text_size
	.globl	_free
	.globl	_FImcf_get_active_col
	.globl	_GRproc_pull_down_list
	.globl	_mrpvar
	.globl	_MRPinterpret_message
	.globl	_strtok
	.globl	_FIg_display
	.globl	_FIf_new
	.globl	_PDU_pdurpt
	.globl	_FIg_set_line_depth
	.globl	_PSUpart_acl
	.globl	_stat
	.globl	_Display_message
	.globl	_MRPstrcpy
	.globl	_FIg_get_type
	.globl	_MRPcheck_position
	.globl	_PDUdba_error
	.globl	_GRchange_pull_down_text
	.globl	_RPT_list_position
	.globl	_PSUplace_attr_fmt
	.globl	_current_form_id
	.globl	_strlen
	.globl	_PSUmessage
	.globl	_psu_format_created
	.globl	_cftime
	.globl	_GRdelete_pull_down_list
	.globl	_MRPdyn_gadget_init
	.globl	_current_form_num
	.globl	_FIg_get_text_length
	.globl	_FIg_set_value
	.globl	_rmrpvar
	.globl	_strcmp
	.globl	_realloc
	.globl	_FIfld_set_active_row
	.globl	_forms
	.globl	_time
	.globl	_FIg_disable
	.globl	_PDUdba_total_lines
	.globl	_memset
	.globl	_total
	.globl	_rpt_value_list
	.globl	_PDUdba_output_fpt
	.globl	_sort_total
	.globl	_UMSGetByNum
	.globl	_FIg_set_text
	.globl	_FIg_erase
	.globl	_fclose
	.globl	_atoi
	.globl	_FIg_get_text
	.globl	_psurpt
	.globl	_sscanf
	.globl	_PSUcommand
	.globl	_PDUdba_num_rows
	.globl	_PSUems_file
	.globl	_PDUfill_in_string
	.globl	_FIf_delete
	.globl	_PDUdba_form_value
	.globl	_PDUdba_filnam_ptr
	.globl	_FIfld_set_num_rows
	.globl	_rpt_value_pulldown
	.globl	_MRPscroll_col
	.globl	_FIfld_get_text
	.globl	_PDUfree_string_array
	.globl	_PDUdba_text_fpt
	.globl	_fseek
	.globl	__pdm_debug
	.globl	_FIg_get_state
	.globl	_sprintf
	.globl	_FIg_enable
	.globl	_MRPdealloc
	.globl	_FIfld_get_text_length
	.globl	_FIfld_get_active_row
	.globl	_GRcreate_pull_down_list
	.globl	_FIg_activate
	.globl	_PDUdba_errtxt
	.globl	_FIg_set_font
	.globl	_PDUmessage
	.globl	_FIf_display
	.globl	_FIg_new
	.globl	_MRPdyn_rect
	.globl	_PDUtranslate_message
	.globl	_FIfld_get_num_vis_rows
	.globl	_subtotal
	.globl	_fgets
	.globl	_printf
	.globl	_FIfld_set_text
	.globl	_PSUsaname
	.globl	_ps_current_form_id
	.globl	_fopen
	.globl	_MRPdyn_text
	.globl	_PSUworkflow
	.globl	_PDUdba_stext
	.globl	_PSUtemplib
