	.file	"PDUpalpdmr.s"
#
# Begin stubs for:  PDMgetstat.o
#
	.data
.T1:	.byte	80, 100, 117, 0
	.byte	112, 100, 117, 47, 112, 97, 108, 47, 115, 114
	.byte	99, 47, 112, 100, 109, 114, 0
	.align	4
.F1:	.long	0x00000700
	.byte	80, 68, 77, 103, 101, 116, 115, 116, 97, 116
	.byte	46, 111, 0
	.text

	.globl	_GetUniqRecord
_GetUniqRecord:
	movw	$.T1,r2
	movw	$.F1,r3
	call	sp,Rload
	b	_GetUniqRecord

	.globl	_GetStaticAttribsAddToRgObj
_GetStaticAttribsAddToRgObj:
	movw	$.T1,r2
	movw	$.F1,r3
	call	sp,Rload
	b	_GetStaticAttribsAddToRgObj

	.globl	_ComputeIDAddToDynCol
_ComputeIDAddToDynCol:
	movw	$.T1,r2
	movw	$.F1,r3
	call	sp,Rload
	b	_ComputeIDAddToDynCol

	.globl	_getattrs
_getattrs:
	movw	$.T1,r2
	movw	$.F1,r3
	call	sp,Rload
	b	_getattrs

	.globl	_check_CID
_check_CID:
	movw	$.T1,r2
	movw	$.F1,r3
	call	sp,Rload
	b	_check_CID

	.globl	_AddStatAttrsToQuery
_AddStatAttrsToQuery:
	movw	$.T1,r2
	movw	$.F1,r3
	call	sp,Rload
	b	_AddStatAttrsToQuery
#
# Begin stubs for:  PDMrsrch.o
#
	.data
	.align	4
.F2:	.long	0x00000700
	.byte	80, 68, 77, 114, 115, 114, 99, 104, 46, 111
	.byte	0
	.text

	.globl	_CleanUpSlctdAttribs
_CleanUpSlctdAttribs:
	movw	$.T1,r2
	movw	$.F2,r3
	call	sp,Rload
	b	_CleanUpSlctdAttribs

	.globl	_RebuildShortList
_RebuildShortList:
	movw	$.T1,r2
	movw	$.F2,r3
	call	sp,Rload
	b	_RebuildShortList

	.globl	_UpdateShortList
_UpdateShortList:
	movw	$.T1,r2
	movw	$.F2,r3
	call	sp,Rload
	b	_UpdateShortList

	.globl	_ParamSearchOnMultipleCtlgs
_ParamSearchOnMultipleCtlgs:
	movw	$.T1,r2
	movw	$.F2,r3
	call	sp,Rload
	b	_ParamSearchOnMultipleCtlgs

	.globl	_do_search
_do_search:
	movw	$.T1,r2
	movw	$.F2,r3
	call	sp,Rload
	b	_do_search

	.globl	_where_condition_line
_where_condition_line:
	movw	$.T1,r2
	movw	$.F2,r3
	call	sp,Rload
	b	_where_condition_line

	.globl	_pdutimestamp_to_ascii
_pdutimestamp_to_ascii:
	movw	$.T1,r2
	movw	$.F2,r3
	call	sp,Rload
	b	_pdutimestamp_to_ascii

	.globl	_CnvtOperNCriteriaToCondition
_CnvtOperNCriteriaToCondition:
	movw	$.T1,r2
	movw	$.F2,r3
	call	sp,Rload
	b	_CnvtOperNCriteriaToCondition

	.globl	_search_on_multiple_ctlgs
_search_on_multiple_ctlgs:
	movw	$.T1,r2
	movw	$.F2,r3
	call	sp,Rload
	b	_search_on_multiple_ctlgs

	.globl	_do_global_search
_do_global_search:
	movw	$.T1,r2
	movw	$.F2,r3
	call	sp,Rload
	b	_do_global_search

	.globl	_add_bufr_to_global_buffer
_add_bufr_to_global_buffer:
	movw	$.T1,r2
	movw	$.F2,r3
	call	sp,Rload
	b	_add_bufr_to_global_buffer

	.globl	_gen_condition_line
_gen_condition_line:
	movw	$.T1,r2
	movw	$.F2,r3
	call	sp,Rload
	b	_gen_condition_line

	.globl	_validate_search_criteria_input
_validate_search_criteria_input:
	movw	$.T1,r2
	movw	$.F2,r3
	call	sp,Rload
	b	_validate_search_criteria_input

	.globl	_PDUgetDefPlcmntName
_PDUgetDefPlcmntName:
	movw	$.T1,r2
	movw	$.F2,r3
	call	sp,Rload
	b	_PDUgetDefPlcmntName

	.globl	_build_and_cond
_build_and_cond:
	movw	$.T1,r2
	movw	$.F2,r3
	call	sp,Rload
	b	_build_and_cond

	.globl	_GetTheseGivenThose
_GetTheseGivenThose:
	movw	$.T1,r2
	movw	$.F2,r3
	call	sp,Rload
	b	_GetTheseGivenThose

	.globl	_format_searchlist_bufr
_format_searchlist_bufr:
	movw	$.T1,r2
	movw	$.F2,r3
	call	sp,Rload
	b	_format_searchlist_bufr

	.globl	_PALgetPartType
_PALgetPartType:
	movw	$.T1,r2
	movw	$.F2,r3
	call	sp,Rload
	b	_PALgetPartType
#
# Begin stubs for:  PDMrsaclist.o
#
	.data
	.align	4
.F3:	.long	0x00000700
	.byte	80, 68, 77, 114, 115, 97, 99, 108, 105, 115
	.byte	116, 46, 111, 0
	.text

	.globl	_search_on_multiple_ctlgs_for_format
_search_on_multiple_ctlgs_for_format:
	movw	$.T1,r2
	movw	$.F3,r3
	call	sp,Rload
	b	_search_on_multiple_ctlgs_for_format

	.globl	_do_incremental_search_for_format
_do_incremental_search_for_format:
	movw	$.T1,r2
	movw	$.F3,r3
	call	sp,Rload
	b	_do_incremental_search_for_format

	.globl	_add_bufr_to_global_buffer_for_format
_add_bufr_to_global_buffer_for_format:
	movw	$.T1,r2
	movw	$.F3,r3
	call	sp,Rload
	b	_add_bufr_to_global_buffer_for_format
#
# Begin stubs for:  PDMlistatr.o
#
	.data
	.align	4
.F4:	.long	0x00000700
	.byte	80, 68, 77, 108, 105, 115, 116, 97, 116, 114
	.byte	46, 111, 0
	.text

	.globl	_search_list_format_attribs
_search_list_format_attribs:
	movw	$.T1,r2
	movw	$.F4,r3
	call	sp,Rload
	b	_search_list_format_attribs

	.globl	_SearchListAttribsAcrossCatalogs
_SearchListAttribsAcrossCatalogs:
	movw	$.T1,r2
	movw	$.F4,r3
	call	sp,Rload
	b	_SearchListAttribsAcrossCatalogs

	.globl	_PALgetcatlist_for_format_attributes
_PALgetcatlist_for_format_attributes:
	movw	$.T1,r2
	movw	$.F4,r3
	call	sp,Rload
	b	_PALgetcatlist_for_format_attributes

	.globl	_GetReportFormatAttribs
_GetReportFormatAttribs:
	movw	$.T1,r2
	movw	$.F4,r3
	call	sp,Rload
	b	_GetReportFormatAttribs
#
# Begin stubs for:  PDMsrcatr.o
#
	.data
	.align	4
.F5:	.long	0x00000700
	.byte	80, 68, 77, 115, 114, 99, 97, 116, 114, 46
	.byte	111, 0
	.text

	.globl	_search_common_attribs
_search_common_attribs:
	movw	$.T1,r2
	movw	$.F5,r3
	call	sp,Rload
	b	_search_common_attribs

	.globl	_PALgetcatlist
_PALgetcatlist:
	movw	$.T1,r2
	movw	$.F5,r3
	call	sp,Rload
	b	_PALgetcatlist

	.globl	_SearchAttribsAcrossCatalogs
_SearchAttribsAcrossCatalogs:
	movw	$.T1,r2
	movw	$.F5,r3
	call	sp,Rload
	b	_SearchAttribsAcrossCatalogs

	.globl	_GetCatTableNo
_GetCatTableNo:
	movw	$.T1,r2
	movw	$.F5,r3
	call	sp,Rload
	b	_GetCatTableNo

	.globl	_GetCatAttribs
_GetCatAttribs:
	movw	$.T1,r2
	movw	$.F5,r3
	call	sp,Rload
	b	_GetCatAttribs

	.globl	_GetCatalogDesc
_GetCatalogDesc:
	movw	$.T1,r2
	movw	$.F5,r3
	call	sp,Rload
	b	_GetCatalogDesc

	.globl	_get_macro_name
_get_macro_name:
	movw	$.T1,r2
	movw	$.F5,r3
	call	sp,Rload
	b	_get_macro_name

	.globl	_SetOrGet_command_flag
_SetOrGet_command_flag:
	movw	$.T1,r2
	movw	$.F5,r3
	call	sp,Rload
	b	_SetOrGet_command_flag

	.globl	_BuildAQuery
_BuildAQuery:
	movw	$.T1,r2
	movw	$.F5,r3
	call	sp,Rload
	b	_BuildAQuery

	.globl	_GetMacroName
_GetMacroName:
	movw	$.T1,r2
	movw	$.F5,r3
	call	sp,Rload
	b	_GetMacroName

	.globl	_UseAttrListInQuery
_UseAttrListInQuery:
	movw	$.T1,r2
	movw	$.F5,r3
	call	sp,Rload
	b	_UseAttrListInQuery

	.globl	_search_list_attribs
_search_list_attribs:
	movw	$.T1,r2
	movw	$.F5,r3
	call	sp,Rload
	b	_search_list_attribs
#
# Begin stubs for:  PDMgetcat.o
#
	.data
	.align	4
.F6:	.long	0x00000700
	.byte	80, 68, 77, 103, 101, 116, 99, 97, 116, 46
	.byte	111, 0
	.text

	.globl	_GetDepthofCatalog
_GetDepthofCatalog:
	movw	$.T1,r2
	movw	$.F6,r3
	call	sp,Rload
	b	_GetDepthofCatalog

	.globl	_GetCatPath
_GetCatPath:
	movw	$.T1,r2
	movw	$.F6,r3
	call	sp,Rload
	b	_GetCatPath
#
# Begin stubs for:  PDMrsac.o
#
	.data
	.align	4
.F7:	.long	0x00000700
	.byte	80, 68, 77, 114, 115, 97, 99, 46, 111, 0
	.text

	.globl	_search_on_multiple_ctlgs_with_union
_search_on_multiple_ctlgs_with_union:
	movw	$.T1,r2
	movw	$.F7,r3
	call	sp,Rload
	b	_search_on_multiple_ctlgs_with_union

	.globl	_gen_valid_list_of_catalogs
_gen_valid_list_of_catalogs:
	movw	$.T1,r2
	movw	$.F7,r3
	call	sp,Rload
	b	_gen_valid_list_of_catalogs

	.globl	_do_incremental_search_with_union
_do_incremental_search_with_union:
	movw	$.T1,r2
	movw	$.F7,r3
	call	sp,Rload
	b	_do_incremental_search_with_union

	.globl	_add_bufr_to_global_buffer_for_union
_add_bufr_to_global_buffer_for_union:
	movw	$.T1,r2
	movw	$.F7,r3
	call	sp,Rload
	b	_add_bufr_to_global_buffer_for_union
#
# Begin stubs for:  PDMunionatr.o
#
	.data
	.align	4
.F8:	.long	0x00000700
	.byte	80, 68, 77, 117, 110, 105, 111, 110, 97, 116
	.byte	114, 46, 111, 0
	.text

	.globl	_search_union_attribs
_search_union_attribs:
	movw	$.T1,r2
	movw	$.F8,r3
	call	sp,Rload
	b	_search_union_attribs

	.globl	_SearchUnionAttribsAcrossCatalogs
_SearchUnionAttribsAcrossCatalogs:
	movw	$.T1,r2
	movw	$.F8,r3
	call	sp,Rload
	b	_SearchUnionAttribsAcrossCatalogs

	.globl	_GetUnionCatAttribs
_GetUnionCatAttribs:
	movw	$.T1,r2
	movw	$.F8,r3
	call	sp,Rload
	b	_GetUnionCatAttribs
#
# Begin stubs for:  CID.o
#
	.data
	.align	4
.F9:	.long	0x00000700
	.byte	67, 73, 68, 46, 111, 0
	.text

	.globl	_FreeConditionTable
_FreeConditionTable:
	movw	$.T1,r2
	movw	$.F9,r3
	call	sp,Rload
	b	_FreeConditionTable

	.globl	_GetCondition
_GetCondition:
	movw	$.T1,r2
	movw	$.F9,r3
	call	sp,Rload
	b	_GetCondition

	.globl	_GetAssignment
_GetAssignment:
	movw	$.T1,r2
	movw	$.F9,r3
	call	sp,Rload
	b	_GetAssignment

	.globl	_MakeConditionTable
_MakeConditionTable:
	movw	$.T1,r2
	movw	$.F9,r3
	call	sp,Rload
	b	_MakeConditionTable

	.globl	_GetParamIndex
_GetParamIndex:
	movw	$.T1,r2
	movw	$.F9,r3
	call	sp,Rload
	b	_GetParamIndex

	.globl	_EvaluateCondition
_EvaluateCondition:
	movw	$.T1,r2
	movw	$.F9,r3
	call	sp,Rload
	b	_EvaluateCondition

	.globl	_DLExpression
_DLExpression:
	movw	$.T1,r2
	movw	$.F9,r3
	call	sp,Rload
	b	_DLExpression

	.globl	_DLStringExpression
_DLStringExpression:
	movw	$.T1,r2
	movw	$.F9,r3
	call	sp,Rload
	b	_DLStringExpression

	.globl	_GetID_N_Compute
_GetID_N_Compute:
	movw	$.T1,r2
	movw	$.F9,r3
	call	sp,Rload
	b	_GetID_N_Compute

	.globl	_Getpartnumber
_Getpartnumber:
	movw	$.T1,r2
	movw	$.F9,r3
	call	sp,Rload
	b	_Getpartnumber

	.globl	_GetattrsGivenID
_GetattrsGivenID:
	movw	$.T1,r2
	movw	$.F9,r3
	call	sp,Rload
	b	_GetattrsGivenID

	.globl	_PosMarkers
_PosMarkers:
	movw	$.T1,r2
	movw	$.F9,r3
	call	sp,Rload
	b	_PosMarkers

	.globl	_GetPartnumberDesc_PDMNORM
_GetPartnumberDesc_PDMNORM:
	movw	$.T1,r2
	movw	$.F9,r3
	call	sp,Rload
	b	_GetPartnumberDesc_PDMNORM

	.globl	_NOTUSED_GetPartnumberDesc
_NOTUSED_GetPartnumberDesc:
	movw	$.T1,r2
	movw	$.F9,r3
	call	sp,Rload
	b	_NOTUSED_GetPartnumberDesc

	.comm	_AttrTypes,4
	.comm	_AttrValsRep_PPart,4
	.comm	_TblNos,8000
	.comm	_NumCatalogs,4
	.comm	_NoExpressions,4
	.comm	_CatNameList,40000
	.comm	_DLresult,40
	.comm	_AttrSynonym,4
	.comm	_ConditionTable,8
	.comm	_CID_yyin,4
	.comm	_RetVal,4
	.comm	_NumAttribs,4
	.comm	_ViewOrTblList,12000
	.comm	_AttrList,4
	.globl	_set_table_field_for_union_or_format
	.globl	_SQLquery
	.globl	_GetAttribindx
	.globl	_MEMopen
	.globl	_format_column
	.globl	_strcpy
	.globl	_EXPlocate
	.globl	_gen_condition_line
	.globl	_PDU_cat_selected
	.globl	_set_table_field
	.globl	_strncpy
	.globl	_PDMconvert_to_lower
	.globl	_PDU_part_sort_string
	.globl	_get_row_from_mcf
	.globl	_add_to_puldwn_list
	.globl	_GetCatTableNo
	.globl	_malloc
	.globl	_get_text_exp_value
	.globl	_free
	.globl	_MEMwrite
	.globl	_CatNameList
	.globl	_warn_box
	.globl	__PDMdebug
	.globl	_define_Aoperator
	.globl	_PALgetcatlist
	.globl	_strtok
	.globl	_FIf_reset
	.globl	_set_sub_form_params
	.globl	_parse_exp_and_get_value
	.globl	_display_all
	.globl	__iob
	.globl	_MEMwrite_format
	.globl	_RISquery
	.globl	_NoColsInID
	.globl	_SVSFreeTablesAndColumns
	.globl	_PDU_DEBUG_FILE
	.globl	_PDMdebug_on
	.globl	_PDU_command
	.globl	_add_quotes
	.globl	_strncmp
	.globl	_AttrTypes
	.globl	_MEMsplit_copy_buffer
	.globl	_GetID_N_Compute
	.globl	_PDU_srch_catalog
	.globl	_strlen
	.globl	_add_bufr_to_global_buffer_for_format
	.globl	_strcat
	.globl	_getattrs
	.globl	__pdm_status
	.globl	_NumAttribs
	.globl	_strcmp
	.globl	_realloc
	.globl	_NumCatalogs
	.globl	_ReadAtrsFromCols
	.globl	_PDU_ComputedID
	.globl	_AttrSynonym
	.globl	_strchr
	.globl	_RIS_box
	.globl	_fclose
	.globl	_s_text
	.globl	_add_attribute
	.globl	_atoi
	.globl	_atof
	.globl	_vals_of_attribs_in_ID
	.globl	_GetOriginalMacroInfo
	.globl	_sscanf
	.globl	_GetattrsGivenID
	.globl	_max_rows_rtvd
	.globl	_from_cat_to_work_units
	.globl	_to_lower
	.globl	_MEMbuild_array
	.globl	_MEMclose
	.globl	_CheckACrgAttribVal
	.globl	_fprintf
	.globl	_SVSGetTablesAndColumnsInView
	.globl	_row_num
	.globl	_IGEresetstop
	.globl	_refresh
	.globl	_attribs_in_ID
	.globl	__pdm_debug
	.globl	_CID_yyparse
	.globl	_sprintf
	.globl	_FImcf_set_select
	.globl	_PDMSQLquery
	.globl	_set_sub_form_params_for_union
	.globl	_PDUmessage
	.globl	_GetDyncolIndx
	.globl	_PDUtranslate_message
	.globl	_FIg_reset
	.globl	_MEMprint_buffer
	.globl	_MEMprint_buffers
	.globl	_gen_valid_list_of_catalogs
	.globl	_PALis_sort_selected
	.globl	_AttrList
	.globl	_printf
	.globl	_FIfld_set_text
	.globl	_IGEstop
	.globl	_FreeArrayPtr
	.globl	_Get_text
	.globl	_PDUsearch_part_list
	.globl	_fopen
	.globl	_MEMappend
	.globl	_PDMget_dyntable_for_catalog
