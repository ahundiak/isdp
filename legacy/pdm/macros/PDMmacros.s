	.file	"PDMmacros.s"
#
# Begin stubs for:  PDMm_parts.o
#
	.data
.T1:	.byte	80, 100, 117, 0
	.byte	112, 100, 109, 47, 109, 97, 99, 114, 111, 115
	.byte	0
	.align	4
.F1:	.long	0x00000700
	.byte	80, 68, 77, 109, 95, 112, 97, 114, 116, 115
	.byte	46, 111, 0
	.text

	.globl	_PDMppl_query_for_parts
_PDMppl_query_for_parts:
	movw	$.T1,r2
	movw	$.F1,r3
	call	sp,Rload
	b	_PDMppl_query_for_parts

	.globl	_PDMppl_query_for_catalogs
_PDMppl_query_for_catalogs:
	movw	$.T1,r2
	movw	$.F1,r3
	call	sp,Rload
	b	_PDMppl_query_for_catalogs

	.globl	_PDMppl_ris_query
_PDMppl_ris_query:
	movw	$.T1,r2
	movw	$.F1,r3
	call	sp,Rload
	b	_PDMppl_ris_query

	.globl	_PDMppl_ris_stmt
_PDMppl_ris_stmt:
	movw	$.T1,r2
	movw	$.F1,r3
	call	sp,Rload
	b	_PDMppl_ris_stmt

	.globl	_PDMppl_query_bom
_PDMppl_query_bom:
	movw	$.T1,r2
	movw	$.F1,r3
	call	sp,Rload
	b	_PDMppl_query_bom

	.globl	_PDMppl_set_alt_bom_switch
_PDMppl_set_alt_bom_switch:
	movw	$.T1,r2
	movw	$.F1,r3
	call	sp,Rload
	b	_PDMppl_set_alt_bom_switch

	.globl	_PDMppl_reset_alt_bom_switch
_PDMppl_reset_alt_bom_switch:
	movw	$.T1,r2
	movw	$.F1,r3
	call	sp,Rload
	b	_PDMppl_reset_alt_bom_switch

	.comm	_PDM_ALT_PARENT_ATTR,45
	.comm	_PDMalt_bom_on,4
	.globl	_SQLquery
	.globl	_strcpy
	.globl	_PDM_debug_on
	.globl	__PDMdebug
	.globl	_PDMquery
	.globl	_PDU_DEBUG_FILE
	.globl	_strcmp
	.globl	_atol
	.globl	_MEMbuild_array
	.globl	_PDUfill_in_string
	.globl	_MEMclose
	.globl	_calloc
	.globl	_refresh
	.globl	__pdm_debug
	.globl	_sprintf
	.globl	_PDMris_stmt
	.globl	_PDUmessage
	.globl	_MEMprint_buffer
