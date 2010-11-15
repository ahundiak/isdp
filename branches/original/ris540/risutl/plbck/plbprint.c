/* Do not alter this SPC information: $Revision: 1.1.53.1 $ */
/*
**	NAME:							plbprint.c
**	AUTHORS:						Terry McIntyre
**	CREATION DATE:					7/92
**	ABSTRACT:
**	
**	REVISION HISTORY:
*/
 
/*
**	INCLUDES
*/
#if defined(WIN32S)
#include <windows.h>
#include <windowsx.h>
#include "winport.h"
#include "winio.h"
#include "winhan.h"
#endif
#include "risutl.h"
#include "plbck.h"
#include "utl_inf.h"
#if defined(WIN32S)
#include "prog32s.h"
#endif 

/*
**	DEFINES
*/

/*
**	TYPES
*/

/*
**	FUNCTION PROTOTYPES
*/
#define plbprint_c
#include "rap.prt"
#include "plbprint.prt"
#include "comumsg.prt"
#include "sys.prt"

/*
**	VARIABLES
*/

/*
**	FUNCTIONS
*/

/******************************************************************************/

static void print_command_status(
command_info_s	*cmd)
{
	FPRINTF(out_fp, "sqlcode:%d\n", cmd->sqlcode);
	if (cmd->command_time != -1)
	{
		FPRINTF(out_fp, MSG(RISUTL_I_CMD_TIME), cmd->command_time);
	}

	if (cmd->total_time != -1)
	{
		FPRINTF(out_fp, MSG(RISUTL_I_ELAPSED_TIME), cmd->total_time);
	}
}

/******************************************************************************/

static void print_checksum(
command_info_s *cmd)
{
	FPRINTF(out_fp, "CHECKSUM SCHEMA FILE\n");

	print_command_status(cmd);
}

/******************************************************************************/

static void print_clear(
command_info_s *cmd)
{
	FPRINTF(out_fp, "CLEAR\n");

	FPRINTF(out_fp, "stmt_id:%d\n", clear.stmt_id);
	FPRINTF(out_fp, "execute_mode:%d\n", clear.execute_mode);
	FPRINTF(out_fp, "new_stmt_id:%d\n", clear.new_stmt_id);
	FPRINTF(out_fp, "async_id:%d\n", clear.async_id);

	print_command_status(cmd);
}

/******************************************************************************/

static void print_clear_async(
command_info_s *cmd)
{
	FPRINTF(out_fp, "CLEAR ASYNC\n");

	FPRINTF(out_fp, "async_id:%d\n", clear.async_id);

	print_command_status(cmd);
}

/******************************************************************************/

static void print_close(
command_info_s *cmd)
{
	FPRINTF(out_fp, "CLOSE\n");

	FPRINTF(out_fp, "stmt_id:%d\n", clse.stmt_id);
	FPRINTF(out_fp, "execute_mode:%d\n", clse.execute_mode);
	FPRINTF(out_fp, "async_id:%d\n", clse.async_id);

	print_command_status(cmd);
}

/******************************************************************************/

static void print_debug(
command_info_s *cmd)
{
	FPRINTF(out_fp, "DEBUG\n");

	FPRINTF(out_fp, "s:0x%x\n", debug.s);
	if (debug.s)
	{
		FPRINTF(out_fp, "*s:<%s>\n", debug.s);
	}

	print_command_status(cmd);
}

/******************************************************************************/

static void print_describe(
command_info_s	*cmd)
{
	FPRINTF(out_fp, "DESCRIBE\n");

	FPRINTF(out_fp, "stmt_id:%d\n", describe.stmt_id);
	FPRINTF(out_fp, "data:0x%x\n", describe.data);
	if (describe.data)
	{
		RISrap_print_describe_sqlda(out_fp, describe.data);
	}
	FPRINTF(out_fp, "in_out:%d\n", describe.in_out);

	print_command_status(cmd);
}

/******************************************************************************/

static void print_execute(
command_info_s *cmd)
{
	FPRINTF(out_fp, "EXECUTE\n");

	FPRINTF(out_fp, "stmt_id:%d\n", execute.stmt_id);
	FPRINTF(out_fp, "in_sqlda:0x%x\n", execute.in_sqlda);
	if (execute.in_sqlda)
	{
		RISrap_print_input_sqlda(out_fp, execute.in_sqlda);
	}
	FPRINTF(out_fp, "execute_mode:%d\n", execute.execute_mode);
	FPRINTF(out_fp, "clear_flag:%d\n", execute.clear_flag);
	FPRINTF(out_fp, "static_flag:%d\n", execute.static_flag);
	FPRINTF(out_fp, "new_stmt_id:%d\n", execute.new_stmt_id);
	FPRINTF(out_fp, "async_id:%d\n", execute.async_id);

	print_command_status(cmd);
}

/******************************************************************************/

static void print_execute_imm(
command_info_s *cmd)
{
	FPRINTF(out_fp, "EXECUTE IMMEDIATE\n");

	FPRINTF(out_fp, "stmt_id:0x%x\n", execute_imm.stmt_id);
	if (execute_imm.stmt_id)
	{
		FPRINTF(out_fp, "*stmt_id:%d\n", *execute_imm.stmt_id);
	}
	FPRINTF(out_fp, "query:<%s>\n", execute_imm.query);
	FPRINTF(out_fp, "in_sqlda:0x%x\n", execute_imm.in_sqlda);
	if (execute_imm.in_sqlda)
	{
		RISrap_print_input_sqlda(out_fp, execute_imm.in_sqlda);
	}
	FPRINTF(out_fp, "execute_mode:%d\n", execute_imm.execute_mode);
	FPRINTF(out_fp, "clear_flag:%d\n", execute_imm.clear_flag);
	FPRINTF(out_fp, "static_flag:%d\n", execute_imm.static_flag);
	FPRINTF(out_fp, "new_stmt_id:%d\n", execute_imm.new_stmt_id);
	FPRINTF(out_fp, "async_id:%d\n", execute_imm.async_id);

	print_command_status(cmd);
}

/******************************************************************************/

static void print_fetch(
command_info_s *cmd)
{
	FPRINTF(out_fp, "FETCH\n");

	FPRINTF(out_fp, "stmt_id:%d\n", fetch.stmt_id);
	FPRINTF(out_fp, "output:0x%x\n", fetch.output);
	if (fetch.output)
	{
		RISrap_print_output_sqlda(out_fp, fetch.output);
	}
	FPRINTF(out_fp, "one_row_only:%d\n", fetch.one_row_only);
	FPRINTF(out_fp, "execute_mode:%d\n", fetch.execute_mode);
	FPRINTF(out_fp, "async_id:%d\n", fetch.async_id);

	print_command_status(cmd);
}

/******************************************************************************/

static void print_get_app_version(
command_info_s *cmd)
{
	FPRINTF(out_fp, "GET APP VERSION\n");

	FPRINTF(out_fp, "maj:0x%x\n", get_app_version.maj);
	FPRINTF(out_fp, "min:0x%x\n", get_app_version.min);
	FPRINTF(out_fp, "rel:0x%x\n", get_app_version.rel);

	print_command_status(cmd);
}

/******************************************************************************/

static void print_get_async_stmts(
command_info_s *cmd)
{
	FPRINTF(out_fp, "GET ASYNC STMTS\n");

	FPRINTF(out_fp, "buffer:0x%x\n", get_async_stmts.buffer);
	FPRINTF(out_fp, "countp:0x%x\n", get_async_stmts.countp);
	if (get_async_stmts.countp)
	{
		FPRINTF(out_fp, "*countp:%d\n", *get_async_stmts.countp);
	}

	print_command_status(cmd);
}

/******************************************************************************/

static void print_get_client_location(
command_info_s *cmd)
{
	FPRINTF(out_fp, "GET CLIENT LOCATION\n");

	FPRINTF(out_fp, "parms:0x%x\n",get_client_location.parms);

	print_command_status(cmd);
}

/******************************************************************************/

static void print_get_db_info(
command_info_s *cmd)
{
	FPRINTF(out_fp, "GET DB INFO\n");

	FPRINTF(out_fp, "dbid:%d\n", get_db_info.dbid);
	FPRINTF(out_fp, "dbp:0x%x\n", get_db_info.dbp);

	print_command_status(cmd);
}

/******************************************************************************/

static void print_get_default_schname(
command_info_s *cmd)
{
	FPRINTF(out_fp, "GET DEFAULT SCHNAME\n");

	FPRINTF(out_fp, "buffer:0x%x\n", get_default_schname.buffer);

	print_command_status(cmd);
}

/******************************************************************************/

static void print_get_flags(
command_info_s *cmd)
{
	FPRINTF(out_fp, "GET FLAGS\n");

	FPRINTF(out_fp, "ansi_mode:0x%x\n", get_flags.ansi_mode);
	FPRINTF(out_fp, "enable_dbms:0x%x\n", get_flags.enable_dbms);
	FPRINTF(out_fp, "verify_mode:0x%x\n", get_flags.verify_mode);
	FPRINTF(out_fp, "blankstrip_mode:0x%x\n", get_flags.blankstrip_mode);
	FPRINTF(out_fp, "autocommit:0x%x\n", get_flags.autocommit);
	FPRINTF(out_fp, "autorename:0x%x\n", get_flags.autorename);

	print_command_status(cmd);
}

/******************************************************************************/

static void print_get_language_name(
	command_info_s *cmd)
{
	FPRINTF(out_fp, "GET LANGUAGE NAME\n");

	FPRINTF(out_fp, "name:0x%x\n", get_language_name.name);

	print_command_status(cmd);
}

/******************************************************************************/

static void print_get_parameters(
command_info_s *cmd)
{
	FPRINTF(out_fp, "GET PARAMETERS\n");

	FPRINTF(out_fp, "parameters:0x%x\n", get_parameters.parameters);

	print_command_status(cmd);
}

/******************************************************************************/

static void print_get_ris_type_code(
command_info_s *cmd)
{
	FPRINTF(out_fp, "GET RIS TYPE CODE\n");

	FPRINTF(out_fp, "code:0x%x\n", get_ris_type_code.code);
	FPRINTF(out_fp, "str:0x%x\n", get_ris_type_code.str);
	if (get_ris_type_code.str)
	{
		FPRINTF(out_fp, "*str:<%s>\n", get_ris_type_code.str);
	}

	print_command_status(cmd);
}

/******************************************************************************/

static void print_get_ris_type_string(
command_info_s *cmd)
{
	FPRINTF(out_fp, "GET RIS TYPE STRING\n");

	FPRINTF(out_fp, "str:0x%x\n", get_ris_type_string.str);
	FPRINTF(out_fp, "code:%d\n", get_ris_type_string.code);

	print_command_status(cmd);
}

/******************************************************************************/

static void print_get_schema_file(
command_info_s *cmd)
{
	FPRINTF(out_fp, "GET SCHEMA FILE\n");

	FPRINTF(out_fp, "schema_filenamep:0x%x\n",get_schema_file.schema_filenamep);
	FPRINTF(out_fp, "dblistp:0x%x\n", get_schema_file.dblistp);
	FPRINTF(out_fp, "schlistp:0x%x\n", get_schema_file.schlistp);
	FPRINTF(out_fp, "granteep:0x%x\n", get_schema_file.granteep);

	print_command_status(cmd);
}

/******************************************************************************/

static void print_get_schema_file_location(
command_info_s *cmd)
{
	FPRINTF(out_fp, "GET SCHEMA FILE LOCATION\n");

	FPRINTF(out_fp, "parms:0x%x\n",get_schema_file_location.parms);

	print_command_status(cmd);
}

/******************************************************************************/

static void print_get_schema_info(
command_info_s *cmd)
{
	FPRINTF(out_fp, "GET SCHEMA INFO\n");

	FPRINTF(out_fp, "schname:0x%x\n", get_schema_info.schname);
	if (get_schema_info.schname)
	{
		FPRINTF(out_fp, "*schname:%s\n", get_schema_info.schname);
	}
	FPRINTF(out_fp, "dbp:0x%x\n", get_schema_info.dbp);
	FPRINTF(out_fp, "schemap:0x%x\n", get_schema_info.schemap);
	FPRINTF(out_fp, "granteep:0x%x\n", get_schema_info.granteep);

	print_command_status(cmd);
}

/******************************************************************************/

static void print_get_schema_names(
command_info_s *cmd)
{
	FPRINTF(out_fp, "GET SCHEMA NAMES\n");

	FPRINTF(out_fp, "buffer:0x%x\n", get_schema_names.buffer);
	FPRINTF(out_fp, "countp:0x%x\n", get_schema_names.countp);
	if (get_schema_names.countp)
	{
		FPRINTF(out_fp, "*countp:%d\n", *get_schema_names.countp);
	}

	print_command_status(cmd);
}

/******************************************************************************/

static void print_get_schema_transactions(
command_info_s *cmd)
{
	FPRINTF(out_fp, "GET SCHEMA TRANSACTIONS\n");

	FPRINTF(out_fp, "buffer:0x%x\n", get_schema_transactions.buffer);
	FPRINTF(out_fp, "countp:0x%x\n", get_schema_transactions.countp);
	if (get_schema_transactions.countp)
	{
		FPRINTF(out_fp, "*countp:%d\n", *get_schema_transactions.countp);
	}

	print_command_status(cmd);
}

/******************************************************************************/

static void print_get_ss_def(
command_info_s *cmd)
{
	FPRINTF(out_fp, "GET SS DEF\n");

	FPRINTF(out_fp, "ss_name:0x%x\n", get_ss_def.ss_name);
	if (get_ss_def.ss_name)
	{
		FPRINTF(out_fp, "*ss_name:<%s>\n", get_ss_def.ss_name);
	}
	FPRINTF(out_fp, "buffer:0x%x\n", get_ss_def.buffer);
	FPRINTF(out_fp, "countp:0x%x\n", get_ss_def.countp);
	if (get_ss_def.countp)
	{
		FPRINTF(out_fp, "*countp:%d\n", *get_ss_def.countp);
	}

	print_command_status(cmd);
}

/******************************************************************************/

static void print_get_ss_names(
command_info_s *cmd)
{
	FPRINTF(out_fp, "GET SS NAMES\n");

	FPRINTF(out_fp, "buffer:0x%x\n", get_ss_names.buffer);
	FPRINTF(out_fp, "countp:0x%x\n", get_ss_names.countp);
	if (get_ss_names.countp)
	{
		FPRINTF(out_fp, "*countp:%d\n", *get_ss_names.countp);
	}

	print_command_status(cmd);
}

/******************************************************************************/

static void print_get_stmt_schname(
command_info_s *cmd)
{
	FPRINTF(out_fp, "GET STMT SCHNAME\n");

	FPRINTF(out_fp, "buffer:0x%x\n", get_stmt_schname.buffer);

	print_command_status(cmd);
}

/******************************************************************************/

static void print_initialize(
command_info_s *cmd)
{
	FPRINTF(out_fp, "INITIALIZE\n");

	FPRINTF(out_fp, "language_name:0x%x\n", initialize.language_name);
	if (initialize.language_name)
	{
		FPRINTF(out_fp, "*language_name:%s\n", initialize.language_name);
	}

	print_command_status(cmd);
}

/******************************************************************************/

static void print_locate_client(
command_info_s *cmd)
{
	FPRINTF(out_fp, "LOCATE CLIENT\n");

	FPRINTF(out_fp, "parms:0x%x\n", locate_client.parms);
	if (locate_client.parms)
	{
		FPRINTF(out_fp, "protocol:%c\n", locate_client.parms->protocol);
		FPRINTF(out_fp, "address:%s\n", locate_client.parms->address);
		FPRINTF(out_fp, "username:%s\n", locate_client.parms->username);
		FPRINTF(out_fp, "password:%s\n", locate_client.parms->password);
	}

	print_command_status(cmd);
}

/******************************************************************************/

static void print_locate_schema_file(
command_info_s *cmd)
{
	FPRINTF(out_fp, "LOCATE SCHEMA FILE\n");

	FPRINTF(out_fp, "parms:0x%x\n", locate_schema_file.parms);
	if (locate_schema_file.parms)
	{
		FPRINTF(out_fp, "protocol:%c\n", locate_schema_file.parms->protocol);
		FPRINTF(out_fp, "address:%s\n", locate_schema_file.parms->address);
		FPRINTF(out_fp, "username:%s\n", locate_schema_file.parms->username);
		FPRINTF(out_fp, "password:%s\n", locate_schema_file.parms->password);
		FPRINTF(out_fp, "filename:%s\n", locate_schema_file.parms->filename);
	}
	print_command_status(cmd);
}

/******************************************************************************/

static void print_prepare(
command_info_s *cmd)
{
	FPRINTF(out_fp, "PREPARE\n");

	FPRINTF(out_fp, "stmt_id:%d\n", prepare.stmt_id);
	FPRINTF(out_fp, "query:<%s>\n", prepare.query);
	FPRINTF(out_fp, "clear_flag:%d\n", prepare.clear_flag);
	FPRINTF(out_fp, "static_flag:%d\n", prepare.static_flag);
	FPRINTF(out_fp, "new_stmt_id:%d\n", prepare.new_stmt_id);

	print_command_status(cmd);
}

/******************************************************************************/

static void print_report_error(
command_info_s *cmd)
{
	FPRINTF(out_fp, "REPORT ERROR\n");

	FPRINTF(out_fp, "async_id:0x%x\n", report_error.async_id);
	if (report_error.async_id)
	{
		FPRINTF(out_fp, "*async_id:%d\n", *report_error.async_id);
	}
	FPRINTF(out_fp, "ptrp:0x%x\n", report_error.ptrp);

	print_command_status(cmd);
}

/******************************************************************************/

static void print_report_ss_error(
command_info_s *cmd)
{
	FPRINTF(out_fp, "REPORT SS ERROR\n");

	FPRINTF(out_fp, "ss_name:0x%x\n", report_ss_error.ss_name);
	if (report_ss_error.ss_name)
	{
		FPRINTF(out_fp, "*ss_name:<%s>\n", report_ss_error.ss_name);
	}

	print_command_status(cmd);
}

/******************************************************************************/

static void print_schema_mgr(
command_info_s *cmd)
{
	FPRINTF(out_fp, "SCHEMA MGR\n");

	FPRINTF(out_fp, "mode:%d\n", schema_mgr.mode);
	FPRINTF(out_fp, "data:0x%x\n", schema_mgr.data);
	if (schema_mgr.data)
	{
		FPRINTF(out_fp, "data:%s\n", schema_mgr.data);
	}
	if (schema_mgr.str)
	{
		FPRINTF(out_fp, "str:%s\n", schema_mgr.str);
	}

	print_command_status(cmd);
}

/******************************************************************************/

static void print_select_into(
command_info_s *cmd)
{
	FPRINTF(out_fp, "SELECT INTO\n");

	FPRINTF(out_fp, "stmt_id:%d\n", select_into.stmt_id);
	FPRINTF(out_fp, "query:<%s>\n", select_into.query);
	FPRINTF(out_fp, "in_sqlda:0x%x\n", select_into.in_sqlda);
	if (select_into.in_sqlda)
	{
		RISrap_print_input_sqlda(out_fp, select_into.in_sqlda);
	}
	FPRINTF(out_fp, "out_sqlda:0x%x\n", select_into.out_sqlda);
	if (select_into.out_sqlda)
	{
		RISrap_print_output_sqlda(out_fp, select_into.out_sqlda);
	}
	FPRINTF(out_fp, "execute_mode:%d\n", select_into.execute_mode);
	FPRINTF(out_fp, "new_stmt_id:%d\n", select_into.new_stmt_id);
	FPRINTF(out_fp, "async_id:%d\n", select_into.async_id);

	print_command_status(cmd);
}

/******************************************************************************/

static void print_start_client(
command_info_s *cmd)
{
	FPRINTF(out_fp, "START CLIENT\n");

	print_command_status(cmd);
}

/******************************************************************************/

static void print_stop_client(
command_info_s *cmd)
{
	FPRINTF(out_fp, "STOP CLIENT\n");

	print_command_status(cmd);
}

/******************************************************************************/

static void print_terminate(
command_info_s *cmd)
{
	FPRINTF(out_fp, "TERMINATE\n");

	print_command_status(cmd);
}

/******************************************************************************/

static void print_test_completion(
command_info_s *cmd)
{
	FPRINTF(out_fp, "TEST COMPLETION\n");

	FPRINTF(out_fp, "desc:0x%x\n", test_completion.desc);
	if (test_completion.desc)
	{
		RISrap_print_test_sqlda(out_fp, describe.data);
	}
	FPRINTF(out_fp, "wait_flag:%d\n", test_completion.wait_flag);

	print_command_status(cmd);
}

/******************************************************************************/

extern void print_command(
command_info_s *cmd)
{
	FPRINTF(out_fp, "COMMAND:%d\n", cmd->number);

	switch(cmd->type)
	{
		case CHECKSUM:
			print_checksum(cmd);
			break;

		case CLEAR:
			print_clear(cmd);
			break;

		case CLEAR_ASYNC:
			print_clear_async(cmd);
			break;

		case CLOSE:
			print_close(cmd);
			break;

		case DEBUG:
			print_debug(cmd);
			break;

		case DESCRIBE:
			print_describe(cmd);
			break;

		case EXECUTE:
			print_execute(cmd);
			break;

		case EXECUTE_IMM:
			print_execute_imm(cmd);
			break;

		case FETCH:
			print_fetch(cmd);
			break;

		case GET_APP_VERSION:
			print_get_app_version(cmd);
			break;

		case GET_ASYNC_STMTS:
			print_get_async_stmts(cmd);
			break;

		case GET_CLIENT_LOCATION:
			print_get_client_location(cmd);
			break;

		case GET_DB_INFO:
			print_get_db_info(cmd);
			break;

		case GET_DEFAULT_SCHNAME:
			print_get_default_schname(cmd);
			break;

		case GET_FLAGS:
			print_get_flags(cmd);
			break;

		case GET_LANGUAGE_NAME:
			print_get_language_name(cmd);
			break;

		case GET_PARAMETERS:
			print_get_parameters(cmd);
			break;

		case GET_RIS_TYPE_CODE:
			print_get_ris_type_code(cmd);
			break;

		case GET_RIS_TYPE_STRING:
			print_get_ris_type_string(cmd);
			break;

		case GET_SCHEMA_FILE:
			print_get_schema_file(cmd);
			break;

		case GET_SCHEMA_FILE_LOCATION:
			print_get_schema_file_location(cmd);
			break;

		case GET_SCHEMA_INFO:
			print_get_schema_info(cmd);
			break;

		case GET_SCHEMA_NAMES:
			print_get_schema_names(cmd);
			break;

		case GET_SCHEMA_TRANSACTIONS:
			print_get_schema_transactions(cmd);
			break;

		case GET_SS_DEF:
			print_get_ss_def(cmd);
			break;

		case GET_SS_NAMES:
			print_get_ss_names(cmd);
			break;

		case GET_STMT_SCHNAME:
			print_get_stmt_schname(cmd);
			break;

		case INITIALIZE:
			print_initialize(cmd);
			break;

		case LOCATE_CLIENT:
			print_locate_client(cmd);
			break;

		case LOCATE_SCHEMA_FILE:
			print_locate_schema_file(cmd);
			break;

		case PREPARE:
			print_prepare(cmd);
			break;

		case REPORT_ERROR:
			print_report_error(cmd);
			break;

		case REPORT_SS_ERROR:
			print_report_ss_error(cmd);
			break;

		case SCHEMA_MGR:
			print_schema_mgr(cmd);
			break;

		case SELECT_INTO:
			print_select_into(cmd);
			break;

		case START_CLIENT:
			print_start_client(cmd);
			break;

		case STOP_CLIENT:
			print_stop_client(cmd);
			break;

		case TERMINATE:
			print_terminate(cmd);
			break;

		case TEST_COMPLETION:
			print_test_completion(cmd);
			break;

		default:
			break;
	}
	FPRINTF(out_fp,"----------\n");
}

/******************************************************************************/

extern void print_delay(
delay_info_s *delay)
{
	FPRINTF(out_fp, "DELAY\n");

	FPRINTF(out_fp, MSG(RISUTL_I_DELAY_TIME), delay->delay_time);
	if (delay->total_time != -1)
	{
		FPRINTF(out_fp, MSG(RISUTL_I_ELAPSED_TIME), delay->total_time);
	}
	FPRINTF(out_fp,"----------\n");
}

/******************************************************************************/

extern void print_system(
	system_info_s *sys)
{
	FPRINTF(out_fp, "SYSTEM\n");
	FPRINTF(out_fp, "cmd:<%s>\n", sys->cmd);
	FPRINTF(out_fp,"----------\n");
}

/******************************************************************************/
