/*
**	NAME:							dldmain.c
**	AUTHORS:						Hitesh R. Patel
**	CREATION DATE:					8/93
**	ABSTRACT:
**	
**	REVISION HISTORY:
*/
 
/*
**	DEFINES
*/
#define DLD_GLOBAL_DEFINE

#if defined(WIN32)
//For NT on currently
#define VERSION_4_ONLY
#endif

/*
**	INCLUDES
*/
#include <stdio.h>
#include <sys/stat.h>
#if defined(unix)
#if defined(VERSION_4_ONLY)
#include "xc/dload.h"
#endif
#endif
#if defined(WIN32)
#include <windows.h>
#endif
#if defined(DOS)
#endif
#include "risver.h"
#include "dload.h"

/*
**	FUNCTION PROTOTYPES
*/
#define dldmain_c
#if defined(VERSION_4_ONLY)
#include "dlderror.prt"
#include "dldgtdir.prt"
#include "sys.prt"
#else
#endif
#include "dldmain.prt"
#if defined(WIN32)
#include "dlddebug.prt"
#endif

/*
**	VARIABLES
*/

#if defined(VERSION_4_ONLY)
/*STATIC STRUCT BEGIN*/
static func_info_s func_info[] = 
{
	{ 0, 0 },
	{ "RISXascii_to_datetime", 0 },
	{ "RISXrestore_schema_file_checksum", 0 },
	{ "RISXint_clear", 0 },
	{ "RISXint_clear_async", 0 },
	{ "RISXint_close", 0 },
	{ "RISXint_process_debug", 0 },
	{ "RISXint_process_debug_no_output", 0 },
	{ "RISXint_describe", 0 },
	{ "RISXdatetime_to_ascii", 0 },
	{ "RISXint_error_msg", 0 },
	{ "RISXint_term_error_msg", 0 },
	{ "RISXint_set_error", 0 },
	{ "RISXint_clear_error", 0 },
	{ "RISXint_execute", 0 },
	{ "RISXint_execute_immediate", 0 },
	{ "RISXint_fetch", 0 },
	{ "RISXget_superschema_names", 0 },
	{ "RISXget_superschema_definition", 0 },
	{ "RISXget_async_stmts", 0 },
	{ "RISXget_schema_info", 0 },
	{ "RISXget_db_info", 0 },
	{ "RISXget_schema_file", 0 },
	{ "RISXint_get_flags", 0 },
	{ "RISXget_ansi_mode", 0 },
	{ "RISXget_enabled_databases", 0 },
	{ "RISXget_verify_mode", 0 },
	{ "RISXget_autocommit_mode", 0 },
	{ "RISXget_schema_names", 0 },
	{ "RISXget_default_schema_name", 0 },
	{ "RISXget_current_stmt_schema_name", 0 },
	{ "RISXget_parameters", 0 },
	{ "RISXget_schema_transactions", 0 },
	{ "RISXget_app_version", 0 },
	{ "RISXinitialize", 0 },
	{ "RISXstart_client", 0 },
	{ "RISXlocate_schema_file", 0 },
	{ "RISXget_schema_file_location", 0 },
	{ "RISXlocate_client", 0 },
	{ "RISXget_client_location", 0 },
	{ "RISXint_prepare", 0 },
	{ "RISXint_report_error", 0 },
	{ "RISXint_show_app_memory", 0 },
	{ "RISXint_show_app_stmts", 0 },
	{ "RISXint_show_async_stmts", 0 },
	{ "RISXint_show_cli_memory", 0 },
	{ "RISXint_show_cli_stmts", 0 },
	{ "RISXint_show_cli_hash_table", 0 },
	{ "RISXint_show_cli_servers", 0 },
	{ "RISXint_show_cli_struct_mgrs", 0 },
	{ "RISXint_select", 0 },
	{ "RISXint_schema_mgr", 0 },
	{ "RISXint_report_superschema_error", 0 },
	{ "RISXterminate", 0 },
	{ "RISXstop_client", 0 },
	{ "RISXint_test_completion", 0 },
	{ "RISXint_get_debug_flags", 0 },
	{ "RISXint_set_sqlcode", 0 },
	{ "RISXget_sqlcode", 0 },
	{ "RISXget_risca", 0 },
	{ "RISXget_dbca", 0 },
	{ "RISXget_superschema_error", 0 },
	{ "RISXget_superschema_warning", 0 },
	{ "RISXint_get_language_code", 0 },
	{ "RISXget_language_name", 0 },
	{ "RISXint_get_client_addresses", 0 },
	{ "RISXget_ris_sqltype_code", 0 },
	{ "RISXget_ris_sqltype_string", 0 },
	{ "RISXrap_initialize", 0 },
	{ "RISXrap_print_input_sqlda", 0 },
	{ "RISXrap_print_output_sqlda", 0 },
	{ "RISXrap_print_describe_sqlda", 0 },
	{ "RISXrap_print_test_sqlda", 0 },
	{ "RISXrap_print_client_parms", 0 },
	{ "RISXrap_print_schema_file_parms", 0 },
	{ "RISXrap_compare_fetch", 0 },
	{ "RISXcom_clear_sqlca", 0 },
	{ "RISXcom_depd", 0 },
	{ "RISXcom_error_code", 0 },
	{ "RISXcom_fclose", 0 },
	{ "RISXcom_fgets", 0 },
	{ "RISXcom_fopen", 0 },
	{ "RISXcom_generate_local_exe_path", 0 },
	{ "RISXcom_get_execute_mode_name", 0 },
	{ "RISXcom_get_output_device_name", 0 },
	{ "RISXcom_get_risdir", 0 },
	{ "RISXcom_init_ums_msg", 0 },
	{ "RISXcom_isalpha", 0 },
	{ "RISXcom_isdigit", 0 },
	{ "RISXcom_islower", 0 },
	{ "RISXcom_isspace", 0 },
	{ "RISXcom_isupper", 0 },
	{ "RISXcom_longjmp", 0 },
	{ "RISXcom_lower_strcpy", 0 },
	{ "RISXcom_output_db_info", 0 },
	{ "RISXcom_voutput_debug", 0 },
	{ "RISXcom_output_debug_flags", 0 },
	{ "RISXcom_output_schema_info", 0 },
	{ "RISXcom_output_sqlvar", 0 },
	{ "RISXcom_parse_command_line", 0 },
	{ "RISXcom_read_rap_file", 0 },
	{ "RISXcom_resetjmp", 0 },
	{ "RISXcom_ris_lang_dir", 0 },
	{ "RISXcom_set_debug_output_device", 0 },
	{ "RISXcom_setjmp", 0 },
	{ "RISXcom_stat", 0 },
	{ "RISXcom_strcmp_ic", 0 },
	{ "RISXcom_strncmp_ic", 0 },
	{ "RISXcom_substr_ic", 0 },
	{ "RISXcom_tmpnam", 0 },
	{ "RISXcom_tolower", 0 },
	{ "RISXcom_toupper", 0 },
	{ "RISXcom_umsg", 0 },
	{ "RISXget_blankstrip_mode", 0 },
	{ "RISXget_autorename_mode", 0 },
	{ "RISXint_upgrade_parms_file", 0 },
	{ "RISXcom_strncpy_ic", 0 },
	{ "RISXfree_memory", 0 },
	{ "RISXget_platform", 0 },
	{ "RISXcom_multiwide", 0 },
	{ "RISXcom_wcstombs", 0 },
	{ "RISXsetbypass", 0 },
	{ "RISXint_process_debug_noRAP", 0 },
	{ "RISXint_process_debug_no_output_noRAP", 0 },
	{ "RISXfree_memory_malloc", 0 },
};
/*STATIC STRUCT END*/

static int func_count =	sizeof(func_info)/sizeof(func_info_s); 
#endif


/*
**	FUNCTIONS
*/
#if defined(unix)
	char *handle; 
#endif
#if defined(WIN32)
	HANDLE handle;
#endif

/******************************************************************************/

#if defined(VERSION_4_ONLY)
extern int RISdld_is_dload_done()
{

	int 		index;
	static int	called_but_failed = 0;
	static int	dynamic_loaded = 0;
	char 		ris_objects[RIS_MAX_PATH_SIZE]; 
	char		RIS_dir[RIS_MAX_PATH_SIZE];
	int			RIS_development = 0;
	int			RIS_app_version_maj = RIS_VERSION_MAJ;
	int			RIS_app_version_min = RIS_VERSION_MIN;
	int			RIS_app_version_rel = RIS_VERSION_REL;


	if(called_but_failed)
	{
		DLD_DBG(("RISdld_is_dload_done: called but failed\n"));
		return(RIS_E_DYNAMIC_LOADING_FAILED);
	}

	if(!dynamic_loaded)
	{ 

		RISdld_initialize_debug();
		if (RISdld_get_risdir("RIS", RIS_app_version_maj, RIS_app_version_min, 
						RIS_app_version_rel, MATCH_COMPATIBLE, RIS_dir, 
						&RIS_development, 0))
		{
			called_but_failed = 1;
			RISdld_error_msg_box(RIS_COULD_NOT_GET_REGISTRY,RIS_VERSION_STR);
			DLD_DBG(("RISdld_is_dload_done: RISdld_get_risdir failed\n"));
			return(RIS_E_DYNAMIC_LOADING_FAILED);
		}

		RISdld_generate_path(ris_objects, RIS_dir, RIS_development);
		DLD_DBG(("RISdld_is_dload_done: Loading <%s>\n", STRING(ris_objects)));

		handle = DYNAMIC_LOAD_FUNCTION(ris_objects);
		if( !handle ) 
		{ 
			DLD_DBG(("RISdld_is_dload_done: LoadLibrary return:%d\n",
					GetLastError()));
			called_but_failed = 1;
			RISdld_error_msg_box(RIS_COULD_NOT_LOAD_RIS_DLL,ris_objects);
			return(RIS_E_DYNAMIC_LOADING_FAILED); 
		} 

		DLD_DBG(("RISdld_is_dload_done: functions:%d\n", func_count-1));
		for( index = 1; index < func_count; index++ ) 
		{ 
			DLD_DBG(("RISdld_is_dload_done: func_info[%d].name = <%s>\n", 
				index, STRING(func_info[index].name)));
			func_info[index].address =  
				GET_FUNCTION_ADDRESS(func_info[index].name);
			if(!func_info[index].address) 
			{ 
#if defined(WIN32)
				FreeLibrary(handle);
#endif
				DLD_DBG(("RISdld_is_dload_done: GetProcAddress return:%d\n",
						GetLastError()));
				called_but_failed = 1;
				RISdld_error_msg_box(RIS_COULD_NOT_FIND_RIS_FUNC,
					func_info[index].name);
				return(RIS_E_DYNAMIC_LOADING_FAILED); 
			} 
			DLD_DBG(("RISdld_is_dload_done: func_info[%d].address = 0x%x\n", 
				index, func_info[index].address));
		} 
		dynamic_loaded = 1; 
		DLD_DBG(("RISdld_is_dload_done: returning SUCCESS\n"));
		return(0);
	} 
	else
	{
		DLD_DBG(("RISdld_is_dload_done: already dloaded.\n"));
		return(0);
	}
}
#endif

/******************************************************************************/

#if defined(VERSION_4_ONLY)
extern FARPROC RISdld_get_func_address(
	int index)
{
	return(func_info[index].address);
}
#endif

/******************************************************************************/

#if defined(VERSION_4_ONLY)
extern char *RISdld_get_func_name(
	int index)
{
	return(func_info[index].name);
}
#endif

/******************************************************************************/
