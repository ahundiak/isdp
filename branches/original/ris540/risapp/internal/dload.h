/* Do not alter this SPC information: $Revision: 1.5.3.1 $ */

/*
**	NAME:							dload.h
**	AUTHORS:						Hitesh R. Patel
**	CREATION DATE:					8/93
**	ABSTRACT:
**	
**	REVISION HISTORY:
*/
 

#ifndef RIS_DLOAD_H
#define RIS_DLOAD_H

#ifdef DLD_GLOBAL_DEFINE
# define DLD_EXTERN
# define DLD_INIT(value) = value
#else
# define DLD_EXTERN extern
# define DLD_INIT(value)
#endif

/*
**	INCLUDES
*/
#include "ris.h"
#include "rislimit.h"
#include "ris_err.h"

/*
**	DEFINES
*/

/*
** The following defines corresponds to each RIS interface call.
*/
/*EXPORTS MACRO BEGIN*/
#define DLD_ascii_to_datetime 					1
#define DLD_restore_schema_file_checksum		2
#define DLD_int_clear							3
#define	DLD_int_clear_async						4
#define DLD_int_close							5
#define DLD_int_process_debug					6
#define DLD_int_process_debug_no_output			7
#define DLD_int_describe						8
#define DLD_datetime_to_ascii					9
#define DLD_int_error_msg						10
#define DLD_int_term_error_msg					11
#define DLD_int_set_error						12
#define DLD_int_clear_error						13
#define DLD_int_execute							14
#define DLD_int_execute_immediate				15
#define DLD_int_fetch							16
#define DLD_get_superschema_names				17
#define DLD_get_superschema_definition			18
#define DLD_get_async_stmts						19
#define DLD_get_schema_info						20
#define DLD_get_db_info							21
#define DLD_get_schema_file						22
#define DLD_int_get_flags						23
#define DLD_get_ansi_mode						24
#define DLD_get_enabled_databases				25
#define DLD_get_verify_mode						26
#define DLD_get_autocommit_mode					27
#define DLD_get_schema_names					28
#define DLD_get_default_schema_name				29
#define DLD_get_current_stmt_schema_name		30
#define DLD_get_parameters						31
#define DLD_get_schema_transactions				32
#define DLD_get_app_version						33
#define DLD_initialize							34
#define DLD_start_client						35
#define DLD_locate_schema_file					36
#define DLD_get_schema_file_location			37
#define DLD_locate_client						38
#define DLD_get_client_location					39
#define DLD_int_prepare							40
#define DLD_int_report_error					41
#define DLD_int_show_app_memory					42
#define DLD_int_show_app_stmts 					43
#define DLD_int_show_async_stmts				44
#define DLD_int_show_cli_memory					45
#define DLD_int_show_cli_stmts					46
#define DLD_int_show_cli_hash_table				47
#define DLD_int_show_cli_servers				48
#define DLD_int_show_cli_struct_mgrs			49
#define DLD_int_select							50
#define DLD_int_schema_mgr						51
#define DLD_int_report_superschema_error		52
#define DLD_terminate							53
#define DLD_stop_client							54
#define DLD_int_test_completion					55
#define DLD_int_get_debug_flags					56
#define DLD_int_set_sqlcode						57
#define DLD_get_sqlcode							58
#define DLD_get_risca							59
#define DLD_get_dbca							60
#define DLD_get_superschema_error				61
#define DLD_get_superschema_warning				62
#define DLD_int_get_language_code				63
#define DLD_get_language_name					64
#define DLD_int_get_client_addresses			65
#define DLD_get_ris_sqltype_code				66
#define DLD_get_ris_sqltype_string				67
#define DLD_rap_initialize						68
#define DLD_rap_print_input_sqlda				69
#define DLD_rap_print_output_sqlda				70
#define DLD_rap_print_describe_sqlda			71
#define DLD_rap_print_test_sqlda				72
#define DLD_rap_print_client_parms				73
#define DLD_rap_print_schema_file_parms			74
#define DLD_rap_compare_fetch					75
#define DLD_com_clear_sqlca						76
#define	DLD_com_depd							77
#define	DLD_com_error_code						78
#define	DLD_com_fclose							79
#define	DLD_com_fgets							80
#define	DLD_com_fopen							81
#define	DLD_com_generate_local_exe_path			82
#define	DLD_com_get_execute_mode_name			83
#define	DLD_com_get_output_device_name			84
#define	DLD_com_get_risdir						85
#define	DLD_com_init_ums_msg					86
#define	DLD_com_isalpha							87
#define	DLD_com_isdigit							88
#define	DLD_com_islower							89
#define	DLD_com_isspace							90
#define	DLD_com_isupper							91
#define	DLD_com_longjmp							92
#define	DLD_com_lower_strcpy					93
#define	DLD_com_output_db_info					94
#define	DLD_com_voutput_debug					95
#define	DLD_com_output_debug_flags				96
#define	DLD_com_output_schema_info				97
#define	DLD_com_output_sqlvar					98
#define	DLD_com_parse_command_line				99
#define	DLD_com_read_rap_file					100
#define	DLD_com_resetjmp						101
#define	DLD_com_ris_lang_dir					102
#define	DLD_com_set_debug_output_device			103
#define	DLD_com_setjmp							104
#define	DLD_com_stat							105
#define	DLD_com_strcmp_ic						106
#define	DLD_com_strncmp_ic						107
#define	DLD_com_substr_ic						108
#define	DLD_com_tmpnam							109
#define	DLD_com_tolower							110
#define	DLD_com_toupper							111
#define	DLD_com_umsg							112
#define DLD_get_blankstrip_mode					113
#define DLD_get_autorename_mode					114
#define DLD_int_upgrade_parms_file				115
#define	DLD_com_strncpy_ic						116
#define	DLD_free_memory							117
#define	DLD_get_platform						118
#define	DLD_com_multiwide						119
#define	DLD_com_wcstombs						120
#define DLD_setbypass						        121
#define DLD_int_process_debug_noRAP     				122
#define DLD_int_process_debug_no_output_noRAP                           123
#define	DLD_free_memory_malloc						124
/*EXPORTS MACRO END*/

/* DLOAD errors */
#define	RIS_COULD_NOT_GET_REGISTRY	1
#define	RIS_COULD_NOT_LOAD_RIS_DLL	2
#define	RIS_COULD_NOT_FIND_RIS_FUNC 3

#define DLOADCODE RISdld_errcode	// Error Code if Dynamic Loading Fails

#define DLD_DBG(s) if(RISdld_debug) {RISdld_output_debug s;}

#define SET_RISCA(status) { DLOADCODE = status; }
#define RIS_RETURN() { return; }

#if defined(__clipper__) || defined(sun) || defined(__hpux__)
#define RIS_OBJECT_NAME "ris.o" 
#endif
#if defined(WIN32)
#define RIS_OBJECT_NAME "i9ris6.dll"
#endif

#if defined(__clipper__) || defined(sun) || defined(__hpux__)
#define DYNAMIC_LOAD_FUNCTION(objects)	dload(objects, TEXTREDEF) 
#endif
#if defined(WIN32)
#define	DYNAMIC_LOAD_FUNCTION(objects)	LoadLibrary(objects)
#endif

#if defined(__clipper__) || defined(sun) || defined(__hpux__)
#define	GET_FUNCTION_ADDRESS(name) \
	(int (*)() )dload_address_lookup(name) 
#endif
#if defined(WIN32)
#define	GET_FUNCTION_ADDRESS(name) \
	GetProcAddress(handle, name)
#endif

#if defined(__clipper__) || defined(sun) || defined(__hpux__)
#define FUNCTION_ADDRESS(func) (*func_info[func].address)
#endif
#if defined(WIN32)
#define FUNCTION_ADDRESS(func) RISdld_get_func_address(func)
#endif

#ifndef STRING
#define STRING(s) ((s)?(s):"NULL")
#endif

/* Modes for RISdld_get_risdir() */
#define MATCH_MAJOR					1
#define MATCH_MAJOR_MINOR			2
#define MATCH_MAJOR_MINOR_RELEASE	3
#define MATCH_HIGHEST				4
#define MATCH_COMPATIBLE			5

#if defined(__clipper__)
#define PLATFORM "c100"
#endif
#if defined(sun)
#define PLATFORM "sun"
#endif
#if defined(sco)
#define PLATFORM "sco"
#endif
#if defined(WIN32)
#define PLATFORM "nt"
#endif
#if defined(DOS)
#define PLATFORM "dos"
#endif
#if defined(__hpux__)
#define PLATFORM "hpux"
#endif

/*
**	TYPES
*/
typedef struct func_info_s
{
	char	*name;
#if defined(__clipper__) || defined(sun) || defined(__hpux__)
	int		(*address)();
#endif
#if defined(WIN32)
	FARPROC address; 
#endif
} func_info_s;


/*
**	VARIABLES
*/

/* Variables available to applications */
DLD_EXTERN	int	RISdld_errcode	DLD_INIT(RIS_SUCCESS);
DLD_EXTERN	int	RISdld_debug 	DLD_INIT(0);

#endif /* RIS_DLOAD_H */
