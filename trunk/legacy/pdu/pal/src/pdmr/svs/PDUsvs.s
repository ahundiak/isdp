	.file	"PDUsvs.s"
#
# Begin stubs for:  svs.o
#
	.data
.T1:	.byte	80, 100, 117, 0
	.byte	112, 100, 117, 47, 112, 97, 108, 47, 115, 114
	.byte	99, 47, 112, 100, 109, 114, 47, 115, 118, 115
	.byte	0
	.align	4
.F1:	.long	0x00000700
	.byte	115, 118, 115, 46, 111, 0
	.text

	.globl	_Search
_Search:
	movw	$.T1,r2
	movw	$.F1,r3
	call	sp,Rload
	b	_Search

	.globl	_SVSToLower
_SVSToLower:
	movw	$.T1,r2
	movw	$.F1,r3
	call	sp,Rload
	b	_SVSToLower

	.globl	_ParseColumn
_ParseColumn:
	movw	$.T1,r2
	movw	$.F1,r3
	call	sp,Rload
	b	_ParseColumn

	.globl	_GetColumnValues
_GetColumnValues:
	movw	$.T1,r2
	movw	$.F1,r3
	call	sp,Rload
	b	_GetColumnValues

	.globl	_ProcessColsAndFormula
_ProcessColsAndFormula:
	movw	$.T1,r2
	movw	$.F1,r3
	call	sp,Rload
	b	_ProcessColsAndFormula

	.globl	_BuildWhere
_BuildWhere:
	movw	$.T1,r2
	movw	$.F1,r3
	call	sp,Rload
	b	_BuildWhere

	.globl	_ProcessRISoutput
_ProcessRISoutput:
	movw	$.T1,r2
	movw	$.F1,r3
	call	sp,Rload
	b	_ProcessRISoutput

	.globl	_StoreVal
_StoreVal:
	movw	$.T1,r2
	movw	$.F1,r3
	call	sp,Rload
	b	_StoreVal

	.globl	_Initialize
_Initialize:
	movw	$.T1,r2
	movw	$.F1,r3
	call	sp,Rload
	b	_Initialize

	.globl	_GetViewDef
_GetViewDef:
	movw	$.T1,r2
	movw	$.F1,r3
	call	sp,Rload
	b	_GetViewDef

	.globl	_CreateViewTable
_CreateViewTable:
	movw	$.T1,r2
	movw	$.F1,r3
	call	sp,Rload
	b	_CreateViewTable

	.globl	_ParseAndTest
_ParseAndTest:
	movw	$.T1,r2
	movw	$.F1,r3
	call	sp,Rload
	b	_ParseAndTest

	.globl	_Between
_Between:
	movw	$.T1,r2
	movw	$.F1,r3
	call	sp,Rload
	b	_Between

	.globl	_CleanString
_CleanString:
	movw	$.T1,r2
	movw	$.F1,r3
	call	sp,Rload
	b	_CleanString

	.globl	_GetColVal
_GetColVal:
	movw	$.T1,r2
	movw	$.F1,r3
	call	sp,Rload
	b	_GetColVal

	.globl	_Expression
_Expression:
	movw	$.T1,r2
	movw	$.F1,r3
	call	sp,Rload
	b	_Expression

	.globl	_StringExpression
_StringExpression:
	movw	$.T1,r2
	movw	$.F1,r3
	call	sp,Rload
	b	_StringExpression

	.globl	_InValueList
_InValueList:
	movw	$.T1,r2
	movw	$.F1,r3
	call	sp,Rload
	b	_InValueList

	.globl	_IsValueInTable
_IsValueInTable:
	movw	$.T1,r2
	movw	$.F1,r3
	call	sp,Rload
	b	_IsValueInTable

	.globl	_IsNull
_IsNull:
	movw	$.T1,r2
	movw	$.F1,r3
	call	sp,Rload
	b	_IsNull

	.globl	_LikeString
_LikeString:
	movw	$.T1,r2
	movw	$.F1,r3
	call	sp,Rload
	b	_LikeString

	.globl	_StartWithWildCard
_StartWithWildCard:
	movw	$.T1,r2
	movw	$.F1,r3
	call	sp,Rload
	b	_StartWithWildCard

	.globl	_EndWithWildCard
_EndWithWildCard:
	movw	$.T1,r2
	movw	$.F1,r3
	call	sp,Rload
	b	_EndWithWildCard

	.globl	_SameTableColumns
_SameTableColumns:
	movw	$.T1,r2
	movw	$.F1,r3
	call	sp,Rload
	b	_SameTableColumns

	.globl	_ClearDependentParams
_ClearDependentParams:
	movw	$.T1,r2
	movw	$.F1,r3
	call	sp,Rload
	b	_ClearDependentParams

	.globl	_InitSmartViewSearch
_InitSmartViewSearch:
	movw	$.T1,r2
	movw	$.F1,r3
	call	sp,Rload
	b	_InitSmartViewSearch

	.globl	_SVSGetTablesAndColumnsInView
_SVSGetTablesAndColumnsInView:
	movw	$.T1,r2
	movw	$.F1,r3
	call	sp,Rload
	b	_SVSGetTablesAndColumnsInView

	.globl	_ParseViewDefinition
_ParseViewDefinition:
	movw	$.T1,r2
	movw	$.F1,r3
	call	sp,Rload
	b	_ParseViewDefinition

	.globl	_AddToList
_AddToList:
	movw	$.T1,r2
	movw	$.F1,r3
	call	sp,Rload
	b	_AddToList

	.globl	_SVSFreeTablesAndColumns
_SVSFreeTablesAndColumns:
	movw	$.T1,r2
	movw	$.F1,r3
	call	sp,Rload
	b	_SVSFreeTablesAndColumns
#
# Begin stubs for:  svswrk.o
#
	.data
	.align	4
.F2:	.long	0x00000700
	.byte	115, 118, 115, 119, 114, 107, 46, 111, 0
	.text

	.globl	_DoesSVSWork
_DoesSVSWork:
	movw	$.T1,r2
	movw	$.F2,r3
	call	sp,Rload
	b	_DoesSVSWork

	.comm	_cols_in_form,360
	.comm	_slctd_params,3240
	.comm	_from_same_tbl,360
	.comm	_col_val,144
	.comm	_start,180
	.globl	_strcpy
	.globl	_exp_cond
	.globl	_EXPlocate
	.globl	_PDU_v_yyin
	.globl	_SVSon
	.globl	_InitSmartViewSearch
	.globl	_malloc
	.globl	_free
	.globl	_ViewTable
	.globl	_NoRows
	.globl	_CurrentSVSView
	.globl	_strtok
	.globl	_TableColList
	.globl	_VueColTypes
	.globl	_NoTables
	.globl	__iob
	.globl	_result
	.globl	_PDU_v_yyparse
	.globl	_RISquery
	.globl	_vals_of_cols
	.globl	_strncmp
	.globl	_NoCols
	.globl	_strlen
	.globl	_strcat
	.globl	__ctype
	.globl	_strcmp
	.globl	_realloc
	.globl	_tolower
	.globl	_NoSlctd
	.globl	_fclose
	.globl	_atof
	.globl	_NoParams
	.globl	_NoExp
	.globl	_PDU_c_yyin
	.globl	_PDU_c_yyparse
	.globl	_fprintf
	.globl	_ViewParamList
	.globl	_refresh
	.globl	_values
	.globl	__pdm_debug
	.globl	_sprintf
	.globl	_printf
	.globl	_fopen
