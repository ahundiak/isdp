	.file	"PDMbom.s"
#
# Begin stubs for:  PDMactive.o
#
	.data
.T1:	.byte	80, 100, 117, 0
	.byte	112, 100, 109, 47, 98, 111, 109, 0
	.align	4
.F1:	.long	0x00000700
	.byte	80, 68, 77, 97, 99, 116, 105, 118, 101, 46
	.byte	111, 0
	.text

	.globl	_PDMXupdate_exist_bom
_PDMXupdate_exist_bom:
	movw	$.T1,r2
	movw	$.F1,r3
	call	sp,Rload
	b	_PDMXupdate_exist_bom

	.globl	_PDMXXXXXXupdate_exist_bom
_PDMXXXXXXupdate_exist_bom:
	movw	$.T1,r2
	movw	$.F1,r3
	call	sp,Rload
	b	_PDMXXXXXXupdate_exist_bom
#
# Begin stubs for:  PDMbom.o
#
	.data
	.align	4
.F2:	.long	0x00000700
	.byte	80, 68, 77, 98, 111, 109, 46, 111, 0
	.text

	.globl	_PDMsmodify_bom_content
_PDMsmodify_bom_content:
	movw	$.T1,r2
	movw	$.F2,r3
	call	sp,Rload
	b	_PDMsmodify_bom_content

	.globl	_PDMsget_bommap_attributes
_PDMsget_bommap_attributes:
	movw	$.T1,r2
	movw	$.F2,r3
	call	sp,Rload
	b	_PDMsget_bommap_attributes

	.globl	_PDMmodify_attribute_buffer
_PDMmodify_attribute_buffer:
	movw	$.T1,r2
	movw	$.F2,r3
	call	sp,Rload
	b	_PDMmodify_attribute_buffer

	.globl	_PDMmodify_dynamic_buffer
_PDMmodify_dynamic_buffer:
	movw	$.T1,r2
	movw	$.F2,r3
	call	sp,Rload
	b	_PDMmodify_dynamic_buffer

	.globl	_PDMchange_attr_data
_PDMchange_attr_data:
	movw	$.T1,r2
	movw	$.F2,r3
	call	sp,Rload
	b	_PDMchange_attr_data

	.globl	_PDMupdate_data_buffer
_PDMupdate_data_buffer:
	movw	$.T1,r2
	movw	$.F2,r3
	call	sp,Rload
	b	_PDMupdate_data_buffer

	.globl	_PDMmodify_template_buffer
_PDMmodify_template_buffer:
	movw	$.T1,r2
	movw	$.F2,r3
	call	sp,Rload
	b	_PDMmodify_template_buffer
#
# Begin stubs for:  PDMbomrtns.o
#
	.data
	.align	4
.F3:	.long	0x00000700
	.byte	80, 68, 77, 98, 111, 109, 114, 116, 110, 115
	.byte	46, 111, 0
	.text

	.globl	_PDMcreate_temp_table
_PDMcreate_temp_table:
	movw	$.T1,r2
	movw	$.F3,r3
	call	sp,Rload
	b	_PDMcreate_temp_table

	.globl	_PDMload_temp_table
_PDMload_temp_table:
	movw	$.T1,r2
	movw	$.F3,r3
	call	sp,Rload
	b	_PDMload_temp_table

	.globl	_PDMcreate_bom_table1
_PDMcreate_bom_table1:
	movw	$.T1,r2
	movw	$.F3,r3
	call	sp,Rload
	b	_PDMcreate_bom_table1

	.globl	_PDMjoin_cits
_PDMjoin_cits:
	movw	$.T1,r2
	movw	$.F3,r3
	call	sp,Rload
	b	_PDMjoin_cits

	.globl	_PDMload_bom_table1
_PDMload_bom_table1:
	movw	$.T1,r2
	movw	$.F3,r3
	call	sp,Rload
	b	_PDMload_bom_table1

	.globl	_PDMcreate_bom_table
_PDMcreate_bom_table:
	movw	$.T1,r2
	movw	$.F3,r3
	call	sp,Rload
	b	_PDMcreate_bom_table

	.globl	_PDMget_bom_attrbs
_PDMget_bom_attrbs:
	movw	$.T1,r2
	movw	$.F3,r3
	call	sp,Rload
	b	_PDMget_bom_attrbs

	.globl	_PDMload_bom_table
_PDMload_bom_table:
	movw	$.T1,r2
	movw	$.F3,r3
	call	sp,Rload
	b	_PDMload_bom_table

	.globl	_PDMupdate_bom_attributes
_PDMupdate_bom_attributes:
	movw	$.T1,r2
	movw	$.F3,r3
	call	sp,Rload
	b	_PDMupdate_bom_attributes

	.globl	_PDMbuild_select_string
_PDMbuild_select_string:
	movw	$.T1,r2
	movw	$.F3,r3
	call	sp,Rload
	b	_PDMbuild_select_string

	.globl	_PDMquery_load_members
_PDMquery_load_members:
	movw	$.T1,r2
	movw	$.F3,r3
	call	sp,Rload
	b	_PDMquery_load_members

	.globl	_PDMbuild_attribute_string
_PDMbuild_attribute_string:
	movw	$.T1,r2
	movw	$.F3,r3
	call	sp,Rload
	b	_PDMbuild_attribute_string

	.globl	_PDMmap_user_attributes
_PDMmap_user_attributes:
	movw	$.T1,r2
	movw	$.F3,r3
	call	sp,Rload
	b	_PDMmap_user_attributes

	.globl	_PDMupdatebom_tagnos
_PDMupdatebom_tagnos:
	movw	$.T1,r2
	movw	$.F3,r3
	call	sp,Rload
	b	_PDMupdatebom_tagnos

	.globl	_PDMactive_carry_tagnos
_PDMactive_carry_tagnos:
	movw	$.T1,r2
	movw	$.F3,r3
	call	sp,Rload
	b	_PDMactive_carry_tagnos

	.globl	_PDMactive_child_tags
_PDMactive_child_tags:
	movw	$.T1,r2
	movw	$.F3,r3
	call	sp,Rload
	b	_PDMactive_child_tags

	.globl	_PDMreview_carry_tagnos
_PDMreview_carry_tagnos:
	movw	$.T1,r2
	movw	$.F3,r3
	call	sp,Rload
	b	_PDMreview_carry_tagnos

	.globl	_PDMreview_child_tags
_PDMreview_child_tags:
	movw	$.T1,r2
	movw	$.F3,r3
	call	sp,Rload
	b	_PDMreview_child_tags

	.globl	_PDMcreate_join_buffer
_PDMcreate_join_buffer:
	movw	$.T1,r2
	movw	$.F3,r3
	call	sp,Rload
	b	_PDMcreate_join_buffer

	.globl	_NFMquery_set_members1
_NFMquery_set_members1:
	movw	$.T1,r2
	movw	$.F3,r3
	call	sp,Rload
	b	_NFMquery_set_members1

	.globl	_PDMstructure_bom
_PDMstructure_bom:
	movw	$.T1,r2
	movw	$.F3,r3
	call	sp,Rload
	b	_PDMstructure_bom

	.globl	_PDMxyz
_PDMxyz:
	movw	$.T1,r2
	movw	$.F3,r3
	call	sp,Rload
	b	_PDMxyz
#
# Begin stubs for:  PDMreview.o
#
	.data
	.align	4
.F4:	.long	0x00000700
	.byte	80, 68, 77, 114, 101, 118, 105, 101, 119, 46
	.byte	111, 0
	.text

	.globl	_PDMgenerate_review_bom
_PDMgenerate_review_bom:
	movw	$.T1,r2
	movw	$.F4,r3
	call	sp,Rload
	b	_PDMgenerate_review_bom
#
# Begin stubs for:  PDMbom_assy.o
#
	.data
	.align	4
.F5:	.long	0x00000700
	.byte	80, 68, 77, 98, 111, 109, 95, 97, 115, 115
	.byte	121, 46, 111, 0
	.text

	.globl	_PDMretrieve_members_for_bom
_PDMretrieve_members_for_bom:
	movw	$.T1,r2
	movw	$.F5,r3
	call	sp,Rload
	b	_PDMretrieve_members_for_bom

	.globl	_PDMget_bom_members
_PDMget_bom_members:
	movw	$.T1,r2
	movw	$.F5,r3
	call	sp,Rload
	b	_PDMget_bom_members

	.globl	_PDMdfs_retrieve_members_for_bom
_PDMdfs_retrieve_members_for_bom:
	movw	$.T1,r2
	movw	$.F5,r3
	call	sp,Rload
	b	_PDMdfs_retrieve_members_for_bom

	.globl	_PDMbom_check_assy_cycle
_PDMbom_check_assy_cycle:
	movw	$.T1,r2
	movw	$.F5,r3
	call	sp,Rload
	b	_PDMbom_check_assy_cycle

	.globl	_PDMbom_check_ancestor_loop
_PDMbom_check_ancestor_loop:
	movw	$.T1,r2
	movw	$.F5,r3
	call	sp,Rload
	b	_PDMbom_check_ancestor_loop

	.globl	_PDMGetAssyStrForSummBom
_PDMGetAssyStrForSummBom:
	movw	$.T1,r2
	movw	$.F5,r3
	call	sp,Rload
	b	_PDMGetAssyStrForSummBom

	.globl	_PDMGetAssyForEngBom
_PDMGetAssyForEngBom:
	movw	$.T1,r2
	movw	$.F5,r3
	call	sp,Rload
	b	_PDMGetAssyForEngBom
#
# Begin stubs for:  PDMbom_attr.o
#
	.data
	.align	4
.F6:	.long	0x00000700
	.byte	80, 68, 77, 98, 111, 109, 95, 97, 116, 116
	.byte	114, 46, 111, 0
	.text

	.globl	_PDMget_bom_attrs
_PDMget_bom_attrs:
	movw	$.T1,r2
	movw	$.F6,r3
	call	sp,Rload
	b	_PDMget_bom_attrs

	.globl	_PDMget_bom_map_attrs
_PDMget_bom_map_attrs:
	movw	$.T1,r2
	movw	$.F6,r3
	call	sp,Rload
	b	_PDMget_bom_map_attrs

	.globl	__PDMbom_load_cattype_in_ll
__PDMbom_load_cattype_in_ll:
	movw	$.T1,r2
	movw	$.F6,r3
	call	sp,Rload
	b	__PDMbom_load_cattype_in_ll

	.globl	__PDMcreate_map_bufr
__PDMcreate_map_bufr:
	movw	$.T1,r2
	movw	$.F6,r3
	call	sp,Rload
	b	__PDMcreate_map_bufr

	.globl	_PDMget_new_bom_attr_bufr
_PDMget_new_bom_attr_bufr:
	movw	$.T1,r2
	movw	$.F6,r3
	call	sp,Rload
	b	_PDMget_new_bom_attr_bufr

	.globl	__PDMcreate_bom_attr_bufr
__PDMcreate_bom_attr_bufr:
	movw	$.T1,r2
	movw	$.F6,r3
	call	sp,Rload
	b	__PDMcreate_bom_attr_bufr

	.globl	__PDMload_bom_attr_bufr
__PDMload_bom_attr_bufr:
	movw	$.T1,r2
	movw	$.F6,r3
	call	sp,Rload
	b	__PDMload_bom_attr_bufr

	.globl	__PDMget_sel_str
__PDMget_sel_str:
	movw	$.T1,r2
	movw	$.F6,r3
	call	sp,Rload
	b	__PDMget_sel_str

	.globl	__PDMload_sel_strs
__PDMload_sel_strs:
	movw	$.T1,r2
	movw	$.F6,r3
	call	sp,Rload
	b	__PDMload_sel_strs

	.globl	_PDMget_new_map_bom_attr_bufr
_PDMget_new_map_bom_attr_bufr:
	movw	$.T1,r2
	movw	$.F6,r3
	call	sp,Rload
	b	_PDMget_new_map_bom_attr_bufr

	.globl	__PDMload_bom_map_attr_bufr
__PDMload_bom_map_attr_bufr:
	movw	$.T1,r2
	movw	$.F6,r3
	call	sp,Rload
	b	__PDMload_bom_map_attr_bufr

	.globl	__PDMget_map_sel_str
__PDMget_map_sel_str:
	movw	$.T1,r2
	movw	$.F6,r3
	call	sp,Rload
	b	__PDMget_map_sel_str

	.globl	__PDMXcreate_map_bufr
__PDMXcreate_map_bufr:
	movw	$.T1,r2
	movw	$.F6,r3
	call	sp,Rload
	b	__PDMXcreate_map_bufr

	.globl	__PDMupdate_catnos_in_llist
__PDMupdate_catnos_in_llist:
	movw	$.T1,r2
	movw	$.F6,r3
	call	sp,Rload
	b	__PDMupdate_catnos_in_llist
#
# Begin stubs for:  PDMgen_bom.o
#
	.data
	.align	4
.F7:	.long	0x00000700
	.byte	80, 68, 77, 103, 101, 110, 95, 98, 111, 109
	.byte	46, 111, 0
	.text

	.globl	_PDMupdate_exist_bom
_PDMupdate_exist_bom:
	movw	$.T1,r2
	movw	$.F7,r3
	call	sp,Rload
	b	_PDMupdate_exist_bom

	.globl	__PDMrollback_pdmboms
__PDMrollback_pdmboms:
	movw	$.T1,r2
	movw	$.F7,r3
	call	sp,Rload
	b	__PDMrollback_pdmboms

	.globl	__PDMget_cat_bom_vals
__PDMget_cat_bom_vals:
	movw	$.T1,r2
	movw	$.F7,r3
	call	sp,Rload
	b	__PDMget_cat_bom_vals

	.globl	__PDMget_altpartno_from_tab_dyntab
__PDMget_altpartno_from_tab_dyntab:
	movw	$.T1,r2
	movw	$.F7,r3
	call	sp,Rload
	b	__PDMget_altpartno_from_tab_dyntab

	.globl	_PDMadd_rows_to_bom
_PDMadd_rows_to_bom:
	movw	$.T1,r2
	movw	$.F7,r3
	call	sp,Rload
	b	_PDMadd_rows_to_bom

	.globl	__PDMorig_get_cat_bom_vals
__PDMorig_get_cat_bom_vals:
	movw	$.T1,r2
	movw	$.F7,r3
	call	sp,Rload
	b	__PDMorig_get_cat_bom_vals
#
# Begin stubs for:  PDMxsum_rps.o
#
	.data
	.align	4
.F8:	.long	0x00000700
	.byte	80, 68, 77, 120, 115, 117, 109, 95, 114, 112
	.byte	115, 46, 111, 0
	.text

	.globl	_PDMgen_explode_summary_bom
_PDMgen_explode_summary_bom:
	movw	$.T1,r2
	movw	$.F8,r3
	call	sp,Rload
	b	_PDMgen_explode_summary_bom

	.globl	_PDMi_setup_explode_summ_table
_PDMi_setup_explode_summ_table:
	movw	$.T1,r2
	movw	$.F8,r3
	call	sp,Rload
	b	_PDMi_setup_explode_summ_table

	.globl	_PDMGetBomAttrBufr
_PDMGetBomAttrBufr:
	movw	$.T1,r2
	movw	$.F8,r3
	call	sp,Rload
	b	_PDMGetBomAttrBufr

	.globl	_PDMGetAssyStrNUpdateBomBufr
_PDMGetAssyStrNUpdateBomBufr:
	movw	$.T1,r2
	movw	$.F8,r3
	call	sp,Rload
	b	_PDMGetAssyStrNUpdateBomBufr

	.globl	_PDMOLDget_exp_summ_bufr
_PDMOLDget_exp_summ_bufr:
	movw	$.T1,r2
	movw	$.F8,r3
	call	sp,Rload
	b	_PDMOLDget_exp_summ_bufr

	.globl	__PDMload_exp_summ_bufr
__PDMload_exp_summ_bufr:
	movw	$.T1,r2
	movw	$.F8,r3
	call	sp,Rload
	b	__PDMload_exp_summ_bufr

	.globl	_PDMget_exp_summ_bufr
_PDMget_exp_summ_bufr:
	movw	$.T1,r2
	movw	$.F8,r3
	call	sp,Rload
	b	_PDMget_exp_summ_bufr

	.globl	__PDMnewold_load_exp_summ_bufr
__PDMnewold_load_exp_summ_bufr:
	movw	$.T1,r2
	movw	$.F8,r3
	call	sp,Rload
	b	__PDMnewold_load_exp_summ_bufr
#
# Begin stubs for:  PDMbom_CID.o
#
	.data
	.align	4
.F9:	.long	0x00000700
	.byte	80, 68, 77, 98, 111, 109, 95, 67, 73, 68
	.byte	46, 111, 0
	.text

	.globl	__PDMget_cat_bom_vals_for_CID_part
__PDMget_cat_bom_vals_for_CID_part:
	movw	$.T1,r2
	movw	$.F9,r3
	call	sp,Rload
	b	__PDMget_cat_bom_vals_for_CID_part

	.globl	_PDMbom_calc_itemdesc_n_insert_for_dinpart
_PDMbom_calc_itemdesc_n_insert_for_dinpart:
	movw	$.T1,r2
	movw	$.F9,r3
	call	sp,Rload
	b	_PDMbom_calc_itemdesc_n_insert_for_dinpart

	.globl	_PDMbom_calc_itemdesc_n_insert
_PDMbom_calc_itemdesc_n_insert:
	movw	$.T1,r2
	movw	$.F9,r3
	call	sp,Rload
	b	_PDMbom_calc_itemdesc_n_insert

	.globl	_PDMbom_get_view_data
_PDMbom_get_view_data:
	movw	$.T1,r2
	movw	$.F9,r3
	call	sp,Rload
	b	_PDMbom_get_view_data
#
# Begin stubs for:  PDMbom_parst.o
#
	.data
	.align	4
.F10:	.long	0x00000700
	.byte	80, 68, 77, 98, 111, 109, 95, 112, 97, 114
	.byte	115, 116, 46, 111, 0
	.text

	.globl	_PDMload_dyn_catname_no
_PDMload_dyn_catname_no:
	movw	$.T1,r2
	movw	$.F10,r3
	call	sp,Rload
	b	_PDMload_dyn_catname_no

	.globl	__PDMget_alternate_parentname
__PDMget_alternate_parentname:
	movw	$.T1,r2
	movw	$.F10,r3
	call	sp,Rload
	b	__PDMget_alternate_parentname

	.globl	_PDMdfs_retrieve_alt_bom_struct
_PDMdfs_retrieve_alt_bom_struct:
	movw	$.T1,r2
	movw	$.F10,r3
	call	sp,Rload
	b	_PDMdfs_retrieve_alt_bom_struct

	.globl	__PDMcheck_duplicate_parent
__PDMcheck_duplicate_parent:
	movw	$.T1,r2
	movw	$.F10,r3
	call	sp,Rload
	b	__PDMcheck_duplicate_parent

	.globl	__PDMcopy_bom_llist
__PDMcopy_bom_llist:
	movw	$.T1,r2
	movw	$.F10,r3
	call	sp,Rload
	b	__PDMcopy_bom_llist

	.globl	_PDMget_alt_bom_members
_PDMget_alt_bom_members:
	movw	$.T1,r2
	movw	$.F10,r3
	call	sp,Rload
	b	_PDMget_alt_bom_members

	.comm	_s,1024
	.comm	_p_seqno2,4
	.comm	_p_seqno1,4
	.comm	_p_seqno,4
	.comm	_p_parentno,4
	.comm	_n_level,4
	.globl	_PDMfind_citc_explode
	.globl	_PDMquery_load_members
	.globl	_SQLquery
	.globl	_PSUexe_rpt
	.globl	_PDMGetAssyForEngBom
	.globl	_PDMstop_transaction
	.globl	_PDMcreate_bom_table
	.globl	_PDMget_attribute_no
	.globl	_PDMquery_report_type
	.globl	_PDMi_insert_pdmtables
	.globl	_PDMcreate_bom_table1
	.globl	_MEMopen
	.globl	__PDMupdate_pdmboms
	.globl	_strcpy
	.globl	_PDMupdate_exist_bom
	.globl	_PDMgen_bomtable_name
	.globl	_PDMget_bom_attrbs
	.globl	__PDMget_double_from_buf_val
	.globl	_PDMfind_maxlevel
	.globl	_NFMquery_set_members
	.globl	_strncpy
	.globl	_PDMget_bom_map_attrs
	.globl	_NFMquery_change_table_information
	.globl	_PDMconvert_to_lower
	.globl	_malloc
	.globl	_PDMquery_partno
	.globl	_PDMrollback_transaction
	.globl	_free
	.globl	_PDMi_get_partnum_rev
	.globl	_MEMwrite
	.globl	_PDMalt_bom_on
	.globl	_PDMget_alt_bom_members
	.globl	_NFMglobal
	.globl	_PDMload_temp_table
	.globl	__PDMdebug
	.globl	_SQLstmt
	.globl	_PDMi_find_bominfo
	.globl	_NFMdecrypt
	.globl	_PDMgen_file_name
	.globl	_strtok
	.globl	_PDMget_attribute_name
	.globl	_PDMget_bom_attr_name
	.globl	_MEMwrite_format
	.globl	_NoColsInID
	.globl	_PDMinit_psurpt
	.globl	_PDMdebug_on
	.globl	_PDMquery_cit_members
	.globl	_PDMget_new_bom_attr_bufr
	.globl	_PDMdfs_retrieve_members_for_bom
	.globl	_strncmp
	.globl	_storage
	.globl	_NFMRtic_it
	.globl	_GetID_N_Compute
	.globl	_strlen
	.globl	__PDMupdate_catnos_in_llist
	.globl	_n_level
	.globl	_PDMgen_table_name
	.globl	_NFMquery_template_definition
	.globl	_strcat
	.globl	_NFMchange_template
	.globl	_PDMbuild_attribute_string
	.globl	_strcmp
	.globl	_realloc
	.globl	_PDMverify_bomlock
	.globl	__PDMprint_bommember_info
	.globl	_PDMverify_part
	.globl	_PDM_ALT_PARENT_ATTR
	.globl	__PDMasc_to_doub
	.globl	_PDMget_table_no
	.globl	_PDMload_bom_table1
	.globl	_PDMris_get_catno
	.globl	_memset
	.globl	_NFMquery_change_template_information
	.globl	_strchr
	.globl	_PDMjoin_cits
	.globl	_PDMpart
	.globl	_atol
	.globl	_atoi
	.globl	_vals_of_attribs_in_ID
	.globl	_PDMdebug
	.globl	_GetattrsGivenID
	.globl	__PDMget_cat_bom_vals_for_CID_part
	.globl	_PDMi_delete_from_pdmtables
	.globl	_MEMbuild_array
	.globl	_PDMget_bom_attrs
	.globl	_MEMclose
	.globl	_PDMquery_catalogno
	.globl	_PDMupdate_bom_attributes
	.globl	_PDMi_maxrow_no
	.globl	_calloc
	.globl	__PDMget_data_type
	.globl	_PDMstart_transaction
	.globl	_p_seqno2
	.globl	_p_seqno1
	.globl	_PDMstructure_bom
	.globl	_p_seqno
	.globl	_attribs_in_ID
	.globl	_PSUrs_load_rpt
	.globl	_MEMwrite_data
	.globl	_sprintf
	.globl	_PDMverify_catalog
	.globl	_PDMquery_assembly_ind
	.globl	_PDMquery_table_no
	.globl	_PDMquery_bom_name
	.globl	_PDM_DEBUG_FILE
	.globl	_PDMload_part_info
	.globl	_PDMcreate_temp_table
	.globl	_PDMreport_from_tmpfile
	.globl	_PDMi_get_partnum_rev_desc
	.globl	__PDMprint_bommember
	.globl	_PDUtranslate_message
	.globl	_PDMadd_buffer_string
	.globl	_PDMxyz
	.globl	_NFMrollback_transaction
	.globl	_MEMprint_buffer
	.globl	_PDMget_new_map_bom_attr_bufr
	.globl	_dba_columns_per_page
	.globl	_PDMswap_bom_tables
	.globl	_PDMfind_p_explode
	.globl	_PDMi_find_tableinfo
	.globl	_PDMi_compare_dates
	.globl	_rMRPfree_psurpt
	.globl	_p_parentno
	.globl	_PDMget_bom_members
	.globl	_PDMexec
	.globl	_PDMget_partnum_rev_CID
