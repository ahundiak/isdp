/* Do not alter this SPC information: $Revision: 1.2.26.1 $ */
/*
**	NAME:							plbexec.c
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
#include <sys/types.h>
#include <signal.h>

#if defined(unix)
#include <sys/time.h>
#include <sys/times.h>
#endif

#if defined(WIN32)
#include <time.h>
#endif

#if defined(DOS)
#include <sys/time.h>
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
#define plbexec_c
#include "comumsg.prt"
#include "plbexec.prt"
#include "plbids.prt"
#include "plbmisc.prt"
#include "ris.prt"
#include "sys.prt"

/*
**	VARIABLES
*/
clock_t		start_time = 0;
#if defined(unix)
static struct tms	buffer;
#endif

/*
**	FUNCTIONS
*/

/******************************************************************************/

extern int execute_command(
command_info_s *cmd)
{
	int		got;
	int		expected;
	int		total_time;
	int		command_time;
	int		async_id;
	int		*async_idp;
	short	stmt_id;
	short	*stmt_idp;
	clock_t	start_cmd_time;
	clock_t	finish_cmd_time;

	if (cmd->sqlcode == RIS_SUCCESS)
	{
		expected = EXPECTED_SUCCESS;
	}
	else if (cmd->sqlcode == END_OF_DATA)
	{
		expected = EXPECTED_END_OF_DATA;
	}
	else
	{
		expected = EXPECTED_ERROR;
	}

	FPRINTF(out_fp, "COMMAND:%d\n", cmd->number);

	if (start_time == (clock_t)0)
	{
#if defined(unix)
		start_time = start_cmd_time = times(&buffer);
#elif defined(WIN32) || defined(DOS)
		start_time = start_cmd_time = clock();
#else
ERROR -- NO CODE
#endif
	}
	else
	{
#if defined(unix)
		start_cmd_time = times(&buffer);
#elif defined(WIN32) || defined(DOS)
		start_cmd_time = clock();
#else
ERROR -- NO CODE
#endif
	}

	switch(cmd->type)
	{
		case CHECKSUM:
			RISrestore_schema_file_checksum();
			break;

		case CLEAR:
			stmt_idp = get_playback_stmt_id_addr(clear.stmt_id);
			async_id = -1;
			RISint_clear(stmt_idp, &async_id, clear.execute_mode);
			if (clear.new_stmt_id != clear.stmt_id)
			{
				set_recorded_stmt_id_value(stmt_idp, clear.new_stmt_id);
			}
			if (clear.async_id != -1)
			{
				set_recorded_async_id_value(async_id, clear.async_id);
			}
			break;

		case CLEAR_ASYNC:
			async_idp = get_playback_async_id_addr(clear_async.async_id);
			RISint_clear_async(async_idp);
			break;

		case CLOSE:
			stmt_id = get_playback_stmt_id_value(clse.stmt_id);
			async_id = -1;
			RISint_close(stmt_id, &async_id, clse.execute_mode);
			if (clse.async_id != -1)
			{
				set_recorded_async_id_value(async_id, clse.async_id);
			}
			break;

		case DEBUG:
			if (debug.output_flag)
			{
				RISint_process_debug(debug.s);
			}
			else
			{
				RISint_process_debug_no_output(debug.s);
			}
			break;

		case DESCRIBE:
			stmt_id = get_playback_stmt_id_value(describe.stmt_id);
			RISint_describe(stmt_id, describe.data, describe.in_out);
			break;
		
		case EXECUTE:
			stmt_idp = get_playback_stmt_id_addr(execute.stmt_id);
			async_id = -1;
			RISint_execute(stmt_idp, &async_id, execute.in_sqlda,
				execute.execute_mode, execute.clear_flag, execute.static_flag);
			if (execute.new_stmt_id != execute.stmt_id)
			{
				set_recorded_stmt_id_value(stmt_idp, execute.new_stmt_id);
			}
			if (execute.async_id != -1)
			{
				set_recorded_async_id_value(async_id, execute.async_id);
			}
			break;

		case EXECUTE_IMM:
			if (execute_imm.stmt_id)
			{
				stmt_idp = get_playback_stmt_id_addr(*execute_imm.stmt_id);
				async_id = -1;
				RISint_execute_immediate(stmt_idp, &async_id, execute_imm.query,
					execute_imm.in_sqlda, execute_imm.execute_mode,
					execute_imm.clear_flag, execute_imm.static_flag);
				if (execute_imm.new_stmt_id != *execute_imm.stmt_id)
				{
					set_recorded_stmt_id_value(stmt_idp,
						execute_imm.new_stmt_id);
				}
				if (execute_imm.async_id != -1)
				{
					set_recorded_async_id_value(async_id, execute_imm.async_id);
				}
			}
			else
			{
				async_id = -1;
				RISint_execute_immediate(0, &async_id, execute_imm.query,
					execute_imm.in_sqlda, execute_imm.execute_mode,
					execute_imm.clear_flag, execute_imm.static_flag);
				if (execute_imm.async_id != -1)
				{
					set_recorded_async_id_value(async_id, execute_imm.async_id);
				}
			}
			break;

		case FETCH:
			stmt_id = get_playback_stmt_id_value(fetch.stmt_id);
			async_id = -1;
			RISint_fetch(stmt_id, &async_id, fetch.output, fetch.one_row_only,
				fetch.execute_mode);
			if (fetch.async_id != -1)
			{
				set_recorded_async_id_value(async_id, fetch.async_id);
			}
			break;

		case GET_APP_VERSION:
		{
			int *majp, maj;
			int *minp, min;
			int *relp, rel;

			if (get_app_version.maj)
			{
				majp = &maj;
			}
			else
			{
				majp = 0;
			}

			if (get_app_version.min)
			{
				minp = &min;
			}
			else
			{
				minp = 0;
			}

			if (get_app_version.rel)
			{
				relp = &rel;
			}
			else
			{
				relp = 0;
			}

			RISget_app_version(majp, minp, relp);
		}
		break;

		case GET_ASYNC_STMTS:
			RISget_async_stmts(get_async_stmts.buffer, get_async_stmts.countp);
		break;
			
		case GET_CLIENT_LOCATION:
		{
			client_parms	parms, *parmsp;
			
			if (get_client_location.parms)
			{
				parmsp = &parms;
			}
			else
			{
				parmsp = 0;
			}
			RISget_client_location(parmsp);
		}
		break;

		case GET_DB_INFO:
		{
			ris_db_info *db = 0, **dbp;

			if (get_db_info.dbp)
			{
				dbp = &db;
			}
			else
			{
				dbp = 0;
			}

			RISget_db_info(get_db_info.dbid, dbp);

			/*
			**	Free up db info
			*/
			if (db)
			{
				free(db);
			}
		}
		break;

		case GET_DEFAULT_SCHNAME:
		{
			char *def_schnamep, def_schname[RIS_MAX_ID_SIZE];

			if (get_default_schname.buffer)
			{
				def_schnamep = def_schname;
			}
			else
			{
				def_schnamep = 0;
			}

			RISget_default_schema_name(def_schnamep);
		}
		break;

		case GET_FLAGS:
		{
			int ansi_mode, *ansi_modep;
			int enable_dbms, *enable_dbmsp;
			int verify_mode, *verify_modep;
			int blankstrip_mode, *blankstrip_modep;
			int autocommit, *autocommitp;
			int autorename, *autorenamep;

			if (get_flags.ansi_mode)
			{
				ansi_modep = &ansi_mode;
			}
			else
			{
				ansi_modep = 0;
			}

			if (get_flags.enable_dbms)
			{
				enable_dbmsp = &enable_dbms;
			}
			else
			{
				enable_dbmsp = 0;
			}

			if (get_flags.verify_mode)
			{
				verify_modep = &verify_mode;
			}
			else
			{
				verify_modep = 0;
			}

			if (get_flags.blankstrip_mode)
			{
				blankstrip_modep = &blankstrip_mode;
			}
			else
			{
				blankstrip_modep = 0;
			}

			if (get_flags.autocommit)
			{
				autocommitp = &autocommit;
			}
			else
			{
				autocommitp = 0;
			}

			if (get_flags.autorename)
			{
				autorenamep = &autorename;
			}
			else
			{
				autorenamep = 0;
			}

			RISint_get_flags(ansi_modep, enable_dbmsp, verify_modep,
				blankstrip_modep, autocommitp, autorenamep);
		}
		break;

		case GET_LANGUAGE_NAME:
		{
			char *language_namep, language_name[RIS_MAX_ID_SIZE];

			if (get_language_name.name)
			{
				language_namep = language_name;
			}
			else
			{
				language_namep = 0;
			}

			RISget_language_name(language_namep);
		}
		break;

		case GET_PARAMETERS:
		{
			ris_parameters	parms, *parmsp;

			if (get_parameters.parameters)
			{
				parmsp = &parms;
			}
			else
			{
				parmsp = 0;
			}

			RISget_parameters(parmsp);
		}
		break;

		case GET_RIS_TYPE_CODE:
		{
			int *codep, code;

			if (get_ris_type_code.code)
			{
				codep = &code;
			}
			else
			{
				codep = 0;
			}
			RISget_ris_sqltype_code(codep, get_ris_type_code.str);
		}
		break;

		case GET_RIS_TYPE_STRING:
		{
			char *strp, str[RIS_MAX_ID_SIZE];

			if (get_ris_type_string.str)
			{
				strp = str;
			}
			else
			{
				strp = 0;
			}
			RISget_ris_sqltype_string(strp, get_ris_type_string.code);
		}
		break;

		case GET_SCHEMA_FILE:
		{
			char				*filename = 0, **filenamep;
			ris_db_info			*dblist = 0, **dblistp, *dblistnext;
			ris_schema_info		*schlist = 0, **schlistp, *schlistnext;
			ris_grantee_info	*grantee = 0, **granteep, *granteenext;

			if (get_schema_file.schema_filenamep)
			{
				filenamep = &filename;
			}
			else
			{
				filenamep = 0;
			}

			if (get_schema_file.dblistp)
			{
				dblistp = &dblist;
			}
			else
			{
				dblistp = 0;
			}

			if (get_schema_file.schlistp)
			{
				schlistp = &schlist;
			}
			else
			{
				schlistp = 0;
			}

			if (get_schema_file.granteep)
			{
				granteep = &grantee;
			}
			else
			{
				granteep = 0;
			}

			RISget_schema_file(filenamep, dblistp, schlistp, granteep);

			/*
			** Free up filename, db, schema and grantee info
			*/
			if (filename)
			{
				free(filename);
			}

			while(dblist)
			{
				dblistnext = dblist->next;
				free(dblist);
				dblist = dblistnext;
			}
			while(schlist)
			{
				schlistnext = schlist->next;
				free(schlist);
				schlist = schlistnext;
			}
			while(grantee)
			{
				granteenext = grantee->next;
				free(grantee);
				grantee = granteenext;
			}
		}
		break;

		case GET_SCHEMA_FILE_LOCATION:
		{
			schema_file_parms	parms, *parmsp;
			
			if (get_schema_file_location.parms)
			{
				parmsp = &parms;
			}
			else
			{
				parmsp = 0;
			}
			RISget_schema_file_location(parmsp);
		}
		break;

		case GET_SCHEMA_INFO:
		{
			ris_schema_info		*schema = 0, **schemap;
			ris_db_info			*db = 0, **dbp;
			ris_grantee_info	*grantee = 0, **granteep, *granteenext;

			if (get_schema_info.schemap)
			{
				schemap = &schema;
			}
			else
			{
				schemap = 0;
			}

			if (get_schema_info.dbp)
			{
				dbp = &db;
			}
			else
			{
				dbp = 0;
			}

			if (get_schema_info.granteep)
			{
				granteep = &grantee;
			}
			else
			{
				granteep = 0;
			}

			RISget_schema_info(get_schema_info.schname, schemap, dbp, granteep);

			/*
			** Free up db, schema and grantee info
			*/
			if (schema)
			{
				free(schema);
			}
			if (db)
			{
				free(db);
			}
			while(grantee)
			{
				granteenext = grantee->next;
				free(grantee);
				grantee = granteenext;
			}
		}
		break;

		case GET_SCHEMA_NAMES:
			RISget_schema_names(get_schema_names.buffer,
				get_schema_names.countp);
		break;
			
		case GET_SCHEMA_TRANSACTIONS:
			RISget_schema_transactions(get_schema_transactions.buffer,
				get_schema_transactions.countp);
		break;
			
		case GET_SS_DEF:
			RISget_superschema_definition(get_ss_def.ss_name, get_ss_def.buffer,
				get_ss_def.countp);
		break;

		case GET_SS_NAMES:
			RISget_superschema_names(get_ss_names.buffer, get_ss_names.countp);
		break;

		case GET_STMT_SCHNAME:
		{
			char *stmt_schnamep, stmt_schname[RIS_MAX_ID_SIZE];

			if (get_stmt_schname.buffer)
			{
				stmt_schnamep = stmt_schname;
			}
			else
			{
				stmt_schnamep = 0;
			}

			RISget_current_stmt_schema_name(stmt_schnamep);
		}
		break;

		case INITIALIZE:
			RISinitialize(initialize.language_name);
		break;

		case LOCATE_CLIENT:
			RISlocate_client(locate_client.parms);
		break;

		case LOCATE_SCHEMA_FILE:
			RISlocate_schema_file(locate_schema_file.parms);
		break;

		case PREPARE:
			stmt_idp = get_playback_stmt_id_addr(prepare.stmt_id);
			RISint_prepare(stmt_idp, prepare.query, prepare.clear_flag,
				prepare.static_flag);
			if (prepare.new_stmt_id != prepare.stmt_id)
			{
				set_recorded_stmt_id_value(stmt_idp, prepare.new_stmt_id);
			}
		break;

		case REPORT_ERROR:
		{
			char	*ptr, **ptrp;
			
			if (report_error.async_id)
			{
				async_idp = get_playback_async_id_addr(*report_error.async_id);
			}
			else
			{
				async_idp = 0;
			}

			if (report_error.ptrp)
			{
				ptrp = &ptr;
			}
			else
			{
				ptrp = 0;
			}
			RISint_report_error(async_idp, ptrp);
		}
		break;

		case REPORT_SS_ERROR:
			RISint_report_superschema_error(report_ss_error.ss_name);
		break;

		case SCHEMA_MGR:
			RISint_schema_mgr((char)schema_mgr.mode, schema_mgr.data, schema_mgr.str);
			break;

		case SELECT_INTO:
			stmt_idp = get_playback_stmt_id_addr(select_into.stmt_id);
			async_id = -1;
			RISint_select(stmt_idp, &async_id, select_into.query,
				select_into.in_sqlda, select_into.out_sqlda, 
				select_into.execute_mode);
			if (select_into.new_stmt_id != select_into.stmt_id)
			{
				set_recorded_stmt_id_value(stmt_idp, select_into.new_stmt_id);
			}
			if (select_into.async_id != -1)
			{
				set_recorded_async_id_value(async_id, select_into.async_id);
			}
		break;

		case START_CLIENT:
			RISstart_client();
		break;

		case STOP_CLIENT:
			RISstop_client();
		break;

		case TERMINATE:
			RISterminate();
		break;

		case TEST_COMPLETION:
		{
			int i;
			sqlda *desc;

			if (test_completion.desc &&
				test_completion.desc->sqlvar)
			{
				desc = test_completion.desc;
				
				for (i = 0; i < desc->sqld; i++)
				{
					if (desc->sqlvar[i].sqltype == RIS_INTEGER &&
						desc->sqlvar[i].sqldata &&
						*(int *)desc->sqlvar[i].sqldata >= 0 &&
						*(int *)desc->sqlvar[i].sqldata < RIS_MAX_TRANSACTIONS)
					{
						async_id = *(int *)desc->sqlvar[i].sqldata;
						desc->sqlvar[i].sqldata =
							(char *)get_playback_async_id_addr(async_id);
					}
				}
			}
			RISint_test_completion(test_completion.desc,
				test_completion.wait_flag);
		}
		break;
	}

#if defined(unix)
	finish_cmd_time = times(&buffer);
#elif defined(WIN32) || defined(DOS)
	finish_cmd_time = clock();
#else
ERROR -- NO CODE
#endif

	if (SQLCODE == RIS_SUCCESS)
	{
		got = GOT_SUCCESS;
	}
	else if (SQLCODE == END_OF_DATA)
	{
		got = GOT_END_OF_DATA;
	}
	else
	{
		got = GOT_ERROR;
	}

	if (cmd->type == REPORT_ERROR)
	{
		/*
		**	REPORT ERROR doesn't set SQLCODE, so print success and
		**	don't compare SQLCODES.
		*/
		FPRINTF(out_fp, "sqlcode:%d\n", RIS_SUCCESS);
	}
	else
	{
		/*
		**	For all other commands,
		**	print SQLCODE and report if SQLCODES are different
		*/
		FPRINTF(out_fp, "sqlcode:%d\n", SQLCODE);
		if (cmd->sqlcode != SQLCODE)
		{
			FPRINTF(out_fp, MSG(RISUTL_I_DIFF_SQLCODES), SQLCODE, cmd->sqlcode);
		}
	}

	if (compare_command_times)
	{
		command_time = finish_cmd_time - start_cmd_time;
		FPRINTF(out_fp, MSG(RISUTL_I_CMD_TIME), command_time);
		if (cmd->command_time != -1)
		{
			FPRINTF(out_fp, MSG(RISUTL_I_CMD_TIME_DELTA),
				command_time - cmd->command_time);
		}
	}

	if (compare_total_times)
	{
		total_time = finish_cmd_time - start_time;
		FPRINTF(out_fp, MSG(RISUTL_I_ELAPSED_TIME), total_time);
		if (cmd->total_time != -1)
		{
			FPRINTF(out_fp, MSG(RISUTL_I_ELAPSED_TIME_DELTA),
				total_time - cmd->total_time);
		}
	}

	FPRINTF(out_fp,"----------\n");

	return action[expected][got];
}

/******************************************************************************/

extern void execute_delay(
delay_info_s	*delay)
{
	int total_time;
	int delay_time;
	clock_t start_delay_time;
	clock_t finish_delay_time;

	FPRINTF(out_fp, "DELAY\n");

	if (start_time == (clock_t)0)
	{
#if defined(unix)
		start_time = start_delay_time = times(&buffer);
#elif defined(WIN32) || defined(DOS)
		start_time = start_delay_time = clock();
#else
ERROR -- NO CODE
#endif
	}
	else
	{
#if defined(unix)
		start_delay_time = times(&buffer);
#elif defined(WIN32) || defined(DOS)
		start_delay_time = clock();
#else
ERROR -- NO CODE
#endif
	}

	sleep60(delay->delay_time);

#if defined(unix)
	finish_delay_time = times(&buffer);
#elif defined(WIN32) || defined(DOS)
	finish_delay_time = clock();
#else
ERROR -- NO CODE
#endif

	if (compare_delay_times)
	{
		delay_time = finish_delay_time - start_delay_time;
		FPRINTF(out_fp, MSG(RISUTL_I_DELAY_TIME), delay_time);
		FPRINTF(out_fp, MSG(RISUTL_I_DELAY_TIME_DELTA),
			delay_time - delay->delay_time);
	}

	if (compare_total_times)
	{
		total_time = finish_delay_time - start_time;
		FPRINTF(out_fp, MSG(RISUTL_I_ELAPSED_TIME), total_time);
		if (delay->total_time != -1)
		{
			FPRINTF(out_fp, MSG(RISUTL_I_ELAPSED_TIME_DELTA),
				total_time - delay->total_time);
		}
	}
	FPRINTF(out_fp,"----------\n");
}

/******************************************************************************/

extern void execute_system(
	system_info_s	*sys)
{
	int total_time;
	int system_time;
	clock_t start_system_time;
	clock_t finish_system_time;

	FPRINTF(out_fp, "SYSTEM\n");

	if (start_time == (clock_t)0)
	{
#if defined(unix)
		start_time = start_system_time = times(&buffer);
#elif defined(WIN32) || defined(DOS)
		start_time = start_system_time = clock();
#else
ERROR -- NO CODE
#endif
	}
	else
	{
#if defined(unix)
		start_system_time = start_system_time = times(&buffer);
#elif defined(WIN32) || defined(DOS)
		start_system_time = start_system_time = clock();
#else
ERROR -- NO CODE
#endif
	}

	system(sys->cmd);

#if defined(unix)
	finish_system_time = start_system_time = times(&buffer);
#elif defined(WIN32) || defined(DOS)
	finish_system_time = start_system_time = clock();
#else
ERROR -- NO CODE
#endif

	if (compare_command_times)
	{
		system_time = finish_system_time - start_system_time;
		FPRINTF(out_fp, MSG(RISUTL_I_SYSTEM_TIME), system_time);
	}

	if (compare_total_times)
	{
		total_time = finish_system_time - start_time;
		FPRINTF(out_fp, MSG(RISUTL_I_ELAPSED_TIME), total_time);
	}

	FPRINTF(out_fp,"----------\n");
}

/******************************************************************************/
