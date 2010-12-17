	.file	"PDUpdmr.s"
#
# Begin stubs for:  PDMrassy.o
#
	.data
.T1:	.byte	80, 100, 117, 0
	.byte	47, 112, 100, 117, 47, 112, 100, 109, 114, 0
	.align	4
.F1:	.long	0x00000700
	.byte	80, 68, 77, 114, 97, 115, 115, 121, 46, 111
	.byte	0
	.text

	.globl	_PDMget_assembly_structure
_PDMget_assembly_structure:
	movw	$.T1,r2
	movw	$.F1,r3
	call	sp,Rload
	b	_PDMget_assembly_structure

	.globl	_PDMdefine_assembly_structure
_PDMdefine_assembly_structure:
	movw	$.T1,r2
	movw	$.F1,r3
	call	sp,Rload
	b	_PDMdefine_assembly_structure

	.globl	_PDMrget_cit_children
_PDMrget_cit_children:
	movw	$.T1,r2
	movw	$.F1,r3
	call	sp,Rload
	b	_PDMrget_cit_children

	.globl	_PDMrget_cit_parents
_PDMrget_cit_parents:
	movw	$.T1,r2
	movw	$.F1,r3
	call	sp,Rload
	b	_PDMrget_cit_parents
#
# Begin stubs for:  PDMrattr.o
#
	.data
	.align	4
.F2:	.long	0x00000700
	.byte	80, 68, 77, 114, 97, 116, 116, 114, 46, 111
	.byte	0
	.text

	.globl	_PDMget_table_attributes
_PDMget_table_attributes:
	movw	$.T1,r2
	movw	$.F2,r3
	call	sp,Rload
	b	_PDMget_table_attributes

	.globl	_PDMget_table_data
_PDMget_table_data:
	movw	$.T1,r2
	movw	$.F2,r3
	call	sp,Rload
	b	_PDMget_table_data

	.globl	_PDMquery_table_definition
_PDMquery_table_definition:
	movw	$.T1,r2
	movw	$.F2,r3
	call	sp,Rload
	b	_PDMquery_table_definition

	.globl	_PDMquery_fast_table_definition
_PDMquery_fast_table_definition:
	movw	$.T1,r2
	movw	$.F2,r3
	call	sp,Rload
	b	_PDMquery_fast_table_definition
#
# Begin stubs for:  PDMrbom.o
#
	.data
	.align	4
.F3:	.long	0x00000700
	.byte	80, 68, 77, 114, 98, 111, 109, 46, 111, 0
	.text

	.globl	_PDMmodify_bom_content
_PDMmodify_bom_content:
	movw	$.T1,r2
	movw	$.F3,r3
	call	sp,Rload
	b	_PDMmodify_bom_content

	.globl	_PDMget_bommap_attributes
_PDMget_bommap_attributes:
	movw	$.T1,r2
	movw	$.F3,r3
	call	sp,Rload
	b	_PDMget_bommap_attributes

	.globl	_PDMrdelete_bom
_PDMrdelete_bom:
	movw	$.T1,r2
	movw	$.F3,r3
	call	sp,Rload
	b	_PDMrdelete_bom

	.globl	_PDMprepare_bomparts_list
_PDMprepare_bomparts_list:
	movw	$.T1,r2
	movw	$.F3,r3
	call	sp,Rload
	b	_PDMprepare_bomparts_list

	.globl	_PDMprepare_summary_bom
_PDMprepare_summary_bom:
	movw	$.T1,r2
	movw	$.F3,r3
	call	sp,Rload
	b	_PDMprepare_summary_bom

	.globl	_PDMprepare_explode_summary_bom
_PDMprepare_explode_summary_bom:
	movw	$.T1,r2
	movw	$.F3,r3
	call	sp,Rload
	b	_PDMprepare_explode_summary_bom

	.globl	_PDMgen_where_used_imm
_PDMgen_where_used_imm:
	movw	$.T1,r2
	movw	$.F3,r3
	call	sp,Rload
	b	_PDMgen_where_used_imm

	.globl	_PDMgen_where_used_top
_PDMgen_where_used_top:
	movw	$.T1,r2
	movw	$.F3,r3
	call	sp,Rload
	b	_PDMgen_where_used_top

	.globl	_PDMgen_bom_report
_PDMgen_bom_report:
	movw	$.T1,r2
	movw	$.F3,r3
	call	sp,Rload
	b	_PDMgen_bom_report

	.globl	_PDMrupdate_bom
_PDMrupdate_bom:
	movw	$.T1,r2
	movw	$.F3,r3
	call	sp,Rload
	b	_PDMrupdate_bom
#
# Begin stubs for:  PDMrcanchko.o
#
	.data
	.align	4
.F4:	.long	0x00000700
	.byte	80, 68, 77, 114, 99, 97, 110, 99, 104, 107
	.byte	111, 46, 111, 0
	.text

	.globl	_PDMrcancel_checkout_part
_PDMrcancel_checkout_part:
	movw	$.T1,r2
	movw	$.F4,r3
	call	sp,Rload
	b	_PDMrcancel_checkout_part
#
# Begin stubs for:  PDMrcatalog.o
#
	.data
	.align	4
.F5:	.long	0x00000700
	.byte	80, 68, 77, 114, 99, 97, 116, 97, 108, 111
	.byte	103, 46, 111, 0
	.text

	.globl	_PDMrcreate_catalog
_PDMrcreate_catalog:
	movw	$.T1,r2
	movw	$.F5,r3
	call	sp,Rload
	b	_PDMrcreate_catalog

	.globl	_PDMrmodify_catalog
_PDMrmodify_catalog:
	movw	$.T1,r2
	movw	$.F5,r3
	call	sp,Rload
	b	_PDMrmodify_catalog

	.globl	_PDMrdelete_catalog
_PDMrdelete_catalog:
	movw	$.T1,r2
	movw	$.F5,r3
	call	sp,Rload
	b	_PDMrdelete_catalog

	.globl	_PDMcatalog_acls
_PDMcatalog_acls:
	movw	$.T1,r2
	movw	$.F5,r3
	call	sp,Rload
	b	_PDMcatalog_acls

	.globl	_PDMget_dynamic_attributes
_PDMget_dynamic_attributes:
	movw	$.T1,r2
	movw	$.F5,r3
	call	sp,Rload
	b	_PDMget_dynamic_attributes
#
# Begin stubs for:  PDMrchkin.o
#
	.data
	.align	4
.F6:	.long	0x00000700
	.byte	80, 68, 77, 114, 99, 104, 107, 105, 110, 46
	.byte	111, 0
	.text

	.globl	_PDMrcheckin_part
_PDMrcheckin_part:
	movw	$.T1,r2
	movw	$.F6,r3
	call	sp,Rload
	b	_PDMrcheckin_part
#
# Begin stubs for:  PDMrchkout.o
#
	.data
	.align	4
.F7:	.long	0x00000700
	.byte	80, 68, 77, 114, 99, 104, 107, 111, 117, 116
	.byte	46, 111, 0
	.text

	.globl	_PDMrcheckout_part
_PDMrcheckout_part:
	movw	$.T1,r2
	movw	$.F7,r3
	call	sp,Rload
	b	_PDMrcheckout_part
#
# Begin stubs for:  PDMrcopy.o
#
	.data
	.align	4
.F8:	.long	0x00000700
	.byte	80, 68, 77, 114, 99, 111, 112, 121, 46, 111
	.byte	0
	.text

	.globl	_PDMcopy
_PDMcopy:
	movw	$.T1,r2
	movw	$.F8,r3
	call	sp,Rload
	b	_PDMcopy

	.globl	_PDMrcopy_attach
_PDMrcopy_attach:
	movw	$.T1,r2
	movw	$.F8,r3
	call	sp,Rload
	b	_PDMrcopy_attach
#
# Begin stubs for:  PDMrdebug.o
#
	.data
	.align	4
.F9:	.long	0x00000700
	.byte	80, 68, 77, 114, 100, 101, 98, 117, 103, 46
	.byte	111, 0
	.text

	.globl	_PDUdebug_on_off
_PDUdebug_on_off:
	movw	$.T1,r2
	movw	$.F9,r3
	call	sp,Rload
	b	_PDUdebug_on_off
#
# Begin stubs for:  PDMrdetach.o
#
	.data
	.align	4
.F10:	.long	0x00000700
	.byte	80, 68, 77, 114, 100, 101, 116, 97, 99, 104
	.byte	46, 111, 0
	.text

	.globl	_PDMdetach_part
_PDMdetach_part:
	movw	$.T1,r2
	movw	$.F10,r3
	call	sp,Rload
	b	_PDMdetach_part
#
# Begin stubs for:  PDMrdyn_part.o
#
	.data
	.align	4
.F11:	.long	0x00000700
	.byte	80, 68, 77, 114, 100, 121, 110, 95, 112, 97
	.byte	114, 116, 46, 111, 0
	.text

	.globl	_PDMget_dyn_attr_names
_PDMget_dyn_attr_names:
	movw	$.T1,r2
	movw	$.F11,r3
	call	sp,Rload
	b	_PDMget_dyn_attr_names
#
# Begin stubs for:  PDMrflag.o
#
	.data
	.align	4
.F12:	.long	0x00000700
	.byte	80, 68, 77, 114, 102, 108, 97, 103, 46, 111
	.byte	0
	.text

	.globl	_PDMflag_part_archive
_PDMflag_part_archive:
	movw	$.T1,r2
	movw	$.F12,r3
	call	sp,Rload
	b	_PDMflag_part_archive

	.globl	_PDMflag_part_backup
_PDMflag_part_backup:
	movw	$.T1,r2
	movw	$.F12,r3
	call	sp,Rload
	b	_PDMflag_part_backup

	.globl	_PDMflag_part_delete
_PDMflag_part_delete:
	movw	$.T1,r2
	movw	$.F12,r3
	call	sp,Rload
	b	_PDMflag_part_delete

	.globl	_PDMflag_part_restore
_PDMflag_part_restore:
	movw	$.T1,r2
	movw	$.F12,r3
	call	sp,Rload
	b	_PDMflag_part_restore

	.globl	_PDMUnflag_part_archive
_PDMUnflag_part_archive:
	movw	$.T1,r2
	movw	$.F12,r3
	call	sp,Rload
	b	_PDMUnflag_part_archive

	.globl	_PDMUnflag_part_delete
_PDMUnflag_part_delete:
	movw	$.T1,r2
	movw	$.F12,r3
	call	sp,Rload
	b	_PDMUnflag_part_delete

	.globl	_PDMUnflag_part_restore
_PDMUnflag_part_restore:
	movw	$.T1,r2
	movw	$.F12,r3
	call	sp,Rload
	b	_PDMUnflag_part_restore

	.globl	_PDMUnflag_part_backup
_PDMUnflag_part_backup:
	movw	$.T1,r2
	movw	$.F12,r3
	call	sp,Rload
	b	_PDMUnflag_part_backup
#
# Begin stubs for:  PDMrfmgr.o
#
	.data
	.align	4
.F13:	.long	0x00000700
	.byte	80, 68, 77, 114, 102, 109, 103, 114, 46, 111
	.byte	0
	.text

	.globl	_PDMrlist_local_files
_PDMrlist_local_files:
	movw	$.T1,r2
	movw	$.F13,r3
	call	sp,Rload
	b	_PDMrlist_local_files

	.globl	_PDMlist_checkedout_files
_PDMlist_checkedout_files:
	movw	$.T1,r2
	movw	$.F13,r3
	call	sp,Rload
	b	_PDMlist_checkedout_files

	.globl	_PDMlist_checkedin_files
_PDMlist_checkedin_files:
	movw	$.T1,r2
	movw	$.F13,r3
	call	sp,Rload
	b	_PDMlist_checkedin_files

	.globl	_PDMrdelete_local_files
_PDMrdelete_local_files:
	movw	$.T1,r2
	movw	$.F13,r3
	call	sp,Rload
	b	_PDMrdelete_local_files

	.globl	_PDMget_state
_PDMget_state:
	movw	$.T1,r2
	movw	$.F13,r3
	call	sp,Rload
	b	_PDMget_state

	.globl	_PDMrcheck_part_status
_PDMrcheck_part_status:
	movw	$.T1,r2
	movw	$.F13,r3
	call	sp,Rload
	b	_PDMrcheck_part_status
#
# Begin stubs for:  PDMrmisc.o
#
	.data
	.align	4
.F14:	.long	0x00000700
	.byte	80, 68, 77, 114, 109, 105, 115, 99, 46, 111
	.byte	0
	.text

	.globl	_PDMget_catno_partno
_PDMget_catno_partno:
	movw	$.T1,r2
	movw	$.F14,r3
	call	sp,Rload
	b	_PDMget_catno_partno
#
# Begin stubs for:  PDMrnfm_rpts.o
#
	.data
	.align	4
.F15:	.long	0x00000700
	.byte	80, 68, 77, 114, 110, 102, 109, 95, 114, 112
	.byte	116, 115, 46, 111, 0
	.text

	.globl	_PDMlist_reports
_PDMlist_reports:
	movw	$.T1,r2
	movw	$.F15,r3
	call	sp,Rload
	b	_PDMlist_reports
#
# Begin stubs for:  PDMrpart.o
#
	.data
	.align	4
.F16:	.long	0x00000700
	.byte	80, 68, 77, 114, 112, 97, 114, 116, 46, 111
	.byte	0
	.text

	.globl	_PDMradd_part
_PDMradd_part:
	movw	$.T1,r2
	movw	$.F16,r3
	call	sp,Rload
	b	_PDMradd_part

	.globl	_PDMrdelete_part
_PDMrdelete_part:
	movw	$.T1,r2
	movw	$.F16,r3
	call	sp,Rload
	b	_PDMrdelete_part

	.globl	_PDMcheck_delete_part
_PDMcheck_delete_part:
	movw	$.T1,r2
	movw	$.F16,r3
	call	sp,Rload
	b	_PDMcheck_delete_part

	.globl	_PDMrmodify_part
_PDMrmodify_part:
	movw	$.T1,r2
	movw	$.F16,r3
	call	sp,Rload
	b	_PDMrmodify_part

	.globl	_PDMdelete_files
_PDMdelete_files:
	movw	$.T1,r2
	movw	$.F16,r3
	call	sp,Rload
	b	_PDMdelete_files

	.globl	_PDMcancel_modify_part
_PDMcancel_modify_part:
	movw	$.T1,r2
	movw	$.F16,r3
	call	sp,Rload
	b	_PDMcancel_modify_part

	.globl	_PDMadd_part_to_project
_PDMadd_part_to_project:
	movw	$.T1,r2
	movw	$.F16,r3
	call	sp,Rload
	b	_PDMadd_part_to_project

	.globl	_PDMcheck_if_checkedin
_PDMcheck_if_checkedin:
	movw	$.T1,r2
	movw	$.F16,r3
	call	sp,Rload
	b	_PDMcheck_if_checkedin
#
# Begin stubs for:  PDMrpart_p.o
#
	.data
	.align	4
.F17:	.long	0x00000700
	.byte	80, 68, 77, 114, 112, 97, 114, 116, 95, 112
	.byte	46, 111, 0
	.text

	.globl	_PDMquery_part_type
_PDMquery_part_type:
	movw	$.T1,r2
	movw	$.F17,r3
	call	sp,Rload
	b	_PDMquery_part_type

	.globl	_PDMchange_part_type
_PDMchange_part_type:
	movw	$.T1,r2
	movw	$.F17,r3
	call	sp,Rload
	b	_PDMchange_part_type
#
# Begin stubs for:  PDMrpartstr.o
#
	.data
	.align	4
.F18:	.long	0x00000700
	.byte	80, 68, 77, 114, 112, 97, 114, 116, 115, 116
	.byte	114, 46, 111, 0
	.text

	.globl	_PDMget_children
_PDMget_children:
	movw	$.T1,r2
	movw	$.F18,r3
	call	sp,Rload
	b	_PDMget_children

	.globl	_PDMshow_saved_views
_PDMshow_saved_views:
	movw	$.T1,r2
	movw	$.F18,r3
	call	sp,Rload
	b	_PDMshow_saved_views

	.globl	_PDMget_part_attach_info
_PDMget_part_attach_info:
	movw	$.T1,r2
	movw	$.F18,r3
	call	sp,Rload
	b	_PDMget_part_attach_info

	.globl	_PDMget_part_view_list
_PDMget_part_view_list:
	movw	$.T1,r2
	movw	$.F18,r3
	call	sp,Rload
	b	_PDMget_part_view_list
#
# Begin stubs for:  PDMrpdm_rpts.o
#
	.data
	.align	4
.F19:	.long	0x00000700
	.byte	80, 68, 77, 114, 112, 100, 109, 95, 114, 112
	.byte	116, 115, 46, 111, 0
	.text

	.globl	_PDMvalidate_report_name
_PDMvalidate_report_name:
	movw	$.T1,r2
	movw	$.F19,r3
	call	sp,Rload
	b	_PDMvalidate_report_name

	.globl	_PDMread_report_format
_PDMread_report_format:
	movw	$.T1,r2
	movw	$.F19,r3
	call	sp,Rload
	b	_PDMread_report_format

	.globl	_PDMadd_report
_PDMadd_report:
	movw	$.T1,r2
	movw	$.F19,r3
	call	sp,Rload
	b	_PDMadd_report

	.globl	_PDMdelete_report
_PDMdelete_report:
	movw	$.T1,r2
	movw	$.F19,r3
	call	sp,Rload
	b	_PDMdelete_report

	.globl	_PDMshow_boms
_PDMshow_boms:
	movw	$.T1,r2
	movw	$.F19,r3
	call	sp,Rload
	b	_PDMshow_boms

	.globl	_PDMgen_loc_report
_PDMgen_loc_report:
	movw	$.T1,r2
	movw	$.F19,r3
	call	sp,Rload
	b	_PDMgen_loc_report

	.globl	_PDMgen_parts_in_catalog
_PDMgen_parts_in_catalog:
	movw	$.T1,r2
	movw	$.F19,r3
	call	sp,Rload
	b	_PDMgen_parts_in_catalog
#
# Begin stubs for:  PDMrrps_f.o
#
	.data
	.align	4
.F20:	.long	0x00000700
	.byte	80, 68, 77, 114, 114, 112, 115, 95, 102, 46
	.byte	111, 0
	.text

	.globl	_PDMopen_report_buffer
_PDMopen_report_buffer:
	movw	$.T1,r2
	movw	$.F20,r3
	call	sp,Rload
	b	_PDMopen_report_buffer
#
# Begin stubs for:  PDMrsearch.o
#
	.data
	.align	4
.F21:	.long	0x00000700
	.byte	80, 68, 77, 114, 115, 101, 97, 114, 99, 104
	.byte	46, 111, 0
	.text

	.globl	_PDMsearch_across_cats
_PDMsearch_across_cats:
	movw	$.T1,r2
	movw	$.F21,r3
	call	sp,Rload
	b	_PDMsearch_across_cats

	.globl	_PDMsearch_parts_in_catalog
_PDMsearch_parts_in_catalog:
	movw	$.T1,r2
	movw	$.F21,r3
	call	sp,Rload
	b	_PDMsearch_parts_in_catalog

	.globl	_PDMsearch_parts_in_project
_PDMsearch_parts_in_project:
	movw	$.T1,r2
	movw	$.F21,r3
	call	sp,Rload
	b	_PDMsearch_parts_in_project

	.globl	_PDMsearch_parts_in_project2
_PDMsearch_parts_in_project2:
	movw	$.T1,r2
	movw	$.F21,r3
	call	sp,Rload
	b	_PDMsearch_parts_in_project2

	.globl	_PDMrlist_of_parts
_PDMrlist_of_parts:
	movw	$.T1,r2
	movw	$.F21,r3
	call	sp,Rload
	b	_PDMrlist_of_parts
#
# Begin stubs for:  PDMrtools.o
#
	.data
	.align	4
.F22:	.long	0x00000700
	.byte	80, 68, 77, 114, 116, 111, 111, 108, 115, 46
	.byte	111, 0
	.text

	.globl	_PDMverify_project
_PDMverify_project:
	movw	$.T1,r2
	movw	$.F22,r3
	call	sp,Rload
	b	_PDMverify_project

	.globl	_PDMrverify_catalog
_PDMrverify_catalog:
	movw	$.T1,r2
	movw	$.F22,r3
	call	sp,Rload
	b	_PDMrverify_catalog

	.globl	_PDMcheck_partnum
_PDMcheck_partnum:
	movw	$.T1,r2
	movw	$.F22,r3
	call	sp,Rload
	b	_PDMcheck_partnum

	.globl	_PDMverify_partnum
_PDMverify_partnum:
	movw	$.T1,r2
	movw	$.F22,r3
	call	sp,Rload
	b	_PDMverify_partnum

	.globl	_PDMget_part_data
_PDMget_part_data:
	movw	$.T1,r2
	movw	$.F22,r3
	call	sp,Rload
	b	_PDMget_part_data

	.globl	_PDMget_existing_data
_PDMget_existing_data:
	movw	$.T1,r2
	movw	$.F22,r3
	call	sp,Rload
	b	_PDMget_existing_data

	.globl	_PDMget_add_buffer
_PDMget_add_buffer:
	movw	$.T1,r2
	movw	$.F22,r3
	call	sp,Rload
	b	_PDMget_add_buffer

	.globl	_PDMpart_in_project
_PDMpart_in_project:
	movw	$.T1,r2
	movw	$.F22,r3
	call	sp,Rload
	b	_PDMpart_in_project

	.globl	_PDMget_part_from_desc
_PDMget_part_from_desc:
	movw	$.T1,r2
	movw	$.F22,r3
	call	sp,Rload
	b	_PDMget_part_from_desc

	.globl	_PDMget_pt_desc
_PDMget_pt_desc:
	movw	$.T1,r2
	movw	$.F22,r3
	call	sp,Rload
	b	_PDMget_pt_desc

	.globl	_PDMcatalog_list
_PDMcatalog_list:
	movw	$.T1,r2
	movw	$.F22,r3
	call	sp,Rload
	b	_PDMcatalog_list

	.globl	_PDMproject_catalog_listing
_PDMproject_catalog_listing:
	movw	$.T1,r2
	movw	$.F22,r3
	call	sp,Rload
	b	_PDMproject_catalog_listing

	.globl	_PDMparts_listing
_PDMparts_listing:
	movw	$.T1,r2
	movw	$.F22,r3
	call	sp,Rload
	b	_PDMparts_listing

	.globl	_PDMrev_listing
_PDMrev_listing:
	movw	$.T1,r2
	movw	$.F22,r3
	call	sp,Rload
	b	_PDMrev_listing

	.globl	_PDMdescription_list
_PDMdescription_list:
	movw	$.T1,r2
	movw	$.F22,r3
	call	sp,Rload
	b	_PDMdescription_list

	.globl	_PDMparts_in_catalog
_PDMparts_in_catalog:
	movw	$.T1,r2
	movw	$.F22,r3
	call	sp,Rload
	b	_PDMparts_in_catalog

	.globl	_PDMget_trans
_PDMget_trans:
	movw	$.T1,r2
	movw	$.F22,r3
	call	sp,Rload
	b	_PDMget_trans

	.globl	_PDMshow_catalogs
_PDMshow_catalogs:
	movw	$.T1,r2
	movw	$.F22,r3
	call	sp,Rload
	b	_PDMshow_catalogs

	.globl	_PDMrverify_part
_PDMrverify_part:
	movw	$.T1,r2
	movw	$.F22,r3
	call	sp,Rload
	b	_PDMrverify_part

	.globl	_PDMquery_dynamic_attrs
_PDMquery_dynamic_attrs:
	movw	$.T1,r2
	movw	$.F22,r3
	call	sp,Rload
	b	_PDMquery_dynamic_attrs

	.globl	_pdmcheck_part_occurrence
_pdmcheck_part_occurrence:
	movw	$.T1,r2
	movw	$.F22,r3
	call	sp,Rload
	b	_pdmcheck_part_occurrence

	.globl	_build_part_occurrence_list
_build_part_occurrence_list:
	movw	$.T1,r2
	movw	$.F22,r3
	call	sp,Rload
	b	_build_part_occurrence_list

	.globl	_pdmfree_part_occurrence
_pdmfree_part_occurrence:
	movw	$.T1,r2
	movw	$.F22,r3
	call	sp,Rload
	b	_pdmfree_part_occurrence

	.globl	_PDMsql_query
_PDMsql_query:
	movw	$.T1,r2
	movw	$.F22,r3
	call	sp,Rload
	b	_PDMsql_query

	.globl	_PDMopen_copy_buffer3
_PDMopen_copy_buffer3:
	movw	$.T1,r2
	movw	$.F22,r3
	call	sp,Rload
	b	_PDMopen_copy_buffer3

	.globl	_PDMcheck_item
_PDMcheck_item:
	movw	$.T1,r2
	movw	$.F22,r3
	call	sp,Rload
	b	_PDMcheck_item

	.globl	_PDMrcheck_dup_sa_fname
_PDMrcheck_dup_sa_fname:
	movw	$.T1,r2
	movw	$.F22,r3
	call	sp,Rload
	b	_PDMrcheck_dup_sa_fname

	.globl	_PDMsql_distinct
_PDMsql_distinct:
	movw	$.T1,r2
	movw	$.F22,r3
	call	sp,Rload
	b	_PDMsql_distinct

	.globl	_PDUstrip_buffer
_PDUstrip_buffer:
	movw	$.T1,r2
	movw	$.F22,r3
	call	sp,Rload
	b	_PDUstrip_buffer
#
# Begin stubs for:  PDMruser.o
#
	.data
	.align	4
.F23:	.long	0x00000700
	.byte	80, 68, 77, 114, 117, 115, 101, 114, 46, 111
	.byte	0
	.text

	.globl	_PDMrlogin
_PDMrlogin:
	movw	$.T1,r2
	movw	$.F23,r3
	call	sp,Rload
	b	_PDMrlogin

	.globl	_PDMrterminate
_PDMrterminate:
	movw	$.T1,r2
	movw	$.F23,r3
	call	sp,Rload
	b	_PDMrterminate

	.globl	_PDMrverify_init
_PDMrverify_init:
	movw	$.T1,r2
	movw	$.F23,r3
	call	sp,Rload
	b	_PDMrverify_init
#
# Begin stubs for:  PDMrwf.o
#
	.data
	.align	4
.F24:	.long	0x00000700
	.byte	80, 68, 77, 114, 119, 102, 46, 111, 0
	.text

	.globl	_PDMvalidate_user_access
_PDMvalidate_user_access:
	movw	$.T1,r2
	movw	$.F24,r3
	call	sp,Rload
	b	_PDMvalidate_user_access

	.globl	_PDMset_to_state
_PDMset_to_state:
	movw	$.T1,r2
	movw	$.F24,r3
	call	sp,Rload
	b	_PDMset_to_state

	.globl	_PDMrmake_transition
_PDMrmake_transition:
	movw	$.T1,r2
	movw	$.F24,r3
	call	sp,Rload
	b	_PDMrmake_transition
#
# Begin stubs for:  PDMrcriteria.o
#
	.data
	.align	4
.F25:	.long	0x00000700
	.byte	80, 68, 77, 114, 99, 114, 105, 116, 101, 114
	.byte	105, 97, 46, 111, 0
	.text

	.globl	_PDMread_criteria
_PDMread_criteria:
	movw	$.T1,r2
	movw	$.F25,r3
	call	sp,Rload
	b	_PDMread_criteria

	.globl	_PDMadd_criteria
_PDMadd_criteria:
	movw	$.T1,r2
	movw	$.F25,r3
	call	sp,Rload
	b	_PDMadd_criteria

	.globl	_PDMvalidate_criteria_name
_PDMvalidate_criteria_name:
	movw	$.T1,r2
	movw	$.F25,r3
	call	sp,Rload
	b	_PDMvalidate_criteria_name
#
# Begin stubs for:  PDMrexec.o
#
	.data
	.align	4
.F26:	.long	0x00000700
	.byte	80, 68, 77, 114, 101, 120, 101, 99, 46, 111
	.byte	0
	.text

	.globl	_PDUload_exec_structure
_PDUload_exec_structure:
	movw	$.T1,r2
	movw	$.F26,r3
	call	sp,Rload
	b	_PDUload_exec_structure
#
# Begin stubs for:  PDMrapi.o
#
	.data
	.align	4
.F27:	.long	0x00000700
	.byte	80, 68, 77, 114, 97, 112, 105, 46, 111, 0
	.text

	.globl	_PDMopen_buffer
_PDMopen_buffer:
	movw	$.T1,r2
	movw	$.F27,r3
	call	sp,Rload
	b	_PDMopen_buffer

	.globl	_PDMget_filenames
_PDMget_filenames:
	movw	$.T1,r2
	movw	$.F27,r3
	call	sp,Rload
	b	_PDMget_filenames

	.globl	_PDMrget_imm_parents
_PDMrget_imm_parents:
	movw	$.T1,r2
	movw	$.F27,r3
	call	sp,Rload
	b	_PDMrget_imm_parents

	.comm	_PDMsock,4
	.comm	_NFMdbg_ptr,4
	.globl	_PDU_connection
	.globl	_PDMsearch_for_parts_in_catalog
	.globl	_PDMcatalogs_of_proj_part
	.globl	_PDMsread_criteria
	.globl	_PDUchange_to_read_only
	.globl	_PDMsquery_part_type
	.globl	_PDMdelete_part
	.globl	_MEMopen
	.globl	_change_mode
	.globl	_strcpy
	.globl	_PDMdelete_catalog
	.globl	_PDMupdate_exist_bom
	.globl	_user
	.globl	_bufr_flag
	.globl	_PDUactivate_stop_sign
	.globl	_PDMquery_part_info
	.globl	_PDMgenerate_review_bom
	.globl	_PDMdelete_files_from_part
	.globl	_PDMprojects_of_catalog
	.globl	_PDM_debug_on
	.globl	_PDU_is_om_file
	.globl	_PDMvalidate_querys
	.globl	_PDMsdefine_assembly_structure
	.globl	_PDMverify_init
	.globl	_PDMschange_part_type
	.globl	_PDMcreate_catalog
	.globl	_PDMget_pdcattr_buffer
	.globl	_PDU_part_sort_string
	.globl	_PDMget_state_name
	.globl	_PDU_form_id
	.globl	_PDMchkin_files_of_user
	.globl	_malloc
	.globl	_PDUlike_search_string
	.globl	_PDMsadd_report
	.globl	_PDMcheckin_part1
	.globl	_free
	.globl	_MEMwrite
	.globl	_PDMterminate
	.globl	_PDMsquery_table_definition
	.globl	_PDMsshow_saved_views
	.globl	_PDMmake_transition
	.globl	_PDMsadd_part_to_project
	.globl	_PDMgen_explode_summary_bom
	.globl	_PDMsshow_boms
	.globl	_PDMsdelete_report
	.globl	_PDMsUnflag_part_restore
	.globl	_PDMcheck_part_status
	.globl	_PDUremove_files_locally
	.globl	_PDMslist_reports
	.globl	_PDMget_ems_files
	.globl	_PDMlist_chkout_files
	.globl	_PDM20modify_part
	.globl	_PDMsread_report_format
	.globl	_PDMsget_assembly_structure
	.globl	_PDMsearch_across_catalogs
	.globl	_PDMget_cit_children
	.globl	_PDMsearch_for_parts
	.globl	_PDMsflag_part_restore
	.globl	_MEMwrite_format
	.globl	_PDMadd_part
	.globl	_PDMreport_of_loc
	.globl	_PDMget_desc
	.globl	_PDU_DEBUG_FILE
	.globl	_PDMdebug_on
	.globl	_PDU_command
	.globl	_similar_mode
	.globl	_PDMqry_catalog_attributes
	.globl	_PDMget_file_names
	.globl	_PDUsts
	.globl	_MEMsplit_copy_buffer
	.globl	_PDUadd_buffer_string
	.globl	_PDMdetach
	.globl	_MEMreset_buffer_no
	.globl	_PDMcheckout_part
	.globl	_PDMfast_query_table_def
	.globl	_PDMsadd_criteria
	.globl	_PDUdeactivate_stop_sign
	.globl	_PDUget_buffer_col
	.globl	_strlen
	.globl	_PDMs_sql_distinct
	.globl	__pdm_status
	.globl	_PDUprint_storage_area
	.globl	_PDMsgen_where_used_top
	.globl	_change_files_flag
	.globl	_review_mode
	.globl	_PDMsgen_where_used_imm
	.globl	_PDMshow_catalog_acls
	.globl	_strcmp
	.globl	_PDMquery_dynamic_table_information
	.globl	_sleep
	.globl	_forms
	.globl	_PDMsflag_part_delete
	.globl	_PDMverify_part
	.globl	_PDMcopy_file
	.globl	_PDU_file_bufr
	.globl	_PDMget_imm_parents
	.globl	_memset
	.globl	_PDMgen_bomparts_list
	.globl	_PDMlist_of_parts
	.globl	_PDMdebug_on_off
	.globl	_PDMcatalogs_in_project
	.globl	_PDU_hold_bufr
	.globl	_PDMget_part_type_desc
	.globl	_PDMquery_dynamic_attributes
	.globl	_PDMget_rev
	.globl	_PDMsvalidate_report_name
	.globl	_PDMprepare_file_info
	.globl	_PDU_main_form_cat
	.globl	_PDUload_exec_structure
	.globl	_PDMdebug
	.globl	_PDMsget_table_attributes
	.globl	_PDUfill_in_string1
	.globl	_PDMmodify_catalog
	.globl	_PDMsUnflag_part_archive
	.globl	_PDMsget_table_data
	.globl	_PDMopen_buffer
	.globl	_PDU_copyof_ret_bufr
	.globl	_PDU_states_bufr
	.globl	_PDUadd_tablename
	.globl	_PDU_dyn_part_search
	.globl	_MEMbuild_array
	.globl	_PDUfill_in_string
	.globl	_PDMdelete_bom
	.globl	_PDMsget_bommap_attributes
	.globl	_MEMclose
	.globl	_PDMsUnflag_part_delete
	.globl	_PDMdelete_local_files
	.globl	__NFMdebug_st
	.globl	_PDMupdate_dots
	.globl	_PDU_dyn_cat_search
	.globl	_PDMsUnflag_part_backup
	.globl	_PDMcancel_checkout_part
	.globl	_refresh
	.globl	_PDU_ret_bufr
	.globl	_PDMquery_part_status
	.globl	_PDMcopy_attach
	.globl	_PDMsverify_project
	.globl	__pdm_debug
	.globl	_MEMwrite_data
	.globl	_sprintf
	.globl	_PDMcheck_dup_sa_fname
	.globl	_PDMverify_catalog
	.globl	_PDUsetup_buffer
	.globl	_PDMsset_to_state
	.globl	_PDMget_part_rev_type
	.globl	_PDUfree_string
	.globl	_PDMget_saved_views
	.globl	_PDUmessage
	.globl	_PDUformat_buffer
	.globl	_add_data_bufr
	.globl	_PDMs_sql_query
	.globl	_PDMgen_summary_bom
	.globl	_PDUremove_local_files_after_delete
	.globl	_PDMsvalidate_user_access
	.globl	_PDMget_part_info
	.globl	_PDMshow_parts
	.globl	_PDMsflag_part_archive
	.globl	_PDUadd_tablename_to_sort_string
	.globl	_PDMget_cit_parents
	.globl	_PDMlist_of_projects
	.globl	_PDU_auto_file_gen
	.globl	_MEMprint_buffer
	.globl	_MEMprint_buffers
	.globl	_PDMlist_local_files
	.globl	_PDMadd_file_bufr
	.globl	_PDMsshow_catalogs
	.globl	_PDMsmodify_bom_content
	.globl	_PDMsflag_part_backup
	.globl	_PDMreport_of_catalog
	.globl	_PDU_add_bufr
	.globl	_part_occur_list
	.globl	_PDMsget_table_data1
	.globl	_PDMsearch_for_parts_in_project
	.globl	_PDMlogin
	.globl	_MEMreset_buffer
	.globl	_PDMdyntable_for_catalog
	.globl	_PDMsearch_for_parts_in_project2
	.globl	_PDMscancel_modify_part
	.globl	_PDMscheck_delete_part
	.globl	_MEMappend
	.globl	_PDMexec
	.globl	_PDMparts_of_catalog
	.globl	_PDMsget_catno_partno
