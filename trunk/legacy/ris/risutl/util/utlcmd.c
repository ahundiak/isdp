/* Do not alter this SPC information: $Revision: 1.2.26.1 $ */
/*
**	NAME:							utlcmd.c
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
#include <ctype.h>
#include <errno.h>
#include "risasync.h"
#include "util.h"

/*
**	FUNCTION PROTOTYPES
*/
#define utlcmd_c
#include "comdebug.prt"
#include "comisfn.prt"
#include "comumsg.prt"
#include "comjmp.prt"
#include "comstcmi.prt"
#include "edtgtcmd.prt"
#include "edtgets.prt"
#include "utlclear.prt"
#include "utlcli.prt"
#include "utlclose.prt"
#include "utlcmd.prt"
#include "utldcode.prt"
#include "utldebug.prt"
#include "utlexec.prt"
#include "utleximm.prt"
#include "utlfetch.prt"
#include "utlloccl.prt"
#include "utllocfl.prt"
#include "utlmisc.prt"
#include "utlparm.prt"
#include "utlpaswd.prt"
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
#define selected_topic(choice, topic) \
(choice == HELP_ALL && \
	(RISutl_help_debug || (topic != HELP_INTERNAL && topic != HELP_PRIMS))) || \
(topic == choice)

/* Macros for command topics */
#define HELP_ALL			1
#define HELP_MISC			2
#define HELP_EMACS			3
#define HELP_VI				4
#define HELP_PRIMS			5
#define HELP_INTERNAL	    6
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
		HELP_PRIMS,
		"Prepare a statement",
		0
	},
	{	"as", RISutl_parm,
		RISutl_line,
		HELP_PRIMS,
		"Assign a value to a parameter",
		0
	},
	{	"input", RISutl_show_input_parms,
		0,
		HELP_PRIMS,
		"Show input parameter values",
		0
	},
	{	"output", RISutl_show_output_parms,
		0,
		HELP_PRIMS,
		"Show output parameter values",
		0
	},
	{	"execimm", RISutl_execimm,
		0,
		HELP_PRIMS,
		"Execute immediately a statement",
		0
	},
	{	"execute", (void (*)())RISutl_exec,
		(void *)SYNC_MODE,
		HELP_PRIMS,
		"Execute a statement",
		0
	},
	{	"fe", RISutl_fetch,
		(void *)FETCH_MODE,
		HELP_PRIMS,
		"Fetch a result row",
		0
	},
	{	"nx", RISutl_fetch,
		(void *)NEXT_MODE,
		HELP_PRIMS,
		"Fetch the next result row",
		0
	},
	{	"retrieve", RISutl_fetch,
		(void *)RETRIEVE_MODE,
		HELP_PRIMS,
		"Fetch all result rows",
		0
	},
	{	"close cursor", (void (*)())RISutl_close,
		(void *)SYNC_MODE,
		HELP_PRIMS,
		"Close a cursor",
		0
	},
	{	"clear all stmts", (void (*)())RISutl_clear,
		0,
		HELP_PRIMS,
		"Clear all statements",
		0
	},
	{	"clear stmt", (void (*)())RISutl_clear,
		(void *)SYNC_MODE,
		HELP_PRIMS,
		"Clear a statement",
		0
	},
	{	"async execimm", RISutl_execimm,
		(void *)ASYNC_START_MODE,
		HELP_PRIMS,
		"Execute immediately a statement",
		0
	},
	{	"async execute", (void (*)())RISutl_exec,
		(void *)ASYNC_START_MODE,
		HELP_PRIMS,
		"Execute a statement asynchronously",
		0
	},
	{	"async fe", RISutl_fetch,
		(void *)ASYNC_FETCH_MODE,
		HELP_PRIMS,
		"Fetch a result row asychronously",
		0
	},
	{	"async nx", RISutl_fetch,
		(void *)ASYNC_NEXT_MODE,
		HELP_PRIMS,
		"Fetch the next result row asynchronously",
		0
	},
	{	"async close cursor", (void (*)())RISutl_close,
		(void *)ASYNC_START_MODE,
		HELP_PRIMS,
		"Close a cursor",
		0
	},
	{	"async clear stmt", (void (*)())RISutl_clear,
		(void *)ASYNC_START_MODE,
		HELP_PRIMS,
		"Clear a statement asynchronously",
		0
	},
	{	"test", RISutl_test_wait,
		0,
		HELP_PRIMS,
		"Test for completion of an asynchronous statement",
		0
	},
	{	"wait", RISutl_test_wait,
		(void *)1,
		HELP_PRIMS,
		"Wait for completion of an asynchronous statement",
		0
	},
	{	"clear async", RISutl_clear_async,
		0,
		HELP_PRIMS,
		"Clear the memory associated with an asynchronous statement",
		0
	},
	{	"report error", RISutl_report_async_error,
		0,
		HELP_PRIMS,
		"Report the last error for a schema",
		0
	},
	{	"report superschema error", RISutl_report_ss_error,
		0,
		HELP_PRIMS,
		"Report the errors for a superschema",
		0
	},

	/*--------------------------*/
	/* RIS Internal Operations */
	/*--------------------------*/

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
		HELP_MISC,
		NULL,
		(int) RISUTL_I_HELP_MISC_1
	},
	{	"?", RISutl_help,
		0,
		HELP_MISC,
		NULL,
		(int) RISUTL_I_HELP_MISC_2
	},
	{	"--", 0,
		0,
		HELP_MISC,
		NULL,
		(int) RISUTL_I_HELP_MISC_3
	},
	{	"checksum schema file", RISutl_schema_file_checksum,
		0,
		HELP_MISC,
		NULL,
		(int) RISUTL_I_HELP_MISC_4
	},
	{	"clear passwords", RISutl_clear_passwords,
		0,
		HELP_MISC,
		NULL,
		(int) RISUTL_I_HELP_MISC_29
	},
	{	"decode", RISutl_decode,
		&RISutl_line[sizeof("decode")-1],
		HELP_MISC,
		NULL,
		(int) RISUTL_I_HELP_MISC_5
	},
	{	"editor vi", EDT_set_edit_style,
		"vi",
		HELP_MISC,
		NULL,
		(int) RISUTL_I_HELP_MISC_6
	},
	{	"editor emacs", EDT_set_edit_style,
		"emacs",
		HELP_MISC,
		NULL,
		(int) RISUTL_I_HELP_MISC_27
	},
	{	"exit", RISutl_terminate,
		(void *)-1,
		HELP_MISC,
		NULL,
		(int) RISUTL_I_HELP_MISC_7
	},
	{	"help", RISutl_help,
		0,
		HELP_MISC,
		NULL,
		(int) RISUTL_I_HELP_MISC_8
	},
	{	"ignore errors", RISutl_ignore_errors,
		(void *)1,
		HELP_MISC,
		NULL,
		(int) RISUTL_I_HELP_MISC_9
	},
	{	"locate client", RISutl_locate_client,
		0,
		HELP_MISC,
		NULL,
		(int) RISUTL_I_HELP_MISC_10
	},
	{	"locate schema file", RISutl_locate_schfile,
		0,
		HELP_MISC,
		NULL,
		(int) RISUTL_I_HELP_MISC_11
	},
	{	"process errors", RISutl_ignore_errors,
		0,
		HELP_MISC,
		NULL,
		(int) RISUTL_I_HELP_MISC_12
	},
	{	"q", RISutl_terminate,
		(void *)-1,
		HELP_MISC,
		NULL,
		(int) RISUTL_I_HELP_MISC_13
	},
	{	"quit", RISutl_terminate,
		(void *)-1,
		HELP_MISC,
		NULL,
		(int) RISUTL_I_HELP_MISC_14
	},
	{	"read", RISutl_read,
		&RISutl_line[sizeof("read")-1],
		HELP_MISC,
		NULL,
		(int) RISUTL_I_HELP_MISC_15
	},
	{	"set passwords", RISutl_set_passwords,
		0,
		HELP_MISC,
		NULL,
		(int) RISUTL_I_HELP_MISC_29
	},
	{	"show client location", RISutl_show_client_loc,
		0,
		HELP_MISC,
		NULL,
		(int) RISUTL_I_HELP_MISC_16
	},
	{	"show default schema", RISutl_show_default_schema_name,
		0,
		HELP_MISC,
		NULL,
		(int) RISUTL_I_HELP_MISC_17
	},
	{	"show flags", RISutl_show_flags,
		0,
		HELP_MISC,
		NULL,
		(int) RISUTL_I_HELP_MISC_18
	},
	{	"show parameters", RISutl_show_parameters,
		0,
		HELP_MISC,
		NULL,
		(int) RISUTL_I_HELP_MISC_19
	},
	{	"show schema file location", RISutl_show_schfile_loc,
		0,
		HELP_MISC,
		NULL,
		(int) RISUTL_I_HELP_MISC_20
	},
	{	"show schema file", RISutl_show_schfile,
		0,
		HELP_MISC,
		NULL,
		(int) RISUTL_I_HELP_MISC_21
	},
	{	"show schema names", RISutl_show_schema_names,
		0,
		HELP_MISC,
		NULL,
		(int) RISUTL_I_HELP_MISC_22
	},
	{	"show superschema definition", RISutl_show_ss_def,
		0,
		HELP_MISC,
		NULL,
		(int) RISUTL_I_HELP_MISC_23
	},
	{	"show superschema names", RISutl_show_ss_names,
		0,
		HELP_MISC,
		NULL,
		(int) RISUTL_I_HELP_MISC_24
	},
	{	"show schema transactions", RISutl_show_schema_transactions,
		0,
		HELP_PRIMS,
		"Show schemas in transaction",
		0
	},
	{	"start client", RISutl_start_client,
		0,
		HELP_MISC,
		NULL,
		(int) RISUTL_I_HELP_MISC_25
	},
	{	"stop client", RISutl_stop_client,
		0,
		HELP_MISC,
		NULL,
		(int) RISUTL_I_HELP_MISC_26
	},

	/* NOTE: (int) RISUTL_I_HELP_MISC_27 is already used for "editor emacs" */

	/*-------------------------------*/
	/* 		EDITOR COMMANDS 		 */
	/*-------------------------------*/

	{	"ctrl-n", 0,
		0,
		HELP_EMACS,
		NULL,
		(int) RISUTL_I_HELP_EMACS_1
	},
	{	"ctrl-p", 0,
		0,
		HELP_EMACS,
		NULL,
		(int) RISUTL_I_HELP_EMACS_2
	},
	{	"esc <", 0,
		0,
		HELP_EMACS,
		NULL,
		(int) RISUTL_I_HELP_EMACS_3
	},
	{	"esc >", 0,
		0,
		HELP_EMACS,
		NULL,
		(int) RISUTL_I_HELP_EMACS_4
	},
	{	"ctrl-a", 0,
		0,
		HELP_EMACS,
		NULL,
		(int) RISUTL_I_HELP_EMACS_5
	},
	{	"ctrl-e", 0,
		0,
		HELP_EMACS,
		NULL,
		(int) RISUTL_I_HELP_EMACS_6
	},
	{	"esc-v", 0,
		0,
		HELP_EMACS,
		NULL,
		(int) RISUTL_I_HELP_EMACS_7
	},
	{	"ctrl-v", 0,
		0,
		HELP_EMACS,
		NULL,
		(int) RISUTL_I_HELP_EMACS_8
	},
	{	"esc-f", 0,
		0,
		HELP_EMACS,
		NULL,
		(int) RISUTL_I_HELP_EMACS_9
	},
	{	"esc-b", 0,
		0,
		HELP_EMACS,
		NULL,
		(int) RISUTL_I_HELP_EMACS_10
	},
	{	"ctrl-f", 0,
		0,
		HELP_EMACS,
		NULL,
		(int) RISUTL_I_HELP_EMACS_11
	},
	{	"ctrl-b", 0,
		0,
		HELP_EMACS,
		NULL,
		(int) RISUTL_I_HELP_EMACS_12
	},
	{	"ctrl-d", 0,
		0,
		HELP_EMACS,
		NULL,
		(int) RISUTL_I_HELP_EMACS_13
	},
	{	"ctrl-h", 0,
		0,
		HELP_EMACS,
		NULL,
		(int) RISUTL_I_HELP_EMACS_14
	},
	{	"ctrl-l", 0,
		0,
		HELP_EMACS,
		NULL,
		(int) RISUTL_I_HELP_EMACS_15
	},
	{	"ctrl-i", 0,
		0,
		HELP_EMACS,
		NULL,
		(int) RISUTL_I_HELP_EMACS_16
	},
	{	"ctrl-k", 0,
		0,
		HELP_EMACS,
		NULL,
		(int) RISUTL_I_HELP_EMACS_17
	},
	{	"ctrl-r<string>", 0,
		0,
		HELP_EMACS,
		NULL,
		(int) RISUTL_I_HELP_EMACS_18
	},
	{	"ctrl-y", 0,
		0,
		HELP_EMACS,
		NULL,
		(int) RISUTL_I_HELP_EMACS_19
	},
	{	"esc", 0,
		0,
		HELP_VI,
		NULL,
		(int) RISUTL_I_HELP_VI_1
	},
	{	"i", 0,
		0,
		HELP_VI,
		NULL,
		(int) RISUTL_I_HELP_VI_2
	},
	{	"I", 0,
		0,
		HELP_VI,
		NULL,
		(int) RISUTL_I_HELP_VI_3
	},
	{	"a", 0,
		0,
		HELP_VI,
		NULL,
		(int) RISUTL_I_HELP_VI_4
	},
	{	"A", 0,
		0,
		HELP_VI,
		NULL,
		(int) RISUTL_I_HELP_VI_5
	},
	{	"-", 0,
		0,
		HELP_VI,
		NULL,
		(int) RISUTL_I_HELP_VI_6
	},
	{	"+", 0,
		0,
		HELP_VI,
		NULL,
		(int) RISUTL_I_HELP_VI_7
	},
	{	"/<string>", 0,
		0,
		HELP_VI,
		NULL,
		(int) RISUTL_I_HELP_VI_8
	},
	{	"n", 0,
		0,
		HELP_VI,
		NULL,
		(int) RISUTL_I_HELP_VI_9
	},
	{	"N", 0,
		0,
		HELP_VI,
		NULL,
		(int) RISUTL_I_HELP_VI_10
	},
	{	"H", 0,
		0,
		HELP_VI,
		NULL,
		(int) RISUTL_I_HELP_VI_11
	},
	{	"G or g", 0,
		0,
		HELP_VI,
		NULL,
		(int) RISUTL_I_HELP_VI_12
	},
	{	"0", 0,
		0,
		HELP_VI,
		NULL,
		(int) RISUTL_I_HELP_VI_13
	},
	{	"$", 0,
		0,
		HELP_VI,
		NULL,
		(int) RISUTL_I_HELP_VI_14
	},
	{	"k", 0,
		0,
		HELP_VI,
		NULL,
		(int) RISUTL_I_HELP_VI_15
	},
	{	"j", 0,
		0,
		HELP_VI,
		NULL,
		(int) RISUTL_I_HELP_VI_16
	},
	{	"o", 0,
		0,
		HELP_VI,
		NULL,
		(int) RISUTL_I_HELP_VI_17
	},
	{	"O", 0,
		0,
		HELP_VI,
		NULL,
		(int) RISUTL_I_HELP_VI_18
	},
	{	"J", 0,
		0,
		HELP_VI,
		NULL,
		(int) RISUTL_I_HELP_VI_19
	},
	{	"w", 0,
		0,
		HELP_VI,
		NULL,
		(int) RISUTL_I_HELP_VI_20
	},
	{	"W", 0,
		0,
		HELP_VI,
		NULL,
		(int) RISUTL_I_HELP_VI_21
	},
	{	"b", 0,
		0,
		HELP_VI,
		NULL,
		(int) RISUTL_I_HELP_VI_22
	},
	{	"B", 0,
		0,
		HELP_VI,
		NULL,
		(int) RISUTL_I_HELP_VI_23
	},
	{	"e", 0,
		0,
		HELP_VI,
		NULL,
		(int) RISUTL_I_HELP_VI_24
	},
	{	"E", 0,
		0,
		HELP_VI,
		NULL,
		(int) RISUTL_I_HELP_VI_25
	},
	{	"l", 0,
		0,
		HELP_VI,
		NULL,
		(int) RISUTL_I_HELP_VI_26
	},
	{	"h", 0,
		0,
		HELP_VI,
		NULL,
		(int) RISUTL_I_HELP_VI_27
	},
	{	"x", 0,
		0,
		HELP_VI,
		NULL,
		(int) RISUTL_I_HELP_VI_28
	},
	{	"ctrl-h", 0,
		0,
		HELP_VI,
		NULL,
		(int) RISUTL_I_HELP_VI_29
	},
	{	"dl (cl)", 0,
		0,
		HELP_VI,
		NULL,
		(int) RISUTL_I_HELP_VI_30
	},
	{	"dh (ch)", 0,
		0,
		HELP_VI,
		NULL,
		(int) RISUTL_I_HELP_VI_31
	},
	{	"dw (cw)", 0,
		0,
		HELP_VI,
		NULL,
		(int) RISUTL_I_HELP_VI_32
	},
	{	"dW (cW)", 0,
		0,
		HELP_VI,
		NULL,
		(int) RISUTL_I_HELP_VI_33
	},
	{	"db (cb)", 0,
		0,
		HELP_VI,
		NULL,
		(int) RISUTL_I_HELP_VI_34
	},
	{	"dB (cB)", 0,
		0,
		HELP_VI,
		NULL,
		(int) RISUTL_I_HELP_VI_35
	},
	{	"d0 (c0)", 0,
		0,
		HELP_VI,
		NULL,
		(int) RISUTL_I_HELP_VI_36
	},
	{	"d$ (c$)", 0,
		0,
		HELP_VI,
		NULL,
		(int) RISUTL_I_HELP_VI_37
	},
	{	"dG (cG)", 0,
		0,
		HELP_VI,
		NULL,
		(int) RISUTL_I_HELP_VI_38
	},
	{	"dd", 0,
		0,
		HELP_VI,
		NULL,
		(int) RISUTL_I_HELP_VI_39
	},
	{	"D", 0,
		0,
		HELP_VI,
		NULL,
		(int) RISUTL_I_HELP_VI_40
	},
	{	"p", 0,
		0,
		HELP_VI,
		NULL,
		(int) RISUTL_I_HELP_VI_41
	},
	{	"P", 0,
		0,
		HELP_VI,
		NULL,
		(int) RISUTL_I_HELP_VI_42
	},
	{	"u", 0,
		0,
		HELP_VI,
		NULL,
		(int) RISUTL_I_HELP_VI_43
	},
	{	".", 0,
		0,
		HELP_VI,
		NULL,
		(int) RISUTL_I_HELP_VI_44
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

extern void RISutl_command(
	void)
{
	int i, sts;
	int	input_to_process;
	int len;

	UTL_DBG(("RISutl_command()\n"));

	if ((input_to_process = get_utl_line()) == 0)
	{
		/*
		**	get an input line
		*/
		if (RISutl_file_tos->next)
		{
			sts = EDT_getcmd(RISutl_buffer, LINE_LEN, RISutl_file_tos->file);
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
			sts = EDT_getcmd(RISutl_buffer, LINE_LEN, 0);
			if (sts == -1)
			{
				LONGJMP(RISUTL_E_INPUT_TOO_LONG);
			}
			if (sts == 0)
			{
				RISutl_terminate(-1);
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
			sts = system(&RISutl_line[1]);
			if (sts != 0)
			{
				UTL_DBG(("RISutl_command:system(\"%s\") returned:%d errno:%d\n",
					&RISutl_line[1], sts, errno));
				if (sts < 0)
				{
					printf(MSG(RISUTL_I_SYSTEM), strerror(errno));
				}
				else
				{
					printf(MSG(RISUTL_I_SYSTEM_ERROR_CODE), sts);
				}
			}
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
						UTL_DBG(("RISutl_command:returning\n"));
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
	UTL_DBG(("RISutl_command:returning\n"));
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

	UTL_DBG(("print_help(cmd_len:%d cmd:0x%x help:0x%x key:0x%x)\n",
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

		printf("%-*s%s\n", cmd_len, cmd, help);
		help = ptr + 1;

		if (first_line)
		{
			cmd = "";
			cmd_len += 4;
			help_space -= 4;
			first_line = 0;
		}
	}
	printf("%-*s%s\n", cmd_len, cmd, help);

	UTL_DBG(("print_help:returning\n"));
}

/******************************************************************************/

extern void RISutl_help(
	void)
{
	int		i;
	int		len;
	int		choice;
	int		valid_choice;
	int		topic;
	int		last_topic;
	int		max_cmd_len;
	char	response[82];
	/* System command listed in risalpha help - TR fix */
    int     printed_bang = 0;

	UTL_DBG(("RISutl_help()\n"));

	CLEAR_INTERRUPT();

	printf(MSG(RISUTL_I_HELP_MENU1));
	printf(MSG(RISUTL_I_HELP_MENU2), HELP_ALL);
	printf(MSG(RISUTL_I_HELP_MENU3), HELP_MISC);
	printf(MSG(RISUTL_I_HELP_MENU4), HELP_EMACS);
	printf(MSG(RISUTL_I_HELP_MENU5), HELP_VI);
	if (RISutl_help_debug)
	{
		printf(MSG(RISUTL_I_HELP_MENU6), HELP_PRIMS);
		printf(MSG(RISUTL_I_HELP_MENU7), HELP_INTERNAL);
	}

	do
	{
		if (!RISutl_help_debug)
		{
			printf(MSG(RISUTL_I_ENTER_HELP_TOPIC), HELP_ALL, HELP_VI);
		}
		else
		{
			printf(MSG(RISUTL_I_ENTER_HELP_TOPIC), HELP_ALL, HELP_INTERNAL);
		}

		RISutl_fgets(response,82,RISutl_file_tos->file);
		if (INTERRUPTED())
		{
			printf("\n");
			return;
		}

		valid_choice = 0;
		choice = atoi(response);
		switch(choice)
		{
			case HELP_ALL:
				valid_choice = 1;
				printf(MSG(RISUTL_I_ALL_COMMANDS1));
				printf(MSG(RISUTL_I_ALL_COMMANDS2));
				printf(MSG(RISUTL_I_ALL_COMMANDS3));
				break;

			case HELP_MISC:
			case HELP_EMACS:
			case HELP_VI:
				valid_choice = 1;
				break;

			case HELP_PRIMS:
			case HELP_INTERNAL:
				if (RISutl_help_debug)
				{
					valid_choice = 1;
					break;
				}
				/* NO BREAK */

			default:
				printf(MSG(RISUTL_I_INVALID_CHOICE));
				break;
		}
	} while (!valid_choice);


	/*
	** Loop through command array to find longest command length
	*/
	max_cmd_len = 0;
	for (i = 0; (int)RISutl_cmds[i].func != -1; ++i)
	{
		topic = RISutl_cmds[i].topic;

		if (selected_topic(choice, topic))
		{
			len = strlen(RISutl_cmds[i].cmd);
			if (len > max_cmd_len)
			{
				max_cmd_len = len;
			}
		}
	}
	max_cmd_len +=2;

	last_topic = 0;
	for (i = 0; (int)RISutl_cmds[i].func != -1; ++i)
	{
		topic = RISutl_cmds[i].topic;

		if (selected_topic(choice, topic))
		{
			if (topic != last_topic)
			{
				switch(topic)
				{
					case HELP_MISC:
						printf(MSG(RISUTL_I_MISC_COMMANDS));
						break;

					case HELP_EMACS:
						printf(MSG(RISUTL_I_EMACS_COMMANDS));
						break;

					case HELP_VI:
						printf(MSG(RISUTL_I_VI_COMMANDS));
						break;

					case HELP_PRIMS:
						printf(MSG(RISUTL_I_NEXT_COMMANDS));
						break;

					case HELP_INTERNAL:
						printf(MSG(RISUTL_I_INTERNAL_COMMANDS));
						break;
				}
			}

/*
** The system command '!' is listed out by risalpha help - TR fix  
*/
			if (!printed_bang && (topic == HELP_MISC))
			{
				print_help(max_cmd_len, "!<cmd>", "execute system command <cmd>", 0);
				printed_bang = 1;
			}

			print_help(max_cmd_len, RISutl_cmds[i].cmd, RISutl_cmds[i].help,
				RISutl_cmds[i].help_key);
			last_topic = topic;
		}
	}

	UTL_DBG(("RISutl_help:returning\n"));
}

/******************************************************************************/

static int get_utl_line(
	void)
{
	int return_sts;
	char *line_ptr;
	char in_literal;

	UTL_DBG(("get_utl_line():\n"));

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

	UTL_DBG(("get_utl_line:returning %d\n", return_sts));
	return return_sts;
}

/******************************************************************************/
