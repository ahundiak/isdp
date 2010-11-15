/* Do not alter this SPC information: $Revision: 1.2.27.1 $ */
/*
**	NAME:							btccmd.c
**	AUTHORS:						Dave Buehmann
**	CREATION DATE:					5/87
**	ABSTRACT:
**		This file contains the routine that processes a command.
**	
**	REVISION HISTORY:
*/
 
/*
**	INCLUDES
*/
#include <errno.h>
#include <ctype.h>
#include "risasync.h"
#include "batch.h"
#if defined(WIN32S)
#include <windows.h>
#include <windowsx.h>
#include "winport.h"
#include "winio.h"
#include "winhan.h"
#include "prog32s.h"
#endif

/*
**	FUNCTION PROTOTYPES
*/
#define btccmd_c
#include "btccmd.prt"
#include "utlprint.prt"
#include "btcgtcmd.prt"
#include "btcdcode.prt"
#include "comdebug.prt"
#include "comisfn.prt"
#include "comumsg.prt"
#include "comjmp.prt"
#include "comstcmi.prt"
#include "utlclear.prt"
#include "utlcli.prt"
#include "utlclose.prt"
#include "utldebug.prt"
#include "utlexec.prt"
#include "utleximm.prt"
#include "utlfetch.prt"
#include "utlloccl.prt"
#include "utllocfl.prt"
#include "utlmisc.prt"
#include "utlparm.prt"
#include "utlprep.prt"
#include "utlquery.prt"
#include "utlread.prt"
#include "utlreprt.prt"
#include "utlshasy.prt"
#include "utlshfil.prt"
#include "utlshflg.prt"
#include "utlshmem.prt"
#include "utlshnam.prt"
#include "utlshprm.prt"
#include "utlshss.prt"
#include "utlshstm.prt"
#include "utlshtrn.prt"
#include "utlterm.prt"
#include "utltest.prt"
#include "sys.prt"

/*
**	DEFINES
*/

/* Macros for command topics */
#define HELP_INTERNAL		1
#define HELP_EXTERNAL		2
#define LAST_ENTRY			99

/*
**	TYPES
*/
typedef struct cmd_struct
{
	char	*cmd;
	void	(* func)();
	void	*arg;
	int		topic;
	char	*help;
	int		help_key;
} cmd_struct;

/*
**	VARIABLES
*/
cmd_struct RISutl_cmds[]=
{
	/*--------------------------*/
	/* RIS Primitive Operations */
	/*--------------------------*/

	{	"prep", RISutl_prep,
		0,
		HELP_INTERNAL,
		"Prepare a statement",
		0
	},
	{	"as", RISutl_parm,
		RISutl_line,
		HELP_INTERNAL,
		"Assign a value to a parameter",
		0
	},
	{	"input", RISutl_show_input_parms,
		0,
		HELP_INTERNAL,
		"Show input parameter values",
		0
	},
	{	"output", RISutl_show_output_parms,
		0,
		HELP_INTERNAL,
		"Show output parameter values",
		0
	},
	{	"execimm", RISutl_execimm,
		0,
		HELP_INTERNAL,
		"Execute immediately a statement",
		0
	},
	{	"execute", (void (*)())RISutl_exec,
		(void *)SYNC_MODE,
		HELP_INTERNAL,
		"Execute a statement",
		0
	},
	{	"fe", RISutl_fetch,
		(void *)FETCH_MODE,
		HELP_INTERNAL,
		"Fetch a result row",
		0
	},
	{	"nx", RISutl_fetch,
		(void *)NEXT_MODE,
		HELP_INTERNAL,
		"Fetch the next result row",
		0
	},
	{	"retrieve", RISutl_fetch,
		(void *)RETRIEVE_MODE,
		HELP_INTERNAL,
		"Fetch all result rows",
		0
	},
	{	"close cursor", (void (*)())RISutl_close,
		(void *)SYNC_MODE,
		HELP_INTERNAL,
		"Close a cursor",
		0
	},
	{	"clear all stmts", (void (*)())RISutl_clear,
		0,
		HELP_INTERNAL,
		"Clear all statements",
		0
	},
	{	"clear stmt", (void (*)())RISutl_clear,
		(void *)SYNC_MODE,
		HELP_INTERNAL,
		"Clear a statement",
		0
	},
	{	"async execimm", RISutl_execimm,
		(void *)ASYNC_START_MODE,
		HELP_INTERNAL,
		"Execute immediately a statement",
		0
	},
	{	"async execute", (void (*)())RISutl_exec,
		(void *)ASYNC_START_MODE,
		HELP_INTERNAL,
		"Execute a statement asynchronously",
		0
	},
	{	"async fe", RISutl_fetch,
		(void *)ASYNC_FETCH_MODE,
		HELP_INTERNAL,
		"Fetch a result row asychronously",
		0
	},
	{	"async nx", RISutl_fetch,
		(void *)ASYNC_NEXT_MODE,
		HELP_INTERNAL,
		"Fetch the next result row asynchronously",
		0
	},
	{	"async close cursor", (void (*)())RISutl_close,
		(void *)ASYNC_START_MODE,
		HELP_INTERNAL,
		"Close a cursor",
		0
	},
	{	"async clear stmt", (void (*)())RISutl_clear,
		(void *)ASYNC_START_MODE,
		HELP_INTERNAL,
		"Clear a statement asynchronously",
		0
	},
	{	"test", RISutl_test_wait,
		0,
		HELP_INTERNAL,
		"Test for completion of an asynchronous statement",
		0
	},
	{	"wait", RISutl_test_wait,
		(void *)1,
		HELP_INTERNAL,
		"Wait for completion of an asynchronous statement",
		0
	},
	{	"clear async", RISutl_clear_async,
		0,
		HELP_INTERNAL,
		"Clear the memory associated with an asynchronous statement",
		0
	},
	{	"report error", RISutl_report_async_error,
		0,
		HELP_INTERNAL,
		"Report the last error for a schema",
		0
	},
	{	"report superschema error", RISutl_report_ss_error,
		0,
		HELP_INTERNAL,
		"Report the errors for a superschema",
		0
	},
	{	"debug", RISutl_process_debug,
		&RISutl_line[sizeof("debug")-1],
		HELP_INTERNAL,
		"Modify debug flags",
		0
	},
	{	"show app memory", RISutl_show_app_memory,
		0,
		HELP_INTERNAL,
		"Show information about the application memory",
		0
	},
	{	"show cli memory", RISutl_show_cli_memory,
		0,
		HELP_INTERNAL,
		"Show information about the client memory",
		0
	},
	{	"show app stmts", RISutl_show_app_stmts,
		0,
		HELP_INTERNAL,
		"Show information about the application statements",
		0
	},
	{	"show cli stmts", RISutl_show_cli_stmts,
		0,
		HELP_INTERNAL,
		"Show information about the client statements",
		0
	},
	{	"show util stmts", RISutl_show_util_stmts,
		0,
		HELP_INTERNAL,
		"Show information about the interactive utility statements",
		0
	},
	{	"show async ids", RISutl_show_async_ids,
		0,
		HELP_INTERNAL,
		"Show asynchronous statement ids only",
		0
	},
	{	"show async stmts", RISutl_show_async_stmts,
		0,
		HELP_INTERNAL,
		"Show information about the asynchronous statements",
		0
	},
	{	"show hash", RISutl_show_cli_hash_table,
		0,
		HELP_INTERNAL,
		"Show information about the hash table",
		0
	},
	{	"show servers", RISutl_show_cli_servers,
		0,
		HELP_INTERNAL,
		"Show information about the database servers",
		0
	},
	{	"show struct mgrs", RISutl_show_cli_struct_mgrs,
		0,
		HELP_INTERNAL,
		"Show information about the structure managers",
		0
	},

	/*---------------*/
	/* Miscellaneous */
	/*---------------*/

	{	"<sql statement>;", 0,
		0,
		HELP_EXTERNAL,
		NULL,
		(int)RISUTL_I_HELP_MISC_1
	},
	{	"?", RISutl_help,
		0,
		HELP_EXTERNAL,
		NULL,
		(int)RISUTL_I_HELP_MISC_2
	},
	{	"--", 0,
		0,
		HELP_EXTERNAL,
		NULL,
		(int)RISUTL_I_HELP_MISC_3
	},
	{	"checksum schema file", RISutl_schema_file_checksum,
		0,
		HELP_EXTERNAL,
		NULL,
		(int)RISUTL_I_HELP_MISC_4
	},
	{	"decode", RISbtc_decode,
		&RISutl_line[sizeof("decode")-1],
		HELP_EXTERNAL,
		NULL,
		(int)RISUTL_I_HELP_MISC_5
	},
	{	"exit", RISutl_terminate,
		0,
		HELP_EXTERNAL,
		NULL,
		(int)RISUTL_I_HELP_MISC_7
	},
	{	"help", RISutl_help,
		0,
		HELP_EXTERNAL,
		NULL,
		(int)RISUTL_I_HELP_MISC_8
	},
	{	"ignore errors", RISutl_ignore_errors,
		(void *)1,
		HELP_EXTERNAL,
		NULL,
		(int)RISUTL_I_HELP_MISC_9
	},
	{	"locate client", RISutl_locate_client,
		0,
		HELP_EXTERNAL,
		NULL,
		(int)RISUTL_I_HELP_MISC_10
	},
	{	"locate schema file", RISutl_locate_schfile,
		0,
		HELP_EXTERNAL,
		NULL,
		(int)RISUTL_I_HELP_MISC_11
	},
	{	"process errors", RISutl_ignore_errors,
		0,
		HELP_EXTERNAL,
		NULL,
		(int)RISUTL_I_HELP_MISC_12
	},
	{	"q", RISutl_terminate,
		0,
		HELP_EXTERNAL,
		NULL,
		(int)RISUTL_I_HELP_MISC_13
	},
	{	"quit", RISutl_terminate,
		0,
		HELP_EXTERNAL,
		NULL,
		(int)RISUTL_I_HELP_MISC_14
	},
	{	"read", RISutl_read,
		&RISutl_line[sizeof("read")-1],
		HELP_EXTERNAL,
		NULL,
		(int)RISUTL_I_HELP_MISC_15
	},
	{	"show client location", RISutl_show_client_loc,
		0,
		HELP_EXTERNAL,
		NULL,
		(int)RISUTL_I_HELP_MISC_16
	},
	{	"show default schema", RISutl_show_default_schema_name,
		0,
		HELP_EXTERNAL,
		NULL,
		(int)RISUTL_I_HELP_MISC_17
	},
	{	"show flags", RISutl_show_flags,
		0,
		HELP_EXTERNAL,
		NULL,
		(int)RISUTL_I_HELP_MISC_18
	},
	{	"show parameters", RISutl_show_parameters,
		0,
		HELP_EXTERNAL,
		NULL,
		(int)RISUTL_I_HELP_MISC_19
	},
	{	"show schema file location", RISutl_show_schfile_loc,
		0,
		HELP_EXTERNAL,
		NULL,
		(int)RISUTL_I_HELP_MISC_20
	},
	{	"show schema file", RISutl_show_schfile,
		0,
		HELP_EXTERNAL,
		NULL,
		(int)RISUTL_I_HELP_MISC_21
	},
	{	"show schema names", RISutl_show_schema_names,
		0,
		HELP_EXTERNAL,
		NULL,
		(int)RISUTL_I_HELP_MISC_22
	},
	{	"show schema transactions", RISutl_show_schema_transactions,
		0,
		HELP_EXTERNAL,
		"Show schemas in transaction",
		0
	},
	{	"show superschema definition", RISutl_show_ss_def,
		0,
		HELP_EXTERNAL,
		NULL,
		(int)RISUTL_I_HELP_MISC_23
	},
	{	"show superschema names", RISutl_show_ss_names,
		0,
		HELP_EXTERNAL,
		NULL,
		(int)RISUTL_I_HELP_MISC_24
	},
	{	"start client", RISutl_start_client,
		0,
		HELP_EXTERNAL,
		NULL,
		(int)RISUTL_I_HELP_MISC_25
	},
	{	"stop client", RISutl_stop_client,
		0,
		HELP_EXTERNAL,
		NULL,
		(int)RISUTL_I_HELP_MISC_26
	},

	/*-------------------------------*/
	/* ADD NEW COMMANDS (ABOVE) HERE */
	/*-------------------------------*/

	{	"LAST_ENTRY ", (void(*)())-1,
		0,
		LAST_ENTRY,
		"last entry of the commands",
		0
	},
};

/*
**	FUNCTIONS
*/

/******************************************************************************/

extern void RISbtc_command(
	void)
{
	int i, sts;
	int	input_to_process;
	int len;

	BTC_DBG(("RISutl_command()\n"));

	if ((input_to_process = get_utl_line()) == 0)
	{
		/*
		**	get an input line
		*/
		if (RISutl_file_tos->next)
		{
			/*
			** -i inputfile or read filename command
			*/
			sts = RISbtc_getcmd(RISutl_buffer, LINE_LEN, RISutl_file_tos->file);
			if (sts == -1)
			{
				LONGJMP(RISUTL_E_INPUT_TOO_LONG);
			}
			if (sts == 0)
			{
				if (*RISutl_buffer)
				{
					RISutl_stop_read(STOP_READ_EOS);
				}
				else
				{
					RISutl_stop_read(STOP_READ_EOF);
				}
				return;
			}
		}
		else
		{
			/*
			** redirected stdin
			*/
			sts = RISbtc_getcmd(RISutl_buffer, LINE_LEN, RISutl_file_tos->file);
			if (sts == -1)
			{
				LONGJMP(RISUTL_E_INPUT_TOO_LONG);
			}
			if (sts == 0)
			{
				RISutl_terminate();
			}
		}

		input_to_process = get_utl_line();
	}

	if (input_to_process)
	{
		RISutl_command_flag = 0;

		if (*RISutl_line == '!')
		{
			/*
			**	execute a command in the shell
			*/
#if defined(WIN32S)
			sts = WinExec(&RISutl_line[1],SW_SHOWNORMAL);
			if (sts == 0)
				PRINTF("The system is out of memory or resources.\n");
			else if (sts == ERROR_FILE_NOT_FOUND)
				PRINTF("The specified file was not found.\n");
			else if (sts == ERROR_PATH_NOT_FOUND)
				PRINTF("The specified path was not found.\n");
			else if (sts == ERROR_BAD_FORMAT)
				PRINTF("The .EXE file is invalid.\n");
			else if (sts <31)
				PRINTF("Unknown error.\n");
#else
			sts = system(&RISutl_line[1]);
			if (sts < 0)
			{
				RISutl_printf(MSG(RISUTL_I_SYSTEM), strerror(errno));
			}
			else if (sts > 0)
			{
				RISutl_printf(MSG(RISUTL_I_SYSTEM_ERROR_CODE), sts);
			}
#endif
		}
		else
		{
			/*
			**	Check rest of commands
			*/
			for (i = 0; (int)RISutl_cmds[i].func != -1; ++i)
			{
				len = strlen(RISutl_cmds[i].cmd);
				if (!RIScom_strncmp_ic(RISutl_cmds[i].cmd, RISutl_line, len) &&
					(RISutl_line[len] == '\0' ||
					 RISutl_line[len] == ' ' ||
					 RISutl_line[len] == ';'))
				{
					if (RISutl_cmds[i].func)
					{
						RISutl_command_flag = 1;
						(*RISutl_cmds[i].func)(RISutl_cmds[i].arg);
						BTC_DBG(("RISutl_command:returning\n"));
						return;
					}
					else
					{
						break;
					}
				}
			}

			/*
			**	command not found... send it to the parser
			*/
			RISutl_query(RISutl_line);
		}
	}
	BTC_DBG(("RISutl_command:returning\n"));
}

/******************************************************************************/

static void print_help(
	int		cmd_len,
	char	*cmd,
	char	*help,
	int		key)
{
	int		help_len;
	int		help_space;
	int		first_line;
	char	*ptr;

	BTC_DBG(("print_help(cmd_len:%d cmd:0x%x help:0x%x key:0x%x)\n",
		cmd_len, cmd, help, key));

	if (!help)
	{
		help = RIScom_umsg(key);
	}

	first_line = 1;
	help_space = RISutl_columns - cmd_len;
	while(1)
	{
		help_len = strlen(help);
		if (help_len <= help_space)
		{
			break;
		}
		ptr = help + help_space;
		while(!RIScom_isspace(*ptr))
		{
			ptr--;
		}
		*ptr = '\0';

		RISutl_printf("%-*s%s\n", cmd_len, cmd, help);
		help = ptr + 1;

		if (first_line)
		{
			cmd = "";
			cmd_len += 4;
			help_space -= 4;
			first_line = 0;
		}
	}
	RISutl_printf("%-*s%s\n", cmd_len, cmd, help);

	BTC_DBG(("print_help:returning\n"));
}

/******************************************************************************/

extern void RISutl_help(
	void)
{
	int		i;
	int		len;
	int		topic;
	int		max_cmd_len;

	BTC_DBG(("RISutl_help()\n"));

	/*
	** Loop through command array to find longest command length
	*/
	max_cmd_len = 0;
	for (i = 0; (int)RISutl_cmds[i].func != -1; ++i)
	{
		topic = RISutl_cmds[i].topic;
		if (topic == HELP_EXTERNAL ||
			(RISutl_help_debug && topic == HELP_INTERNAL))
		{
			len = strlen(RISutl_cmds[i].cmd);
			if (len > max_cmd_len)
			{
				max_cmd_len = len;
			}
		}
	}
	max_cmd_len +=2;

	for (i = 0; (int)RISutl_cmds[i].func != -1; ++i)
	{
		topic = RISutl_cmds[i].topic;
		if (topic == HELP_EXTERNAL ||
			(RISutl_help_debug && topic == HELP_INTERNAL))
		{
			print_help(max_cmd_len, RISutl_cmds[i].cmd, RISutl_cmds[i].help,
				RISutl_cmds[i].help_key);
		}
	}

	BTC_DBG(("RISutl_help:returning\n"));
}

/******************************************************************************/

static int get_utl_line(
	void)
{
	int return_sts;
	char *line_ptr;
	char in_literal;

	if (RISutl_ptr && *RISutl_ptr == '!')
	{
		/* secial case of shell command -- use the rest of the buffer */
		strcpy(RISutl_line, RISutl_ptr);
		RISutl_ptr = NULL;
		return_sts = 1;
	}
	else
	{
		in_literal = 0;
		line_ptr = RISutl_line;
		while(RISutl_ptr && *RISutl_ptr)
		{
			if (*RISutl_ptr == ';' && !in_literal)
			{
				RISutl_ptr++;
				while(*RISutl_ptr && RIScom_isspace(*RISutl_ptr))
				{
					RISutl_ptr++;
				}
				break;
			}
			if (*RISutl_ptr == '\'')
			{
				*line_ptr++ = *RISutl_ptr++;
				if (in_literal)
				{
					if (*RISutl_ptr == '\'')
					{
						*line_ptr++ = *RISutl_ptr++;
					}
					else
					{
						in_literal = 0;
					}
				}
				else
				{
					in_literal = 1;
				}
			}
			else
			{
				*line_ptr++ = *RISutl_ptr++;
			}
		}
		*line_ptr = '\0';

		if (line_ptr == RISutl_line)
		{
			return_sts = 0;
			RISutl_ptr = RISutl_buffer;
		}
		else
		{
			return_sts = 1;
		}
	}

	BTC_DBG(("get_utl_line:returning %d\n", return_sts));
	return return_sts;
}

/******************************************************************************/
