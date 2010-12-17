	.file	"PDMpdms.s"
#
# Begin stubs for:  PDMattr.o
#
	.data
.T1:	.byte	80, 100, 117, 0
	.byte	112, 100, 109, 47, 112, 100, 109, 115, 0
	.align	4
.F1:	.long	0x00000700
	.byte	80, 68, 77, 97, 116, 116, 114, 46, 111, 0
	.text

	.globl	_PDMsget_table_attributes
_PDMsget_table_attributes:
	movw	$.T1,r2
	movw	$.F1,r3
	call	sp,Rload
	b	_PDMsget_table_attributes

	.globl	_PDMcreate_application1
_PDMcreate_application1:
	movw	$.T1,r2
	movw	$.F1,r3
	call	sp,Rload
	b	_PDMcreate_application1

	.globl	_PDMcreate_application
_PDMcreate_application:
	movw	$.T1,r2
	movw	$.F1,r3
	call	sp,Rload
	b	_PDMcreate_application

	.globl	_PDMsget_table_data
_PDMsget_table_data:
	movw	$.T1,r2
	movw	$.F1,r3
	call	sp,Rload
	b	_PDMsget_table_data

	.globl	_PDMget_table_template
_PDMget_table_template:
	movw	$.T1,r2
	movw	$.F1,r3
	call	sp,Rload
	b	_PDMget_table_template

	.globl	_PDMquery_template_information
_PDMquery_template_information:
	movw	$.T1,r2
	movw	$.F1,r3
	call	sp,Rload
	b	_PDMquery_template_information

	.globl	_PDMsquery_table_definition
_PDMsquery_table_definition:
	movw	$.T1,r2
	movw	$.F1,r3
	call	sp,Rload
	b	_PDMsquery_table_definition

	.globl	_PDMquery_dynamic_attributes
_PDMquery_dynamic_attributes:
	movw	$.T1,r2
	movw	$.F1,r3
	call	sp,Rload
	b	_PDMquery_dynamic_attributes

	.globl	_PDMget_dyn_upd_attr
_PDMget_dyn_upd_attr:
	movw	$.T1,r2
	movw	$.F1,r3
	call	sp,Rload
	b	_PDMget_dyn_upd_attr

	.globl	_PDMget_pdcattr_buffer
_PDMget_pdcattr_buffer:
	movw	$.T1,r2
	movw	$.F1,r3
	call	sp,Rload
	b	_PDMget_pdcattr_buffer

	.globl	_PDMfast_query_table_def
_PDMfast_query_table_def:
	movw	$.T1,r2
	movw	$.F1,r3
	call	sp,Rload
	b	_PDMfast_query_table_def

	.globl	_PDMcreate_application_PDM0
_PDMcreate_application_PDM0:
	movw	$.T1,r2
	movw	$.F1,r3
	call	sp,Rload
	b	_PDMcreate_application_PDM0

	.globl	_PDMcreate_application2
_PDMcreate_application2:
	movw	$.T1,r2
	movw	$.F1,r3
	call	sp,Rload
	b	_PDMcreate_application2

	.globl	_PDMquery_dynamic_table_information
_PDMquery_dynamic_table_information:
	movw	$.T1,r2
	movw	$.F1,r3
	call	sp,Rload
	b	_PDMquery_dynamic_table_information

	.globl	_PDMsget_table_data1
_PDMsget_table_data1:
	movw	$.T1,r2
	movw	$.F1,r3
	call	sp,Rload
	b	_PDMsget_table_data1

	.globl	_PDMget_list_buffer
_PDMget_list_buffer:
	movw	$.T1,r2
	movw	$.F1,r3
	call	sp,Rload
	b	_PDMget_list_buffer
#
# Begin stubs for:  PDMcatalog.o
#
	.data
	.align	4
.F2:	.long	0x00000700
	.byte	80, 68, 77, 99, 97, 116, 97, 108, 111, 103
	.byte	46, 111, 0
	.text

	.globl	_PDMcreate_catalog
_PDMcreate_catalog:
	movw	$.T1,r2
	movw	$.F2,r3
	call	sp,Rload
	b	_PDMcreate_catalog

	.globl	_PDMi_create_catalog
_PDMi_create_catalog:
	movw	$.T1,r2
	movw	$.F2,r3
	call	sp,Rload
	b	_PDMi_create_catalog

	.globl	_PDMcreate_dynamic_table
_PDMcreate_dynamic_table:
	movw	$.T1,r2
	movw	$.F2,r3
	call	sp,Rload
	b	_PDMcreate_dynamic_table

	.globl	_PDMmodify_catalog
_PDMmodify_catalog:
	movw	$.T1,r2
	movw	$.F2,r3
	call	sp,Rload
	b	_PDMmodify_catalog

	.globl	_PDMdelete_catalog
_PDMdelete_catalog:
	movw	$.T1,r2
	movw	$.F2,r3
	call	sp,Rload
	b	_PDMdelete_catalog
#
# Begin stubs for:  PDMflag.o
#
	.data
	.align	4
.F3:	.long	0x00000700
	.byte	80, 68, 77, 102, 108, 97, 103, 46, 111, 0
	.text

	.globl	_PDMsflag_part_archive
_PDMsflag_part_archive:
	movw	$.T1,r2
	movw	$.F3,r3
	call	sp,Rload
	b	_PDMsflag_part_archive

	.globl	__PDMInterpretPendingFlag
__PDMInterpretPendingFlag:
	movw	$.T1,r2
	movw	$.F3,r3
	call	sp,Rload
	b	__PDMInterpretPendingFlag

	.globl	_PDMsflag_part_backup
_PDMsflag_part_backup:
	movw	$.T1,r2
	movw	$.F3,r3
	call	sp,Rload
	b	_PDMsflag_part_backup

	.globl	_PDMsflag_part_delete
_PDMsflag_part_delete:
	movw	$.T1,r2
	movw	$.F3,r3
	call	sp,Rload
	b	_PDMsflag_part_delete

	.globl	_PDMsflag_part_restore
_PDMsflag_part_restore:
	movw	$.T1,r2
	movw	$.F3,r3
	call	sp,Rload
	b	_PDMsflag_part_restore

	.globl	__PDMcheck_flag_status
__PDMcheck_flag_status:
	movw	$.T1,r2
	movw	$.F3,r3
	call	sp,Rload
	b	__PDMcheck_flag_status

	.globl	_PDMsUnflag_part_archive
_PDMsUnflag_part_archive:
	movw	$.T1,r2
	movw	$.F3,r3
	call	sp,Rload
	b	_PDMsUnflag_part_archive

	.globl	_PDMsUnflag_part_delete
_PDMsUnflag_part_delete:
	movw	$.T1,r2
	movw	$.F3,r3
	call	sp,Rload
	b	_PDMsUnflag_part_delete

	.globl	_PDMsUnflag_part_restore
_PDMsUnflag_part_restore:
	movw	$.T1,r2
	movw	$.F3,r3
	call	sp,Rload
	b	_PDMsUnflag_part_restore

	.globl	_PDMsUnflag_part_backup
_PDMsUnflag_part_backup:
	movw	$.T1,r2
	movw	$.F3,r3
	call	sp,Rload
	b	_PDMsUnflag_part_backup
#
# Begin stubs for:  PDMgr_asly.o
#
	.data
	.align	4
.F4:	.long	0x00000700
	.byte	80, 68, 77, 103, 114, 95, 97, 115, 108, 121
	.byte	46, 111, 0
	.text

	.globl	_PDMsdefine_assembly_structure
_PDMsdefine_assembly_structure:
	movw	$.T1,r2
	movw	$.F4,r3
	call	sp,Rload
	b	_PDMsdefine_assembly_structure

	.globl	_PDMload_parentnos
_PDMload_parentnos:
	movw	$.T1,r2
	movw	$.F4,r3
	call	sp,Rload
	b	_PDMload_parentnos

	.globl	_PDMcheck_cycles
_PDMcheck_cycles:
	movw	$.T1,r2
	movw	$.F4,r3
	call	sp,Rload
	b	_PDMcheck_cycles

	.globl	_PDMdron_setindicator
_PDMdron_setindicator:
	movw	$.T1,r2
	movw	$.F4,r3
	call	sp,Rload
	b	_PDMdron_setindicator

	.globl	_PDMload_set_members
_PDMload_set_members:
	movw	$.T1,r2
	movw	$.F4,r3
	call	sp,Rload
	b	_PDMload_set_members

	.globl	_PDMi_check_level
_PDMi_check_level:
	movw	$.T1,r2
	movw	$.F4,r3
	call	sp,Rload
	b	_PDMi_check_level

	.globl	_PDMwrite_2_cols
_PDMwrite_2_cols:
	movw	$.T1,r2
	movw	$.F4,r3
	call	sp,Rload
	b	_PDMwrite_2_cols

	.globl	_PDMload_citnos
_PDMload_citnos:
	movw	$.T1,r2
	movw	$.F4,r3
	call	sp,Rload
	b	_PDMload_citnos
#
# Begin stubs for:  PDMnlogin.o
#
	.data
	.align	4
.F5:	.long	0x00000700
	.byte	80, 68, 77, 110, 108, 111, 103, 105, 110, 46
	.byte	111, 0
	.text

	.globl	_PDMlogin
_PDMlogin:
	movw	$.T1,r2
	movw	$.F5,r3
	call	sp,Rload
	b	_PDMlogin

	.globl	_PDMreset_ris_env
_PDMreset_ris_env:
	movw	$.T1,r2
	movw	$.F5,r3
	call	sp,Rload
	b	_PDMreset_ris_env
#
# Begin stubs for:  PDMnet.o
#
	.data
	.align	4
.F6:	.long	0x00000700
	.byte	80, 68, 77, 110, 101, 116, 46, 111, 0
	.text

	.globl	_PDMverify_init
_PDMverify_init:
	movw	$.T1,r2
	movw	$.F6,r3
	call	sp,Rload
	b	_PDMverify_init

	.globl	_PDMterminate
_PDMterminate:
	movw	$.T1,r2
	movw	$.F6,r3
	call	sp,Rload
	b	_PDMterminate
#
# Begin stubs for:  PDMpart.o
#
	.data
	.align	4
.F7:	.long	0x00000700
	.byte	80, 68, 77, 112, 97, 114, 116, 46, 111, 0
	.text

	.globl	_PDMadd_part
_PDMadd_part:
	movw	$.T1,r2
	movw	$.F7,r3
	call	sp,Rload
	b	_PDMadd_part

	.globl	_PDMdelete_part
_PDMdelete_part:
	movw	$.T1,r2
	movw	$.F7,r3
	call	sp,Rload
	b	_PDMdelete_part

	.globl	_PDMdel_part
_PDMdel_part:
	movw	$.T1,r2
	movw	$.F7,r3
	call	sp,Rload
	b	_PDMdel_part

	.globl	_PDMscancel_modify_part
_PDMscancel_modify_part:
	movw	$.T1,r2
	movw	$.F7,r3
	call	sp,Rload
	b	_PDMscancel_modify_part

	.globl	_PDMsadd_part_to_project
_PDMsadd_part_to_project:
	movw	$.T1,r2
	movw	$.F7,r3
	call	sp,Rload
	b	_PDMsadd_part_to_project

	.globl	_PDMscheck_delete_part
_PDMscheck_delete_part:
	movw	$.T1,r2
	movw	$.F7,r3
	call	sp,Rload
	b	_PDMscheck_delete_part

	.globl	_PDMload_state_name
_PDMload_state_name:
	movw	$.T1,r2
	movw	$.F7,r3
	call	sp,Rload
	b	_PDMload_state_name

	.globl	_PDMcheck_for_delete_part
_PDMcheck_for_delete_part:
	movw	$.T1,r2
	movw	$.F7,r3
	call	sp,Rload
	b	_PDMcheck_for_delete_part

	.globl	_PDMreset_transfer_status
_PDMreset_transfer_status:
	movw	$.T1,r2
	movw	$.F7,r3
	call	sp,Rload
	b	_PDMreset_transfer_status
#
# Begin stubs for:  PDMpartstr.o
#
	.data
	.align	4
.F8:	.long	0x00000700
	.byte	80, 68, 77, 112, 97, 114, 116, 115, 116, 114
	.byte	46, 111, 0
	.text

	.globl	_PDMget_children_attachments
_PDMget_children_attachments:
	movw	$.T1,r2
	movw	$.F8,r3
	call	sp,Rload
	b	_PDMget_children_attachments

	.globl	_PDMmake_file_list
_PDMmake_file_list:
	movw	$.T1,r2
	movw	$.F8,r3
	call	sp,Rload
	b	_PDMmake_file_list

	.globl	_PDMmake_attach_bufr
_PDMmake_attach_bufr:
	movw	$.T1,r2
	movw	$.F8,r3
	call	sp,Rload
	b	_PDMmake_attach_bufr

	.globl	_PDMget_attach_count
_PDMget_attach_count:
	movw	$.T1,r2
	movw	$.F8,r3
	call	sp,Rload
	b	_PDMget_attach_count

	.globl	_PDMsshow_saved_views
_PDMsshow_saved_views:
	movw	$.T1,r2
	movw	$.F8,r3
	call	sp,Rload
	b	_PDMsshow_saved_views

	.globl	_PDMget_saved_views
_PDMget_saved_views:
	movw	$.T1,r2
	movw	$.F8,r3
	call	sp,Rload
	b	_PDMget_saved_views

	.globl	_PDMmodify_assembly
_PDMmodify_assembly:
	movw	$.T1,r2
	movw	$.F8,r3
	call	sp,Rload
	b	_PDMmodify_assembly
#
# Begin stubs for:  PDMs_rtns.o
#
	.data
	.align	4
.F9:	.long	0x00000700
	.byte	80, 68, 77, 115, 95, 114, 116, 110, 115, 46
	.byte	111, 0
	.text

	.globl	_PDMupdate_set_members
_PDMupdate_set_members:
	movw	$.T1,r2
	movw	$.F9,r3
	call	sp,Rload
	b	_PDMupdate_set_members

	.globl	_PDMdelete_pdm_entries
_PDMdelete_pdm_entries:
	movw	$.T1,r2
	movw	$.F9,r3
	call	sp,Rload
	b	_PDMdelete_pdm_entries

	.globl	_PDMadd_child
_PDMadd_child:
	movw	$.T1,r2
	movw	$.F9,r3
	call	sp,Rload
	b	_PDMadd_child

	.globl	_PDMinsert_citinfo
_PDMinsert_citinfo:
	movw	$.T1,r2
	movw	$.F9,r3
	call	sp,Rload
	b	_PDMinsert_citinfo

	.globl	_PDMi_delete_dynamic_info
_PDMi_delete_dynamic_info:
	movw	$.T1,r2
	movw	$.F9,r3
	call	sp,Rload
	b	_PDMi_delete_dynamic_info

	.globl	_PDMinsert_dynamic_table_info
_PDMinsert_dynamic_table_info:
	movw	$.T1,r2
	movw	$.F9,r3
	call	sp,Rload
	b	_PDMinsert_dynamic_table_info

	.globl	_PDMget_citno
_PDMget_citno:
	movw	$.T1,r2
	movw	$.F9,r3
	call	sp,Rload
	b	_PDMget_citno

	.globl	_PDMinsert_views
_PDMinsert_views:
	movw	$.T1,r2
	movw	$.F9,r3
	call	sp,Rload
	b	_PDMinsert_views

	.globl	_PDMConvertToAtomic
_PDMConvertToAtomic:
	movw	$.T1,r2
	movw	$.F9,r3
	call	sp,Rload
	b	_PDMConvertToAtomic
#
# Begin stubs for:  PDMsearch.o
#
	.data
	.align	4
.F10:	.long	0x00000700
	.byte	80, 68, 77, 115, 101, 97, 114, 99, 104, 46
	.byte	111, 0
	.text

	.globl	_PDMsearch_across_catalogs
_PDMsearch_across_catalogs:
	movw	$.T1,r2
	movw	$.F10,r3
	call	sp,Rload
	b	_PDMsearch_across_catalogs

	.globl	_PDMi_search_across_catalogs
_PDMi_search_across_catalogs:
	movw	$.T1,r2
	movw	$.F10,r3
	call	sp,Rload
	b	_PDMi_search_across_catalogs

	.globl	_PDMsearch_for_parts
_PDMsearch_for_parts:
	movw	$.T1,r2
	movw	$.F10,r3
	call	sp,Rload
	b	_PDMsearch_for_parts
#
# Begin stubs for:  PDMwf.o
#
	.data
	.align	4
.F11:	.long	0x00000700
	.byte	80, 68, 77, 119, 102, 46, 111, 0
	.text

	.globl	_PDMsvalidate_user_access
_PDMsvalidate_user_access:
	movw	$.T1,r2
	movw	$.F11,r3
	call	sp,Rload
	b	_PDMsvalidate_user_access

	.globl	_PDMadd_cmd
_PDMadd_cmd:
	movw	$.T1,r2
	movw	$.F11,r3
	call	sp,Rload
	b	_PDMadd_cmd

	.globl	_PDMvalidate_project
_PDMvalidate_project:
	movw	$.T1,r2
	movw	$.F11,r3
	call	sp,Rload
	b	_PDMvalidate_project

	.globl	_PDMvalidate_catalog
_PDMvalidate_catalog:
	movw	$.T1,r2
	movw	$.F11,r3
	call	sp,Rload
	b	_PDMvalidate_catalog

	.globl	_PDMvalidate_item
_PDMvalidate_item:
	movw	$.T1,r2
	movw	$.F11,r3
	call	sp,Rload
	b	_PDMvalidate_item

	.globl	_PDMvalidate_noentity
_PDMvalidate_noentity:
	movw	$.T1,r2
	movw	$.F11,r3
	call	sp,Rload
	b	_PDMvalidate_noentity

	.globl	_PDMsp_validate_project
_PDMsp_validate_project:
	movw	$.T1,r2
	movw	$.F11,r3
	call	sp,Rload
	b	_PDMsp_validate_project

	.globl	_PDMsp_validate_catalog
_PDMsp_validate_catalog:
	movw	$.T1,r2
	movw	$.F11,r3
	call	sp,Rload
	b	_PDMsp_validate_catalog

	.globl	_PDMsp_validate_item
_PDMsp_validate_item:
	movw	$.T1,r2
	movw	$.F11,r3
	call	sp,Rload
	b	_PDMsp_validate_item

	.globl	_PDMsp_validate_noentity
_PDMsp_validate_noentity:
	movw	$.T1,r2
	movw	$.F11,r3
	call	sp,Rload
	b	_PDMsp_validate_noentity

	.globl	_PDMsset_to_state
_PDMsset_to_state:
	movw	$.T1,r2
	movw	$.F11,r3
	call	sp,Rload
	b	_PDMsset_to_state

	.globl	_PDMi_backup_wfinfo
_PDMi_backup_wfinfo:
	movw	$.T1,r2
	movw	$.F11,r3
	call	sp,Rload
	b	_PDMi_backup_wfinfo

	.globl	_PDMi_restore_wfinfo
_PDMi_restore_wfinfo:
	movw	$.T1,r2
	movw	$.F11,r3
	call	sp,Rload
	b	_PDMi_restore_wfinfo

	.globl	_PDMmake_transition
_PDMmake_transition:
	movw	$.T1,r2
	movw	$.F11,r3
	call	sp,Rload
	b	_PDMmake_transition

	.globl	_PDMitem_val_in_unmapped_cat
_PDMitem_val_in_unmapped_cat:
	movw	$.T1,r2
	movw	$.F11,r3
	call	sp,Rload
	b	_PDMitem_val_in_unmapped_cat

	.globl	__PDMprint_nfm_global
__PDMprint_nfm_global:
	movw	$.T1,r2
	movw	$.F11,r3
	call	sp,Rload
	b	__PDMprint_nfm_global

	.globl	_PDMquery_make_transition
_PDMquery_make_transition:
	movw	$.T1,r2
	movw	$.F11,r3
	call	sp,Rload
	b	_PDMquery_make_transition

	.globl	__PDMload_wfinfo_for_make_transition
__PDMload_wfinfo_for_make_transition:
	movw	$.T1,r2
	movw	$.F11,r3
	call	sp,Rload
	b	__PDMload_wfinfo_for_make_transition

	.globl	_PDMsvalidate_user_access_cl
_PDMsvalidate_user_access_cl:
	movw	$.T1,r2
	movw	$.F11,r3
	call	sp,Rload
	b	_PDMsvalidate_user_access_cl
#
# Begin stubs for:  PDMloc_part.o
#
	.data
	.align	4
.F12:	.long	0x00000700
	.byte	80, 68, 77, 108, 111, 99, 95, 112, 97, 114
	.byte	116, 46, 111, 0
	.text

	.globl	_PDMlist_of_parts
_PDMlist_of_parts:
	movw	$.T1,r2
	movw	$.F12,r3
	call	sp,Rload
	b	_PDMlist_of_parts

	.globl	_PDMi_list_of_parts
_PDMi_list_of_parts:
	movw	$.T1,r2
	movw	$.F12,r3
	call	sp,Rload
	b	_PDMi_list_of_parts

	.globl	_PDMfind_entry_in_fmgr_bufr
_PDMfind_entry_in_fmgr_bufr:
	movw	$.T1,r2
	movw	$.F12,r3
	call	sp,Rload
	b	_PDMfind_entry_in_fmgr_bufr

	.globl	_PDMsearch_for_parts_in_project
_PDMsearch_for_parts_in_project:
	movw	$.T1,r2
	movw	$.F12,r3
	call	sp,Rload
	b	_PDMsearch_for_parts_in_project

	.globl	_PDMsearch_for_parts_in_project2
_PDMsearch_for_parts_in_project2:
	movw	$.T1,r2
	movw	$.F12,r3
	call	sp,Rload
	b	_PDMsearch_for_parts_in_project2

	.globl	_PDMsearch_for_parts_in_catalog
_PDMsearch_for_parts_in_catalog:
	movw	$.T1,r2
	movw	$.F12,r3
	call	sp,Rload
	b	_PDMsearch_for_parts_in_catalog

	.globl	_PDMexpand_parts_list
_PDMexpand_parts_list:
	movw	$.T1,r2
	movw	$.F12,r3
	call	sp,Rload
	b	_PDMexpand_parts_list
#
# Begin stubs for:  PDMcat_class.o
#
	.data
	.align	4
.F13:	.long	0x00000700
	.byte	80, 68, 77, 99, 97, 116, 95, 99, 108, 97
	.byte	115, 115, 46, 111, 0
	.text

	.globl	_PDMquery_classification
_PDMquery_classification:
	movw	$.T1,r2
	movw	$.F13,r3
	call	sp,Rload
	b	_PDMquery_classification

	.globl	_PDMget_class_of_cat
_PDMget_class_of_cat:
	movw	$.T1,r2
	movw	$.F13,r3
	call	sp,Rload
	b	_PDMget_class_of_cat

	.globl	_PDMget_pdmloc_levels
_PDMget_pdmloc_levels:
	movw	$.T1,r2
	movw	$.F13,r3
	call	sp,Rload
	b	_PDMget_pdmloc_levels

	.globl	_PDMget_usageid_cat
_PDMget_usageid_cat:
	movw	$.T1,r2
	movw	$.F13,r3
	call	sp,Rload
	b	_PDMget_usageid_cat

	.globl	_PDMtemplate_catalog_attributes
_PDMtemplate_catalog_attributes:
	movw	$.T1,r2
	movw	$.F13,r3
	call	sp,Rload
	b	_PDMtemplate_catalog_attributes

	.globl	_PDMstore_classification
_PDMstore_classification:
	movw	$.T1,r2
	movw	$.F13,r3
	call	sp,Rload
	b	_PDMstore_classification

	.globl	_PDMadd_more_levels
_PDMadd_more_levels:
	movw	$.T1,r2
	movw	$.F13,r3
	call	sp,Rload
	b	_PDMadd_more_levels
#
# Begin stubs for:  PDMcat_attr.o
#
	.data
	.align	4
.F14:	.long	0x00000700
	.byte	80, 68, 77, 99, 97, 116, 95, 97, 116, 116
	.byte	114, 46, 111, 0
	.text

	.globl	_PDMqry_catalog_attributes
_PDMqry_catalog_attributes:
	movw	$.T1,r2
	movw	$.F14,r3
	call	sp,Rload
	b	_PDMqry_catalog_attributes

	.globl	_PDMi_qry_catalog_attributes
_PDMi_qry_catalog_attributes:
	movw	$.T1,r2
	movw	$.F14,r3
	call	sp,Rload
	b	_PDMi_qry_catalog_attributes

	.globl	__PDMload_values_in_data_bufr
__PDMload_values_in_data_bufr:
	movw	$.T1,r2
	movw	$.F14,r3
	call	sp,Rload
	b	__PDMload_values_in_data_bufr

	.globl	__PDMload_default_vals_in_data_bufr
__PDMload_default_vals_in_data_bufr:
	movw	$.T1,r2
	movw	$.F14,r3
	call	sp,Rload
	b	__PDMload_default_vals_in_data_bufr

	.globl	_PDMquery_catalog_writable_attributes
_PDMquery_catalog_writable_attributes:
	movw	$.T1,r2
	movw	$.F14,r3
	call	sp,Rload
	b	_PDMquery_catalog_writable_attributes

	.globl	_PDMquery_catalog_readable_attributes
_PDMquery_catalog_readable_attributes:
	movw	$.T1,r2
	movw	$.F14,r3
	call	sp,Rload
	b	_PDMquery_catalog_readable_attributes

	.globl	_PDMquery_catalog_updatable_attributes
_PDMquery_catalog_updatable_attributes:
	movw	$.T1,r2
	movw	$.F14,r3
	call	sp,Rload
	b	_PDMquery_catalog_updatable_attributes

	.globl	_PDMOLDqry_catalog_attributes
_PDMOLDqry_catalog_attributes:
	movw	$.T1,r2
	movw	$.F14,r3
	call	sp,Rload
	b	_PDMOLDqry_catalog_attributes
#
# Begin stubs for:  PDMattr_func.o
#
	.data
	.align	4
.F15:	.long	0x00000700
	.byte	80, 68, 77, 97, 116, 116, 114, 95, 102, 117
	.byte	110, 99, 46, 111, 0
	.text

	.globl	_PDMmap_attribute_functions
_PDMmap_attribute_functions:
	movw	$.T1,r2
	movw	$.F15,r3
	call	sp,Rload
	b	_PDMmap_attribute_functions

	.globl	_PDMcopy_catalog_functions
_PDMcopy_catalog_functions:
	movw	$.T1,r2
	movw	$.F15,r3
	call	sp,Rload
	b	_PDMcopy_catalog_functions

	.globl	_PDMmove_functions
_PDMmove_functions:
	movw	$.T1,r2
	movw	$.F15,r3
	call	sp,Rload
	b	_PDMmove_functions

	.globl	_PDMdelete_functions
_PDMdelete_functions:
	movw	$.T1,r2
	movw	$.F15,r3
	call	sp,Rload
	b	_PDMdelete_functions

	.globl	_PDMquery_attribute_functions
_PDMquery_attribute_functions:
	movw	$.T1,r2
	movw	$.F15,r3
	call	sp,Rload
	b	_PDMquery_attribute_functions
#
# Begin stubs for:  PDMupd_mem.o
#
	.data
	.align	4
.F16:	.long	0x00000700
	.byte	80, 68, 77, 117, 112, 100, 95, 109, 101, 109
	.byte	46, 111, 0
	.text

	.globl	_PDMcheck_set_loop
_PDMcheck_set_loop:
	movw	$.T1,r2
	movw	$.F16,r3
	call	sp,Rload
	b	_PDMcheck_set_loop

	.globl	_PDMcheck_parent_loop
_PDMcheck_parent_loop:
	movw	$.T1,r2
	movw	$.F16,r3
	call	sp,Rload
	b	_PDMcheck_parent_loop
#
# Begin stubs for:  PDMwhr_usd.o
#
	.data
	.align	4
.F17:	.long	0x00000700
	.byte	80, 68, 77, 119, 104, 114, 95, 117, 115, 100
	.byte	46, 111, 0
	.text

	.globl	_PDMget_cit_parents
_PDMget_cit_parents:
	movw	$.T1,r2
	movw	$.F17,r3
	call	sp,Rload
	b	_PDMget_cit_parents

	.globl	_PDMget_list_partinfo
_PDMget_list_partinfo:
	movw	$.T1,r2
	movw	$.F17,r3
	call	sp,Rload
	b	_PDMget_list_partinfo

	.globl	_PDMget_cit_children
_PDMget_cit_children:
	movw	$.T1,r2
	movw	$.F17,r3
	call	sp,Rload
	b	_PDMget_cit_children

	.globl	_PDMget_imm_parents
_PDMget_imm_parents:
	movw	$.T1,r2
	movw	$.F17,r3
	call	sp,Rload
	b	_PDMget_imm_parents

	.comm	_sql_str,1024
	.comm	_PDMdynamic_table,20
	.globl	_NFMflag_item_delete
	.globl	_NFMchange_table
	.globl	_PDMget_catno_type
	.globl	_SQLquery
	.globl	_NFMquery_addto_loc_attributes
	.globl	_PDMquery_stateno
	.globl	_NFMcancel_update_item
	.globl	_PDMlogin_find_sainfo
	.globl	_PDMload_partnos
	.globl	_NFMstart_transaction
	.globl	_WFmake_transition
	.globl	_PDMstop_transaction
	.globl	_NFMcancel_set_flag
	.globl	_PDMquery_itemno_assind
	.globl	_RIS_parms_filename
	.globl	_NFMupdate_project_members
	.globl	_PDMdynamic_table
	.globl	_NFMquery_add_user_attributes
	.globl	_MEMopen
	.globl	_NFMflag_set_archive
	.globl	_strcpy
	.globl	_NFMquery_table_template
	.globl	_PDMquery_cit_attachment
	.globl	_PDMload_catno
	.globl	_NFMget_file_information
	.globl	_NFMquery_set_members
	.globl	_NFMquery_change_table_information
	.globl	_PDMget_state_aclno
	.globl	_PDMconvert_to_lower
	.globl	_NFMload_fto_buf
	.globl	_NFMquery_table_attributes
	.globl	_PDMget_attr_of_view
	.globl	__PDMinit_part_struct
	.globl	_PDMi_prepare_buffer1
	.globl	_malloc
	.globl	_PDMquery_partno
	.globl	__PDMadd_cols_to_attr_bufr
	.globl	_PDMrollback_transaction
	.globl	_NFMdelete_catalog
	.globl	_NFMdelete_table
	.globl	_free
	.globl	_MEMwrite
	.globl	_NFMreturn_serial_slot
	.globl	_ERRget_specific_message
	.globl	_NFMreset_file_information
	.globl	_NFMquery_catalog_definition
	.globl	_NFMglobal
	.globl	__PDMdebug
	.globl	_SQLstmt
	.globl	_NFMlogoff
	.globl	_NFMset_autocommit_on
	.globl	_errno
	.globl	_strdup
	.globl	_NFMcancel_item_flag
	.globl	_putenv
	.globl	_NFMflag_item_restore
	.globl	_NFMchange_catalog
	.globl	_NFMquery_item_attributes
	.globl	_PDU_IS_LOGGED_IN
	.globl	_NFMquery_table_definition
	.globl	_stat
	.globl	_PDMget_commandno
	.globl	__iob
	.globl	_PDUcleanup_local_filemgr
	.globl	_NFMstop_transaction
	.globl	__PDMget_db_error
	.globl	_NFMflag_item_archive
	.globl	_MEMwrite_format
	.globl	_NFMquery_template_attributes
	.globl	_PDMdebug_on
	.globl	__PDMload_datalist_bufr
	.globl	_strncmp
	.globl	_NFMpre_execute_process
	.globl	_storage
	.globl	_PDMris_get_catname
	.globl	_NFMquery_change_catalog_information
	.globl	_PDMsvalidate_user_access_cl
	.globl	_PDMQueryAssyIndPFlag
	.globl	_MEMsplit_copy_buffer
	.globl	_NFMcreate_catalog
	.globl	_MEMreset_buffer_no
	.globl	_NFM_PL_LOCK
	.globl	_strlen
	.globl	_NFMsearch_across_catalogs
	.globl	_WFinfo
	.globl	_PDMgen_table_name
	.globl	_strcat
	.globl	_NFMquery_template_definition
	.globl	_NFMflag_item_backup
	.globl	_PDMfree_query_info_struct
	.globl	_NFMbuild_fto_buffer
	.globl	_ERRget_specific_number
	.globl	_strcmp
	.globl	_sleep
	.globl	_NFMquery_changeto_loc_attributes
	.globl	_NFMset_autocommit_off
	.globl	_PDMverify_part
	.globl	_NFMflag_set_backup
	.globl	__NFMget_sano_info_fto_buf
	.globl	_NFMquery_project_members
	.globl	__NFMget_table_attr
	.globl	_PDMget_table_no
	.globl	_PDMquery_catalog_partnos
	.globl	_PDMris_get_catno
	.globl	_memset
	.globl	_NFMget_file_name
	.globl	_PDMquery_bom_attachment
	.globl	_NFMquery_change_template_information
	.globl	_UI_status
	.globl	_PDMpart
	.globl	_NFMlog_in
	.globl	_ERRload_struct
	.globl	_NFMdelete_item
	.globl	_PDMdelete_functions
	.globl	_RISget_schema_file_location
	.globl	_PDMget_workflowno
	.globl	__NFMcheck_item_condition_make_transition
	.globl	_PDMquery_make_transition
	.globl	_atol
	.globl	_atoi
	.globl	_NFMreset_change_table
	.globl	_PDMdebug
	.globl	_sscanf
	.globl	_PDMexpand_parts_list
	.globl	_NFMquery_catalog_information
	.globl	_PDMinit_query_info_struct
	.globl	_PDMi_find_cofilename
	.globl	_PDMquery_parm_catalog_attributes
	.globl	_PDMreset_dots
	.globl	_MEMbuild_array
	.globl	_NFMfs_chg_files
	.globl	_PDUfill_in_string
	.globl	_PDMdelete_bom
	.globl	_MEMclose
	.globl	_NFMquery_loc_definition
	.globl	_PDMi_maxrow_no
	.globl	__PDMget_data_type
	.globl	_PDMstart_transaction
	.globl	_fprintf
	.globl	_NFMset_wf_state
	.globl	_PDMupdate_dots
	.globl	_NFMadd_item
	.globl	_PDMset_n_setindicator
	.globl	_PDMris_get_projectno
	.globl	_PDMcount_bom_attachments
	.globl	_PDMquery_parttype
	.globl	_PDMquery_catalogno_type
	.globl	_dba_support
	.globl	_PDMexpand_copy_buffer
	.globl	_PDMsano_to_name
	.globl	_NFMretrieve_query
	.globl	_NFMcreate_table
	.globl	_MEMwrite_data
	.globl	_sprintf
	.globl	_PDMdron_setindicator
	.globl	_unlink
	.globl	_PDMquery_assembly_ind
	.globl	_PDMparse_for_illegal_char
	.globl	_PDMquery_table_no
	.globl	_PDMSQLquery
	.globl	_PDMload_state_name
	.globl	_PDMquery_bom_name
	.globl	_PDMi_find_storageno_name
	.globl	_PDMris_get_pitemno
	.globl	_PDM_DEBUG_FILE
	.globl	_PDMload_part_info
	.globl	_PDUmessage
	.globl	_PDMprint_storage_area
	.globl	_PDMi_get_partnum_rev_desc
	.globl	_NFMquery_catalog_template_n
	.globl	__WFinit_wfinfo
	.globl	_PDUtranslate_message
	.globl	_glob_var
	.globl	__NFMget_data_value
	.globl	_NFMrollback_transaction
	.globl	_NFMprepare_update_item
	.globl	_MEMprint_buffer
	.globl	_MEMprint_buffers
	.globl	__PDMload_defaults
	.globl	__NFMadd_temp_sa
	.globl	_getenv
	.globl	_NFMquery_catalog_attributes
	.globl	_PDMfind_p_explode
	.globl	_NFMflag_set_restore
	.globl	_NFMretrieve_values
	.globl	_NFMprint_wfinfo
	.globl	_NFMquery_add_item_attributes
	.globl	__NFMfs_undo_recv_files
	.globl	_NFMget_storage_info
	.globl	_PDMquery_catalogtype_no
	.globl	_PDMdyntable_for_catalog
	.globl	__NFMfs_recv_files
	.globl	_MEMappend
	.globl	_PDMexec
	.globl	_PDMget_dyntable_for_catalog
	.globl	_NFMdefine_file_information
