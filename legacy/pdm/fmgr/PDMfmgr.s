	.file	"PDMfmgr.s"
#
# Begin stubs for:  PDMfmgr_m.o
#
	.data
.T1:	.byte	80, 100, 117, 0
	.byte	112, 100, 109, 47, 102, 109, 103, 114, 0
	.align	4
.F1:	.long	0x00000700
	.byte	80, 68, 77, 102, 109, 103, 114, 95, 109, 46
	.byte	111, 0
	.text

	.globl	_PDMlist_local_files
_PDMlist_local_files:
	movw	$.T1,r2
	movw	$.F1,r3
	call	sp,Rload
	b	_PDMlist_local_files

	.globl	_PDMdelete_local_files
_PDMdelete_local_files:
	movw	$.T1,r2
	movw	$.F1,r3
	call	sp,Rload
	b	_PDMdelete_local_files

	.globl	_PDMchkin_files_of_user
_PDMchkin_files_of_user:
	movw	$.T1,r2
	movw	$.F1,r3
	call	sp,Rload
	b	_PDMchkin_files_of_user

	.globl	_PDMlist_chkout_files
_PDMlist_chkout_files:
	movw	$.T1,r2
	movw	$.F1,r3
	call	sp,Rload
	b	_PDMlist_chkout_files
#
# Begin stubs for:  PDMfmgr_f.o
#
	.data
	.align	4
.F2:	.long	0x00000700
	.byte	80, 68, 77, 102, 109, 103, 114, 95, 102, 46
	.byte	111, 0
	.text

	.globl	_PDMi_get_file_list
_PDMi_get_file_list:
	movw	$.T1,r2
	movw	$.F2,r3
	call	sp,Rload
	b	_PDMi_get_file_list

	.globl	_PDMasses_move_type
_PDMasses_move_type:
	movw	$.T1,r2
	movw	$.F2,r3
	call	sp,Rload
	b	_PDMasses_move_type

	.globl	_PDMi_set_fileco
_PDMi_set_fileco:
	movw	$.T1,r2
	movw	$.F2,r3
	call	sp,Rload
	b	_PDMi_set_fileco

	.globl	_PDMi_update_bufr_column
_PDMi_update_bufr_column:
	movw	$.T1,r2
	movw	$.F2,r3
	call	sp,Rload
	b	_PDMi_update_bufr_column

	.globl	_PDMshow_file_list
_PDMshow_file_list:
	movw	$.T1,r2
	movw	$.F2,r3
	call	sp,Rload
	b	_PDMshow_file_list

	.globl	__PDMclean_lfm_bufr
__PDMclean_lfm_bufr:
	movw	$.T1,r2
	movw	$.F2,r3
	call	sp,Rload
	b	__PDMclean_lfm_bufr

	.globl	_PDMsort_local_buffer
_PDMsort_local_buffer:
	movw	$.T1,r2
	movw	$.F2,r3
	call	sp,Rload
	b	_PDMsort_local_buffer

	.globl	_PDMdelete_file_list
_PDMdelete_file_list:
	movw	$.T1,r2
	movw	$.F2,r3
	call	sp,Rload
	b	_PDMdelete_file_list

	.globl	_PDMshow_chkout_files
_PDMshow_chkout_files:
	movw	$.T1,r2
	movw	$.F2,r3
	call	sp,Rload
	b	_PDMshow_chkout_files

	.globl	_PDMsort_checkout_buffer
_PDMsort_checkout_buffer:
	movw	$.T1,r2
	movw	$.F2,r3
	call	sp,Rload
	b	_PDMsort_checkout_buffer
#
# Begin stubs for:  PDMfmgr_in.o
#
	.data
	.align	4
.F3:	.long	0x00000700
	.byte	80, 68, 77, 102, 109, 103, 114, 95, 105, 110
	.byte	46, 111, 0
	.text

	.globl	_PDMchkin_file_transfers
_PDMchkin_file_transfers:
	movw	$.T1,r2
	movw	$.F3,r3
	call	sp,Rload
	b	_PDMchkin_file_transfers

	.globl	_PDMcheck_fmgr_chkin
_PDMcheck_fmgr_chkin:
	movw	$.T1,r2
	movw	$.F3,r3
	call	sp,Rload
	b	_PDMcheck_fmgr_chkin

	.globl	_PDMfmgr_dereferencing
_PDMfmgr_dereferencing:
	movw	$.T1,r2
	movw	$.F3,r3
	call	sp,Rload
	b	_PDMfmgr_dereferencing

	.globl	_PDMprocess_parametric_files
_PDMprocess_parametric_files:
	movw	$.T1,r2
	movw	$.F3,r3
	call	sp,Rload
	b	_PDMprocess_parametric_files

	.globl	_PDMupdate_fmgr_chkin
_PDMupdate_fmgr_chkin:
	movw	$.T1,r2
	movw	$.F3,r3
	call	sp,Rload
	b	_PDMupdate_fmgr_chkin

	.globl	_PDMcr_chkin_fmgrbufr
_PDMcr_chkin_fmgrbufr:
	movw	$.T1,r2
	movw	$.F3,r3
	call	sp,Rload
	b	_PDMcr_chkin_fmgrbufr

	.globl	_PDMpdu_delete_filelist
_PDMpdu_delete_filelist:
	movw	$.T1,r2
	movw	$.F3,r3
	call	sp,Rload
	b	_PDMpdu_delete_filelist
#
# Begin stubs for:  PDMfmgr_out.o
#
	.data
	.align	4
.F4:	.long	0x00000700
	.byte	80, 68, 77, 102, 109, 103, 114, 95, 111, 117
	.byte	116, 46, 111, 0
	.text

	.globl	_PDMchkout_file_transfers
_PDMchkout_file_transfers:
	movw	$.T1,r2
	movw	$.F4,r3
	call	sp,Rload
	b	_PDMchkout_file_transfers

	.globl	_PDMupdate_filemanager
_PDMupdate_filemanager:
	movw	$.T1,r2
	movw	$.F4,r3
	call	sp,Rload
	b	_PDMupdate_filemanager

	.globl	_PDMupdate_fmgrentry
_PDMupdate_fmgrentry:
	movw	$.T1,r2
	movw	$.F4,r3
	call	sp,Rload
	b	_PDMupdate_fmgrentry

	.globl	_PDMload_fmgrentry
_PDMload_fmgrentry:
	movw	$.T1,r2
	movw	$.F4,r3
	call	sp,Rload
	b	_PDMload_fmgrentry

	.globl	_PDMupdate_fmgrdates
_PDMupdate_fmgrdates:
	movw	$.T1,r2
	movw	$.F4,r3
	call	sp,Rload
	b	_PDMupdate_fmgrdates
#
# Begin stubs for:  PDMffmgr_out.o
#
	.data
	.align	4
.F5:	.long	0x00000700
	.byte	80, 68, 77, 102, 102, 109, 103, 114, 95, 111
	.byte	117, 116, 46, 111, 0
	.text

	.globl	_PDMload_fmgr_ris
_PDMload_fmgr_ris:
	movw	$.T1,r2
	movw	$.F5,r3
	call	sp,Rload
	b	_PDMload_fmgr_ris

	.globl	_PDMfmgr_increment
_PDMfmgr_increment:
	movw	$.T1,r2
	movw	$.F5,r3
	call	sp,Rload
	b	_PDMfmgr_increment

	.globl	_PDMfmgr_decrement
_PDMfmgr_decrement:
	movw	$.T1,r2
	movw	$.F5,r3
	call	sp,Rload
	b	_PDMfmgr_decrement
#
# Begin stubs for:  PDMffilemgr.o
#
	.data
	.align	4
.F6:	.long	0x00000700
	.byte	80, 68, 77, 102, 102, 105, 108, 101, 109, 103
	.byte	114, 46, 111, 0
	.text

	.globl	_PDMXchkout_file_transfers
_PDMXchkout_file_transfers:
	movw	$.T1,r2
	movw	$.F6,r3
	call	sp,Rload
	b	_PDMXchkout_file_transfers

	.globl	_PDMXupdate_filemanager
_PDMXupdate_filemanager:
	movw	$.T1,r2
	movw	$.F6,r3
	call	sp,Rload
	b	_PDMXupdate_filemanager

	.globl	_PDMXupdate_fmgrentry
_PDMXupdate_fmgrentry:
	movw	$.T1,r2
	movw	$.F6,r3
	call	sp,Rload
	b	_PDMXupdate_fmgrentry

	.globl	_PDMXload_fmgrentry
_PDMXload_fmgrentry:
	movw	$.T1,r2
	movw	$.F6,r3
	call	sp,Rload
	b	_PDMXload_fmgrentry

	.globl	_PDMXupdate_fmgrdates
_PDMXupdate_fmgrdates:
	movw	$.T1,r2
	movw	$.F6,r3
	call	sp,Rload
	b	_PDMXupdate_fmgrdates
#
# Begin stubs for:  PDMfmgr_cpy.o
#
	.data
	.align	4
.F7:	.long	0x00000700
	.byte	80, 68, 77, 102, 109, 103, 114, 95, 99, 112
	.byte	121, 46, 111, 0
	.text

	.globl	_PDMcopy_file_transfers
_PDMcopy_file_transfers:
	movw	$.T1,r2
	movw	$.F7,r3
	call	sp,Rload
	b	_PDMcopy_file_transfers

	.globl	_PDMupdate_fmgr_copy
_PDMupdate_fmgr_copy:
	movw	$.T1,r2
	movw	$.F7,r3
	call	sp,Rload
	b	_PDMupdate_fmgr_copy

	.globl	_PDMcheck_fmgr_copy
_PDMcheck_fmgr_copy:
	movw	$.T1,r2
	movw	$.F7,r3
	call	sp,Rload
	b	_PDMcheck_fmgr_copy

	.globl	_PDMcheck_fmgr_attach
_PDMcheck_fmgr_attach:
	movw	$.T1,r2
	movw	$.F7,r3
	call	sp,Rload
	b	_PDMcheck_fmgr_attach

	.globl	_PDMcreate_fmgr_bufr
_PDMcreate_fmgr_bufr:
	movw	$.T1,r2
	movw	$.F7,r3
	call	sp,Rload
	b	_PDMcreate_fmgr_bufr

	.globl	_PDMupdate_fmgr_copy_file
_PDMupdate_fmgr_copy_file:
	movw	$.T1,r2
	movw	$.F7,r3
	call	sp,Rload
	b	_PDMupdate_fmgr_copy_file

	.globl	_PDMcheck_if_child_before_fmgr_update
_PDMcheck_if_child_before_fmgr_update:
	movw	$.T1,r2
	movw	$.F7,r3
	call	sp,Rload
	b	_PDMcheck_if_child_before_fmgr_update

	.globl	_PDMupdate_fmgr_delete
_PDMupdate_fmgr_delete:
	movw	$.T1,r2
	movw	$.F7,r3
	call	sp,Rload
	b	_PDMupdate_fmgr_delete

	.globl	__PDMRetrySqlStmt
__PDMRetrySqlStmt:
	movw	$.T1,r2
	movw	$.F7,r3
	call	sp,Rload
	b	__PDMRetrySqlStmt

	.globl	_PDMcreate_delete_bufr
_PDMcreate_delete_bufr:
	movw	$.T1,r2
	movw	$.F7,r3
	call	sp,Rload
	b	_PDMcreate_delete_bufr

	.globl	_PDMdelete_filelist_pdu
_PDMdelete_filelist_pdu:
	movw	$.T1,r2
	movw	$.F7,r3
	call	sp,Rload
	b	_PDMdelete_filelist_pdu
#
# Begin stubs for:  PDMfmgr_fns.o
#
	.data
	.align	4
.F8:	.long	0x00000700
	.byte	80, 68, 77, 102, 109, 103, 114, 95, 102, 110
	.byte	115, 46, 111, 0
	.text

	.globl	_PDMi_find_storageno
_PDMi_find_storageno:
	movw	$.T1,r2
	movw	$.F8,r3
	call	sp,Rload
	b	_PDMi_find_storageno
#
# Begin stubs for:  PDMco_lfm.o
#
	.data
	.align	4
.F9:	.long	0x00000700
	.byte	80, 68, 77, 99, 111, 95, 108, 102, 109, 46
	.byte	111, 0
	.text

	.globl	_PDMget_fmgr_values
_PDMget_fmgr_values:
	movw	$.T1,r2
	movw	$.F9,r3
	call	sp,Rload
	b	_PDMget_fmgr_values

	.globl	_PDMall_files_moved
_PDMall_files_moved:
	movw	$.T1,r2
	movw	$.F9,r3
	call	sp,Rload
	b	_PDMall_files_moved

	.globl	_PDMmark_files_to_be_moved
_PDMmark_files_to_be_moved:
	movw	$.T1,r2
	movw	$.F9,r3
	call	sp,Rload
	b	_PDMmark_files_to_be_moved

	.globl	_PDMget_children_fmgr_entries
_PDMget_children_fmgr_entries:
	movw	$.T1,r2
	movw	$.F9,r3
	call	sp,Rload
	b	_PDMget_children_fmgr_entries

	.globl	_PDMget_children_fmgr_entries_for_cancelco
_PDMget_children_fmgr_entries_for_cancelco:
	movw	$.T1,r2
	movw	$.F9,r3
	call	sp,Rload
	b	_PDMget_children_fmgr_entries_for_cancelco
#
# Begin stubs for:  PDMco_updlfm.o
#
	.data
	.align	4
.F10:	.long	0x00000700
	.byte	80, 68, 77, 99, 111, 95, 117, 112, 100, 108
	.byte	102, 109, 46, 111, 0
	.text

	.globl	_PDMco_update_filemanager
_PDMco_update_filemanager:
	movw	$.T1,r2
	movw	$.F10,r3
	call	sp,Rload
	b	_PDMco_update_filemanager

	.globl	_PDMco_item_update_filemanager
_PDMco_item_update_filemanager:
	movw	$.T1,r2
	movw	$.F10,r3
	call	sp,Rload
	b	_PDMco_item_update_filemanager

	.globl	_PDMcancel_co_update_filemanager
_PDMcancel_co_update_filemanager:
	movw	$.T1,r2
	movw	$.F10,r3
	call	sp,Rload
	b	_PDMcancel_co_update_filemanager

	.globl	_PDMCoUpdateFilemgrForPart
_PDMCoUpdateFilemgrForPart:
	movw	$.T1,r2
	movw	$.F10,r3
	call	sp,Rload
	b	_PDMCoUpdateFilemgrForPart

	.globl	_PDMCancelCoUpdateFilemgrForPart
_PDMCancelCoUpdateFilemgrForPart:
	movw	$.T1,r2
	movw	$.F10,r3
	call	sp,Rload
	b	_PDMCancelCoUpdateFilemgrForPart

	.globl	_PDMCancelCoUpdateFilemgrForAssy
_PDMCancelCoUpdateFilemgrForAssy:
	movw	$.T1,r2
	movw	$.F10,r3
	call	sp,Rload
	b	_PDMCancelCoUpdateFilemgrForAssy

	.globl	_SQLquery
	.globl	_PDMload_partdata
	.globl	_NFMitem_files
	.globl	_PDMload_partnos
	.globl	_NFMstart_transaction
	.globl	_PDMi_get_cidate
	.globl	_PDMi_find_references
	.globl	_MEMopen
	.globl	_strcpy
	.globl	_PDMget_filenum
	.globl	_PDMcr_chkin_fmgrbufr
	.globl	_PDMconvert_to_lower
	.globl	_PDMget_children_fmgr_entries_for_cancelco
	.globl	_malloc
	.globl	_PDMget_max_filever_fname
	.globl	_free
	.globl	_MEMwrite
	.globl	__PDMdebug
	.globl	_SQLstmt
	.globl	_PDMi_find_maxtype
	.globl	_PDMi_find_nodeno
	.globl	__PDMprint_itementry
	.globl	_PDMi_get_file_list
	.globl	_PDMris_maxrow_no
	.globl	__PDMget_db_error
	.globl	_MEMwrite_format
	.globl	__PDMprint_fileentry
	.globl	_PDMdebug_on
	.globl	_strncmp
	.globl	_storage
	.globl	_MEMsplit_copy_buffer
	.globl	_PDUget_buffer_col
	.globl	_strlen
	.globl	_PDMi_find_fileno
	.globl	__PDMRetrySqlStmt
	.globl	_strcat
	.globl	_PDMi_set_fileco
	.globl	__pdm_status
	.globl	_strcmp
	.globl	_sleep
	.globl	_PDMquery_catalog_partnos
	.globl	_PDMris_get_catno
	.globl	_PDMpart
	.globl	_PDMget_attach_count
	.globl	_atol
	.globl	_atoi
	.globl	_PDMi_find_partnum
	.globl	_PDMdebug
	.globl	_PDMpdu_delete_filelist
	.globl	_PDMreset_dots
	.globl	_MEMbuild_array
	.globl	_MEMclose
	.globl	_PDMi_get_date
	.globl	_PDMupdate_fmgr_chkin
	.globl	_PDMi_maxrow_no
	.globl	_calloc
	.globl	_PDMupdate_dots
	.globl	__PDMget_cofilename_cprfnum
	.globl	_PDMfind_part_type
	.globl	_PDMfmgr_dereferencing
	.globl	_PDMi_find_sano
	.globl	_PDMexpand_copy_buffer
	.globl	_MEMwrite_data
	.globl	_PDMupdate_fmgr_delete
	.globl	_sprintf
	.globl	_PDUsetup_buffer
	.globl	_PDMshow_chkout_files
	.globl	_PDMris_stmt
	.globl	_PDMi_find_storageno
	.globl	_PDM_DEBUG_FILE
	.globl	_PDMload_part_info
	.globl	_PDUmessage
	.globl	_PDMprint_storage_area
	.globl	__PDMprint_setmember
	.globl	_PDMshow_file_list
	.globl	_PDUtranslate_message
	.globl	_glob_var
	.globl	_MEMprint_buffer
	.globl	_PDMexp_copy_bufr
	.globl	_PDMi_compare_dates
	.globl	_PDMset_offsets
	.globl	_PDMexec
