	.file	"PDMris.s"
#
# Begin stubs for:  PDMrs_tool.o
#
	.data
.T1:	.byte	80, 100, 117, 0
	.byte	112, 100, 109, 47, 114, 105, 115, 0
	.align	4
.F1:	.long	0x00000700
	.byte	80, 68, 77, 114, 115, 95, 116, 111, 111, 108
	.byte	46, 111, 0
	.text

	.globl	_PDMris_get_catno
_PDMris_get_catno:
	movw	$.T1,r2
	movw	$.F1,r3
	call	sp,Rload
	b	_PDMris_get_catno

	.globl	_PDMris_get_projectno
_PDMris_get_projectno:
	movw	$.T1,r2
	movw	$.F1,r3
	call	sp,Rload
	b	_PDMris_get_projectno

	.globl	_PDMris_get_catname
_PDMris_get_catname:
	movw	$.T1,r2
	movw	$.F1,r3
	call	sp,Rload
	b	_PDMris_get_catname

	.globl	_PDMload_catno
_PDMload_catno:
	movw	$.T1,r2
	movw	$.F1,r3
	call	sp,Rload
	b	_PDMload_catno

	.globl	_PDMload_fcatno
_PDMload_fcatno:
	movw	$.T1,r2
	movw	$.F1,r3
	call	sp,Rload
	b	_PDMload_fcatno

	.globl	_PDMris_maxrow_no
_PDMris_maxrow_no:
	movw	$.T1,r2
	movw	$.F1,r3
	call	sp,Rload
	b	_PDMris_maxrow_no

	.globl	_PDMris_get_pitemno
_PDMris_get_pitemno:
	movw	$.T1,r2
	movw	$.F1,r3
	call	sp,Rload
	b	_PDMris_get_pitemno

	.globl	_PDMris_get_tableno
_PDMris_get_tableno:
	movw	$.T1,r2
	movw	$.F1,r3
	call	sp,Rload
	b	_PDMris_get_tableno

	.globl	_PDMris_max_childno
_PDMris_max_childno:
	movw	$.T1,r2
	movw	$.F1,r3
	call	sp,Rload
	b	_PDMris_max_childno

	.globl	_PDMris_max_tempchildno
_PDMris_max_tempchildno:
	movw	$.T1,r2
	movw	$.F1,r3
	call	sp,Rload
	b	_PDMris_max_tempchildno

	.globl	_PDMget_assembly_ind
_PDMget_assembly_ind:
	movw	$.T1,r2
	movw	$.F1,r3
	call	sp,Rload
	b	_PDMget_assembly_ind

	.globl	_PDMris_get_userno
_PDMris_get_userno:
	movw	$.T1,r2
	movw	$.F1,r3
	call	sp,Rload
	b	_PDMris_get_userno

	.globl	_PDMris_get_catnodesc
_PDMris_get_catnodesc:
	movw	$.T1,r2
	movw	$.F1,r3
	call	sp,Rload
	b	_PDMris_get_catnodesc

	.globl	_PDMquery
_PDMquery:
	movw	$.T1,r2
	movw	$.F1,r3
	call	sp,Rload
	b	_PDMquery

	.globl	_PDMris_stmt
_PDMris_stmt:
	movw	$.T1,r2
	movw	$.F1,r3
	call	sp,Rload
	b	_PDMris_stmt

	.globl	_PDMget_catno_type
_PDMget_catno_type:
	movw	$.T1,r2
	movw	$.F1,r3
	call	sp,Rload
	b	_PDMget_catno_type

	.globl	_PDMquery_stateno
_PDMquery_stateno:
	movw	$.T1,r2
	movw	$.F1,r3
	call	sp,Rload
	b	_PDMquery_stateno
#
# Begin stubs for:  PDMrs_fmgr.o
#
	.data
	.align	4
.F2:	.long	0x00000700
	.byte	80, 68, 77, 114, 115, 95, 102, 109, 103, 114
	.byte	46, 111, 0
	.text

	.globl	_PDMris_get_fmgr
_PDMris_get_fmgr:
	movw	$.T1,r2
	movw	$.F2,r3
	call	sp,Rload
	b	_PDMris_get_fmgr

	.globl	_PDMris_find_references
_PDMris_find_references:
	movw	$.T1,r2
	movw	$.F2,r3
	call	sp,Rload
	b	_PDMris_find_references

	.globl	_PDMris_get_sano
_PDMris_get_sano:
	movw	$.T1,r2
	movw	$.F2,r3
	call	sp,Rload
	b	_PDMris_get_sano
#
# Begin stubs for:  PDMrs_bom.o
#
	.data
	.align	4
.F3:	.long	0x00000700
	.byte	80, 68, 77, 114, 115, 95, 98, 111, 109, 46
	.byte	111, 0
	.text

	.globl	_PSUrs_get_pitemno
_PSUrs_get_pitemno:
	movw	$.T1,r2
	movw	$.F3,r3
	call	sp,Rload
	b	_PSUrs_get_pitemno

	.globl	_PSUrs_get_bomname
_PSUrs_get_bomname:
	movw	$.T1,r2
	movw	$.F3,r3
	call	sp,Rload
	b	_PSUrs_get_bomname
#
# Begin stubs for:  PDMrs_cat.o
#
	.data
	.align	4
.F4:	.long	0x00000700
	.byte	80, 68, 77, 114, 115, 95, 99, 97, 116, 46
	.byte	111, 0
	.text

	.globl	_rMRPrs_free_values
_rMRPrs_free_values:
	movw	$.T1,r2
	movw	$.F4,r3
	call	sp,Rload
	b	_rMRPrs_free_values

	.globl	_MRPrs_get_catno
_MRPrs_get_catno:
	movw	$.T1,r2
	movw	$.F4,r3
	call	sp,Rload
	b	_MRPrs_get_catno

	.globl	_MRPrs_mk_elect_cat
_MRPrs_mk_elect_cat:
	movw	$.T1,r2
	movw	$.F4,r3
	call	sp,Rload
	b	_MRPrs_mk_elect_cat

	.globl	_rMRPrs_in_nfmcat
_rMRPrs_in_nfmcat:
	movw	$.T1,r2
	movw	$.F4,r3
	call	sp,Rload
	b	_rMRPrs_in_nfmcat

	.globl	_rMRPrs_get_nfmattrs_pdmcat
_rMRPrs_get_nfmattrs_pdmcat:
	movw	$.T1,r2
	movw	$.F4,r3
	call	sp,Rload
	b	_rMRPrs_get_nfmattrs_pdmcat

	.globl	_rMRPrs_mk_cat_tab
_rMRPrs_mk_cat_tab:
	movw	$.T1,r2
	movw	$.F4,r3
	call	sp,Rload
	b	_rMRPrs_mk_cat_tab

	.globl	_rMRPrs_create_tab
_rMRPrs_create_tab:
	movw	$.T1,r2
	movw	$.F4,r3
	call	sp,Rload
	b	_rMRPrs_create_tab

	.globl	_rMRPrs_alter_tab
_rMRPrs_alter_tab:
	movw	$.T1,r2
	movw	$.F4,r3
	call	sp,Rload
	b	_rMRPrs_alter_tab

	.globl	_rMRPrs_fill_nfmattr_values
_rMRPrs_fill_nfmattr_values:
	movw	$.T1,r2
	movw	$.F4,r3
	call	sp,Rload
	b	_rMRPrs_fill_nfmattr_values

	.globl	_rMRPrs_fill_nfmattr_rows
_rMRPrs_fill_nfmattr_rows:
	movw	$.T1,r2
	movw	$.F4,r3
	call	sp,Rload
	b	_rMRPrs_fill_nfmattr_rows
#
# Begin stubs for:  PDMrs_rpt.o
#
	.data
	.align	4
.F5:	.long	0x00000700
	.byte	80, 68, 77, 114, 115, 95, 114, 112, 116, 46
	.byte	111, 0
	.text

	.globl	_PSUrs_cre_rpt
_PSUrs_cre_rpt:
	movw	$.T1,r2
	movw	$.F5,r3
	call	sp,Rload
	b	_PSUrs_cre_rpt

	.globl	_PSUrs_load_rpt
_PSUrs_load_rpt:
	movw	$.T1,r2
	movw	$.F5,r3
	call	sp,Rload
	b	_PSUrs_load_rpt

	.globl	_PSUrs_load_rptopt
_PSUrs_load_rptopt:
	movw	$.T1,r2
	movw	$.F5,r3
	call	sp,Rload
	b	_PSUrs_load_rptopt

	.globl	_PSUrs_load_rptlst
_PSUrs_load_rptlst:
	movw	$.T1,r2
	movw	$.F5,r3
	call	sp,Rload
	b	_PSUrs_load_rptlst

	.globl	_PSUrs_cre_rtabs
_PSUrs_cre_rtabs:
	movw	$.T1,r2
	movw	$.F5,r3
	call	sp,Rload
	b	_PSUrs_cre_rtabs

	.globl	_PSUrs_get_tempno
_PSUrs_get_tempno:
	movw	$.T1,r2
	movw	$.F5,r3
	call	sp,Rload
	b	_PSUrs_get_tempno

	.globl	_PSUrs_update_rpt
_PSUrs_update_rpt:
	movw	$.T1,r2
	movw	$.F5,r3
	call	sp,Rload
	b	_PSUrs_update_rpt

	.globl	_PSUrs_insert_rpt
_PSUrs_insert_rpt:
	movw	$.T1,r2
	movw	$.F5,r3
	call	sp,Rload
	b	_PSUrs_insert_rpt

	.globl	_PSUrs_insert_rptlst
_PSUrs_insert_rptlst:
	movw	$.T1,r2
	movw	$.F5,r3
	call	sp,Rload
	b	_PSUrs_insert_rptlst
#
# Begin stubs for:  SQLqry.o
#
	.data
	.align	4
.F6:	.long	0x00000700
	.byte	83, 81, 76, 113, 114, 121, 46, 111, 0
	.text

	.globl	_PDMSQLquery
_PDMSQLquery:
	movw	$.T1,r2
	movw	$.F6,r3
	call	sp,Rload
	b	_PDMSQLquery

	.comm	_rMRPattr_columno,4
	.comm	_rmrpattr,4
	.comm	_values_total,4
	.comm	_col_total,4
	.comm	_rMRPv_tableno,4
	.comm	_rMRPtableno,4
	.comm	_rMRPf_tableno,4
	.comm	_query_out_desc,8
	.globl	_SQLquery
	.globl	_PSUexe_rpt
	.globl	_RISint_set_sqlcode
	.globl	_MEMopen
	.globl	_strcpy
	.globl	_catno_type
	.globl	_strncpy
	.globl	_RISint_close
	.globl	_malloc
	.globl	_RISint_execute
	.globl	_risca
	.globl	_free
	.globl	_MEMwrite
	.globl	__PDMdebug
	.globl	_mrpvar
	.globl	_SQLglobal
	.globl	_MRPstrcpy
	.globl	_MEMwrite_format
	.globl	_MRPget_time
	.globl	_PDMdebug_on
	.globl	_RISdatetime_to_ascii
	.globl	_strlen
	.globl	_strcat
	.globl	_strcmp
	.globl	_realloc
	.globl	_RISget_sqlcode
	.globl	_MRPget_date
	.globl	_RISint_select
	.globl	_memset
	.globl	_RISint_execute_immediate
	.globl	_PDMpart
	.globl	_RISint_prepare
	.globl	_ERRload_struct
	.globl	_RISint_fetch
	.globl	_atoi
	.globl	_RISint_describe
	.globl	_PDMdebug
	.globl	_MEMbuild_array
	.globl	_SQLCODE
	.globl	_MEMclose
	.globl	_RISint_report_error
	.globl	__NFMdebug_function
	.globl	_puts
	.globl	_calloc
	.globl	__NFMdebug_st
	.globl	_sprintf
	.globl	_RISint_clear
	.globl	_SQLerror
