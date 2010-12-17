	.file	"PDUris.s"
#
# Begin stubs for:  RISqry.o
#
	.data
.T1:	.byte	80, 100, 117, 0
	.byte	112, 100, 117, 47, 112, 97, 108, 47, 115, 114
	.byte	99, 47, 114, 105, 115, 0
	.align	4
.F1:	.long	0x00000700
	.byte	82, 73, 83, 113, 114, 121, 46, 111, 0
	.text

	.globl	_RISqry_no_output
_RISqry_no_output:
	movw	$.T1,r2
	movw	$.F1,r3
	call	sp,Rload
	b	_RISqry_no_output
#
# Begin stubs for:  RISquery.o
#
	.data
	.align	4
.F2:	.long	0x00000700
	.byte	82, 73, 83, 113, 117, 101, 114, 121, 46, 111
	.byte	0
	.text

	.globl	_RISquery
_RISquery:
	movw	$.T1,r2
	movw	$.F2,r3
	call	sp,Rload
	b	_RISquery

	.globl	_RISint_set_sqlcode
	.globl	_strcpy
	.globl	_strncpy
	.globl	_RISint_close
	.globl	_malloc
	.globl	_RISint_execute
	.globl	_risca
	.globl	_RISdatetime_to_ascii
	.globl	_strlen
	.globl	_strcat
	.globl	_realloc
	.globl	_RISget_sqlcode
	.globl	_gets
	.globl	_RISint_prepare
	.globl	_RISint_fetch
	.globl	_RISint_describe
	.globl	_sscanf
	.globl	_RISint_report_error
	.globl	_calloc
	.globl	__pdm_debug
	.globl	_sprintf
	.globl	_RISint_clear
	.globl	_printf
