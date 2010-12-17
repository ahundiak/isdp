	.file	"PDMpdmp.s"
#
# Begin stubs for:  PDMmacros.o
#
	.data
.T1:	.byte	80, 100, 117, 0
	.byte	112, 100, 109, 47, 112, 100, 109, 112, 0
	.align	4
.F1:	.long	0x00000700
	.byte	80, 68, 77, 109, 97, 99, 114, 111, 115, 46
	.byte	111, 0
	.text

	.globl	_PDMsget_macro_format
_PDMsget_macro_format:
	movw	$.T1,r2
	movw	$.F1,r3
	call	sp,Rload
	b	_PDMsget_macro_format

	.globl	_PDMadd_macro_library
_PDMadd_macro_library:
	movw	$.T1,r2
	movw	$.F1,r3
	call	sp,Rload
	b	_PDMadd_macro_library

	.globl	_PDMstore_parameters
_PDMstore_parameters:
	movw	$.T1,r2
	movw	$.F1,r3
	call	sp,Rload
	b	_PDMstore_parameters

	.globl	_PDMmap_catalog_macro
_PDMmap_catalog_macro:
	movw	$.T1,r2
	movw	$.F1,r3
	call	sp,Rload
	b	_PDMmap_catalog_macro

	.globl	_PDMget_macro_parameters
_PDMget_macro_parameters:
	movw	$.T1,r2
	movw	$.F1,r3
	call	sp,Rload
	b	_PDMget_macro_parameters
#
# Begin stubs for:  PDMcp_macro.o
#
	.data
	.align	4
.F2:	.long	0x00000700
	.byte	80, 68, 77, 99, 112, 95, 109, 97, 99, 114
	.byte	111, 46, 111, 0
	.text

	.globl	_PDMcopy_macro_library
_PDMcopy_macro_library:
	movw	$.T1,r2
	movw	$.F2,r3
	call	sp,Rload
	b	_PDMcopy_macro_library

	.globl	_PDMdetach_macro_library
_PDMdetach_macro_library:
	movw	$.T1,r2
	movw	$.F2,r3
	call	sp,Rload
	b	_PDMdetach_macro_library

	.globl	_PDMattach_macro_library
_PDMattach_macro_library:
	movw	$.T1,r2
	movw	$.F2,r3
	call	sp,Rload
	b	_PDMattach_macro_library

	.globl	_PDMold_detach_macro_library
_PDMold_detach_macro_library:
	movw	$.T1,r2
	movw	$.F2,r3
	call	sp,Rload
	b	_PDMold_detach_macro_library
#
# Begin stubs for:  PDMmac_cpio.o
#
	.data
	.align	4
.F3:	.long	0x00000700
	.byte	80, 68, 77, 109, 97, 99, 95, 99, 112, 105
	.byte	111, 46, 111, 0
	.text

	.globl	_PDMbundle_macros
_PDMbundle_macros:
	movw	$.T1,r2
	movw	$.F3,r3
	call	sp,Rload
	b	_PDMbundle_macros

	.globl	_PDMsystem
_PDMsystem:
	movw	$.T1,r2
	movw	$.F3,r3
	call	sp,Rload
	b	_PDMsystem

	.globl	_PDMunbundle_macros
_PDMunbundle_macros:
	movw	$.T1,r2
	movw	$.F3,r3
	call	sp,Rload
	b	_PDMunbundle_macros

	.globl	_PDMXdefine_parametric_assembly
_PDMXdefine_parametric_assembly:
	movw	$.T1,r2
	movw	$.F3,r3
	call	sp,Rload
	b	_PDMXdefine_parametric_assembly
#
# Begin stubs for:  PDMpara_cat.o
#
	.data
	.align	4
.F4:	.long	0x00000700
	.byte	80, 68, 77, 112, 97, 114, 97, 95, 99, 97
	.byte	116, 46, 111, 0
	.text

	.globl	_PDMprepare_view_catalog_creation
_PDMprepare_view_catalog_creation:
	movw	$.T1,r2
	movw	$.F4,r3
	call	sp,Rload
	b	_PDMprepare_view_catalog_creation

	.globl	_PDMcreate_view_catalog
_PDMcreate_view_catalog:
	movw	$.T1,r2
	movw	$.F4,r3
	call	sp,Rload
	b	_PDMcreate_view_catalog

	.globl	_PDMcreate_interface_table
_PDMcreate_interface_table:
	movw	$.T1,r2
	movw	$.F4,r3
	call	sp,Rload
	b	_PDMcreate_interface_table

	.globl	_PDMcreate_systable_view
_PDMcreate_systable_view:
	movw	$.T1,r2
	movw	$.F4,r3
	call	sp,Rload
	b	_PDMcreate_systable_view

	.globl	_PDMcreate_parametric_catalog
_PDMcreate_parametric_catalog:
	movw	$.T1,r2
	movw	$.F4,r3
	call	sp,Rload
	b	_PDMcreate_parametric_catalog

	.globl	_PDMstore_compute_functions
_PDMstore_compute_functions:
	movw	$.T1,r2
	movw	$.F4,r3
	call	sp,Rload
	b	_PDMstore_compute_functions

	.globl	_PDMpopulate_attribute_info
_PDMpopulate_attribute_info:
	movw	$.T1,r2
	movw	$.F4,r3
	call	sp,Rload
	b	_PDMpopulate_attribute_info

	.globl	__PDMfake_create_table
__PDMfake_create_table:
	movw	$.T1,r2
	movw	$.F4,r3
	call	sp,Rload
	b	__PDMfake_create_table
#
# Begin stubs for:  PDMadd_fly.o
#
	.data
	.align	4
.F5:	.long	0x00000700
	.byte	80, 68, 77, 97, 100, 100, 95, 102, 108, 121
	.byte	46, 111, 0
	.text

	.globl	_PDMsget_families
_PDMsget_families:
	movw	$.T1,r2
	movw	$.F5,r3
	call	sp,Rload
	b	_PDMsget_families

	.globl	_PDMi_create_family
_PDMi_create_family:
	movw	$.T1,r2
	movw	$.F5,r3
	call	sp,Rload
	b	_PDMi_create_family
#
# Begin stubs for:  PDMppart.o
#
	.data
	.align	4
.F6:	.long	0x00000700
	.byte	80, 68, 77, 112, 112, 97, 114, 116, 46, 111
	.byte	0
	.text

	.globl	_PDMi_copy_library
_PDMi_copy_library:
	movw	$.T1,r2
	movw	$.F6,r3
	call	sp,Rload
	b	_PDMi_copy_library

	.globl	_PDMcopy_macrolib_file
_PDMcopy_macrolib_file:
	movw	$.T1,r2
	movw	$.F6,r3
	call	sp,Rload
	b	_PDMcopy_macrolib_file
#
# Begin stubs for:  PDMpara_ass.o
#
	.data
	.align	4
.F7:	.long	0x00000700
	.byte	80, 68, 77, 112, 97, 114, 97, 95, 97, 115
	.byte	115, 46, 111, 0
	.text

	.globl	_PDMdefine_parametric_assembly
_PDMdefine_parametric_assembly:
	movw	$.T1,r2
	movw	$.F7,r3
	call	sp,Rload
	b	_PDMdefine_parametric_assembly

	.globl	_PDMdefine_support_libraries
_PDMdefine_support_libraries:
	movw	$.T1,r2
	movw	$.F7,r3
	call	sp,Rload
	b	_PDMdefine_support_libraries
#
# Begin stubs for:  PDMmod_del.o
#
	.data
	.align	4
.F8:	.long	0x00000700
	.byte	80, 68, 77, 109, 111, 100, 95, 100, 101, 108
	.byte	46, 111, 0
	.text

	.globl	_PDMprepare_change_parametric_catalog
_PDMprepare_change_parametric_catalog:
	movw	$.T1,r2
	movw	$.F8,r3
	call	sp,Rload
	b	_PDMprepare_change_parametric_catalog

	.globl	_PDMchange_parametric_catalog
_PDMchange_parametric_catalog:
	movw	$.T1,r2
	movw	$.F8,r3
	call	sp,Rload
	b	_PDMchange_parametric_catalog

	.globl	_PDMchange_view_catalog
_PDMchange_view_catalog:
	movw	$.T1,r2
	movw	$.F8,r3
	call	sp,Rload
	b	_PDMchange_view_catalog

	.globl	_PDMdelete_parametric_catalog
_PDMdelete_parametric_catalog:
	movw	$.T1,r2
	movw	$.F8,r3
	call	sp,Rload
	b	_PDMdelete_parametric_catalog

	.globl	_PDMdelete_view_catalog
_PDMdelete_view_catalog:
	movw	$.T1,r2
	movw	$.F8,r3
	call	sp,Rload
	b	_PDMdelete_view_catalog

	.globl	_PDMprepare_change_view_catalog
_PDMprepare_change_view_catalog:
	movw	$.T1,r2
	movw	$.F8,r3
	call	sp,Rload
	b	_PDMprepare_change_view_catalog
#
# Begin stubs for:  PDMpar_part.o
#
	.data
	.align	4
.F9:	.long	0x00000700
	.byte	80, 68, 77, 112, 97, 114, 95, 112, 97, 114
	.byte	116, 46, 111, 0
	.text

	.globl	_PDMadd_parametric_part
_PDMadd_parametric_part:
	movw	$.T1,r2
	movw	$.F9,r3
	call	sp,Rload
	b	_PDMadd_parametric_part

	.globl	__PDMcreate_parm_ret_buffer
__PDMcreate_parm_ret_buffer:
	movw	$.T1,r2
	movw	$.F9,r3
	call	sp,Rload
	b	__PDMcreate_parm_ret_buffer

	.globl	_PDMinsert_rows_to_parm_cat
_PDMinsert_rows_to_parm_cat:
	movw	$.T1,r2
	movw	$.F9,r3
	call	sp,Rload
	b	_PDMinsert_rows_to_parm_cat

	.globl	__PDMadd_errrow_to_retbufr
__PDMadd_errrow_to_retbufr:
	movw	$.T1,r2
	movw	$.F9,r3
	call	sp,Rload
	b	__PDMadd_errrow_to_retbufr

	.globl	_PDMsadd_parametric_part_to_project
_PDMsadd_parametric_part_to_project:
	movw	$.T1,r2
	movw	$.F9,r3
	call	sp,Rload
	b	_PDMsadd_parametric_part_to_project

	.globl	__PDMget_data_type
__PDMget_data_type:
	movw	$.T1,r2
	movw	$.F9,r3
	call	sp,Rload
	b	__PDMget_data_type

	.globl	_PDMinsert_f_cat_rows
_PDMinsert_f_cat_rows:
	movw	$.T1,r2
	movw	$.F9,r3
	call	sp,Rload
	b	_PDMinsert_f_cat_rows

	.globl	_PDMdelete_parametric_parts
_PDMdelete_parametric_parts:
	movw	$.T1,r2
	movw	$.F9,r3
	call	sp,Rload
	b	_PDMdelete_parametric_parts

	.globl	_PDMdelete_parm_assy_entries_from_CIT
_PDMdelete_parm_assy_entries_from_CIT:
	movw	$.T1,r2
	movw	$.F9,r3
	call	sp,Rload
	b	_PDMdelete_parm_assy_entries_from_CIT

	.globl	_PDMmove_parametric_parts_to_next_state
_PDMmove_parametric_parts_to_next_state:
	movw	$.T1,r2
	movw	$.F9,r3
	call	sp,Rload
	b	_PDMmove_parametric_parts_to_next_state

	.globl	__PDMget_to_state
__PDMget_to_state:
	movw	$.T1,r2
	movw	$.F9,r3
	call	sp,Rload
	b	__PDMget_to_state

	.globl	__PDMget_uniq_no_list
__PDMget_uniq_no_list:
	movw	$.T1,r2
	movw	$.F9,r3
	call	sp,Rload
	b	__PDMget_uniq_no_list

	.globl	_PDMvalidate_parametric_part
_PDMvalidate_parametric_part:
	movw	$.T1,r2
	movw	$.F9,r3
	call	sp,Rload
	b	_PDMvalidate_parametric_part
#
# Begin stubs for:  PDMmod_part.o
#
	.data
	.align	4
.F10:	.long	0x00000700
	.byte	80, 68, 77, 109, 111, 100, 95, 112, 97, 114
	.byte	116, 46, 111, 0
	.text

	.globl	_PDMget_list_for_modify
_PDMget_list_for_modify:
	movw	$.T1,r2
	movw	$.F10,r3
	call	sp,Rload
	b	_PDMget_list_for_modify

	.globl	__PDMget_cit_childno
__PDMget_cit_childno:
	movw	$.T1,r2
	movw	$.F10,r3
	call	sp,Rload
	b	__PDMget_cit_childno

	.globl	_PDMupdate_parametric_parts
_PDMupdate_parametric_parts:
	movw	$.T1,r2
	movw	$.F10,r3
	call	sp,Rload
	b	_PDMupdate_parametric_parts

	.globl	_PDMupdate_rows_to_parm_cat
_PDMupdate_rows_to_parm_cat:
	movw	$.T1,r2
	movw	$.F10,r3
	call	sp,Rload
	b	_PDMupdate_rows_to_parm_cat

	.globl	__PDMconst_upd_str
__PDMconst_upd_str:
	movw	$.T1,r2
	movw	$.F10,r3
	call	sp,Rload
	b	__PDMconst_upd_str

	.globl	_PDMupdate_f_cat_rows
_PDMupdate_f_cat_rows:
	movw	$.T1,r2
	movw	$.F10,r3
	call	sp,Rload
	b	_PDMupdate_f_cat_rows

	.globl	_NFMchange_table
	.globl	_PDMget_catno_type
	.globl	_NFMdelete_loc_entry
	.globl	__NFMfree_linked_lists
	.globl	_SQLquery
	.globl	__NFMget_data_info
	.globl	_PDMload_partnos
	.globl	_NFMstart_transaction
	.globl	_NFMdelete_template
	.globl	_PDMstop_transaction
	.globl	_wait
	.globl	_PDMquery_itemno_assind
	.globl	_NFMupdate_project_members
	.globl	_PDMdynamic_table
	.globl	_MEMopen
	.globl	_strcpy
	.globl	_execl
	.globl	_strncpy
	.globl	_NFMreset_loc_entry
	.globl	_NFMquery_change_table_information
	.globl	_NFMascii_to_timestamp_format
	.globl	_PDMconvert_to_lower
	.globl	_PDU_form_id
	.globl	_SQLexec_imm
	.globl	_PDMinsert_nthlevel_dynamic_info
	.globl	_malloc
	.globl	_PDMquery_partno
	.globl	_PDMrollback_transaction
	.globl	_NFMdelete_catalog
	.globl	_NFMdelete_table
	.globl	_PDMparse_for_tic
	.globl	_free
	.globl	_MEMwrite
	.globl	_PDMupdate_fmgr_copy
	.globl	_NFMnew_file_name
	.globl	_NFMglobal
	.globl	_system
	.globl	__PDMdebug
	.globl	_SQLstmt
	.globl	_NFMupdate_loc_entry
	.globl	_errno
	.globl	_PDMcopy_atomic_file
	.globl	_PDMi_verify_catalog
	.globl	_PDMi_create_catalog
	.globl	_mktemp
	.globl	_stat
	.globl	_PDMi_create_pdc_table
	.globl	_NFMstop_transaction
	.globl	_MEMwrite_format
	.globl	_SVSFreeTablesAndColumns
	.globl	_PDMload_partno_filename
	.globl	_PDMcreate_fmgr_bufr
	.globl	_PDMdebug_on
	.globl	_NFMget_datetime
	.globl	_strncmp
	.globl	_storage
	.globl	_MEMsplit_copy_buffer
	.globl	__NFMbuild_working_buffer_format
	.globl	_MEMreset_buffer_no
	.globl	_strlen
	.globl	_WFinfo
	.globl	_strcat
	.globl	_NFMchange_template
	.globl	_PDMget_ris_datatype
	.globl	_NFMbuild_fto_buffer
	.globl	_WFload_catalog_no
	.globl	_PDMquery_assyind_parttype
	.globl	__PDMadd_errrow_to_retbufr
	.globl	__PDMcreate_parm_ret_buffer
	.globl	_strcmp
	.globl	__NFMget_catalog_acl_list
	.globl	_PDMquery_ass_struc
	.globl	_forms
	.globl	_NFMquery_changeto_loc_attributes
	.globl	_PDMload_set_members
	.globl	_WFload_catalog_name
	.globl	__NFMcreate_table
	.globl	_PDMget_table_no
	.globl	_PDMquery_catalog_partnos
	.globl	_PDMris_get_catno
	.globl	_memset
	.globl	_NFMquery_change_template_information
	.globl	_NFMsystem
	.globl	_PDMpart
	.globl	_exit
	.globl	_NFMsplit_template_attributes
	.globl	_NFMcreate_template
	.globl	_atol
	.globl	_atoi
	.globl	_NFMreset_change_table
	.globl	_vfork
	.globl	_PDMdebug
	.globl	_NFMcomplete_item_copy
	.globl	_NFMi_template
	.globl	_PDMi_find_cofilename
	.globl	_PDMi_query_familyno
	.globl	_MEMbuild_array
	.globl	_WFload_wf_struct_for_sts
	.globl	_MEMclose
	.globl	_PDMquery_catalogno
	.globl	_PDMi_query_families
	.globl	_PDMi_maxrow_no
	.globl	_calloc
	.globl	__PDMget_data_type
	.globl	_PDMstart_transaction
	.globl	_PDMi_find_datatype
	.globl	_SVSGetTablesAndColumnsInView
	.globl	_NFMadd_item
	.globl	_PDMset_n_setindicator
	.globl	__NFMget_attributes_from_query
	.globl	_PDMcheck_fmgr_attach
	.globl	_PDMexpand_copy_buffer
	.globl	_NFMcreate_table
	.globl	_MEMwrite_data
	.globl	_sprintf
	.globl	_PDMdron_setindicator
	.globl	_unlink
	.globl	_PDMquery_assembly_ind
	.globl	_PDMSQLquery
	.globl	_PDMcreate_dynamic_table
	.globl	_PDMris_get_pitemno
	.globl	_PDM_DEBUG_FILE
	.globl	_memccpy
	.globl	_NFMget_catalog_no
	.globl	__NFMload_attributes
	.globl	_PDMdelete_pdm_entries
	.globl	_PDMload_parentnos
	.globl	_NFMrollback_transaction
	.globl	_MEMprint_buffer
	.globl	_NFMlock_table
	.globl	_NFMget_storages_information
	.globl	_MEMprint_buffers
	.globl	_NFMcheck_catalog_empty
	.globl	__NFMcheck_cat_no_mapping
	.globl	_WFload_acl_st
	.globl	_NFMretrieve_values
	.globl	__NFMfs_undo_recv_files
	.globl	_NFMget_storage_info
	.globl	_PDMdyntable_for_catalog
	.globl	_NFMget_serial_slot
	.globl	__NFMfs_recv_files
	.globl	_PDMexec
	.globl	_PDMget_dyntable_for_catalog
	.globl	_NFMprepare_item_copy
