	.file	"PDUtools.s"
#
# Begin stubs for:  PDUverify.o
#
	.data
.T1:	.byte	80, 100, 117, 0
	.byte	112, 100, 117, 47, 116, 111, 111, 108, 115, 0
	.align	4
.F1:	.long	0x00000700
	.byte	80, 68, 85, 118, 101, 114, 105, 102, 121, 46
	.byte	111, 0
	.text

	.globl	_PDUverify_catalog
_PDUverify_catalog:
	movw	$.T1,r2
	movw	$.F1,r3
	call	sp,Rload
	b	_PDUverify_catalog

	.globl	_PDUverify_element
_PDUverify_element:
	movw	$.T1,r2
	movw	$.F1,r3
	call	sp,Rload
	b	_PDUverify_element
#
# Begin stubs for:  PDUbfr_tools.o
#
	.data
	.align	4
.F2:	.long	0x00000700
	.byte	80, 68, 85, 98, 102, 114, 95, 116, 111, 111
	.byte	108, 115, 46, 111, 0
	.text

	.globl	_PDUfind_col_in_buffer
_PDUfind_col_in_buffer:
	movw	$.T1,r2
	movw	$.F2,r3
	call	sp,Rload
	b	_PDUfind_col_in_buffer

	.globl	_PDUget_column_width
_PDUget_column_width:
	movw	$.T1,r2
	movw	$.F2,r3
	call	sp,Rload
	b	_PDUget_column_width

	.globl	_PDUheader_string_to_array
_PDUheader_string_to_array:
	movw	$.T1,r2
	movw	$.F2,r3
	call	sp,Rload
	b	_PDUheader_string_to_array

	.globl	_PDUupdate_copy_macro_lib_bufr
_PDUupdate_copy_macro_lib_bufr:
	movw	$.T1,r2
	movw	$.F2,r3
	call	sp,Rload
	b	_PDUupdate_copy_macro_lib_bufr
#
# Begin stubs for:  PDUupdat_buf.o
#
	.data
	.align	4
.F3:	.long	0x00000700
	.byte	80, 68, 85, 117, 112, 100, 97, 116, 95, 98
	.byte	117, 102, 46, 111, 0
	.text

	.globl	_PDUupdate_data_buffer
_PDUupdate_data_buffer:
	movw	$.T1,r2
	movw	$.F3,r3
	call	sp,Rload
	b	_PDUupdate_data_buffer

	.globl	_PDUupdate_parm_data_buffer
_PDUupdate_parm_data_buffer:
	movw	$.T1,r2
	movw	$.F3,r3
	call	sp,Rload
	b	_PDUupdate_parm_data_buffer

	.globl	_PDUupdate_dyn_data_buffer
_PDUupdate_dyn_data_buffer:
	movw	$.T1,r2
	movw	$.F3,r3
	call	sp,Rload
	b	_PDUupdate_dyn_data_buffer

	.globl	_PDUupdate_dyn_data_buffer1
_PDUupdate_dyn_data_buffer1:
	movw	$.T1,r2
	movw	$.F3,r3
	call	sp,Rload
	b	_PDUupdate_dyn_data_buffer1
#
# Begin stubs for:  PDUdebug.o
#
	.data
	.align	4
.F4:	.long	0x00000700
	.byte	80, 68, 85, 100, 101, 98, 117, 103, 46, 111
	.byte	0
	.text

	.globl	_PDUdebug_on
_PDUdebug_on:
	movw	$.T1,r2
	movw	$.F4,r3
	call	sp,Rload
	b	_PDUdebug_on

	.globl	_PDUdebug_off
_PDUdebug_off:
	movw	$.T1,r2
	movw	$.F4,r3
	call	sp,Rload
	b	_PDUdebug_off
#
# Begin stubs for:  PDUstr_attr.o
#
	.data
	.align	4
.F5:	.long	0x00000700
	.byte	80, 68, 85, 115, 116, 114, 95, 97, 116, 116
	.byte	114, 46, 111, 0
	.text

	.globl	_PDUstring_to_attributes
_PDUstring_to_attributes:
	movw	$.T1,r2
	movw	$.F5,r3
	call	sp,Rload
	b	_PDUstring_to_attributes
#
# Begin stubs for:  PDUvalid.o
#
	.data
	.align	4
.F6:	.long	0x00000700
	.byte	80, 68, 85, 118, 97, 108, 105, 100, 46, 111
	.byte	0
	.text

	.globl	_PDUvalid_alt_tag
_PDUvalid_alt_tag:
	movw	$.T1,r2
	movw	$.F6,r3
	call	sp,Rload
	b	_PDUvalid_alt_tag

	.globl	_PDUvalid_alt_tag_edt_part
_PDUvalid_alt_tag_edt_part:
	movw	$.T1,r2
	movw	$.F6,r3
	call	sp,Rload
	b	_PDUvalid_alt_tag_edt_part

	.globl	_PDUvalid_part_type
_PDUvalid_part_type:
	movw	$.T1,r2
	movw	$.F6,r3
	call	sp,Rload
	b	_PDUvalid_part_type

	.globl	_PDUvalid_date
_PDUvalid_date:
	movw	$.T1,r2
	movw	$.F6,r3
	call	sp,Rload
	b	_PDUvalid_date

	.globl	_PDUvalid_dynamic_attr
_PDUvalid_dynamic_attr:
	movw	$.T1,r2
	movw	$.F6,r3
	call	sp,Rload
	b	_PDUvalid_dynamic_attr

	.globl	_PDUvalid_Y_N_attr
_PDUvalid_Y_N_attr:
	movw	$.T1,r2
	movw	$.F6,r3
	call	sp,Rload
	b	_PDUvalid_Y_N_attr

	.globl	_PDUvalid_dynamic_value
_PDUvalid_dynamic_value:
	movw	$.T1,r2
	movw	$.F6,r3
	call	sp,Rload
	b	_PDUvalid_dynamic_value

	.globl	_PDUvalid_synonym
_PDUvalid_synonym:
	movw	$.T1,r2
	movw	$.F6,r3
	call	sp,Rload
	b	_PDUvalid_synonym

	.globl	_PDUvalid_level
_PDUvalid_level:
	movw	$.T1,r2
	movw	$.F6,r3
	call	sp,Rload
	b	_PDUvalid_level

	.globl	_PDUvalidate_dyn_attr_uniqueness
_PDUvalidate_dyn_attr_uniqueness:
	movw	$.T1,r2
	movw	$.F6,r3
	call	sp,Rload
	b	_PDUvalidate_dyn_attr_uniqueness

	.globl	_PDUvalid_case
_PDUvalid_case:
	movw	$.T1,r2
	movw	$.F6,r3
	call	sp,Rload
	b	_PDUvalid_case

	.globl	_PDUcheck_for_blanks
_PDUcheck_for_blanks:
	movw	$.T1,r2
	movw	$.F6,r3
	call	sp,Rload
	b	_PDUcheck_for_blanks

	.globl	_PDUpart_id
_PDUpart_id:
	movw	$.T1,r2
	movw	$.F6,r3
	call	sp,Rload
	b	_PDUpart_id

	.globl	_PDUfile_id
_PDUfile_id:
	movw	$.T1,r2
	movw	$.F6,r3
	call	sp,Rload
	b	_PDUfile_id

	.globl	_PDUvalidate_function
_PDUvalidate_function:
	movw	$.T1,r2
	movw	$.F6,r3
	call	sp,Rload
	b	_PDUvalidate_function

	.globl	_PDUvalid_decimal
_PDUvalid_decimal:
	movw	$.T1,r2
	movw	$.F6,r3
	call	sp,Rload
	b	_PDUvalid_decimal

	.globl	_PDUvalidate_synonym_is_unique
_PDUvalidate_synonym_is_unique:
	movw	$.T1,r2
	movw	$.F6,r3
	call	sp,Rload
	b	_PDUvalidate_synonym_is_unique
#
# Begin stubs for:  PDUlinklist.o
#
	.data
	.align	4
.F7:	.long	0x00000700
	.byte	80, 68, 85, 108, 105, 110, 107, 108, 105, 115
	.byte	116, 46, 111, 0
	.text

	.globl	_PDUassy_buffer_to_linklist
_PDUassy_buffer_to_linklist:
	movw	$.T1,r2
	movw	$.F7,r3
	call	sp,Rload
	b	_PDUassy_buffer_to_linklist

	.globl	_PDUprint_linklist
_PDUprint_linklist:
	movw	$.T1,r2
	movw	$.F7,r3
	call	sp,Rload
	b	_PDUprint_linklist

	.globl	_PDUassy_linklist_to_buffer
_PDUassy_linklist_to_buffer:
	movw	$.T1,r2
	movw	$.F7,r3
	call	sp,Rload
	b	_PDUassy_linklist_to_buffer

	.globl	_PDUdrop_node_from_linklist
_PDUdrop_node_from_linklist:
	movw	$.T1,r2
	movw	$.F7,r3
	call	sp,Rload
	b	_PDUdrop_node_from_linklist

	.globl	_PDUadd_node_to_linklist
_PDUadd_node_to_linklist:
	movw	$.T1,r2
	movw	$.F7,r3
	call	sp,Rload
	b	_PDUadd_node_to_linklist

	.globl	_PDUfind_field_in_linklist
_PDUfind_field_in_linklist:
	movw	$.T1,r2
	movw	$.F7,r3
	call	sp,Rload
	b	_PDUfind_field_in_linklist

	.globl	_PDUupdate_field_in_linklist
_PDUupdate_field_in_linklist:
	movw	$.T1,r2
	movw	$.F7,r3
	call	sp,Rload
	b	_PDUupdate_field_in_linklist

	.globl	_PDUfind_instanceno_in_linklist
_PDUfind_instanceno_in_linklist:
	movw	$.T1,r2
	movw	$.F7,r3
	call	sp,Rload
	b	_PDUfind_instanceno_in_linklist

	.globl	_PDUfind_childno_in_linklist
_PDUfind_childno_in_linklist:
	movw	$.T1,r2
	movw	$.F7,r3
	call	sp,Rload
	b	_PDUfind_childno_in_linklist

	.globl	_PDUcheck_usageid_for_uniqueness
_PDUcheck_usageid_for_uniqueness:
	movw	$.T1,r2
	movw	$.F7,r3
	call	sp,Rload
	b	_PDUcheck_usageid_for_uniqueness

	.globl	_PDUgenerate_tagno_from_linklist
_PDUgenerate_tagno_from_linklist:
	movw	$.T1,r2
	movw	$.F7,r3
	call	sp,Rload
	b	_PDUgenerate_tagno_from_linklist

	.globl	_PDUcheck_alttag_for_uniqueness
_PDUcheck_alttag_for_uniqueness:
	movw	$.T1,r2
	movw	$.F7,r3
	call	sp,Rload
	b	_PDUcheck_alttag_for_uniqueness
#
# Begin stubs for:  PDUchsym_frm.o
#
	.data
	.align	4
.F8:	.long	0x00000700
	.byte	80, 68, 85, 99, 104, 115, 121, 109, 95, 102
	.byte	114, 109, 46, 111, 0
	.text

	.globl	_change_symbology_notification_routine
_change_symbology_notification_routine:
	movw	$.T1,r2
	movw	$.F8,r3
	call	sp,Rload
	b	_change_symbology_notification_routine

	.globl	_change_symbology_form
_change_symbology_form:
	movw	$.T1,r2
	movw	$.F8,r3
	call	sp,Rload
	b	_change_symbology_form

	.globl	_PDUchange_symbology
_PDUchange_symbology:
	movw	$.T1,r2
	movw	$.F8,r3
	call	sp,Rload
	b	_PDUchange_symbology
#
# Begin stubs for:  PDUtoolsapi.o
#
	.data
	.align	4
.F9:	.long	0x00000700
	.byte	80, 68, 85, 116, 111, 111, 108, 115, 97, 112
	.byte	105, 46, 111, 0
	.text

	.globl	_PDUadd_buffer_string
_PDUadd_buffer_string:
	movw	$.T1,r2
	movw	$.F9,r3
	call	sp,Rload
	b	_PDUadd_buffer_string

	.globl	_PDUvalid_attr
_PDUvalid_attr:
	movw	$.T1,r2
	movw	$.F9,r3
	call	sp,Rload
	b	_PDUvalid_attr

	.globl	_PDUvalid_timestamp
_PDUvalid_timestamp:
	movw	$.T1,r2
	movw	$.F9,r3
	call	sp,Rload
	b	_PDUvalid_timestamp

	.globl	_PDUvalid_number
_PDUvalid_number:
	movw	$.T1,r2
	movw	$.F9,r3
	call	sp,Rload
	b	_PDUvalid_number

	.globl	_PDUvalid_string
_PDUvalid_string:
	movw	$.T1,r2
	movw	$.F9,r3
	call	sp,Rload
	b	_PDUvalid_string

	.globl	_PDUvalid_smallint
_PDUvalid_smallint:
	movw	$.T1,r2
	movw	$.F9,r3
	call	sp,Rload
	b	_PDUvalid_smallint

	.globl	_PDUfind_attr_in_buffer
_PDUfind_attr_in_buffer:
	movw	$.T1,r2
	movw	$.F9,r3
	call	sp,Rload
	b	_PDUfind_attr_in_buffer

	.globl	_PDUvalid_datatype
_PDUvalid_datatype:
	movw	$.T1,r2
	movw	$.F9,r3
	call	sp,Rload
	b	_PDUvalid_datatype
#
# Begin stubs for:  PDUstat.o
#
	.data
	.align	4
.F10:	.long	0x00000700
	.byte	80, 68, 85, 115, 116, 97, 116, 46, 111, 0
	.text

	.globl	_PDUstat
_PDUstat:
	movw	$.T1,r2
	movw	$.F10,r3
	call	sp,Rload
	b	_PDUstat

	.globl	_PDU_incl_BOM
	.globl	_PDU_alt_tagno
	.globl	_PDUmacro_lib_list
	.globl	_PDUdebug_on_off
	.globl	_PDUvalidate_alt_tag
	.globl	_PDMrverify_part
	.globl	_MEMopen
	.globl	_strcpy
	.globl	_PDM_debug_on
	.globl	_strncpy
	.globl	_malloc
	.globl	_free
	.globl	_MEMwrite
	.globl	_PDUcheck_uniqueness
	.globl	_strtok
	.globl	_FIf_new
	.globl	_stat
	.globl	_MEMwrite_format
	.globl	_PDUformat_macro_bufr
	.globl	_PDMdebug_on
	.globl	_PDU_DEBUG_FILE
	.globl	_PDU_command
	.globl	_PDU_assy_head
	.globl	_strncmp
	.globl	_PDUadd_buffer_string
	.globl	_PDUget_buffer_col
	.globl	_strlen
	.globl	_PDU_calling_form
	.globl	_strcat
	.globl	_PDU_incl_ASM
	.globl	__ctype
	.globl	__pdm_status
	.globl	_PDMrverify_catalog
	.globl	_strcmp
	.globl	_forms
	.globl	_PDU_assy_catalog
	.globl	_PDUvalid_number
	.globl	_memset
	.globl	_strchr
	.globl	_fclose
	.globl	_isdigit
	.globl	_atoi
	.globl	_sscanf
	.globl	_MEMbuild_array
	.globl	_PDUfill_in_string
	.globl	_FIf_delete
	.globl	_MEMclose
	.globl	_fprintf
	.globl	_FIfld_get_text
	.globl	_PDU_assy_partid
	.globl	__pdm_debug
	.globl	_sprintf
	.globl	_PDU_assy_revision
	.globl	_PDUsetup_buffer
	.globl	_FIfld_get_text_length
	.globl	_PDUmessage
	.globl	_FIf_display
	.globl	_PDUformat_buffer
	.globl	_MEMprint_buffer
	.globl	_printf
	.globl	_getenv
	.globl	_fopen
