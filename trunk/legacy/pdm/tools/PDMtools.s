	.file	"PDMtools.s"
#
# Begin stubs for:  PDMattr_f.o
#
	.data
.T1:	.byte	80, 100, 117, 0
	.byte	112, 100, 109, 47, 116, 111, 111, 108, 115, 0
	.align	4
.F1:	.long	0x00000700
	.byte	80, 68, 77, 97, 116, 116, 114, 95, 102, 46
	.byte	111, 0
	.text

	.globl	_PDMget_attribute_no
_PDMget_attribute_no:
	movw	$.T1,r2
	movw	$.F1,r3
	call	sp,Rload
	b	_PDMget_attribute_no

	.globl	_PDMget_attribute_name
_PDMget_attribute_name:
	movw	$.T1,r2
	movw	$.F1,r3
	call	sp,Rload
	b	_PDMget_attribute_name

	.globl	_PDMget_table_no
_PDMget_table_no:
	movw	$.T1,r2
	movw	$.F1,r3
	call	sp,Rload
	b	_PDMget_table_no

	.globl	_PDMi_get_nname
_PDMi_get_nname:
	movw	$.T1,r2
	movw	$.F1,r3
	call	sp,Rload
	b	_PDMi_get_nname

	.globl	_PDMi_maxrow_no
_PDMi_maxrow_no:
	movw	$.T1,r2
	movw	$.F1,r3
	call	sp,Rload
	b	_PDMi_maxrow_no

	.globl	_PDMi_query_synonym
_PDMi_query_synonym:
	movw	$.T1,r2
	movw	$.F1,r3
	call	sp,Rload
	b	_PDMi_query_synonym

	.globl	_PDMi_find_datatype
_PDMi_find_datatype:
	movw	$.T1,r2
	movw	$.F1,r3
	call	sp,Rload
	b	_PDMi_find_datatype

	.globl	_PDMload_nnames
_PDMload_nnames:
	movw	$.T1,r2
	movw	$.F1,r3
	call	sp,Rload
	b	_PDMload_nnames

	.globl	_PDMget_bom_attr_name
_PDMget_bom_attr_name:
	movw	$.T1,r2
	movw	$.F1,r3
	call	sp,Rload
	b	_PDMget_bom_attr_name
#
# Begin stubs for:  PDMbom_f.o
#
	.data
	.align	4
.F2:	.long	0x00000700
	.byte	80, 68, 77, 98, 111, 109, 95, 102, 46, 111
	.byte	0
	.text

	.globl	_PDMquery_bom_name
_PDMquery_bom_name:
	movw	$.T1,r2
	movw	$.F2,r3
	call	sp,Rload
	b	_PDMquery_bom_name

	.globl	_PDMfind_maxlevel
_PDMfind_maxlevel:
	movw	$.T1,r2
	movw	$.F2,r3
	call	sp,Rload
	b	_PDMfind_maxlevel

	.globl	_PDMfind_p_explode
_PDMfind_p_explode:
	movw	$.T1,r2
	movw	$.F2,r3
	call	sp,Rload
	b	_PDMfind_p_explode

	.globl	_PDMfind_citp_explode
_PDMfind_citp_explode:
	movw	$.T1,r2
	movw	$.F2,r3
	call	sp,Rload
	b	_PDMfind_citp_explode

	.globl	_PDMfind_citc_explode
_PDMfind_citc_explode:
	movw	$.T1,r2
	movw	$.F2,r3
	call	sp,Rload
	b	_PDMfind_citc_explode

	.globl	_PDMswap_bom_tables
_PDMswap_bom_tables:
	movw	$.T1,r2
	movw	$.F2,r3
	call	sp,Rload
	b	_PDMswap_bom_tables

	.globl	_PDMdelete_bom
_PDMdelete_bom:
	movw	$.T1,r2
	movw	$.F2,r3
	call	sp,Rload
	b	_PDMdelete_bom

	.globl	_PDMdrop_bom
_PDMdrop_bom:
	movw	$.T1,r2
	movw	$.F2,r3
	call	sp,Rload
	b	_PDMdrop_bom

	.globl	_PDMdrop_a_bom
_PDMdrop_a_bom:
	movw	$.T1,r2
	movw	$.F2,r3
	call	sp,Rload
	b	_PDMdrop_a_bom

	.globl	_PDMi_find_bomtable
_PDMi_find_bomtable:
	movw	$.T1,r2
	movw	$.F2,r3
	call	sp,Rload
	b	_PDMi_find_bomtable

	.globl	_PDMi_find_bominfo
_PDMi_find_bominfo:
	movw	$.T1,r2
	movw	$.F2,r3
	call	sp,Rload
	b	_PDMi_find_bominfo

	.globl	_PDMverify_bomlock
_PDMverify_bomlock:
	movw	$.T1,r2
	movw	$.F2,r3
	call	sp,Rload
	b	_PDMverify_bomlock
#
# Begin stubs for:  PDMbommnpl.o
#
	.data
	.align	4
.F3:	.long	0x00000700
	.byte	80, 68, 77, 98, 111, 109, 109, 110, 112, 108
	.byte	46, 111, 0
	.text

	.globl	_PDMdelete_sub_tree
_PDMdelete_sub_tree:
	movw	$.T1,r2
	movw	$.F3,r3
	call	sp,Rload
	b	_PDMdelete_sub_tree

	.globl	_PDMrecursive_fetch
_PDMrecursive_fetch:
	movw	$.T1,r2
	movw	$.F3,r3
	call	sp,Rload
	b	_PDMrecursive_fetch

	.globl	_PDMbuild_assembly
_PDMbuild_assembly:
	movw	$.T1,r2
	movw	$.F3,r3
	call	sp,Rload
	b	_PDMbuild_assembly

	.globl	_PDMinsert_new_child
_PDMinsert_new_child:
	movw	$.T1,r2
	movw	$.F3,r3
	call	sp,Rload
	b	_PDMinsert_new_child

	.globl	_PDMcopy_active_bom
_PDMcopy_active_bom:
	movw	$.T1,r2
	movw	$.F3,r3
	call	sp,Rload
	b	_PDMcopy_active_bom

	.globl	_PDMcopy_table
_PDMcopy_table:
	movw	$.T1,r2
	movw	$.F3,r3
	call	sp,Rload
	b	_PDMcopy_table

	.globl	_PDMcopy_review_bom
_PDMcopy_review_bom:
	movw	$.T1,r2
	movw	$.F3,r3
	call	sp,Rload
	b	_PDMcopy_review_bom

	.globl	_PDMcopy_abom_attachments
_PDMcopy_abom_attachments:
	movw	$.T1,r2
	movw	$.F3,r3
	call	sp,Rload
	b	_PDMcopy_abom_attachments

	.globl	_PDMassemble_bottomup
_PDMassemble_bottomup:
	movw	$.T1,r2
	movw	$.F3,r3
	call	sp,Rload
	b	_PDMassemble_bottomup

	.globl	_PDMverify_assembly
_PDMverify_assembly:
	movw	$.T1,r2
	movw	$.F3,r3
	call	sp,Rload
	b	_PDMverify_assembly

	.globl	_PDMset_attached_flag
_PDMset_attached_flag:
	movw	$.T1,r2
	movw	$.F3,r3
	call	sp,Rload
	b	_PDMset_attached_flag

	.globl	_PDMcopy_rbom_attachments
_PDMcopy_rbom_attachments:
	movw	$.T1,r2
	movw	$.F3,r3
	call	sp,Rload
	b	_PDMcopy_rbom_attachments

	.globl	_PDMaccumulate_parent
_PDMaccumulate_parent:
	movw	$.T1,r2
	movw	$.F3,r3
	call	sp,Rload
	b	_PDMaccumulate_parent

	.globl	_PDMcompare_assemblies
_PDMcompare_assemblies:
	movw	$.T1,r2
	movw	$.F3,r3
	call	sp,Rload
	b	_PDMcompare_assemblies
#
# Begin stubs for:  PDMctools.o
#
	.data
	.align	4
.F4:	.long	0x00000700
	.byte	80, 68, 77, 99, 116, 111, 111, 108, 115, 46
	.byte	111, 0
	.text

	.globl	_PDMquery_cit_members
_PDMquery_cit_members:
	movw	$.T1,r2
	movw	$.F4,r3
	call	sp,Rload
	b	_PDMquery_cit_members

	.globl	_PDMopen_set_buffer
_PDMopen_set_buffer:
	movw	$.T1,r2
	movw	$.F4,r3
	call	sp,Rload
	b	_PDMopen_set_buffer

	.globl	_PDMget_catalog_name
_PDMget_catalog_name:
	movw	$.T1,r2
	movw	$.F4,r3
	call	sp,Rload
	b	_PDMget_catalog_name

	.globl	_PDMget_itemname
_PDMget_itemname:
	movw	$.T1,r2
	movw	$.F4,r3
	call	sp,Rload
	b	_PDMget_itemname

	.globl	_PDMcount_cit_attachments
_PDMcount_cit_attachments:
	movw	$.T1,r2
	movw	$.F4,r3
	call	sp,Rload
	b	_PDMcount_cit_attachments

	.globl	_PDMcount_bom_attachments
_PDMcount_bom_attachments:
	movw	$.T1,r2
	movw	$.F4,r3
	call	sp,Rload
	b	_PDMcount_bom_attachments

	.globl	_PDMget_itemname_filever
_PDMget_itemname_filever:
	movw	$.T1,r2
	movw	$.F4,r3
	call	sp,Rload
	b	_PDMget_itemname_filever

	.globl	_PDMget_max_filever
_PDMget_max_filever:
	movw	$.T1,r2
	movw	$.F4,r3
	call	sp,Rload
	b	_PDMget_max_filever

	.globl	_PDMget_filenum
_PDMget_filenum:
	movw	$.T1,r2
	movw	$.F4,r3
	call	sp,Rload
	b	_PDMget_filenum

	.globl	_PDMget_projectno
_PDMget_projectno:
	movw	$.T1,r2
	movw	$.F4,r3
	call	sp,Rload
	b	_PDMget_projectno

	.globl	_PDMget_max_filever_fname
_PDMget_max_filever_fname:
	movw	$.T1,r2
	movw	$.F4,r3
	call	sp,Rload
	b	_PDMget_max_filever_fname
#
# Begin stubs for:  PDMdbms_f.o
#
	.data
	.align	4
.F5:	.long	0x00000700
	.byte	80, 68, 77, 100, 98, 109, 115, 95, 102, 46
	.byte	111, 0
	.text

	.globl	_PDMstop_transaction
_PDMstop_transaction:
	movw	$.T1,r2
	movw	$.F5,r3
	call	sp,Rload
	b	_PDMstop_transaction

	.globl	_PDMstart_transaction
_PDMstart_transaction:
	movw	$.T1,r2
	movw	$.F5,r3
	call	sp,Rload
	b	_PDMstart_transaction

	.globl	_PDMrollback_transaction
_PDMrollback_transaction:
	movw	$.T1,r2
	movw	$.F5,r3
	call	sp,Rload
	b	_PDMrollback_transaction
#
# Begin stubs for:  PDMdyn_tbd.o
#
	.data
	.align	4
.F6:	.long	0x00000700
	.byte	80, 68, 77, 100, 121, 110, 95, 116, 98, 100
	.byte	46, 111, 0
	.text

	.globl	_PDMi_find_maxdatatype
_PDMi_find_maxdatatype:
	movw	$.T1,r2
	movw	$.F6,r3
	call	sp,Rload
	b	_PDMi_find_maxdatatype
#
# Begin stubs for:  PDMdynamic.o
#
	.data
	.align	4
.F7:	.long	0x00000700
	.byte	80, 68, 77, 100, 121, 110, 97, 109, 105, 99
	.byte	46, 111, 0
	.text

	.globl	_PDMi_find_maxtype
_PDMi_find_maxtype:
	movw	$.T1,r2
	movw	$.F7,r3
	call	sp,Rload
	b	_PDMi_find_maxtype

	.globl	_PDMexpand_copy_buffer
_PDMexpand_copy_buffer:
	movw	$.T1,r2
	movw	$.F7,r3
	call	sp,Rload
	b	_PDMexpand_copy_buffer

	.globl	_PDMset_offsets
_PDMset_offsets:
	movw	$.T1,r2
	movw	$.F7,r3
	call	sp,Rload
	b	_PDMset_offsets
#
# Begin stubs for:  PDMpart_f.o
#
	.data
	.align	4
.F8:	.long	0x00000700
	.byte	80, 68, 77, 112, 97, 114, 116, 95, 102, 46
	.byte	111, 0
	.text

	.globl	_PDMquery_assembly_ind
_PDMquery_assembly_ind:
	movw	$.T1,r2
	movw	$.F8,r3
	call	sp,Rload
	b	_PDMquery_assembly_ind

	.globl	_PDMquery_itemno_assind
_PDMquery_itemno_assind:
	movw	$.T1,r2
	movw	$.F8,r3
	call	sp,Rload
	b	_PDMquery_itemno_assind

	.globl	__PDMget_db_error
__PDMget_db_error:
	movw	$.T1,r2
	movw	$.F8,r3
	call	sp,Rload
	b	__PDMget_db_error

	.globl	_PDMquery_assyind_parttype
_PDMquery_assyind_parttype:
	movw	$.T1,r2
	movw	$.F8,r3
	call	sp,Rload
	b	_PDMquery_assyind_parttype

	.globl	_PDMset_n_setindicator
_PDMset_n_setindicator:
	movw	$.T1,r2
	movw	$.F8,r3
	call	sp,Rload
	b	_PDMset_n_setindicator

	.globl	_PDMquery_catalog_partnos
_PDMquery_catalog_partnos:
	movw	$.T1,r2
	movw	$.F8,r3
	call	sp,Rload
	b	_PDMquery_catalog_partnos

	.globl	_PDMquery_catalogno
_PDMquery_catalogno:
	movw	$.T1,r2
	movw	$.F8,r3
	call	sp,Rload
	b	_PDMquery_catalogno

	.globl	_PDMstorage_location_check
_PDMstorage_location_check:
	movw	$.T1,r2
	movw	$.F8,r3
	call	sp,Rload
	b	_PDMstorage_location_check

	.globl	_PDMquery_partno
_PDMquery_partno:
	movw	$.T1,r2
	movw	$.F8,r3
	call	sp,Rload
	b	_PDMquery_partno

	.globl	_PDMquery_catalogtype_no
_PDMquery_catalogtype_no:
	movw	$.T1,r2
	movw	$.F8,r3
	call	sp,Rload
	b	_PDMquery_catalogtype_no

	.globl	_PDMprint_exec
_PDMprint_exec:
	movw	$.T1,r2
	movw	$.F8,r3
	call	sp,Rload
	b	_PDMprint_exec

	.globl	_PDMquery_parttype
_PDMquery_parttype:
	movw	$.T1,r2
	movw	$.F8,r3
	call	sp,Rload
	b	_PDMquery_parttype

	.globl	_PDMset_parttype
_PDMset_parttype:
	movw	$.T1,r2
	movw	$.F8,r3
	call	sp,Rload
	b	_PDMset_parttype

	.globl	_PDMi_query_parmtype
_PDMi_query_parmtype:
	movw	$.T1,r2
	movw	$.F8,r3
	call	sp,Rload
	b	_PDMi_query_parmtype

	.globl	_PDMi_get_partnum_rev
_PDMi_get_partnum_rev:
	movw	$.T1,r2
	movw	$.F8,r3
	call	sp,Rload
	b	_PDMi_get_partnum_rev

	.globl	_PDMget_partnum_rev_CID
_PDMget_partnum_rev_CID:
	movw	$.T1,r2
	movw	$.F8,r3
	call	sp,Rload
	b	_PDMget_partnum_rev_CID

	.globl	_PDMi_get_cidate
_PDMi_get_cidate:
	movw	$.T1,r2
	movw	$.F8,r3
	call	sp,Rload
	b	_PDMi_get_cidate

	.globl	_PDMi_find_cofilename
_PDMi_find_cofilename:
	movw	$.T1,r2
	movw	$.F8,r3
	call	sp,Rload
	b	_PDMi_find_cofilename

	.globl	_PDMload_partdata
_PDMload_partdata:
	movw	$.T1,r2
	movw	$.F8,r3
	call	sp,Rload
	b	_PDMload_partdata

	.globl	_PDMload_partnos
_PDMload_partnos:
	movw	$.T1,r2
	movw	$.F8,r3
	call	sp,Rload
	b	_PDMload_partnos

	.globl	_PDMload_partnums
_PDMload_partnums:
	movw	$.T1,r2
	movw	$.F8,r3
	call	sp,Rload
	b	_PDMload_partnums

	.globl	_PDMload_filenos
_PDMload_filenos:
	movw	$.T1,r2
	movw	$.F8,r3
	call	sp,Rload
	b	_PDMload_filenos

	.globl	_PDMi_query_catalogname
_PDMi_query_catalogname:
	movw	$.T1,r2
	movw	$.F8,r3
	call	sp,Rload
	b	_PDMi_query_catalogname

	.globl	_PDMi_query_partnumrev
_PDMi_query_partnumrev:
	movw	$.T1,r2
	movw	$.F8,r3
	call	sp,Rload
	b	_PDMi_query_partnumrev

	.globl	_PDMquery_table_no
_PDMquery_table_no:
	movw	$.T1,r2
	movw	$.F8,r3
	call	sp,Rload
	b	_PDMquery_table_no

	.globl	_PDMquery_file_status
_PDMquery_file_status:
	movw	$.T1,r2
	movw	$.F8,r3
	call	sp,Rload
	b	_PDMquery_file_status

	.globl	_PDMget_part_info
_PDMget_part_info:
	movw	$.T1,r2
	movw	$.F8,r3
	call	sp,Rload
	b	_PDMget_part_info

	.globl	_PDMget_file_names
_PDMget_file_names:
	movw	$.T1,r2
	movw	$.F8,r3
	call	sp,Rload
	b	_PDMget_file_names

	.globl	_PDMget_part_rev_type
_PDMget_part_rev_type:
	movw	$.T1,r2
	movw	$.F8,r3
	call	sp,Rload
	b	_PDMget_part_rev_type

	.globl	_PDMget_rev
_PDMget_rev:
	movw	$.T1,r2
	movw	$.F8,r3
	call	sp,Rload
	b	_PDMget_rev

	.globl	_PDMcatalogs_of_proj_part
_PDMcatalogs_of_proj_part:
	movw	$.T1,r2
	movw	$.F8,r3
	call	sp,Rload
	b	_PDMcatalogs_of_proj_part

	.globl	_PDMget_ems_files
_PDMget_ems_files:
	movw	$.T1,r2
	movw	$.F8,r3
	call	sp,Rload
	b	_PDMget_ems_files

	.globl	_PDMval_part_for_copy
_PDMval_part_for_copy:
	movw	$.T1,r2
	movw	$.F8,r3
	call	sp,Rload
	b	_PDMval_part_for_copy

	.globl	_PDMi_get_partnum_rev_desc
_PDMi_get_partnum_rev_desc:
	movw	$.T1,r2
	movw	$.F8,r3
	call	sp,Rload
	b	_PDMi_get_partnum_rev_desc

	.globl	_PDMi_get_partnum_rev_type
_PDMi_get_partnum_rev_type:
	movw	$.T1,r2
	movw	$.F8,r3
	call	sp,Rload
	b	_PDMi_get_partnum_rev_type

	.globl	_PDMload_partno_filename
_PDMload_partno_filename:
	movw	$.T1,r2
	movw	$.F8,r3
	call	sp,Rload
	b	_PDMload_partno_filename

	.globl	_PDMget_storageno
_PDMget_storageno:
	movw	$.T1,r2
	movw	$.F8,r3
	call	sp,Rload
	b	_PDMget_storageno

	.globl	_PDMcheck_partnum_without_rev
_PDMcheck_partnum_without_rev:
	movw	$.T1,r2
	movw	$.F8,r3
	call	sp,Rload
	b	_PDMcheck_partnum_without_rev

	.globl	_PDMquery_dyn_table_no
_PDMquery_dyn_table_no:
	movw	$.T1,r2
	movw	$.F8,r3
	call	sp,Rload
	b	_PDMquery_dyn_table_no

	.globl	_PDMconvert_to_lower
_PDMconvert_to_lower:
	movw	$.T1,r2
	movw	$.F8,r3
	call	sp,Rload
	b	_PDMconvert_to_lower

	.globl	__PDMget_attribute_value
__PDMget_attribute_value:
	movw	$.T1,r2
	movw	$.F8,r3
	call	sp,Rload
	b	__PDMget_attribute_value

	.globl	_PDMQueryAssyIndPTypePDesc
_PDMQueryAssyIndPTypePDesc:
	movw	$.T1,r2
	movw	$.F8,r3
	call	sp,Rload
	b	_PDMQueryAssyIndPTypePDesc

	.globl	_PDMQueryAssyIndPFlag
_PDMQueryAssyIndPFlag:
	movw	$.T1,r2
	movw	$.F8,r3
	call	sp,Rload
	b	_PDMQueryAssyIndPFlag

	.globl	_PDMQueryAssyIndGivenPartno
_PDMQueryAssyIndGivenPartno:
	movw	$.T1,r2
	movw	$.F8,r3
	call	sp,Rload
	b	_PDMQueryAssyIndGivenPartno
#
# Begin stubs for:  PDMrefresh.o
#
	.data
	.align	4
.F9:	.long	0x00000700
	.byte	80, 68, 77, 114, 101, 102, 114, 101, 115, 104
	.byte	46, 111, 0
	.text

	.globl	_PDMverify_catalog
_PDMverify_catalog:
	movw	$.T1,r2
	movw	$.F9,r3
	call	sp,Rload
	b	_PDMverify_catalog

	.globl	_PDMcatalog_project_map
_PDMcatalog_project_map:
	movw	$.T1,r2
	movw	$.F9,r3
	call	sp,Rload
	b	_PDMcatalog_project_map

	.globl	_PDMi_verify_catalog
_PDMi_verify_catalog:
	movw	$.T1,r2
	movw	$.F9,r3
	call	sp,Rload
	b	_PDMi_verify_catalog

	.globl	_PDMverify_part
_PDMverify_part:
	movw	$.T1,r2
	movw	$.F9,r3
	call	sp,Rload
	b	_PDMverify_part

	.globl	_PDMquery_part_status
_PDMquery_part_status:
	movw	$.T1,r2
	movw	$.F9,r3
	call	sp,Rload
	b	_PDMquery_part_status

	.globl	_PDMsshow_catalogs
_PDMsshow_catalogs:
	movw	$.T1,r2
	movw	$.F9,r3
	call	sp,Rload
	b	_PDMsshow_catalogs

	.globl	_PDMshow_parts
_PDMshow_parts:
	movw	$.T1,r2
	movw	$.F9,r3
	call	sp,Rload
	b	_PDMshow_parts

	.globl	_PDMs_sql_query
_PDMs_sql_query:
	movw	$.T1,r2
	movw	$.F9,r3
	call	sp,Rload
	b	_PDMs_sql_query

	.globl	_PDMs_sql_distinct
_PDMs_sql_distinct:
	movw	$.T1,r2
	movw	$.F9,r3
	call	sp,Rload
	b	_PDMs_sql_distinct

	.globl	_PDMcatalogs_in_project
_PDMcatalogs_in_project:
	movw	$.T1,r2
	movw	$.F9,r3
	call	sp,Rload
	b	_PDMcatalogs_in_project

	.globl	_PDMprojects_of_catalog
_PDMprojects_of_catalog:
	movw	$.T1,r2
	movw	$.F9,r3
	call	sp,Rload
	b	_PDMprojects_of_catalog

	.globl	_PDMlist_of_projects
_PDMlist_of_projects:
	movw	$.T1,r2
	movw	$.F9,r3
	call	sp,Rload
	b	_PDMlist_of_projects

	.globl	_PDMsverify_project
_PDMsverify_project:
	movw	$.T1,r2
	movw	$.F9,r3
	call	sp,Rload
	b	_PDMsverify_project

	.globl	_convert_toupper
_convert_toupper:
	movw	$.T1,r2
	movw	$.F9,r3
	call	sp,Rload
	b	_convert_toupper

	.globl	_PDMparts_of_catalog
_PDMparts_of_catalog:
	movw	$.T1,r2
	movw	$.F9,r3
	call	sp,Rload
	b	_PDMparts_of_catalog

	.globl	_PDMget_desc
_PDMget_desc:
	movw	$.T1,r2
	movw	$.F9,r3
	call	sp,Rload
	b	_PDMget_desc

	.globl	_PDMget_state_name
_PDMget_state_name:
	movw	$.T1,r2
	movw	$.F9,r3
	call	sp,Rload
	b	_PDMget_state_name

	.globl	_PDMshow_catalog_acls
_PDMshow_catalog_acls:
	movw	$.T1,r2
	movw	$.F9,r3
	call	sp,Rload
	b	_PDMshow_catalog_acls

	.globl	_PDMget_part_type_desc
_PDMget_part_type_desc:
	movw	$.T1,r2
	movw	$.F9,r3
	call	sp,Rload
	b	_PDMget_part_type_desc

	.globl	_PDMsget_catno_partno
_PDMsget_catno_partno:
	movw	$.T1,r2
	movw	$.F9,r3
	call	sp,Rload
	b	_PDMsget_catno_partno

	.globl	_PDMcheck_part_status
_PDMcheck_part_status:
	movw	$.T1,r2
	movw	$.F9,r3
	call	sp,Rload
	b	_PDMcheck_part_status

	.globl	_PDMquery_lower_case_catalogname
_PDMquery_lower_case_catalogname:
	movw	$.T1,r2
	movw	$.F9,r3
	call	sp,Rload
	b	_PDMquery_lower_case_catalogname
#
# Begin stubs for:  PDMreport_f.o
#
	.data
	.align	4
.F10:	.long	0x00000700
	.byte	80, 68, 77, 114, 101, 112, 111, 114, 116, 95
	.byte	102, 46, 111, 0
	.text

	.globl	_PDMappend_10_buffers
_PDMappend_10_buffers:
	movw	$.T1,r2
	movw	$.F10,r3
	call	sp,Rload
	b	_PDMappend_10_buffers

	.globl	_PDMsplit_10_buffers
_PDMsplit_10_buffers:
	movw	$.T1,r2
	movw	$.F10,r3
	call	sp,Rload
	b	_PDMsplit_10_buffers

	.globl	_PDMsplit_16_buffers
_PDMsplit_16_buffers:
	movw	$.T1,r2
	movw	$.F10,r3
	call	sp,Rload
	b	_PDMsplit_16_buffers

	.globl	_PDMappend_16_buffers
_PDMappend_16_buffers:
	movw	$.T1,r2
	movw	$.F10,r3
	call	sp,Rload
	b	_PDMappend_16_buffers

	.globl	_PDMget_templateno
_PDMget_templateno:
	movw	$.T1,r2
	movw	$.F10,r3
	call	sp,Rload
	b	_PDMget_templateno
#
# Begin stubs for:  PDMstools1.o
#
	.data
	.align	4
.F11:	.long	0x00000700
	.byte	80, 68, 77, 115, 116, 111, 111, 108, 115, 49
	.byte	46, 111, 0
	.text

	.globl	_PDMget_cwd
_PDMget_cwd:
	movw	$.T1,r2
	movw	$.F11,r3
	call	sp,Rload
	b	_PDMget_cwd

	.globl	_PDMi_get_date
_PDMi_get_date:
	movw	$.T1,r2
	movw	$.F11,r3
	call	sp,Rload
	b	_PDMi_get_date

	.globl	_PDMget_date_time
_PDMget_date_time:
	movw	$.T1,r2
	movw	$.F11,r3
	call	sp,Rload
	b	_PDMget_date_time

	.globl	_PDMcheck_for_double_quotes
_PDMcheck_for_double_quotes:
	movw	$.T1,r2
	movw	$.F11,r3
	call	sp,Rload
	b	_PDMcheck_for_double_quotes

	.globl	_PDMgen_bomtable_name
_PDMgen_bomtable_name:
	movw	$.T1,r2
	movw	$.F11,r3
	call	sp,Rload
	b	_PDMgen_bomtable_name

	.globl	_PDMgen_file_name
_PDMgen_file_name:
	movw	$.T1,r2
	movw	$.F11,r3
	call	sp,Rload
	b	_PDMgen_file_name

	.globl	_PDMgen_table_name
_PDMgen_table_name:
	movw	$.T1,r2
	movw	$.F11,r3
	call	sp,Rload
	b	_PDMgen_table_name

	.globl	_PDMcreate_ris_table
_PDMcreate_ris_table:
	movw	$.T1,r2
	movw	$.F11,r3
	call	sp,Rload
	b	_PDMcreate_ris_table

	.globl	_PDMquery_cit_attachment
_PDMquery_cit_attachment:
	movw	$.T1,r2
	movw	$.F11,r3
	call	sp,Rload
	b	_PDMquery_cit_attachment

	.globl	_PDMquery_bom_attachment
_PDMquery_bom_attachment:
	movw	$.T1,r2
	movw	$.F11,r3
	call	sp,Rload
	b	_PDMquery_bom_attachment

	.globl	_PDMi_delete_rows
_PDMi_delete_rows:
	movw	$.T1,r2
	movw	$.F11,r3
	call	sp,Rload
	b	_PDMi_delete_rows

	.globl	_PDMi_query_passwd
_PDMi_query_passwd:
	movw	$.T1,r2
	movw	$.F11,r3
	call	sp,Rload
	b	_PDMi_query_passwd

	.globl	_PDMi_delete_fileno
_PDMi_delete_fileno:
	movw	$.T1,r2
	movw	$.F11,r3
	call	sp,Rload
	b	_PDMi_delete_fileno

	.globl	_PDMi_delete_partnum
_PDMi_delete_partnum:
	movw	$.T1,r2
	movw	$.F11,r3
	call	sp,Rload
	b	_PDMi_delete_partnum

	.globl	_PDMcofilename
_PDMcofilename:
	movw	$.T1,r2
	movw	$.F11,r3
	call	sp,Rload
	b	_PDMcofilename

	.globl	_PDMcheck_for_autofilename
_PDMcheck_for_autofilename:
	movw	$.T1,r2
	movw	$.F11,r3
	call	sp,Rload
	b	_PDMcheck_for_autofilename
#
# Begin stubs for:  PDMstools2.o
#
	.data
	.align	4
.F12:	.long	0x00000700
	.byte	80, 68, 77, 115, 116, 111, 111, 108, 115, 50
	.byte	46, 111, 0
	.text

	.globl	_PDMi_find_nodeno
_PDMi_find_nodeno:
	movw	$.T1,r2
	movw	$.F12,r3
	call	sp,Rload
	b	_PDMi_find_nodeno

	.globl	_PDMi_find_partnum
_PDMi_find_partnum:
	movw	$.T1,r2
	movw	$.F12,r3
	call	sp,Rload
	b	_PDMi_find_partnum

	.globl	_PDMi_find_fileno
_PDMi_find_fileno:
	movw	$.T1,r2
	movw	$.F12,r3
	call	sp,Rload
	b	_PDMi_find_fileno

	.globl	_PDMi_find_filenos
_PDMi_find_filenos:
	movw	$.T1,r2
	movw	$.F12,r3
	call	sp,Rload
	b	_PDMi_find_filenos

	.globl	_PDMi_find_references
_PDMi_find_references:
	movw	$.T1,r2
	movw	$.F12,r3
	call	sp,Rload
	b	_PDMi_find_references

	.globl	_PDMi_find_allrefs
_PDMi_find_allrefs:
	movw	$.T1,r2
	movw	$.F12,r3
	call	sp,Rload
	b	_PDMi_find_allrefs

	.globl	_PDMi_update_references
_PDMi_update_references:
	movw	$.T1,r2
	movw	$.F12,r3
	call	sp,Rload
	b	_PDMi_update_references

	.globl	_PDMi_next_negativeno
_PDMi_next_negativeno:
	movw	$.T1,r2
	movw	$.F12,r3
	call	sp,Rload
	b	_PDMi_next_negativeno

	.globl	_PDMi_find_sano
_PDMi_find_sano:
	movw	$.T1,r2
	movw	$.F12,r3
	call	sp,Rload
	b	_PDMi_find_sano

	.globl	_PDMi_copy_format
_PDMi_copy_format:
	movw	$.T1,r2
	movw	$.F12,r3
	call	sp,Rload
	b	_PDMi_copy_format

	.globl	_PDMi_compare_dates
_PDMi_compare_dates:
	movw	$.T1,r2
	movw	$.F12,r3
	call	sp,Rload
	b	_PDMi_compare_dates

	.globl	_PDMi_update_attachments
_PDMi_update_attachments:
	movw	$.T1,r2
	movw	$.F12,r3
	call	sp,Rload
	b	_PDMi_update_attachments

	.globl	_PDMsano_to_name
_PDMsano_to_name:
	movw	$.T1,r2
	movw	$.F12,r3
	call	sp,Rload
	b	_PDMsano_to_name

	.globl	_PDMcheck_to_update
_PDMcheck_to_update:
	movw	$.T1,r2
	movw	$.F12,r3
	call	sp,Rload
	b	_PDMcheck_to_update

	.globl	_PDMupdate_to_define
_PDMupdate_to_define:
	movw	$.T1,r2
	movw	$.F12,r3
	call	sp,Rload
	b	_PDMupdate_to_define

	.globl	_PDMupdate_os_necessary
_PDMupdate_os_necessary:
	movw	$.T1,r2
	movw	$.F12,r3
	call	sp,Rload
	b	_PDMupdate_os_necessary

	.globl	_PDMset_update_os_flag
_PDMset_update_os_flag:
	movw	$.T1,r2
	movw	$.F12,r3
	call	sp,Rload
	b	_PDMset_update_os_flag
#
# Begin stubs for:  PDMbom_tools.o
#
	.data
	.align	4
.F13:	.long	0x00000700
	.byte	80, 68, 77, 98, 111, 109, 95, 116, 111, 111
	.byte	108, 115, 46, 111, 0
	.text

	.globl	_PDMadd_buffer_string
_PDMadd_buffer_string:
	movw	$.T1,r2
	movw	$.F13,r3
	call	sp,Rload
	b	_PDMadd_buffer_string

	.globl	__PDMprint_bommember
__PDMprint_bommember:
	movw	$.T1,r2
	movw	$.F13,r3
	call	sp,Rload
	b	__PDMprint_bommember

	.globl	__PDMprint_bommember_info
__PDMprint_bommember_info:
	movw	$.T1,r2
	movw	$.F13,r3
	call	sp,Rload
	b	__PDMprint_bommember_info

	.globl	__PDMget_double_from_buf_val
__PDMget_double_from_buf_val:
	movw	$.T1,r2
	movw	$.F13,r3
	call	sp,Rload
	b	__PDMget_double_from_buf_val

	.globl	__PDMasc_to_doub
__PDMasc_to_doub:
	movw	$.T1,r2
	movw	$.F13,r3
	call	sp,Rload
	b	__PDMasc_to_doub

	.globl	_PDMappend
_PDMappend:
	movw	$.T1,r2
	movw	$.F13,r3
	call	sp,Rload
	b	_PDMappend

	.globl	__PDMupdate_pdmboms
__PDMupdate_pdmboms:
	movw	$.T1,r2
	movw	$.F13,r3
	call	sp,Rload
	b	__PDMupdate_pdmboms

	.globl	_PDMget_dyntable_for_catalog
_PDMget_dyntable_for_catalog:
	movw	$.T1,r2
	movw	$.F13,r3
	call	sp,Rload
	b	_PDMget_dyntable_for_catalog

	.globl	__PDMi_get_dyn_catname
__PDMi_get_dyn_catname:
	movw	$.T1,r2
	movw	$.F13,r3
	call	sp,Rload
	b	__PDMi_get_dyn_catname
#
# Begin stubs for:  PDMlfm_tools.o
#
	.data
	.align	4
.F14:	.long	0x00000700
	.byte	80, 68, 77, 108, 102, 109, 95, 116, 111, 111
	.byte	108, 115, 46, 111, 0
	.text

	.globl	__PDMprint_setmember
__PDMprint_setmember:
	movw	$.T1,r2
	movw	$.F14,r3
	call	sp,Rload
	b	__PDMprint_setmember

	.globl	__PDMprint_fileentry
__PDMprint_fileentry:
	movw	$.T1,r2
	movw	$.F14,r3
	call	sp,Rload
	b	__PDMprint_fileentry

	.globl	__PDMprint_itementry
__PDMprint_itementry:
	movw	$.T1,r2
	movw	$.F14,r3
	call	sp,Rload
	b	__PDMprint_itementry

	.globl	__PDMprint_all_setmember
__PDMprint_all_setmember:
	movw	$.T1,r2
	movw	$.F14,r3
	call	sp,Rload
	b	__PDMprint_all_setmember

	.globl	_PDMprint_storage_area
_PDMprint_storage_area:
	movw	$.T1,r2
	movw	$.F14,r3
	call	sp,Rload
	b	_PDMprint_storage_area

	.globl	__PDMget_cofilename_cprfnum
__PDMget_cofilename_cprfnum:
	movw	$.T1,r2
	movw	$.F14,r3
	call	sp,Rload
	b	__PDMget_cofilename_cprfnum

	.globl	_PDMGetPartInfoGivenFileName
_PDMGetPartInfoGivenFileName:
	movw	$.T1,r2
	movw	$.F14,r3
	call	sp,Rload
	b	_PDMGetPartInfoGivenFileName

	.globl	_PDMget_stg_filename
_PDMget_stg_filename:
	movw	$.T1,r2
	movw	$.F14,r3
	call	sp,Rload
	b	_PDMget_stg_filename
#
# Begin stubs for:  PDMrep_tools.o
#
	.data
	.align	4
.F15:	.long	0x00000700
	.byte	80, 68, 77, 114, 101, 112, 95, 116, 111, 111
	.byte	108, 115, 46, 111, 0
	.text

	.globl	_PDMfind_system_path
_PDMfind_system_path:
	movw	$.T1,r2
	movw	$.F15,r3
	call	sp,Rload
	b	_PDMfind_system_path

	.globl	_PDMquery_report_type
_PDMquery_report_type:
	movw	$.T1,r2
	movw	$.F15,r3
	call	sp,Rload
	b	_PDMquery_report_type
#
# Begin stubs for:  PDMtable_f.o
#
	.data
	.align	4
.F16:	.long	0x00000700
	.byte	80, 68, 77, 116, 97, 98, 108, 101, 95, 102
	.byte	46, 111, 0
	.text

	.globl	_PDMi_find_tablename
_PDMi_find_tablename:
	movw	$.T1,r2
	movw	$.F16,r3
	call	sp,Rload
	b	_PDMi_find_tablename

	.globl	_PDMi_find_tableinfo
_PDMi_find_tableinfo:
	movw	$.T1,r2
	movw	$.F16,r3
	call	sp,Rload
	b	_PDMi_find_tableinfo

	.globl	_PDMi_insert_pdmtables
_PDMi_insert_pdmtables:
	movw	$.T1,r2
	movw	$.F16,r3
	call	sp,Rload
	b	_PDMi_insert_pdmtables

	.globl	_PDMget_ris_datatype
_PDMget_ris_datatype:
	movw	$.T1,r2
	movw	$.F16,r3
	call	sp,Rload
	b	_PDMget_ris_datatype

	.globl	_PDMi_delete_from_pdmtables
_PDMi_delete_from_pdmtables:
	movw	$.T1,r2
	movw	$.F16,r3
	call	sp,Rload
	b	_PDMi_delete_from_pdmtables
#
# Begin stubs for:  PDMwf_acl.o
#
	.data
	.align	4
.F17:	.long	0x00000700
	.byte	80, 68, 77, 119, 102, 95, 97, 99, 108, 46
	.byte	111, 0
	.text

	.globl	_PDMwfacl_of_catalog
_PDMwfacl_of_catalog:
	movw	$.T1,r2
	movw	$.F17,r3
	call	sp,Rload
	b	_PDMwfacl_of_catalog

	.globl	_PDMstrg_of_catalog
_PDMstrg_of_catalog:
	movw	$.T1,r2
	movw	$.F17,r3
	call	sp,Rload
	b	_PDMstrg_of_catalog

	.globl	_PDMget_commandno
_PDMget_commandno:
	movw	$.T1,r2
	movw	$.F17,r3
	call	sp,Rload
	b	_PDMget_commandno

	.globl	_PDMget_workflowno
_PDMget_workflowno:
	movw	$.T1,r2
	movw	$.F17,r3
	call	sp,Rload
	b	_PDMget_workflowno

	.globl	_PDMget_state_aclno
_PDMget_state_aclno:
	movw	$.T1,r2
	movw	$.F17,r3
	call	sp,Rload
	b	_PDMget_state_aclno

	.globl	_PDMgetacl_info
_PDMgetacl_info:
	movw	$.T1,r2
	movw	$.F17,r3
	call	sp,Rload
	b	_PDMgetacl_info
#
# Begin stubs for:  PDMdebug.o
#
	.data
	.align	4
.F18:	.long	0x00000700
	.byte	80, 68, 77, 100, 101, 98, 117, 103, 46, 111
	.byte	0
	.text

	.globl	_PDMdebug_on_off
_PDMdebug_on_off:
	movw	$.T1,r2
	movw	$.F18,r3
	call	sp,Rload
	b	_PDMdebug_on_off

	.globl	_PDMdebug
_PDMdebug:
	movw	$.T1,r2
	movw	$.F18,r3
	call	sp,Rload
	b	_PDMdebug

	.globl	__PDMdebug
__PDMdebug:
	movw	$.T1,r2
	movw	$.F18,r3
	call	sp,Rload
	b	__PDMdebug
#
# Begin stubs for:  PDMmisc.o
#
	.data
	.align	4
.F19:	.long	0x00000700
	.byte	80, 68, 77, 109, 105, 115, 99, 46, 111, 0
	.text

	.globl	_PDMcopy_data_buffer
_PDMcopy_data_buffer:
	movw	$.T1,r2
	movw	$.F19,r3
	call	sp,Rload
	b	_PDMcopy_data_buffer
#
# Begin stubs for:  PDMquery_cat.o
#
	.data
	.align	4
.F20:	.long	0x00000700
	.byte	80, 68, 77, 113, 117, 101, 114, 121, 95, 99
	.byte	97, 116, 46, 111, 0
	.text

	.globl	_PDMquery_catalog_attributes
_PDMquery_catalog_attributes:
	movw	$.T1,r2
	movw	$.F20,r3
	call	sp,Rload
	b	_PDMquery_catalog_attributes

	.globl	_PDMget_user_name
_PDMget_user_name:
	movw	$.T1,r2
	movw	$.F20,r3
	call	sp,Rload
	b	_PDMget_user_name
#
# Begin stubs for:  PDMptools.o
#
	.data
	.align	4
.F21:	.long	0x00000700
	.byte	80, 68, 77, 112, 116, 111, 111, 108, 115, 46
	.byte	111, 0
	.text

	.globl	_PDMi_query_families
_PDMi_query_families:
	movw	$.T1,r2
	movw	$.F21,r3
	call	sp,Rload
	b	_PDMi_query_families

	.globl	_PDMi_create_pdc_table
_PDMi_create_pdc_table:
	movw	$.T1,r2
	movw	$.F21,r3
	call	sp,Rload
	b	_PDMi_create_pdc_table

	.globl	_PDMi_create_databuffer
_PDMi_create_databuffer:
	movw	$.T1,r2
	movw	$.F21,r3
	call	sp,Rload
	b	_PDMi_create_databuffer

	.globl	_PDMi_query_familyno
_PDMi_query_familyno:
	movw	$.T1,r2
	movw	$.F21,r3
	call	sp,Rload
	b	_PDMi_query_familyno

	.globl	_PDMi_query_libraryno
_PDMi_query_libraryno:
	movw	$.T1,r2
	movw	$.F21,r3
	call	sp,Rload
	b	_PDMi_query_libraryno

	.globl	_PDMi_query_flyname
_PDMi_query_flyname:
	movw	$.T1,r2
	movw	$.F21,r3
	call	sp,Rload
	b	_PDMi_query_flyname

	.globl	_PDMi_verify_macronames
_PDMi_verify_macronames:
	movw	$.T1,r2
	movw	$.F21,r3
	call	sp,Rload
	b	_PDMi_verify_macronames

	.globl	_PDMi_verify_macrodefn
_PDMi_verify_macrodefn:
	movw	$.T1,r2
	movw	$.F21,r3
	call	sp,Rload
	b	_PDMi_verify_macrodefn

	.globl	_PDMi_delete_pdcentry
_PDMi_delete_pdcentry:
	movw	$.T1,r2
	movw	$.F21,r3
	call	sp,Rload
	b	_PDMi_delete_pdcentry

	.globl	_PDMi_insert_pdcinfo
_PDMi_insert_pdcinfo:
	movw	$.T1,r2
	movw	$.F21,r3
	call	sp,Rload
	b	_PDMi_insert_pdcinfo

	.globl	_PDMi_find_sizes
_PDMi_find_sizes:
	movw	$.T1,r2
	movw	$.F21,r3
	call	sp,Rload
	b	_PDMi_find_sizes

	.globl	_PDMi_delete_pdc_entries
_PDMi_delete_pdc_entries:
	movw	$.T1,r2
	movw	$.F21,r3
	call	sp,Rload
	b	_PDMi_delete_pdc_entries

	.globl	_PDMinsert_nthlevel_dynamic_info
_PDMinsert_nthlevel_dynamic_info:
	movw	$.T1,r2
	movw	$.F21,r3
	call	sp,Rload
	b	_PDMinsert_nthlevel_dynamic_info

	.globl	_PDUXi_delete_dynamic_info
_PDUXi_delete_dynamic_info:
	movw	$.T1,r2
	movw	$.F21,r3
	call	sp,Rload
	b	_PDUXi_delete_dynamic_info
#
# Begin stubs for:  PDMpart_p.o
#
	.data
	.align	4
.F22:	.long	0x00000700
	.byte	80, 68, 77, 112, 97, 114, 116, 95, 112, 46
	.byte	111, 0
	.text

	.globl	_PDMsquery_part_type
_PDMsquery_part_type:
	movw	$.T1,r2
	movw	$.F22,r3
	call	sp,Rload
	b	_PDMsquery_part_type

	.globl	_PDMfind_part_type
_PDMfind_part_type:
	movw	$.T1,r2
	movw	$.F22,r3
	call	sp,Rload
	b	_PDMfind_part_type

	.globl	_PDMschange_part_type
_PDMschange_part_type:
	movw	$.T1,r2
	movw	$.F22,r3
	call	sp,Rload
	b	_PDMschange_part_type
#
# Begin stubs for:  PDMviews.o
#
	.data
	.align	4
.F23:	.long	0x00000700
	.byte	80, 68, 77, 118, 105, 101, 119, 115, 46, 111
	.byte	0
	.text

	.globl	_PDMget_views_of_paracat
_PDMget_views_of_paracat:
	movw	$.T1,r2
	movw	$.F23,r3
	call	sp,Rload
	b	_PDMget_views_of_paracat

	.globl	_PDMstore_usageid_cat
_PDMstore_usageid_cat:
	movw	$.T1,r2
	movw	$.F23,r3
	call	sp,Rload
	b	_PDMstore_usageid_cat

	.globl	_PDMget_attr_of_view
_PDMget_attr_of_view:
	movw	$.T1,r2
	movw	$.F23,r3
	call	sp,Rload
	b	_PDMget_attr_of_view

	.globl	_PDMget_dyntable_for_attr
_PDMget_dyntable_for_attr:
	movw	$.T1,r2
	movw	$.F23,r3
	call	sp,Rload
	b	_PDMget_dyntable_for_attr
#
# Begin stubs for:  PDMpget_attr.o
#
	.data
	.align	4
.F24:	.long	0x00000700
	.byte	80, 68, 77, 112, 103, 101, 116, 95, 97, 116
	.byte	116, 114, 46, 111, 0
	.text

	.globl	_PDMquery_parm_catalog_attributes
_PDMquery_parm_catalog_attributes:
	movw	$.T1,r2
	movw	$.F24,r3
	call	sp,Rload
	b	_PDMquery_parm_catalog_attributes

	.globl	__PDMadd_cols_to_attr_bufr
__PDMadd_cols_to_attr_bufr:
	movw	$.T1,r2
	movw	$.F24,r3
	call	sp,Rload
	b	__PDMadd_cols_to_attr_bufr

	.globl	__PDMload_datalist_bufr
__PDMload_datalist_bufr:
	movw	$.T1,r2
	movw	$.F24,r3
	call	sp,Rload
	b	__PDMload_datalist_bufr

	.globl	__PDMload_defaults
__PDMload_defaults:
	movw	$.T1,r2
	movw	$.F24,r3
	call	sp,Rload
	b	__PDMload_defaults

	.globl	__PDMcreate_new_attr_bufr
__PDMcreate_new_attr_bufr:
	movw	$.T1,r2
	movw	$.F24,r3
	call	sp,Rload
	b	__PDMcreate_new_attr_bufr

	.globl	__PDMCreateValueListBufr
__PDMCreateValueListBufr:
	movw	$.T1,r2
	movw	$.F24,r3
	call	sp,Rload
	b	__PDMCreateValueListBufr

	.globl	__PDMXXget_list_bufr
__PDMXXget_list_bufr:
	movw	$.T1,r2
	movw	$.F24,r3
	call	sp,Rload
	b	__PDMXXget_list_bufr

	.globl	_PDMXXget_program_value
_PDMXXget_program_value:
	movw	$.T1,r2
	movw	$.F24,r3
	call	sp,Rload
	b	_PDMXXget_program_value

	.globl	_PDMXXget_range_list
_PDMXXget_range_list:
	movw	$.T1,r2
	movw	$.F24,r3
	call	sp,Rload
	b	_PDMXXget_range_list

	.globl	__PDMXXget_list_list
__PDMXXget_list_list:
	movw	$.T1,r2
	movw	$.F24,r3
	call	sp,Rload
	b	__PDMXXget_list_list

	.globl	_PDMXXget_program_list
_PDMXXget_program_list:
	movw	$.T1,r2
	movw	$.F24,r3
	call	sp,Rload
	b	_PDMXXget_program_list

	.globl	__PDMXXget_list_list2
__PDMXXget_list_list2:
	movw	$.T1,r2
	movw	$.F24,r3
	call	sp,Rload
	b	__PDMXXget_list_list2

	.globl	_PDMXXget_range_info
_PDMXXget_range_info:
	movw	$.T1,r2
	movw	$.F24,r3
	call	sp,Rload
	b	_PDMXXget_range_info

	.globl	_PDMXXbuild_attr_list
_PDMXXbuild_attr_list:
	movw	$.T1,r2
	movw	$.F24,r3
	call	sp,Rload
	b	_PDMXXbuild_attr_list

	.globl	_PDMXXget_list_info
_PDMXXget_list_info:
	movw	$.T1,r2
	movw	$.F24,r3
	call	sp,Rload
	b	_PDMXXget_list_info

	.globl	_PDMXXget_program_info
_PDMXXget_program_info:
	movw	$.T1,r2
	movw	$.F24,r3
	call	sp,Rload
	b	_PDMXXget_program_info

	.globl	_PDMXXget_program_value_info
_PDMXXget_program_value_info:
	movw	$.T1,r2
	movw	$.F24,r3
	call	sp,Rload
	b	_PDMXXget_program_value_info

	.globl	__PDMrecreate_grandchildren_dyn_databufr
__PDMrecreate_grandchildren_dyn_databufr:
	movw	$.T1,r2
	movw	$.F24,r3
	call	sp,Rload
	b	__PDMrecreate_grandchildren_dyn_databufr

	.globl	__PDMget_cat_index
__PDMget_cat_index:
	movw	$.T1,r2
	movw	$.F24,r3
	call	sp,Rload
	b	__PDMget_cat_index

	.globl	_PDMrecreate_validated_dyn_databufr
_PDMrecreate_validated_dyn_databufr:
	movw	$.T1,r2
	movw	$.F24,r3
	call	sp,Rload
	b	_PDMrecreate_validated_dyn_databufr

	.globl	_PDMget_attr_bufr_for_dyn_cat
_PDMget_attr_bufr_for_dyn_cat:
	movw	$.T1,r2
	movw	$.F24,r3
	call	sp,Rload
	b	_PDMget_attr_bufr_for_dyn_cat
#
# Begin stubs for:  PDMfasttool.o
#
	.data
	.align	4
.F25:	.long	0x00000700
	.byte	80, 68, 77, 102, 97, 115, 116, 116, 111, 111
	.byte	108, 46, 111, 0
	.text

	.globl	_PDMload_part_info
_PDMload_part_info:
	movw	$.T1,r2
	movw	$.F25,r3
	call	sp,Rload
	b	_PDMload_part_info

	.globl	_PDMload_child_info
_PDMload_child_info:
	movw	$.T1,r2
	movw	$.F25,r3
	call	sp,Rload
	b	_PDMload_child_info

	.globl	_PDMquery_part_info
_PDMquery_part_info:
	movw	$.T1,r2
	movw	$.F25,r3
	call	sp,Rload
	b	_PDMquery_part_info

	.globl	__PDMinit_part_struct
__PDMinit_part_struct:
	movw	$.T1,r2
	movw	$.F25,r3
	call	sp,Rload
	b	__PDMinit_part_struct

	.globl	__PDMprint_setinfo1_struct
__PDMprint_setinfo1_struct:
	movw	$.T1,r2
	movw	$.F25,r3
	call	sp,Rload
	b	__PDMprint_setinfo1_struct

	.globl	__PDMprint_childinfo_struct
__PDMprint_childinfo_struct:
	movw	$.T1,r2
	movw	$.F25,r3
	call	sp,Rload
	b	__PDMprint_childinfo_struct
#
# Begin stubs for:  PDMpara_tool.o
#
	.data
	.align	4
.F26:	.long	0x00000700
	.byte	80, 68, 77, 112, 97, 114, 97, 95, 116, 111
	.byte	111, 108, 46, 111, 0
	.text

	.globl	_PDMquery_catalog_type
_PDMquery_catalog_type:
	movw	$.T1,r2
	movw	$.F26,r3
	call	sp,Rload
	b	_PDMquery_catalog_type

	.globl	_PDMcheck_for_view
_PDMcheck_for_view:
	movw	$.T1,r2
	movw	$.F26,r3
	call	sp,Rload
	b	_PDMcheck_for_view

	.globl	_PDMplacement_attributes
_PDMplacement_attributes:
	movw	$.T1,r2
	movw	$.F26,r3
	call	sp,Rload
	b	_PDMplacement_attributes

	.globl	_PDMparse_for_tic
_PDMparse_for_tic:
	movw	$.T1,r2
	movw	$.F26,r3
	call	sp,Rload
	b	_PDMparse_for_tic

	.globl	_PDMcr_para_ass_bufr
_PDMcr_para_ass_bufr:
	movw	$.T1,r2
	movw	$.F26,r3
	call	sp,Rload
	b	_PDMcr_para_ass_bufr
#
# Begin stubs for:  PDMpdms_tool.o
#
	.data
	.align	4
.F27:	.long	0x00000700
	.byte	80, 68, 77, 112, 100, 109, 115, 95, 116, 111
	.byte	111, 108, 46, 111, 0
	.text

	.globl	_PDMvalidate_attribute
_PDMvalidate_attribute:
	movw	$.T1,r2
	movw	$.F27,r3
	call	sp,Rload
	b	_PDMvalidate_attribute

	.globl	_PDMcreate_data_buffer
_PDMcreate_data_buffer:
	movw	$.T1,r2
	movw	$.F27,r3
	call	sp,Rload
	b	_PDMcreate_data_buffer

	.globl	_PDMparse_for_illegal_char
_PDMparse_for_illegal_char:
	movw	$.T1,r2
	movw	$.F27,r3
	call	sp,Rload
	b	_PDMparse_for_illegal_char

	.globl	_PDMdyntable_for_catalog
_PDMdyntable_for_catalog:
	movw	$.T1,r2
	movw	$.F27,r3
	call	sp,Rload
	b	_PDMdyntable_for_catalog

	.globl	_PDMquery_catalogno_type
_PDMquery_catalogno_type:
	movw	$.T1,r2
	movw	$.F27,r3
	call	sp,Rload
	b	_PDMquery_catalogno_type

	.globl	_PDMfree_query_info_struct
_PDMfree_query_info_struct:
	movw	$.T1,r2
	movw	$.F27,r3
	call	sp,Rload
	b	_PDMfree_query_info_struct

	.globl	_PDMinit_query_info_struct
_PDMinit_query_info_struct:
	movw	$.T1,r2
	movw	$.F27,r3
	call	sp,Rload
	b	_PDMinit_query_info_struct
#
# Begin stubs for:  PDMfmgr_tool.o
#
	.data
	.align	4
.F28:	.long	0x00000700
	.byte	80, 68, 77, 102, 109, 103, 114, 95, 116, 111
	.byte	111, 108, 46, 111, 0
	.text

	.globl	_PDMlogin_find_sainfo
_PDMlogin_find_sainfo:
	movw	$.T1,r2
	movw	$.F28,r3
	call	sp,Rload
	b	_PDMlogin_find_sainfo

	.globl	__PDMCheckDuplPath
__PDMCheckDuplPath:
	movw	$.T1,r2
	movw	$.F28,r3
	call	sp,Rload
	b	__PDMCheckDuplPath

	.globl	_PDMi_find_storageno_name
_PDMi_find_storageno_name:
	movw	$.T1,r2
	movw	$.F28,r3
	call	sp,Rload
	b	_PDMi_find_storageno_name
#
# Begin stubs for:  PDMcico_tool.o
#
	.data
	.align	4
.F29:	.long	0x00000700
	.byte	80, 68, 77, 99, 105, 99, 111, 95, 116, 111
	.byte	111, 108, 46, 111, 0
	.text

	.globl	_PDMi_prepare_buffer1
_PDMi_prepare_buffer1:
	movw	$.T1,r2
	movw	$.F29,r3
	call	sp,Rload
	b	_PDMi_prepare_buffer1

	.globl	_PDMXXsa_info
_PDMXXsa_info:
	movw	$.T1,r2
	movw	$.F29,r3
	call	sp,Rload
	b	_PDMXXsa_info

	.globl	_PDMget_file_list
_PDMget_file_list:
	movw	$.T1,r2
	movw	$.F29,r3
	call	sp,Rload
	b	_PDMget_file_list

	.globl	_PDMmake_data_buffer
_PDMmake_data_buffer:
	movw	$.T1,r2
	movw	$.F29,r3
	call	sp,Rload
	b	_PDMmake_data_buffer

	.globl	_PDMXmake_file_buffer
_PDMXmake_file_buffer:
	movw	$.T1,r2
	movw	$.F29,r3
	call	sp,Rload
	b	_PDMXmake_file_buffer

	.globl	_PDMXload_sano_info
_PDMXload_sano_info:
	movw	$.T1,r2
	movw	$.F29,r3
	call	sp,Rload
	b	_PDMXload_sano_info

	.globl	_PDMset_info_oper_struct
_PDMset_info_oper_struct:
	movw	$.T1,r2
	movw	$.F29,r3
	call	sp,Rload
	b	_PDMset_info_oper_struct

	.globl	_PDMset_oper_struct
_PDMset_oper_struct:
	movw	$.T1,r2
	movw	$.F29,r3
	call	sp,Rload
	b	_PDMset_oper_struct

	.globl	_PDMupdate_ncoout
_PDMupdate_ncoout:
	movw	$.T1,r2
	movw	$.F29,r3
	call	sp,Rload
	b	_PDMupdate_ncoout

	.globl	_PDMreset_ncoout
_PDMreset_ncoout:
	movw	$.T1,r2
	movw	$.F29,r3
	call	sp,Rload
	b	_PDMreset_ncoout

	.globl	_PDMupdate_dots
_PDMupdate_dots:
	movw	$.T1,r2
	movw	$.F29,r3
	call	sp,Rload
	b	_PDMupdate_dots

	.globl	_PDMreset_dots
_PDMreset_dots:
	movw	$.T1,r2
	movw	$.F29,r3
	call	sp,Rload
	b	_PDMreset_dots

	.globl	_PDMquery_catalog_part_rev_type
_PDMquery_catalog_part_rev_type:
	movw	$.T1,r2
	movw	$.F29,r3
	call	sp,Rload
	b	_PDMquery_catalog_part_rev_type

	.globl	_PDMget_mul_file
_PDMget_mul_file:
	movw	$.T1,r2
	movw	$.F29,r3
	call	sp,Rload
	b	_PDMget_mul_file

	.globl	_PDMget_new_files
_PDMget_new_files:
	movw	$.T1,r2
	movw	$.F29,r3
	call	sp,Rload
	b	_PDMget_new_files

	.globl	_PDMcheck_dup_sa_fname
_PDMcheck_dup_sa_fname:
	movw	$.T1,r2
	movw	$.F29,r3
	call	sp,Rload
	b	_PDMcheck_dup_sa_fname

	.globl	_PDMget_co_username
_PDMget_co_username:
	movw	$.T1,r2
	movw	$.F29,r3
	call	sp,Rload
	b	_PDMget_co_username
#
# Begin stubs for:  PDMtimestamp.o
#
	.data
	.align	4
.F30:	.long	0x00000700
	.byte	80, 68, 77, 116, 105, 109, 101, 115, 116, 97
	.byte	109, 112, 46, 111, 0
	.text

	.globl	__PDMtime_data
__PDMtime_data:
	movw	$.T1,r2
	movw	$.F30,r3
	call	sp,Rload
	b	__PDMtime_data

	.globl	__PDMtime_commit
__PDMtime_commit:
	movw	$.T1,r2
	movw	$.F30,r3
	call	sp,Rload
	b	__PDMtime_commit

	.comm	_PDMwf_info,150
	.comm	_PDMlast_oper,4
	.comm	_PDMchild,296
	.comm	_PDMpart,300
	.comm	_glob_var,100
	.comm	_PDMoperation,4
	.globl	_PDMget_catno_type
	.globl	_NFMall_debug
	.globl	_SQLquery
	.globl	_NFMstart_transaction
	.globl	_PDMcheck_for_view
	.globl	_MEMopen
	.globl	_strcpy
	.globl	_PDMgen_bomtable_name
	.globl	_NFMquery_table_template
	.globl	_strncpy
	.globl	_NFMascii_to_timestamp_format
	.globl	_PDMconvert_to_lower
	.globl	_malloc
	.globl	_PDMquery_partno
	.globl	_PDMrollback_transaction
	.globl	_free
	.globl	_MEMwrite
	.globl	_ERRget_specific_message
	.globl	_vfprintf
	.globl	_NFMglobal
	.globl	__PDMdebug
	.globl	_SQLstmt
	.globl	_NFMdecrypt
	.globl	__NFMget_cat_internal_sa_list
	.globl	_strtok
	.globl	_SQLglobal
	.globl	_PDMi_find_nodeno
	.globl	_PDMget_commandno
	.globl	__iob
	.globl	_NFMstop_transaction
	.globl	__PDMget_db_error
	.globl	_getcwd
	.globl	_MEMwrite_format
	.globl	_PDMquery
	.globl	_STO_info
	.globl	_PDMdebug_on
	.globl	_NFMget_datetime
	.globl	_toupper
	.globl	_strncmp
	.globl	_storage
	.globl	_NFMRtic_it
	.globl	_PDMris_get_catname
	.globl	_PDMsvalidate_user_access_cl
	.globl	_MEMsplit_copy_buffer
	.globl	_PDUadd_buffer_string
	.globl	_PDMvalidate_attribute
	.globl	_MEMreset_buffer_no
	.globl	_PDUget_buffer_col
	.globl	_strlen
	.globl	_WFinfo
	.globl	_strcat
	.globl	_NFMbuild_fto_buffer
	.globl	__pdm_status
	.globl	_vsprintf
	.globl	_NFMchange_working_area_passwd
	.globl	_ERRget_specific_number
	.globl	_strcmp
	.globl	_sleep
	.globl	_localtime
	.globl	_time
	.globl	_PDMverify_part
	.globl	_tolower
	.globl	__NFMget_table_attr
	.globl	_PDMget_table_no
	.globl	_PDMtimestamp_file
	.globl	_PDMquery_catalog_partnos
	.globl	_PDMris_get_catno
	.globl	_memset
	.globl	_NFMget_program_name
	.globl	_UI_status
	.globl	_PDMpart
	.globl	_ERRload_struct
	.globl	_fclose
	.globl	_isdigit
	.globl	_atol
	.globl	_atoi
	.globl	_atof
	.globl	_UI_error
	.globl	_PDMi_find_partnum
	.globl	_PDMdebug
	.globl	_sscanf
	.globl	__NFMget_template_no
	.globl	_PDMi_query_familyno
	.globl	_NFMget_sa_no_info
	.globl	_PDMtimestamp_buffer
	.globl	_MEMbuild_array
	.globl	_strtod
	.globl	_MEMclose
	.globl	__NFMdebug_function
	.globl	_PDMi_maxrow_no
	.globl	_calloc
	.globl	__NFMdebug_st
	.globl	_fprintf
	.globl	_PDMupdate_dots
	.globl	__NFM_str
	.globl	__NFMget_cat_acl_list
	.globl	_PDMris_get_projectno
	.globl	_strncat
	.globl	_PDMi_find_maxdatatype
	.globl	_NFMcreate_table
	.globl	_MEMwrite_data
	.globl	_sprintf
	.globl	_PDMquery_table_no
	.globl	_PDMris_stmt
	.globl	_PDMris_get_pitemno
	.globl	_PDM_DEBUG_FILE
	.globl	_PDMi_get_partnum_rev_desc
	.globl	_PDMi_query_catalogname
	.globl	_PDUtranslate_message
	.globl	__NFMget_data_value
	.globl	_NFMrollback_transaction
	.globl	_MEMprint_buffer
	.globl	_MEMprint_buffers
	.globl	_PDMdrop_a_bom
	.globl	_PDMi_qry_catalog_attributes
	.globl	_MEMno_buffers
	.globl	_getenv
	.globl	_NFMquery_add_item_attributes
	.globl	_NFMchange_case
	.globl	_fputs
	.globl	__NFMfs_undo_recv_files
	.globl	_PDMi_compare_dates
	.globl	_NFMget_storage_info
	.globl	_fopen
	.globl	__PDMget_attribute_value
	.globl	_PDMquery_catalogtype_no
	.globl	_MEMreset_buffer
	.globl	_PDMdyntable_for_catalog
	.globl	_NFMget_table_attr
	.globl	__NFMfs_recv_files
	.globl	_MEMappend
	.globl	_PDMexec
