	.file	"PDMmulfile.s"
#
# Begin stubs for:  PDMnew_part.o
#
	.data
.T1:	.byte	80, 100, 117, 0
	.byte	112, 100, 109, 47, 109, 117, 108, 102, 105, 108
	.byte	101, 0
	.align	4
.F1:	.long	0x00000700
	.byte	80, 68, 77, 110, 101, 119, 95, 112, 97, 114
	.byte	116, 46, 111, 0
	.text

	.globl	_PDMprepare_file_info
_PDMprepare_file_info:
	movw	$.T1,r2
	movw	$.F1,r3
	call	sp,Rload
	b	_PDMprepare_file_info

	.globl	_PDMtranslate_item_flag
_PDMtranslate_item_flag:
	movw	$.T1,r2
	movw	$.F1,r3
	call	sp,Rload
	b	_PDMtranslate_item_flag

	.globl	_PDMadd_file_bufr
_PDMadd_file_bufr:
	movw	$.T1,r2
	movw	$.F1,r3
	call	sp,Rload
	b	_PDMadd_file_bufr

	.globl	_PDM20modify_part
_PDM20modify_part:
	movw	$.T1,r2
	movw	$.F1,r3
	call	sp,Rload
	b	_PDM20modify_part
#
# Begin stubs for:  PDMadd_del.o
#
	.data
	.align	4
.F2:	.long	0x00000700
	.byte	80, 68, 77, 97, 100, 100, 95, 100, 101, 108
	.byte	46, 111, 0
	.text

	.globl	_PDMdelete_files_from_part
_PDMdelete_files_from_part:
	movw	$.T1,r2
	movw	$.F2,r3
	call	sp,Rload
	b	_PDMdelete_files_from_part

	.globl	_SQLquery
	.globl	_NFMcancel_update_item
	.globl	_PDMstop_transaction
	.globl	_NFMget_file_information
	.globl	_PDMrollback_transaction
	.globl	_NFMreset_file_information
	.globl	__PDMdebug
	.globl	_SQLstmt
	.globl	_PDMdebug_on
	.globl	_strncmp
	.globl	_NFMupdate_item
	.globl	_ERRget_specific_number
	.globl	_strcmp
	.globl	_PDMpart
	.globl	_PDMdebug
	.globl	_MEMclose
	.globl	_PDMstart_transaction
	.globl	_sprintf
	.globl	_PDM_DEBUG_FILE
	.globl	_PDMload_part_info
	.globl	_MEMprint_buffer
	.globl	_MEMprint_buffers
	.globl	_MEMappend
	.globl	_PDMexec
	.globl	_NFMdefine_file_information
