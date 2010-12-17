	.file	"PDUmacros.s"
#
# Begin stubs for:  PDUm_login.o
#
	.data
.T1:	.byte	80, 100, 117, 0
	.byte	112, 100, 117, 47, 109, 97, 99, 114, 111, 115
	.byte	0
	.align	4
.F1:	.long	0x00000700
	.byte	80, 68, 85, 109, 95, 108, 111, 103, 105, 110
	.byte	46, 111, 0
	.text

	.globl	_PDUppl_login
_PDUppl_login:
	movw	$.T1,r2
	movw	$.F1,r3
	call	sp,Rload
	b	_PDUppl_login
#
# Begin stubs for:  PDUm_logout.o
#
	.data
	.align	4
.F2:	.long	0x00000700
	.byte	80, 68, 85, 109, 95, 108, 111, 103, 111, 117
	.byte	116, 46, 111, 0
	.text

	.globl	_PDUppl_logout
_PDUppl_logout:
	movw	$.T1,r2
	movw	$.F2,r3
	call	sp,Rload
	b	_PDUppl_logout
#
# Begin stubs for:  PDUm_chkout.o
#
	.data
	.align	4
.F3:	.long	0x00000700
	.byte	80, 68, 85, 109, 95, 99, 104, 107, 111, 117
	.byte	116, 46, 111, 0
	.text

	.globl	_PDUppl_checkout_part
_PDUppl_checkout_part:
	movw	$.T1,r2
	movw	$.F3,r3
	call	sp,Rload
	b	_PDUppl_checkout_part

	.globl	_PDUmacro_checkout_part
_PDUmacro_checkout_part:
	movw	$.T1,r2
	movw	$.F3,r3
	call	sp,Rload
	b	_PDUmacro_checkout_part
#
# Begin stubs for:  PDUm_chkin.o
#
	.data
	.align	4
.F4:	.long	0x00000700
	.byte	80, 68, 85, 109, 95, 99, 104, 107, 105, 110
	.byte	46, 111, 0
	.text

	.globl	_PDUppl_checkin_part
_PDUppl_checkin_part:
	movw	$.T1,r2
	movw	$.F4,r3
	call	sp,Rload
	b	_PDUppl_checkin_part

	.globl	_PDUmacro_checkin_part
_PDUmacro_checkin_part:
	movw	$.T1,r2
	movw	$.F4,r3
	call	sp,Rload
	b	_PDUmacro_checkin_part
#
# Begin stubs for:  PDUm_cpfiles.o
#
	.data
	.align	4
.F5:	.long	0x00000700
	.byte	80, 68, 85, 109, 95, 99, 112, 102, 105, 108
	.byte	101, 115, 46, 111, 0
	.text

	.globl	_PDUppl_copy_files
_PDUppl_copy_files:
	movw	$.T1,r2
	movw	$.F5,r3
	call	sp,Rload
	b	_PDUppl_copy_files

	.globl	_PDUmacro_copy_file
_PDUmacro_copy_file:
	movw	$.T1,r2
	movw	$.F5,r3
	call	sp,Rload
	b	_PDUmacro_copy_file
#
# Begin stubs for:  PDUm_cat.o
#
	.data
	.align	4
.F6:	.long	0x00000700
	.byte	80, 68, 85, 109, 95, 99, 97, 116, 46, 111
	.byte	0
	.text

	.globl	_PDUprepare_create_catalog
_PDUprepare_create_catalog:
	movw	$.T1,r2
	movw	$.F6,r3
	call	sp,Rload
	b	_PDUprepare_create_catalog
#
# Begin stubs for:  PDUm_add_pt.o
#
	.data
	.align	4
.F7:	.long	0x00000700
	.byte	80, 68, 85, 109, 95, 97, 100, 100, 95, 112
	.byte	116, 46, 111, 0
	.text

	.globl	_PDUm_add_part
_PDUm_add_part:
	movw	$.T1,r2
	movw	$.F7,r3
	call	sp,Rload
	b	_PDUm_add_part

	.globl	_PDUload_file_structure
_PDUload_file_structure:
	movw	$.T1,r2
	movw	$.F7,r3
	call	sp,Rload
	b	_PDUload_file_structure

	.globl	_PDUload_change_structure
_PDUload_change_structure:
	movw	$.T1,r2
	movw	$.F7,r3
	call	sp,Rload
	b	_PDUload_change_structure

	.globl	_PDUfree_file_structure
_PDUfree_file_structure:
	movw	$.T1,r2
	movw	$.F7,r3
	call	sp,Rload
	b	_PDUfree_file_structure

	.globl	_PDUfree_change_file_structure
_PDUfree_change_file_structure:
	movw	$.T1,r2
	movw	$.F7,r3
	call	sp,Rload
	b	_PDUfree_change_file_structure
#
# Begin stubs for:  PDUm_chg_pt.o
#
	.data
	.align	4
.F8:	.long	0x00000700
	.byte	80, 68, 85, 109, 95, 99, 104, 103, 95, 112
	.byte	116, 46, 111, 0
	.text

	.globl	_PDUm_chg_part
_PDUm_chg_part:
	movw	$.T1,r2
	movw	$.F8,r3
	call	sp,Rload
	b	_PDUm_chg_part
#
# Begin stubs for:  PDUactdeact.o
#
	.data
	.align	4
.F9:	.long	0x00000700
	.byte	80, 68, 85, 97, 99, 116, 100, 101, 97, 99
	.byte	116, 46, 111, 0
	.text

	.globl	_PDUprepare_activate_part
_PDUprepare_activate_part:
	movw	$.T1,r2
	movw	$.F9,r3
	call	sp,Rload
	b	_PDUprepare_activate_part

	.globl	_PDUprepare_deactivate_part
_PDUprepare_deactivate_part:
	movw	$.T1,r2
	movw	$.F9,r3
	call	sp,Rload
	b	_PDUprepare_deactivate_part

	.globl	_PDUprepare_create_bom
_PDUprepare_create_bom:
	movw	$.T1,r2
	movw	$.F9,r3
	call	sp,Rload
	b	_PDUprepare_create_bom

	.globl	_PDUprepare_where_used
_PDUprepare_where_used:
	movw	$.T1,r2
	movw	$.F9,r3
	call	sp,Rload
	b	_PDUprepare_where_used

	.globl	_PDMget_existing_data
	.globl	_PDU_parm_cat
	.globl	_PDUprocess_wrkst_info
	.globl	_PDMrverify_part
	.globl	_PDUcheck_part_syntax
	.globl	_PDU_view
	.globl	_MEMopen
	.globl	_change_mode
	.globl	_strcpy
	.globl	_user
	.globl	_bufr_flag
	.globl	_PDU_cat_description
	.globl	_PDUprepare_queue
	.globl	_PDUint_checkin
	.globl	_PDUverify_change_file_list
	.globl	_PDUverify_storage_name
	.globl	_PDM_debug_on
	.globl	_PDUvalid_catalog
	.globl	_PDMvalidate_user_access
	.globl	_PDUformat_cat_class_bufr
	.globl	_malloc
	.globl	_PDUget_catalog_buffers
	.globl	_PDUcheck_rev_syntax
	.globl	_free
	.globl	_PDUadd_files_to_buffer
	.globl	_MEMwrite
	.globl	_PDUadd_dynamic_attributes
	.globl	_PDUsetup_buffer_list
	.globl	_PDUvalidate_access
	.globl	_PDUprint_file_list
	.globl	_PDU_save
	.globl	_PDMrmodify_part
	.globl	_PDUrun_ppl
	.globl	_PDUlogout
	.globl	_PDUmessage_trans
	.globl	_PDU_cat_class_bufr
	.globl	_PDUwf_check
	.globl	_PDMget_filenames
	.globl	_PDUdeactivate
	.globl	_PDMdebug_on
	.globl	_PDU_DEBUG_FILE
	.globl	_PDU_command
	.globl	_PDUverify_PDUattr_list
	.globl	_storage
	.globl	_PDUget_col_number
	.globl	_MEMsplit_copy_buffer
	.globl	_PDUadd_buffer_string
	.globl	_PDUget_buffer_col
	.globl	_PDMcheck_partnum
	.globl	_strlen
	.globl	_PDMcatalog_acls
	.globl	_PDU_view_buffer
	.globl	_PDUvalidate_catalog
	.globl	__pdm_status
	.globl	_PDMrverify_catalog
	.globl	_strcmp
	.globl	_PDUcheck_rev_datatype
	.globl	_PDUcleanup_change_part
	.globl	_PDU_file_bufr
	.globl	_PDUchange_files_in_buffer
	.globl	_memset
	.globl	_PDMquery_part_type
	.globl	_PDUget_file_status
	.globl	_PDU_main_form_cat
	.globl	_atoi
	.globl	_PDMgen_where_used_top
	.globl	_PDMradd_part
	.globl	_PDUget_parttype
	.globl	_PDMcancel_modify_part
	.globl	_PDU_attach_buffer
	.globl	_MEMbuild_array
	.globl	_PDUfill_in_string
	.globl	_MEMclose
	.globl	_PDMset_to_state
	.globl	_PDUcheck_part_datatype
	.globl	_PDUadd_static_attributes
	.globl	_refresh
	.globl	_PDU_ret_bufr
	.globl	_PDU_template_catalog
	.globl	_PDU_cat_aclno
	.globl	__pdm_debug
	.globl	_MEMwrite_data
	.globl	_PDUcreate_catalog
	.globl	_PDUsetup_buffer
	.globl	_PDMvalidate_report_name
	.globl	_PDUverify_file
	.globl	_PDUmadd_attribute_defaults
	.globl	_PDUuser_init
	.globl	_PDUverify_add_file_list
	.globl	_PDUmessage
	.globl	_PDUpart_init
	.globl	_PDUformat_buffer
	.globl	_PDMcopy
	.globl	_PDUtranslate_message
	.globl	_MEMprint_buffer
	.globl	_PDUverify_aclname
	.globl	_PDMrupdate_bom
	.globl	_PDUvalidate_parttype
	.globl	_PDUcheck_desc_datatype
	.globl	_PDU_add_bufr
	.globl	_PDU_child_buffer
	.globl	_PDUprocess_login
	.globl	_PDUprint_change_list
	.globl	_PSUdisplay_rpt
	.globl	_PDMrcheckout_part
	.globl	_refresh_init
	.globl	_PDMrcheckin_part
	.globl	_PDUverify_part
	.globl	_PDUcheckout_part
	.globl	_PDU_login
