	.file	"PDMcicocp.s"
#
# Begin stubs for:  PDMcopy_f.o
#
	.data
.T1:	.byte	80, 100, 117, 0
	.byte	112, 100, 109, 47, 99, 105, 99, 111, 99, 112
	.byte	0
	.align	4
.F1:	.long	0x00000700
	.byte	80, 68, 77, 99, 111, 112, 121, 95, 102, 46
	.byte	111, 0
	.text

	.globl	_PDMcopy_assembly_files
_PDMcopy_assembly_files:
	movw	$.T1,r2
	movw	$.F1,r3
	call	sp,Rload
	b	_PDMcopy_assembly_files

	.globl	_PDMprocess_attachments
_PDMprocess_attachments:
	movw	$.T1,r2
	movw	$.F1,r3
	call	sp,Rload
	b	_PDMprocess_attachments

	.globl	_PDMsend_files
_PDMsend_files:
	movw	$.T1,r2
	movw	$.F1,r3
	call	sp,Rload
	b	_PDMsend_files

	.globl	_PDMcopy_atomic_file
_PDMcopy_atomic_file:
	movw	$.T1,r2
	movw	$.F1,r3
	call	sp,Rload
	b	_PDMcopy_atomic_file
#
# Begin stubs for:  PDMffast.o
#
	.data
	.align	4
.F2:	.long	0x00000700
	.byte	80, 68, 77, 102, 102, 97, 115, 116, 46, 111
	.byte	0
	.text

	.globl	_PDMcopy_attach
_PDMcopy_attach:
	movw	$.T1,r2
	movw	$.F2,r3
	call	sp,Rload
	b	_PDMcopy_attach

	.globl	_PDMload_copy_buffer
_PDMload_copy_buffer:
	movw	$.T1,r2
	movw	$.F2,r3
	call	sp,Rload
	b	_PDMload_copy_buffer

	.globl	_PDMcopy_atomic
_PDMcopy_atomic:
	movw	$.T1,r2
	movw	$.F2,r3
	call	sp,Rload
	b	_PDMcopy_atomic

	.globl	_PDMfcopy_assembly
_PDMfcopy_assembly:
	movw	$.T1,r2
	movw	$.F2,r3
	call	sp,Rload
	b	_PDMfcopy_assembly
#
# Begin stubs for:  PDMcopy_m.o
#
	.data
	.align	4
.F3:	.long	0x00000700
	.byte	80, 68, 77, 99, 111, 112, 121, 95, 109, 46
	.byte	111, 0
	.text

	.globl	_PDMscopy
_PDMscopy:
	movw	$.T1,r2
	movw	$.F3,r3
	call	sp,Rload
	b	_PDMscopy

	.globl	_PDMXcopy_attach
_PDMXcopy_attach:
	movw	$.T1,r2
	movw	$.F3,r3
	call	sp,Rload
	b	_PDMXcopy_attach

	.globl	_PDMdetach
_PDMdetach:
	movw	$.T1,r2
	movw	$.F3,r3
	call	sp,Rload
	b	_PDMdetach

	.globl	_PDMXcheck_dup_sa_fname
_PDMXcheck_dup_sa_fname:
	movw	$.T1,r2
	movw	$.F3,r3
	call	sp,Rload
	b	_PDMXcheck_dup_sa_fname
#
# Begin stubs for:  PDMassy_mem.o
#
	.data
	.align	4
.F4:	.long	0x00000700
	.byte	80, 68, 77, 97, 115, 115, 121, 95, 109, 101
	.byte	109, 46, 111, 0
	.text

	.globl	_PDMXXget_set_members
_PDMXXget_set_members:
	movw	$.T1,r2
	movw	$.F4,r3
	call	sp,Rload
	b	_PDMXXget_set_members

	.globl	__PDMprint_childinfo_struct1
__PDMprint_childinfo_struct1:
	movw	$.T1,r2
	movw	$.F4,r3
	call	sp,Rload
	b	__PDMprint_childinfo_struct1

	.globl	_PDMXXsort_linked_list
_PDMXXsort_linked_list:
	movw	$.T1,r2
	movw	$.F4,r3
	call	sp,Rload
	b	_PDMXXsort_linked_list

	.globl	_PDMXXfree_linked_list
_PDMXXfree_linked_list:
	movw	$.T1,r2
	movw	$.F4,r3
	call	sp,Rload
	b	_PDMXXfree_linked_list

	.globl	_PDMget_assy_members
_PDMget_assy_members:
	movw	$.T1,r2
	movw	$.F4,r3
	call	sp,Rload
	b	_PDMget_assy_members

	.globl	_PDMsort_set_member_list
_PDMsort_set_member_list:
	movw	$.T1,r2
	movw	$.F4,r3
	call	sp,Rload
	b	_PDMsort_set_member_list

	.globl	_PDMget_assy_members_for_cancel_part_co
_PDMget_assy_members_for_cancel_part_co:
	movw	$.T1,r2
	movw	$.F4,r3
	call	sp,Rload
	b	_PDMget_assy_members_for_cancel_part_co
#
# Begin stubs for:  PDMfunc1.o
#
	.data
	.align	4
.F5:	.long	0x00000700
	.byte	80, 68, 77, 102, 117, 110, 99, 49, 46, 111
	.byte	0
	.text

	.globl	_PDMXget_set_ci_files_info1
_PDMXget_set_ci_files_info1:
	movw	$.T1,r2
	movw	$.F5,r3
	call	sp,Rload
	b	_PDMXget_set_ci_files_info1

	.globl	_PDMXcheck_and_update_items_status1
_PDMXcheck_and_update_items_status1:
	movw	$.T1,r2
	movw	$.F5,r3
	call	sp,Rload
	b	_PDMXcheck_and_update_items_status1

	.globl	_PDMXset_colevel
_PDMXset_colevel:
	movw	$.T1,r2
	movw	$.F5,r3
	call	sp,Rload
	b	_PDMXset_colevel

	.globl	_PDMXget_children_info
_PDMXget_children_info:
	movw	$.T1,r2
	movw	$.F5,r3
	call	sp,Rload
	b	_PDMXget_children_info
#
# Begin stubs for:  PDMcp_files.o
#
	.data
	.align	4
.F6:	.long	0x00000700
	.byte	80, 68, 77, 99, 112, 95, 102, 105, 108, 101
	.byte	115, 46, 111, 0
	.text

	.globl	_PDMcopy_part_files
_PDMcopy_part_files:
	movw	$.T1,r2
	movw	$.F6,r3
	call	sp,Rload
	b	_PDMcopy_part_files
#
# Begin stubs for:  PDMfcopy_m.o
#
	.data
	.align	4
.F7:	.long	0x00000700
	.byte	80, 68, 77, 102, 99, 111, 112, 121, 95, 109
	.byte	46, 111, 0
	.text

	.globl	_PDMfcopy_attach
_PDMfcopy_attach:
	movw	$.T1,r2
	movw	$.F7,r3
	call	sp,Rload
	b	_PDMfcopy_attach

	.globl	_PDMcopy_file
_PDMcopy_file:
	movw	$.T1,r2
	movw	$.F7,r3
	call	sp,Rload
	b	_PDMcopy_file
#
# Begin stubs for:  PDMiteminfo.o
#
	.data
	.align	4
.F8:	.long	0x00000700
	.byte	80, 68, 77, 105, 116, 101, 109, 105, 110, 102
	.byte	111, 46, 111, 0
	.text

	.globl	_PDMXget_item_data_def_and_values1
_PDMXget_item_data_def_and_values1:
	movw	$.T1,r2
	movw	$.F8,r3
	call	sp,Rload
	b	_PDMXget_item_data_def_and_values1

	.globl	_PDMXget_items_data_def_values1
_PDMXget_items_data_def_values1:
	movw	$.T1,r2
	movw	$.F8,r3
	call	sp,Rload
	b	_PDMXget_items_data_def_values1
#
# Begin stubs for:  PDMn_ci.o
#
	.data
	.align	4
.F9:	.long	0x00000700
	.byte	80, 68, 77, 110, 95, 99, 105, 46, 111, 0
	.text

	.globl	_PDMcheckin_part
_PDMcheckin_part:
	movw	$.T1,r2
	movw	$.F9,r3
	call	sp,Rload
	b	_PDMcheckin_part

	.globl	_PDMcheckin_part1
_PDMcheckin_part1:
	movw	$.T1,r2
	movw	$.F9,r3
	call	sp,Rload
	b	_PDMcheckin_part1

	.globl	_PDMcheckin_case1
_PDMcheckin_case1:
	movw	$.T1,r2
	movw	$.F9,r3
	call	sp,Rload
	b	_PDMcheckin_case1

	.globl	_PDMcheckin_case2
_PDMcheckin_case2:
	movw	$.T1,r2
	movw	$.F9,r3
	call	sp,Rload
	b	_PDMcheckin_case2

	.globl	_PDMcheckin_case3
_PDMcheckin_case3:
	movw	$.T1,r2
	movw	$.F9,r3
	call	sp,Rload
	b	_PDMcheckin_case3

	.globl	_PDMcheckin_case4
_PDMcheckin_case4:
	movw	$.T1,r2
	movw	$.F9,r3
	call	sp,Rload
	b	_PDMcheckin_case4

	.globl	_PDMdelete_local_macros
_PDMdelete_local_macros:
	movw	$.T1,r2
	movw	$.F9,r3
	call	sp,Rload
	b	_PDMdelete_local_macros

	.globl	__PDMupdate_permission_change_bufr
__PDMupdate_permission_change_bufr:
	movw	$.T1,r2
	movw	$.F9,r3
	call	sp,Rload
	b	__PDMupdate_permission_change_bufr
#
# Begin stubs for:  PDMsettools.o
#
	.data
	.align	4
.F10:	.long	0x00000700
	.byte	80, 68, 77, 115, 101, 116, 116, 111, 111, 108
	.byte	115, 46, 111, 0
	.text

	.globl	_PDMretrieve_set_members
_PDMretrieve_set_members:
	movw	$.T1,r2
	movw	$.F10,r3
	call	sp,Rload
	b	_PDMretrieve_set_members

	.globl	_XPDMget_catalog_names
_XPDMget_catalog_names:
	movw	$.T1,r2
	movw	$.F10,r3
	call	sp,Rload
	b	_XPDMget_catalog_names

	.globl	_PDMXXretrieve_set_members
_PDMXXretrieve_set_members:
	movw	$.T1,r2
	movw	$.F10,r3
	call	sp,Rload
	b	_PDMXXretrieve_set_members

	.globl	_PDMXretrieve_set_members
_PDMXretrieve_set_members:
	movw	$.T1,r2
	movw	$.F10,r3
	call	sp,Rload
	b	_PDMXretrieve_set_members

	.globl	_PDMexp_retrieve_set_members
_PDMexp_retrieve_set_members:
	movw	$.T1,r2
	movw	$.F10,r3
	call	sp,Rload
	b	_PDMexp_retrieve_set_members

	.globl	_PDMcheck_and_add_cat
_PDMcheck_and_add_cat:
	movw	$.T1,r2
	movw	$.F10,r3
	call	sp,Rload
	b	_PDMcheck_and_add_cat
#
# Begin stubs for:  PDMexp_copy.o
#
	.data
	.align	4
.F11:	.long	0x00000700
	.byte	80, 68, 77, 101, 120, 112, 95, 99, 111, 112
	.byte	121, 46, 111, 0
	.text

	.globl	_PDMexp_copy_bufr
_PDMexp_copy_bufr:
	movw	$.T1,r2
	movw	$.F11,r3
	call	sp,Rload
	b	_PDMexp_copy_bufr
#
# Begin stubs for:  PDMsave_part.o
#
	.data
	.align	4
.F12:	.long	0x00000700
	.byte	80, 68, 77, 115, 97, 118, 101, 95, 112, 97
	.byte	114, 116, 46, 111, 0
	.text

	.globl	_PDMpost_to_database
_PDMpost_to_database:
	movw	$.T1,r2
	movw	$.F12,r3
	call	sp,Rload
	b	_PDMpost_to_database

	.globl	_PDMsave_part_case1
_PDMsave_part_case1:
	movw	$.T1,r2
	movw	$.F12,r3
	call	sp,Rload
	b	_PDMsave_part_case1

	.globl	_PDMsave_part_case2
_PDMsave_part_case2:
	movw	$.T1,r2
	movw	$.F12,r3
	call	sp,Rload
	b	_PDMsave_part_case2

	.globl	_PDMsave_part_case3
_PDMsave_part_case3:
	movw	$.T1,r2
	movw	$.F12,r3
	call	sp,Rload
	b	_PDMsave_part_case3

	.globl	_PDMsave_part_case4
_PDMsave_part_case4:
	movw	$.T1,r2
	movw	$.F12,r3
	call	sp,Rload
	b	_PDMsave_part_case4

	.globl	_PDMload_lfm_for_updatedb
_PDMload_lfm_for_updatedb:
	movw	$.T1,r2
	movw	$.F12,r3
	call	sp,Rload
	b	_PDMload_lfm_for_updatedb
#
# Begin stubs for:  PDMcipart.o
#
	.data
	.align	4
.F13:	.long	0x00000700
	.byte	80, 68, 77, 99, 105, 112, 97, 114, 116, 46
	.byte	111, 0
	.text

	.globl	_PDMcheckin_item
_PDMcheckin_item:
	movw	$.T1,r2
	movw	$.F13,r3
	call	sp,Rload
	b	_PDMcheckin_item
#
# Begin stubs for:  PDMCheckOut.o
#
	.data
	.align	4
.F14:	.long	0x00000700
	.byte	80, 68, 77, 67, 104, 101, 99, 107, 79, 117
	.byte	116, 46, 111, 0
	.text

	.globl	_PDMcheckout_part
_PDMcheckout_part:
	movw	$.T1,r2
	movw	$.F14,r3
	call	sp,Rload
	b	_PDMcheckout_part

	.globl	_PDMCheckoutPart
_PDMCheckoutPart:
	movw	$.T1,r2
	movw	$.F14,r3
	call	sp,Rload
	b	_PDMCheckoutPart

	.globl	_PDMcancel_checkout_part
_PDMcancel_checkout_part:
	movw	$.T1,r2
	movw	$.F14,r3
	call	sp,Rload
	b	_PDMcancel_checkout_part

	.globl	_PDMundo_part_file_co_changes
_PDMundo_part_file_co_changes:
	movw	$.T1,r2
	movw	$.F14,r3
	call	sp,Rload
	b	_PDMundo_part_file_co_changes

	.globl	_PDMCancelCheckoutPart
_PDMCancelCheckoutPart:
	movw	$.T1,r2
	movw	$.F14,r3
	call	sp,Rload
	b	_PDMCancelCheckoutPart

	.globl	_PDMRetrieveAssyFiles
_PDMRetrieveAssyFiles:
	movw	$.T1,r2
	movw	$.F14,r3
	call	sp,Rload
	b	_PDMRetrieveAssyFiles

	.globl	_PDMOLDCancelCheckoutPart
_PDMOLDCancelCheckoutPart:
	movw	$.T1,r2
	movw	$.F14,r3
	call	sp,Rload
	b	_PDMOLDCancelCheckoutPart

	.comm	_PDMwf_info,150
	.comm	_PDMlast_oper,4
	.comm	_PDMcat_list,4
	.comm	_PDMparam_cat_list,4
	.comm	_PDMend_cat_list,4
	.comm	_NFMmessage_buffer,4
	.comm	_PDMuser,25
	.comm	_PDMoperation,4
	.globl	_PDMset_parttype
	.globl	_PDMget_catno_type
	.globl	_NFMsave_item_files
	.globl	__NFMfree_linked_lists
	.globl	_SQLquery
	.globl	_PDMConvertToAtomic
	.globl	__NFMfs_undo_send_files
	.globl	_NFMitem_files
	.globl	_PDMload_partnos
	.globl	_NFMstart_transaction
	.globl	_PDMstop_transaction
	.globl	_NFMrm_co_files
	.globl	_PDMbuild_assembly
	.globl	_PDMupdate_set_members
	.globl	_NFMundo_microstation_set
	.globl	_NFMload_item_file_information
	.globl	__NFMstack_error_from_buffer
	.globl	_MEMopen
	.globl	_strcpy
	.globl	_PDMchildren_list
	.globl	_NFMcancel_item_copy
	.globl	_PDMquery_cit_attachment
	.globl	_PDMcr_chkin_fmgrbufr
	.globl	_PDMload_catno
	.globl	_NFMconvert_to_item
	.globl	_NFMquery_set_members
	.globl	_NFMdisconnect
	.globl	_strncpy
	.globl	__PDMprint_setinfo1_struct
	.globl	_ERRreset_struct
	.globl	_NFMascii_to_timestamp_format
	.globl	_PDMdelete_local_macros
	.globl	_PDMi_prepare_buffer1
	.globl	_malloc
	.globl	_PDMquery_partno
	.globl	_PDMrollback_transaction
	.globl	_NFMconvert_to_set
	.globl	_free
	.globl	_MEMwrite
	.globl	_PDMupdate_fmgr_copy
	.globl	_NFMnew_file_name
	.globl	_NFMglobal
	.globl	_ERRget_number
	.globl	_PDMassy_members
	.globl	_PDMfmgr_increment
	.globl	__PDMdebug
	.globl	_SQLstmt
	.globl	_PDMget_new_files
	.globl	_PDMupdate_filemanager
	.globl	_PDMcopy_atomic_file
	.globl	_PDMris_get_fmgr
	.globl	_PDMXXsa_info
	.globl	_stat
	.globl	_PDMval_part_for_copy
	.globl	_PDMsget_assembly_structure
	.globl	_NFMstop_transaction
	.globl	__NFMcleanup
	.globl	_PDMchild
	.globl	__PDMget_db_error
	.globl	__PDMupdate_permission_change_bufr
	.globl	_MEMwrite_format
	.globl	_PDMupdate_fmgr_copy_file
	.globl	_PDMcreate_fmgr_bufr
	.globl	_PDMget_storageno
	.globl	_PDMdebug_on
	.globl	_NFMget_datetime
	.globl	_strncmp
	.globl	_PDMdefine_parametric_assembly
	.globl	_storage
	.globl	_PDMlast_child
	.globl	_PDMsend_files
	.globl	_PDMload_child_info
	.globl	_PDMcopy_file_transfers
	.globl	_MEMsplit_copy_buffer
	.globl	__NFMbuild_working_buffer_format
	.globl	_strlen
	.globl	_WFinfo
	.globl	_NFMset_item_status
	.globl	_strcat
	.globl	_NFMbuild_fto_buffer
	.globl	_PDMquery_assyind_parttype
	.globl	_PDMquery_file_status
	.globl	_ERRget_specific_number
	.globl	_strcmp
	.globl	_UI_prompt
	.globl	_sleep
	.globl	__NFMfs_send_files
	.globl	_PDMquery_ass_struc
	.globl	_PDMverify_part
	.globl	_PDMcopy_file
	.globl	_PDMquery_catalog_partnos
	.globl	__NFMmv_files_out
	.globl	_PDMris_get_catno
	.globl	_NFMget_file_name
	.globl	_PDMCoUpdateFilemgrForPart
	.globl	_UI_status
	.globl	_PDMset_update_os_flag
	.globl	_NFMfs_purge
	.globl	_PDMCancelCoUpdateFilemgrForPart
	.globl	_PDMpart
	.globl	_ERRload_struct
	.globl	_NFMopen_message_buffer
	.globl	_atol
	.globl	_atoi
	.globl	_PDMparam_cat_list
	.globl	_PDMdebug
	.globl	_NFMcomplete_item_copy
	.globl	_PDMi_find_cofilename
	.globl	_PDMchkin_file_transfers
	.globl	_PDMpdu_delete_filelist
	.globl	_PDMdelete_filelist_pdu
	.globl	_PDMreset_dots
	.globl	_NFMget_sa_no_info
	.globl	_PDMinsert_citinfo
	.globl	_MEMbuild_array
	.globl	_PDMinsert_views
	.globl	_PDMdelete_bom
	.globl	_MEMclose
	.globl	__NFMdebug_function
	.globl	_PDMupdate_fmgr_chkin
	.globl	_PDMassy_mem_list
	.globl	_calloc
	.globl	_PDMcopy_part_files
	.globl	__NFMdebug_st
	.globl	_PDMstart_transaction
	.globl	_PDMupdate_dots
	.globl	__NFMmv_files_in
	.globl	_PDMset_n_setindicator
	.globl	_PDMquery_parttype
	.globl	_PDMexp_retrieve_set_members
	.globl	_PDMcheck_fmgr_attach
	.globl	_PDMcheck_fmgr_copy
	.globl	_PDMcopy_attach
	.globl	_MEMwrite_data
	.globl	_sprintf
	.globl	_PDMdron_setindicator
	.globl	_PDMquery_assembly_ind
	.globl	_PDUget_keyin
	.globl	_PDMcheckin_item
	.globl	_PDMi_find_storageno
	.globl	__NFMload_message
	.globl	_PDMload_fmgr_ris
	.globl	_PDMquery_bom_name
	.globl	_PDM_DEBUG_FILE
	.globl	_PDMload_part_info
	.globl	__NFMrollback_and_undo_buffer
	.globl	_PDMCancelCoUpdateFilemgrForAssy
	.globl	_PDUmessage
	.globl	_PDMprint_storage_area
	.globl	_PDMi_get_partnum_rev_type
	.globl	_NFMcheck_item
	.globl	__PDMprint_setmember
	.globl	_NFMbuild_microstation_set
	.globl	_PDUtranslate_message
	.globl	_glob_var
	.globl	_PDMattach_macro_library
	.globl	_NFMrollback_transaction
	.globl	_MEMprint_buffer
	.globl	_NFMlock_table
	.globl	_NFMget_storages_information
	.globl	_MEMprint_buffers
	.globl	_PDMreset_ncoout
	.globl	__NFMadd_temp_sa
	.globl	_PDMcat_list
	.globl	_PDMget_assembly_ind
	.globl	_PDMmodify_assembly
	.globl	_PDMexp_copy_bufr
	.globl	_NFMretrieve_values
	.globl	_PDMcheck_and_add_cat
	.globl	__NFMfs_undo_recv_files
	.globl	_NFMget_storage_info
	.globl	_MEMreset_buffer
	.globl	_PDMset_info_oper_struct
	.globl	_NFMfree_item_file_information
	.globl	__NFMfs_recv_files
	.globl	_PDMget_mul_file
	.globl	_PDMexec
	.globl	_NFMprepare_item_copy
