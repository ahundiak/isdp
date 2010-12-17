	.file	"PDMreports.s"
#
# Begin stubs for:  PDMbom_rps.o
#
	.data
.T1:	.byte	80, 100, 117, 0
	.byte	112, 100, 109, 47, 114, 101, 112, 111, 114, 116
	.byte	115, 0
	.align	4
.F1:	.long	0x00000700
	.byte	80, 68, 77, 98, 111, 109, 95, 114, 112, 115
	.byte	46, 111, 0
	.text

	.globl	_PDMgen_bomparts_list
_PDMgen_bomparts_list:
	movw	$.T1,r2
	movw	$.F1,r3
	call	sp,Rload
	b	_PDMgen_bomparts_list

	.globl	_PDMi_setup_table1
_PDMi_setup_table1:
	movw	$.T1,r2
	movw	$.F1,r3
	call	sp,Rload
	b	_PDMi_setup_table1

	.globl	_PDMload_seq_tagnos
_PDMload_seq_tagnos:
	movw	$.T1,r2
	movw	$.F1,r3
	call	sp,Rload
	b	_PDMload_seq_tagnos

	.globl	_PDMi_find_seqtagnos
_PDMi_find_seqtagnos:
	movw	$.T1,r2
	movw	$.F1,r3
	call	sp,Rload
	b	_PDMi_find_seqtagnos

	.globl	_PDMgen_summary_bom
_PDMgen_summary_bom:
	movw	$.T1,r2
	movw	$.F1,r3
	call	sp,Rload
	b	_PDMgen_summary_bom

	.globl	_PDMi_setup_table2
_PDMi_setup_table2:
	movw	$.T1,r2
	movw	$.F1,r3
	call	sp,Rload
	b	_PDMi_setup_table2

	.globl	_PDMi_query_non_assemblies
_PDMi_query_non_assemblies:
	movw	$.T1,r2
	movw	$.F1,r3
	call	sp,Rload
	b	_PDMi_query_non_assemblies

	.globl	_PDMGetChildListBufr
_PDMGetChildListBufr:
	movw	$.T1,r2
	movw	$.F1,r3
	call	sp,Rload
	b	_PDMGetChildListBufr

	.globl	_PDMRetrieveMembersWithModifiedQty
_PDMRetrieveMembersWithModifiedQty:
	movw	$.T1,r2
	movw	$.F1,r3
	call	sp,Rload
	b	_PDMRetrieveMembersWithModifiedQty
#
# Begin stubs for:  PDMcit_rps.o
#
	.data
	.align	4
.F2:	.long	0x00000700
	.byte	80, 68, 77, 99, 105, 116, 95, 114, 112, 115
	.byte	46, 111, 0
	.text

	.globl	_PDMsgen_where_used_imm
_PDMsgen_where_used_imm:
	movw	$.T1,r2
	movw	$.F2,r3
	call	sp,Rload
	b	_PDMsgen_where_used_imm

	.globl	_PDMi_setup_table3
_PDMi_setup_table3:
	movw	$.T1,r2
	movw	$.F2,r3
	call	sp,Rload
	b	_PDMi_setup_table3

	.globl	_PDMsgen_where_used_top
_PDMsgen_where_used_top:
	movw	$.T1,r2
	movw	$.F2,r3
	call	sp,Rload
	b	_PDMsgen_where_used_top

	.globl	_PDMi_setup_table4
_PDMi_setup_table4:
	movw	$.T1,r2
	movw	$.F2,r3
	call	sp,Rload
	b	_PDMi_setup_table4

	.globl	_PDMi_recurse_to_highest
_PDMi_recurse_to_highest:
	movw	$.T1,r2
	movw	$.F2,r3
	call	sp,Rload
	b	_PDMi_recurse_to_highest

	.globl	_PDMreport_of_loc
_PDMreport_of_loc:
	movw	$.T1,r2
	movw	$.F2,r3
	call	sp,Rload
	b	_PDMreport_of_loc

	.globl	_PDMcreate_nfmpdmcat_view
_PDMcreate_nfmpdmcat_view:
	movw	$.T1,r2
	movw	$.F2,r3
	call	sp,Rload
	b	_PDMcreate_nfmpdmcat_view

	.globl	_PDMreport_of_catalog
_PDMreport_of_catalog:
	movw	$.T1,r2
	movw	$.F2,r3
	call	sp,Rload
	b	_PDMreport_of_catalog
#
# Begin stubs for:  PDMnfm_rpts.o
#
	.data
	.align	4
.F3:	.long	0x00000700
	.byte	80, 68, 77, 110, 102, 109, 95, 114, 112, 116
	.byte	115, 46, 111, 0
	.text

	.globl	_PDMslist_reports
_PDMslist_reports:
	movw	$.T1,r2
	movw	$.F3,r3
	call	sp,Rload
	b	_PDMslist_reports
#
# Begin stubs for:  PDMpdm_rpts.o
#
	.data
	.align	4
.F4:	.long	0x00000700
	.byte	80, 68, 77, 112, 100, 109, 95, 114, 112, 116
	.byte	115, 46, 111, 0
	.text

	.globl	_PDMsvalidate_report_name
_PDMsvalidate_report_name:
	movw	$.T1,r2
	movw	$.F4,r3
	call	sp,Rload
	b	_PDMsvalidate_report_name

	.globl	_PDMsread_report_format
_PDMsread_report_format:
	movw	$.T1,r2
	movw	$.F4,r3
	call	sp,Rload
	b	_PDMsread_report_format

	.globl	_PDMsread_criteria
_PDMsread_criteria:
	movw	$.T1,r2
	movw	$.F4,r3
	call	sp,Rload
	b	_PDMsread_criteria

	.globl	_PDMload_criteria_bufr
_PDMload_criteria_bufr:
	movw	$.T1,r2
	movw	$.F4,r3
	call	sp,Rload
	b	_PDMload_criteria_bufr

	.globl	_PDMsadd_report
_PDMsadd_report:
	movw	$.T1,r2
	movw	$.F4,r3
	call	sp,Rload
	b	_PDMsadd_report

	.globl	_PDMsadd_criteria
_PDMsadd_criteria:
	movw	$.T1,r2
	movw	$.F4,r3
	call	sp,Rload
	b	_PDMsadd_criteria

	.globl	_PDMvalidate_querys
_PDMvalidate_querys:
	movw	$.T1,r2
	movw	$.F4,r3
	call	sp,Rload
	b	_PDMvalidate_querys

	.globl	_PDMsdelete_report
_PDMsdelete_report:
	movw	$.T1,r2
	movw	$.F4,r3
	call	sp,Rload
	b	_PDMsdelete_report

	.globl	_PDMsshow_boms
_PDMsshow_boms:
	movw	$.T1,r2
	movw	$.F4,r3
	call	sp,Rload
	b	_PDMsshow_boms
#
# Begin stubs for:  PDMcvt_bufr.o
#
	.data
	.align	4
.F5:	.long	0x00000700
	.byte	80, 68, 77, 99, 118, 116, 95, 98, 117, 102
	.byte	114, 46, 111, 0
	.text

	.globl	_PDMcvt_bufr_struct
_PDMcvt_bufr_struct:
	movw	$.T1,r2
	movw	$.F5,r3
	call	sp,Rload
	b	_PDMcvt_bufr_struct

	.globl	_PDMcvt_struct_bufr
_PDMcvt_struct_bufr:
	movw	$.T1,r2
	movw	$.F5,r3
	call	sp,Rload
	b	_PDMcvt_struct_bufr

	.globl	_PDMcreate_dba_op
_PDMcreate_dba_op:
	movw	$.T1,r2
	movw	$.F5,r3
	call	sp,Rload
	b	_PDMcreate_dba_op

	.globl	_PDMcreate_dba_list
_PDMcreate_dba_list:
	movw	$.T1,r2
	movw	$.F5,r3
	call	sp,Rload
	b	_PDMcreate_dba_list

	.globl	_PDMinit_psurpt
_PDMinit_psurpt:
	movw	$.T1,r2
	movw	$.F5,r3
	call	sp,Rload
	b	_PDMinit_psurpt
#
# Begin stubs for:  PDMmove_rpt.o
#
	.data
	.align	4
.F6:	.long	0x00000700
	.byte	80, 68, 77, 109, 111, 118, 101, 95, 114, 112
	.byte	116, 46, 111, 0
	.text

	.globl	_PDMmove_rpt_file
_PDMmove_rpt_file:
	movw	$.T1,r2
	movw	$.F6,r3
	call	sp,Rload
	b	_PDMmove_rpt_file

	.globl	_PDMimport_ris_rpt
_PDMimport_ris_rpt:
	movw	$.T1,r2
	movw	$.F6,r3
	call	sp,Rload
	b	_PDMimport_ris_rpt

	.globl	_PDMexport_ris_rpt
_PDMexport_ris_rpt:
	movw	$.T1,r2
	movw	$.F6,r3
	call	sp,Rload
	b	_PDMexport_ris_rpt

	.globl	_PDMdelete_ris_rpt
_PDMdelete_ris_rpt:
	movw	$.T1,r2
	movw	$.F6,r3
	call	sp,Rload
	b	_PDMdelete_ris_rpt
#
# Begin stubs for:  PDMdef_qry.o
#
	.data
	.align	4
.F7:	.long	0x00000700
	.byte	80, 68, 77, 100, 101, 102, 95, 113, 114, 121
	.byte	46, 111, 0
	.text

	.globl	_PDMdefine_query
_PDMdefine_query:
	movw	$.T1,r2
	movw	$.F7,r3
	call	sp,Rload
	b	_PDMdefine_query

	.globl	_PDMretrieve_query
_PDMretrieve_query:
	movw	$.T1,r2
	movw	$.F7,r3
	call	sp,Rload
	b	_PDMretrieve_query

	.globl	__PDMread_query_info
__PDMread_query_info:
	movw	$.T1,r2
	movw	$.F7,r3
	call	sp,Rload
	b	__PDMread_query_info

	.globl	_PDMretrieve_query_info
_PDMretrieve_query_info:
	movw	$.T1,r2
	movw	$.F7,r3
	call	sp,Rload
	b	_PDMretrieve_query_info
#
# Begin stubs for:  PDMstls.o
#
	.data
	.align	4
.F8:	.long	0x00000700
	.byte	80, 68, 77, 115, 116, 108, 115, 46, 111, 0
	.text

	.globl	_PSUexe_rpt
_PSUexe_rpt:
	movw	$.T1,r2
	movw	$.F8,r3
	call	sp,Rload
	b	_PSUexe_rpt

	.globl	_PDMreport_from_tmpfile
_PDMreport_from_tmpfile:
	movw	$.T1,r2
	movw	$.F8,r3
	call	sp,Rload
	b	_PDMreport_from_tmpfile

	.globl	_PDMIndentReportFile
_PDMIndentReportFile:
	movw	$.T1,r2
	movw	$.F8,r3
	call	sp,Rload
	b	_PDMIndentReportFile

	.globl	_SQLquery
	.globl	_PSUexe_rpt
	.globl	_NFMadd_query
	.globl	_PDMstop_transaction
	.globl	_NFMrm_co_files
	.globl	_PDMquery_report_type
	.globl	_PDMi_insert_pdmtables
	.globl	_fgetc
	.globl	_MEMopen
	.globl	_strcpy
	.globl	_PDMupdate_exist_bom
	.globl	_dba_setup_dbforms
	.globl	_dba_setup_script
	.globl	_PDMmove_rpt_file
	.globl	_strncpy
	.globl	_PDMconvert_to_lower
	.globl	_dba_add_to_table_list
	.globl	_malloc
	.globl	_PDMrollback_transaction
	.globl	_dba_execute_default
	.globl	_NFMwrite_query_struct
	.globl	_free
	.globl	_PDMi_get_partnum_rev
	.globl	_MEMwrite
	.globl	_NFMglobal
	.globl	_PDUgetcwd
	.globl	__PDMdebug
	.globl	_SQLstmt
	.globl	_PDMi_find_bominfo
	.globl	_dba_setup_dbnuc
	.globl	_NFMdecrypt
	.globl	_PDMgen_file_name
	.globl	_PDMi_find_maxtype
	.globl	_mktemp
	.globl	_PDMexport_ris_rpt
	.globl	_stat
	.globl	_chdir
	.globl	_dba_setup
	.globl	_MEMwrite_format
	.globl	_PDMinit_psurpt
	.globl	_PDMdebug_on
	.globl	_dba_schema_select
	.globl	_strncmp
	.globl	_storage
	.globl	_dba_setup_report
	.globl	_NFMRtic_it
	.globl	_PDMcvt_struct_bufr
	.globl	_strlen
	.globl	_strcat
	.globl	_PDMgen_table_name
	.globl	_PSUrs_get_tempno
	.globl	_PDMQueryAssyIndGivenPartno
	.globl	_PDMfree_query_info_struct
	.globl	_NFMbuild_fto_buffer
	.globl	_PDMi_query_partnumrev
	.globl	_PDMdelete_ris_rpt
	.globl	_NFMwrite_query_file
	.globl	_strcmp
	.globl	_UI_prompt
	.globl	_PSUrs_update_rpt
	.globl	__PDMasc_to_doub
	.globl	_PDMquery_catalog_partnos
	.globl	_memset
	.globl	_UI_status
	.globl	_strchr
	.globl	_dba_single_report
	.globl	_fclose
	.globl	_atol
	.globl	_atoi
	.globl	_PDMdebug
	.globl	_PDMcvt_bufr_struct
	.globl	_dba_setup_gui
	.globl	_MEMbuild_array
	.globl	_PDMcreate_ris_table
	.globl	_MEMclose
	.globl	_PDMi_maxrow_no
	.globl	_calloc
	.globl	_PDMstart_transaction
	.globl	_NFMupdate_query
	.globl	_NFMload_user_info
	.globl	_PDMquery_catalogno_type
	.globl	_PDMexpand_copy_buffer
	.globl	_fseek
	.globl	_PSUrs_load_rpt
	.globl	_MEMwrite_data
	.globl	_dba_process_report
	.globl	_sprintf
	.globl	_unlink
	.globl	_PDUget_keyin
	.globl	_NFMcopy_file
	.globl	_PDMdefine_query
	.globl	_PDM_DEBUG_FILE
	.globl	_dba_message_strip
	.globl	_PDMreport_from_tmpfile
	.globl	_PDMi_get_partnum_rev_desc
	.globl	_PDMi_query_catalogname
	.globl	_NFMfind_user_no
	.globl	__PDMprint_bommember
	.globl	_PDUtranslate_message
	.globl	_NFMrollback_transaction
	.globl	_MEMprint_buffer
	.globl	_MEMprint_buffers
	.globl	_fgets
	.globl	_dba_columns_per_page
	.globl	_PDMretrieve_query
	.globl	_dba_set_variable_start
	.globl	_PDMbom_check_assy_cycle
	.globl	_PDMi_find_tableinfo
	.globl	_fputs
	.globl	__NFMfs_undo_recv_files
	.globl	_PDMi_compare_dates
	.globl	_NFMget_storage_info
	.globl	_rMRPfree_psurpt
	.globl	_dba_set_field_justify
	.globl	_fopen
	.globl	__NFMfs_recv_files
	.globl	_PDMexec
