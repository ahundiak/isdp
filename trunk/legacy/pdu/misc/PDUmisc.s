	.file	"PDUmisc.s"
#
# Begin stubs for:  PDUnode_info.o
#
	.data
.T1:	.byte	80, 100, 117, 0
	.byte	112, 100, 117, 47, 109, 105, 115, 99, 0
	.align	4
.F1:	.long	0x00000700
	.byte	80, 68, 85, 110, 111, 100, 101, 95, 105, 110
	.byte	102, 111, 46, 111, 0
	.text

	.globl	_PDUget_user_node_info
_PDUget_user_node_info:
	movw	$.T1,r2
	movw	$.F1,r3
	call	sp,Rload
	b	_PDUget_user_node_info

	.globl	_PDUload_storage_area
_PDUload_storage_area:
	movw	$.T1,r2
	movw	$.F1,r3
	call	sp,Rload
	b	_PDUload_storage_area

	.globl	_PDUget_storage_buffer
_PDUget_storage_buffer:
	movw	$.T1,r2
	movw	$.F1,r3
	call	sp,Rload
	b	_PDUget_storage_buffer

	.globl	_PDUprint_storage_area
_PDUprint_storage_area:
	movw	$.T1,r2
	movw	$.F1,r3
	call	sp,Rload
	b	_PDUprint_storage_area
#
# Begin stubs for:  PDUget_node.o
#
	.data
	.align	4
.F2:	.long	0x00000700
	.byte	80, 68, 85, 103, 101, 116, 95, 110, 111, 100
	.byte	101, 46, 111, 0
	.text

	.globl	_MYget_node_name
_MYget_node_name:
	movw	$.T1,r2
	movw	$.F2,r3
	call	sp,Rload
	b	_MYget_node_name
#
# Begin stubs for:  PDUmiscapi.o
#
	.data
	.align	4
.F3:	.long	0x00000700
	.byte	80, 68, 85, 109, 105, 115, 99, 97, 112, 105
	.byte	46, 111, 0
	.text

	.globl	_PDUget_sun_nodename
_PDUget_sun_nodename:
	movw	$.T1,r2
	movw	$.F3,r3
	call	sp,Rload
	b	_PDUget_sun_nodename

	.globl	_crypt
	.globl	_strcpy
	.globl	_user
	.globl	_malloc
	.globl	_get_remote_path
	.globl	_free
	.globl	_MEMwrite
	.globl	_clh_vbyop
	.globl	_getuid
	.globl	_strtok
	.globl	_storage
	.globl	_getpwuid
	.globl	_PDUadd_buffer_string
	.globl	_strlen
	.globl	__pdm_status
	.globl	_strcmp
	.globl	_strstr
	.globl	_memset
	.globl	_fclose
	.globl	_PDMopen_buffer
	.globl	_PDUfill_in_string
	.globl	_refresh
	.globl	__pdm_debug
	.globl	_sprintf
	.globl	_PDUmessage
	.globl	_fgets
	.globl	_getenv
	.globl	_PDUread_refresh_file
	.globl	_fopen
