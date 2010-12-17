	.file	"PDMass.s"
#
# Begin stubs for:  PDMass_struc.o
#
	.data
.T1:	.byte	80, 100, 117, 0
	.byte	112, 100, 109, 47, 97, 115, 115, 0
	.align	4
.F1:	.long	0x00000700
	.byte	80, 68, 77, 97, 115, 115, 95, 115, 116, 114
	.byte	117, 99, 46, 111, 0
	.text

	.globl	_PDMcreate_temp_pdmcit
_PDMcreate_temp_pdmcit:
	movw	$.T1,r2
	movw	$.F1,r3
	call	sp,Rload
	b	_PDMcreate_temp_pdmcit

	.globl	_PDMsget_assembly_structure
_PDMsget_assembly_structure:
	movw	$.T1,r2
	movw	$.F1,r3
	call	sp,Rload
	b	_PDMsget_assembly_structure
#
# Begin stubs for:  PDMatt_struc.o
#
	.data
	.align	4
.F2:	.long	0x00000700
	.byte	80, 68, 77, 97, 116, 116, 95, 115, 116, 114
	.byte	117, 99, 46, 111, 0
	.text

	.globl	_PDMprocess_struc_attach
_PDMprocess_struc_attach:
	movw	$.T1,r2
	movw	$.F2,r3
	call	sp,Rload
	b	_PDMprocess_struc_attach
#
# Begin stubs for:  PDMchkin_cit.o
#
	.data
	.align	4
.F3:	.long	0x00000700
	.byte	80, 68, 77, 99, 104, 107, 105, 110, 95, 99
	.byte	105, 116, 46, 111, 0
	.text

	.globl	_PDMXXinsert_citinfo
_PDMXXinsert_citinfo:
	movw	$.T1,r2
	movw	$.F3,r3
	call	sp,Rload
	b	_PDMXXinsert_citinfo
#
# Begin stubs for:  PDMqry_mem.o
#
	.data
	.align	4
.F4:	.long	0x00000700
	.byte	80, 68, 77, 113, 114, 121, 95, 109, 101, 109
	.byte	46, 111, 0
	.text

	.globl	_PDMquery_ass_struc
_PDMquery_ass_struc:
	movw	$.T1,r2
	movw	$.F4,r3
	call	sp,Rload
	b	_PDMquery_ass_struc

	.globl	_PDMassembly_attributes
_PDMassembly_attributes:
	movw	$.T1,r2
	movw	$.F4,r3
	call	sp,Rload
	b	_PDMassembly_attributes

	.globl	_PDMload_ass_members
_PDMload_ass_members:
	movw	$.T1,r2
	movw	$.F4,r3
	call	sp,Rload
	b	_PDMload_ass_members

	.globl	_SQLquery
	.globl	_PDMstop_transaction
	.globl	_MEMopen
	.globl	_strcpy
	.globl	_PDMload_catno
	.globl	_malloc
	.globl	_PDMrollback_transaction
	.globl	_free
	.globl	_MEMwrite
	.globl	__PDMdebug
	.globl	_SQLstmt
	.globl	_PDMi_insert_pdcinfo
	.globl	_MEMwrite_format
	.globl	_PDMdebug_on
	.globl	_MEMreset_buffer_no
	.globl	_strlen
	.globl	_strcat
	.globl	_strcmp
	.globl	_sleep
	.globl	_PDMquery_ass_struc
	.globl	_PDMris_get_catno
	.globl	_UI_status
	.globl	_PDMpart
	.globl	_ERRload_struct
	.globl	_atol
	.globl	_atoi
	.globl	_PDMdebug
	.globl	_MEMbuild_array
	.globl	_MEMclose
	.globl	_PDMi_maxrow_no
	.globl	_PDMstart_transaction
	.globl	_PDMupdate_dots
	.globl	__sql_error
	.globl	_MEMwrite_data
	.globl	_sprintf
	.globl	_PDM_DEBUG_FILE
	.globl	_PDMload_part_info
	.globl	_PDUtranslate_message
	.globl	_PDMi_delete_dynamic_info
	.globl	_MEMprint_buffer
	.globl	_PDMQueryAssyIndPTypePDesc
	.globl	_PDMexec
