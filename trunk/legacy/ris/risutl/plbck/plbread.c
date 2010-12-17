/* Do not alter this SPC information: $Revision: 1.2.50.1 $ */
/*
**	NAME:							plbread.c
**	AUTHORS:						Terry McIntyre
**	CREATION DATE:					7/92
**	ABSTRACT:
**	
**	REVISION HISTORY:

TDM:11/10/93:	changed 'sqlda' functions to use sqln instead of sqld to
				determine the number of sqlvars to allocate
TDM:02/28/94:	added ris_blob support
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
#include <stdarg.h>
#include <ctype.h>
#include "risasync.h"
#include "risutl.h"
#include "risver.h"
#include "plbck.h"
#include "utl_inf.h"
#include "utl_err.h"
#if defined(WIN32S)
#include "prog32s.h"
#endif 

/*
**	DEFINES
*/
#define READ_KEYWORD(x)  { if (read_keyword(x)) { return 1; } }
#define MALLOC(t,s)\
{\
	(t) = (void *)calloc(1, s);\
	if ((t) == NULL)\
	{\
		error_msg(MSG(RISUTL_E_MALLOC));\
		report_errors = 0;\
		return 1;\
	}\
}

/*
**	TYPES
*/

/*
**	FUNCTION PROTOTYPES
*/
#define plbread_c
#include "plbfree.prt"
#include "plbmisc.prt"
#include "plbread.prt"
#include "comumsg.prt"
#include "sys.prt"

/*
**	VARIABLES
*/

/*
**	FUNCTIONS
*/

/******************************************************************************/

extern void error_msg(
	const char *fmt,
	...)
{
	va_list	args;

	if (report_errors)
	{
		va_start(args, fmt);

		PRINTF("\"%s\", line %d: ", in_filename, line);
		VPRINTF(fmt, args);
		va_end(args);
	}
}

/******************************************************************************/

extern int get_next_line(
	int	eof_flag,
	int	nl_flag)
{
	int		return_sts = 0;
	char	*nl;


	if ((p = fgets(s, 80, in_fp)) != NULL)
	{
		if ((nl = strchr(s, '\n')) != NULL)
		{
			/*
			**	If a newline was read increment line
			*/
			line++;

			/*
			**	if !nl_flag replace newline with null
			*/
			if (!nl_flag)
			{
				*nl = '\0';
			}
		}
	}
	else if (eof_flag == EOF_ERROR)
	{
		error_msg(MSG(RISUTL_I_UNEXPECTED_EOF));
		report_errors = 0;
		return_sts = 1;
	}

	return return_sts;
}

/******************************************************************************/

static int get_string_data(
	char **sp,
	char *end)
{
	int		len;
	int		end_len;
	int		data_len;
	char	*data;

	data = NULL;
	data_len = 0;
	end_len = strlen(end);
	while(1)
	{
		GET_NEXT_LINE(EOF_ERROR, KEEP_NL);
		if (!strncmp(p, end, end_len))
		{
			break;
		}

		len = strlen(p);
		if (data_len)
		{
			data = (char *)realloc(data, data_len + len);
		}
		else
		{
			data = (char *)malloc(len);
		}
		if (data == NULL)
		{
			error_msg(MSG(RISUTL_E_MALLOC));
			report_errors = 0;
			return 1;
		}
		memcpy(data + data_len, p, len);
		data_len += len;
	}

	if (data)
	{
		if (data_len > 0 && data[data_len - 1] == '\n')
		{
			data[data_len - 1] = '\0';
		}
		else
		{
			data[data_len] = '\0';
		}
	}

	*sp = data;

	return 0;
}

/******************************************************************************/

static int get_blob_data(
	ris_blob *b)
{
	unsigned int i,j;
	char byte[3] = { '\0', '\0', '\0' };
	char *ptr;

	MALLOC(b->array, b->array_size);

	GET_NEXT_LINE(EOF_ERROR, DROP_NL);
	ptr = p;
	for (i = 0; i < b->array_size; i++)
	{
		if (!*ptr)
		{
			GET_NEXT_LINE(EOF_ERROR, DROP_NL);
			ptr = p;
		}

		for (j = 0; j < 2; j++)
		{
			if (!*ptr || !isxdigit(*ptr))
			{
				error_msg("Error reading ris_blob data\n");
				report_errors = 0;
				return 1;
			}
			byte[j] = *ptr;
			ptr++;
		}
		b->array[i] = (char)strtol(byte, (char **)0, 16);
	}

	return 0;
}

/******************************************************************************/

static int read_keyword(
	char *keyword)
{
	int len;

	len = strlen(keyword);
	if (strncmp(p, keyword, len))
	{
		error_msg(MSG(RISUTL_I_EXPECTED_GOT), keyword, p);
		report_errors = 0;
		return 1;
	}
	p += len;

	return 0;
}

/******************************************************************************/

static int get_command_status(
	command_info_s *cmd)
{
	READ_KEYWORD("sqlcode:");
	cmd->sqlcode = atoi(p);

	GET_NEXT_LINE(EOF_ERROR, DROP_NL);
	if (!strncmp(p, "time:", 5))
	{
		p += 5;
		cmd->command_time = atoi(p);
		GET_NEXT_LINE(EOF_ERROR, DROP_NL);
	}
	else
	{
		cmd->command_time = -1;
	}

	if (!strncmp(p, "elapsed time:", 13))
	{
		p += 13;
		cmd->total_time = atoi(p);
		GET_NEXT_LINE(EOF_ERROR, DROP_NL);
	}
	else
	{
		cmd->total_time = -1;
	}

	/*
	**	seperator: required
	*/
	READ_KEYWORD("----------");

	return 0;
}

/******************************************************************************/

static int get_input_sqlda(
	sqlda *input)
{
	int i;

	GET_NEXT_LINE(EOF_ERROR, DROP_NL);
	READ_KEYWORD("n:");
	input->sqln = atoi(p);

	GET_NEXT_LINE(EOF_ERROR, DROP_NL);
	READ_KEYWORD("d:");
	input->sqld = atoi(p);

	GET_NEXT_LINE(EOF_ERROR, DROP_NL);
	READ_KEYWORD("var:");
	input->sqlvar = (sqlvar *)strtol(p, (char **)0, 16);
	if (input->sqlvar && input->sqln > 0)
	{
		MALLOC(input->sqlvar, input->sqln * sizeof(sqlvar));

		for (i = 0; i < input->sqln; i++)
		{
			GET_NEXT_LINE(EOF_ERROR, DROP_NL);
			READ_KEYWORD("null:");
			input->sqlvar[i].sqlnull = atoi(p);

			GET_NEXT_LINE(EOF_ERROR, DROP_NL);
			READ_KEYWORD("ind:");
			input->sqlvar[i].sqlind = (long *)strtol(p, (char **)0, 16);
			if (input->sqlvar[i].sqlnull && input->sqlvar[i].sqlind)
			{
				MALLOC(input->sqlvar[i].sqlind, sizeof(long));

				GET_NEXT_LINE(EOF_ERROR, DROP_NL);
				READ_KEYWORD("*ind:");
				*input->sqlvar[i].sqlind = atoi(p);
			}
			else
			{
/*
**	TDM 10/27/93 - if a valid indicator is not malloc'd clear the value
*/
				input->sqlvar[i].sqlind = (long *)0;
				
			}

			if (!input->sqlvar[i].sqlind || *input->sqlvar[i].sqlind >= 0)
			{
				GET_NEXT_LINE(EOF_ERROR, DROP_NL);
				READ_KEYWORD("type:");
				input->sqlvar[i].sqltype = atoi(p);

				GET_NEXT_LINE(EOF_ERROR, DROP_NL);
				READ_KEYWORD("len:");
				input->sqlvar[i].sqllen = atoi(p);

				if (input->sqlvar[i].sqltype == RIS_DECIMAL)
				{
					GET_NEXT_LINE(EOF_ERROR, DROP_NL);
					READ_KEYWORD("scale:");
					input->sqlvar[i].sqlscale = atoi(p);
				}

				GET_NEXT_LINE(EOF_ERROR, DROP_NL);
				READ_KEYWORD("data:");
				input->sqlvar[i].sqldata = (char *)strtol(p, (char **)0, 16);
				if (input->sqlvar[i].sqldata)
				{
					switch(input->sqlvar[i].sqltype)
					{
						case RIS_CHARACTER:
							GET_NEXT_LINE(EOF_ERROR, DROP_NL);
							READ_KEYWORD("start *data:");
							GET_STRING_DATA(input->sqlvar[i].sqldata,
								"stop *data:");
							break;

						case RIS_SMALLINT:
							MALLOC(input->sqlvar[i].sqldata, sizeof(short));
							GET_NEXT_LINE(EOF_ERROR, DROP_NL);
							READ_KEYWORD("*data:");
							*(short *)input->sqlvar[i].sqldata = (short)atoi(p);
							break;

						case RIS_INTEGER:
							MALLOC(input->sqlvar[i].sqldata, sizeof(int));
							GET_NEXT_LINE(EOF_ERROR, DROP_NL);
							READ_KEYWORD("*data:");
							*(int *)input->sqlvar[i].sqldata = (int)atoi(p);
							break;

						case RIS_REAL:
							MALLOC(input->sqlvar[i].sqldata, sizeof(float));
							GET_NEXT_LINE(EOF_ERROR, DROP_NL);
							READ_KEYWORD("*data:");
							*(float *)input->sqlvar[i].sqldata = (float)atof(p);
							break;

						case RIS_DOUBLE:
							MALLOC(input->sqlvar[i].sqldata, sizeof(double));
							GET_NEXT_LINE(EOF_ERROR, DROP_NL);
							READ_KEYWORD("*data:");
							*(double *)input->sqlvar[i].sqldata =
								(double)atof(p);
							break;

						case RIS_DECIMAL:
							GET_NEXT_LINE(EOF_ERROR, DROP_NL);
							READ_KEYWORD("*data:");
							MALLOC(input->sqlvar[i].sqldata, strlen(p)+1);
							strcpy(input->sqlvar[i].sqldata, p);
							break;

						case RIS_DATETIME:
						case RIS_INTERVAL:
						{
							datetime *dtp;

							MALLOC(input->sqlvar[i].sqldata, sizeof(datetime));
							dtp = (datetime *)input->sqlvar[i].sqldata;
							GET_NEXT_LINE(EOF_ERROR, DROP_NL);
							READ_KEYWORD("*data:");
							sscanf(p, "%d-%d-%d:%d:%d:%d",
								&dtp->year,
								&dtp->month,
								&dtp->day,
								&dtp->hour,
								&dtp->minute,
								&dtp->second);

							break;
						}

						case RIS_BLOB:
						case RIS_TEXT:
						{
							ris_blob *b;

							MALLOC(input->sqlvar[i].sqldata, sizeof(ris_blob));
							b = (ris_blob *)input->sqlvar[i].sqldata;
							GET_NEXT_LINE(EOF_ERROR, DROP_NL);
							READ_KEYWORD("file_used:");
							b->file_used = (char)atoi(p);
							if (b->file_used)
							{
								GET_NEXT_LINE(EOF_ERROR, DROP_NL);
								READ_KEYWORD("file_offset:");
								b->file_offset = atoi(p);

								GET_NEXT_LINE(EOF_ERROR, DROP_NL);
								READ_KEYWORD("filename:");
								b->filename =
									(char *)strtol(p,(char **)0,16);
								if (b->filename)
								{
									GET_NEXT_LINE(EOF_ERROR, DROP_NL);
									READ_KEYWORD("*filename:");
									MALLOC(b->filename, strlen(p)+1);
									strcpy(b->filename, p);
								}
							}
							else
							{
								GET_NEXT_LINE(EOF_ERROR, DROP_NL);
								READ_KEYWORD("array_size:");
								b->array_size = atoi(p);

								GET_NEXT_LINE(EOF_ERROR, DROP_NL);
								READ_KEYWORD("array:");
								b->array = (char *)strtol(p,(char **)0,16);
								if (b->array)
								{
									GET_NEXT_LINE(EOF_ERROR, DROP_NL);
									READ_KEYWORD("*array:");
									GET_BLOB_DATA(b);
								}
							}
							break;
						}
					}
				}
			}
			else
			{
/*
**  TDM 10/27/93 -- RIS expects a sqltype and sqldata, even if sqlind < 0
**					we are assuming it doesn't use them, thus the stupid values
*/
				input->sqlvar[i].sqltype = 1;
				MALLOC(input->sqlvar[i].sqldata, 1);
			}
		}
	}
	else
	{
		input->sqlvar = (sqlvar *)NULL;
	}

	return 0;
}

/******************************************************************************/

static int get_output_sqlda(
	sqlda *output)
{
	int i;

	GET_NEXT_LINE(EOF_ERROR, DROP_NL);
	READ_KEYWORD("n:");
	output->sqln = atoi(p);

	GET_NEXT_LINE(EOF_ERROR, DROP_NL);
	READ_KEYWORD("d:");
	output->sqld = atoi(p);

	GET_NEXT_LINE(EOF_ERROR, DROP_NL);
	READ_KEYWORD("var:");
	output->sqlvar = (sqlvar *)strtol(p, (char **)0, 16);
	if (output->sqlvar && output->sqln > 0)
	{
		MALLOC(output->sqlvar, output->sqln * sizeof(sqlvar));

		for (i = 0; i < output->sqln; i++)
		{
			GET_NEXT_LINE(EOF_ERROR, DROP_NL);
			READ_KEYWORD("null:");
			output->sqlvar[i].sqlnull = atoi(p);

			GET_NEXT_LINE(EOF_ERROR, DROP_NL);
			READ_KEYWORD("ind:");
			output->sqlvar[i].sqlind = (long *)strtol(p, (char **)0, 16);
			if (output->sqlvar[i].sqlind)
			{
				MALLOC(output->sqlvar[i].sqlind, sizeof(long));
			}

			GET_NEXT_LINE(EOF_ERROR, DROP_NL);
			READ_KEYWORD("type:");
			output->sqlvar[i].sqltype = atoi(p);

			GET_NEXT_LINE(EOF_ERROR, DROP_NL);
			READ_KEYWORD("len:");
			output->sqlvar[i].sqllen = atoi(p);

			if (output->sqlvar[i].sqltype == RIS_DECIMAL)
			{
				GET_NEXT_LINE(EOF_ERROR, DROP_NL);
				READ_KEYWORD("scale:");
				output->sqlvar[i].sqlscale = atoi(p);
			}

			GET_NEXT_LINE(EOF_ERROR, DROP_NL);
			READ_KEYWORD("data:");
			output->sqlvar[i].sqldata = (char *)strtol(p, (char **)0, 16);
			if (output->sqlvar[i].sqldata)
			{
				if (output->sqlvar[i].sqltype == RIS_BLOB ||
					output->sqlvar[i].sqltype == RIS_TEXT)
				{
					ris_blob *b;

					MALLOC(output->sqlvar[i].sqldata, sizeof(ris_blob));
					b = (ris_blob *)output->sqlvar[i].sqldata;

					GET_NEXT_LINE(EOF_ERROR, DROP_NL);
					READ_KEYWORD("file_used:");
					b->file_used = (char)atoi(p);
					if (b->file_used)
					{
						GET_NEXT_LINE(EOF_ERROR, DROP_NL);
						READ_KEYWORD("file_offset:");
						b->file_offset = atoi(p);

						GET_NEXT_LINE(EOF_ERROR, DROP_NL);
						READ_KEYWORD("filename:");
						b->filename =
							(char *)strtol(p,(char **)0,16);
						if (b->filename)
						{
							GET_NEXT_LINE(EOF_ERROR, DROP_NL);
							READ_KEYWORD("*filename:");
							if (fetch_blob_same_files)
							{
								MALLOC(b->filename, strlen(p)+1);
								strcpy(b->filename, p);
							}
							else
							{
								MALLOC(b->filename, L_tmpnam);
								tmpnam(b->filename);
								add_tempfile(b->filename);
							}
						}
					}
					else
					{
						GET_NEXT_LINE(EOF_ERROR, DROP_NL);
						READ_KEYWORD("array_size:");
						b->array_size = atoi(p);

						GET_NEXT_LINE(EOF_ERROR, DROP_NL);
						READ_KEYWORD("array:");
						b->array = (char *)strtol(p,(char **)0,16);
						if (b->array)
						{
							MALLOC(b->array, b->array_size);
						}
					}
				}
				else
				{
					if (output->sqlvar[i].sqllen > 0)
					{
						/* Kludge to prevent a core dump which was seen
						** when the MALLOC was called with size = -1
						** Shiva 4/28/94
						*/

					MALLOC(output->sqlvar[i].sqldata, output->sqlvar[i].sqllen);
					}
					else output->sqlvar[i].sqldata = 0;
				}
			}
		}
	}
	else
	{
		output->sqlvar = (sqlvar *)NULL;
	}
	return 0;
}

/******************************************************************************/

static int get_describe_sqlda(
	sqlda *data)
{
	GET_NEXT_LINE(EOF_ERROR, DROP_NL);
	READ_KEYWORD("n:");
	data->sqln = atoi(p);

	GET_NEXT_LINE(EOF_ERROR, DROP_NL);
	READ_KEYWORD("d:");
	data->sqld = atoi(p);

	GET_NEXT_LINE(EOF_ERROR, DROP_NL);
	READ_KEYWORD("var:");
	data->sqlvar = (sqlvar *)strtol(p, (char **)0, 16);
	if (data->sqlvar && data->sqln > 0)
	{
		MALLOC(data->sqlvar, data->sqln * sizeof(sqlvar));
	}
	else
	{
		data->sqlvar = NULL;
	}
	return 0;
}

/******************************************************************************/

static int get_test_sqlda(
	sqlda *desc)
{
	int i;

	GET_NEXT_LINE(EOF_ERROR, DROP_NL);
	READ_KEYWORD("n:");
	desc->sqln = atoi(p);

	GET_NEXT_LINE(EOF_ERROR, DROP_NL);
	READ_KEYWORD("d:");
	desc->sqld = atoi(p);

	GET_NEXT_LINE(EOF_ERROR, DROP_NL);
	READ_KEYWORD("var:");
	desc->sqlvar = (sqlvar *)strtol(p, (char **)0, 16);
	if (desc->sqlvar && desc->sqln > 0)
	{
		MALLOC(desc->sqlvar, desc->sqln * sizeof(sqlvar));

		for (i = 0; i < desc->sqln; i++)
		{
			GET_NEXT_LINE(EOF_ERROR, DROP_NL);
			READ_KEYWORD("type:");
			desc->sqlvar[i].sqltype = atoi(p);

			GET_NEXT_LINE(EOF_ERROR, DROP_NL);
			READ_KEYWORD("data:");
			desc->sqlvar[i].sqldata = (char *)strtol(p, (char **)0, 16);
			if (desc->sqlvar[i].sqldata)
			{
				switch(desc->sqlvar[i].sqltype)
				{
					case RIS_CHARACTER:
						GET_NEXT_LINE(EOF_ERROR, DROP_NL);
						READ_KEYWORD("start *data:");
						GET_STRING_DATA(desc->sqlvar[i].sqldata, "stop *data:");
						break;

					case RIS_INTEGER:
						MALLOC(desc->sqlvar[i].sqldata, sizeof(int));
						GET_NEXT_LINE(EOF_ERROR, DROP_NL);
						READ_KEYWORD("*data:");
						*(int *)desc->sqlvar[i].sqldata = (int)atoi(p);
						break;
				}
			}
		}
	}
	else
	{
		desc->sqlvar = (sqlvar *)NULL;
	}
	return 0;
}

/******************************************************************************/

static int read_checksum(
	command_info_s *cmd)
{
	cmd->type = CHECKSUM;

	GET_NEXT_LINE(EOF_ERROR, DROP_NL);
	GET_COMMAND_STATUS(cmd);

	return 0;
}

/******************************************************************************/

static int read_clear(
	command_info_s *cmd)
{
	free_clear();

	cmd->type = CLEAR;

	GET_NEXT_LINE(EOF_ERROR, DROP_NL);
	READ_KEYWORD("stmt_id:");
	clear.stmt_id = atoi(p);

	GET_NEXT_LINE(EOF_ERROR, DROP_NL);
	READ_KEYWORD("execute_mode:");
	clear.execute_mode = atoi(p);

	GET_NEXT_LINE(EOF_ERROR, DROP_NL);
	READ_KEYWORD("new_stmt_id:");
	clear.new_stmt_id = atoi(p);

	GET_NEXT_LINE(EOF_ERROR, DROP_NL);
	if (IN_START_MODE_ONLY(clear.execute_mode) &&
		!strncmp(p, "async_id:", 9))
	{
		p += 9;
		clear.async_id = atoi(p);
		GET_NEXT_LINE(EOF_ERROR, DROP_NL);
	}
	else
	{
		clear.async_id = -1;
	}
	GET_COMMAND_STATUS(cmd);

	return 0;
}

/******************************************************************************/

static int read_clear_async(
	command_info_s *cmd)
{
	free_clear_async();

	cmd->type = CLEAR_ASYNC;

	GET_NEXT_LINE(EOF_ERROR, DROP_NL);
	READ_KEYWORD("async_id:");
	clear_async.async_id = atoi(p);

	GET_NEXT_LINE(EOF_ERROR, DROP_NL);
	GET_COMMAND_STATUS(cmd);

	return 0;
}

/******************************************************************************/

static int read_close(
	command_info_s *cmd)
{
	free_close();

	cmd->type = CLOSE;

	GET_NEXT_LINE(EOF_ERROR, DROP_NL);
	READ_KEYWORD("stmt_id:");
	clse.stmt_id = atoi(p);

	GET_NEXT_LINE(EOF_ERROR, DROP_NL);
	READ_KEYWORD("execute_mode:");
	clse.execute_mode = atoi(p);

	GET_NEXT_LINE(EOF_ERROR, DROP_NL);
	if (IN_START_MODE_ONLY(clse.execute_mode) &&
		!strncmp(p, "async_id:", 9))
	{
		p += 9;
		clse.async_id = atoi(p);

		GET_NEXT_LINE(EOF_ERROR, DROP_NL);
	}
	else
	{
		clse.async_id = -1;
	}
	GET_COMMAND_STATUS(cmd);

	return 0;
}

/******************************************************************************/

static int read_debug(
	command_info_s *cmd)
{
	int len;

	free_debug();

	cmd->type = DEBUG;

	GET_NEXT_LINE(EOF_ERROR, DROP_NL);
	READ_KEYWORD("s:");
	debug.s = (char *)strtol(p, (char **)0, 16);
	if (debug.s)
	{
		GET_NEXT_LINE(EOF_ERROR, DROP_NL);
		READ_KEYWORD("*s:");
		len = strlen(p) + 1;
		MALLOC(debug.s, len);
		memcpy(debug.s, p, len);
	}

	GET_NEXT_LINE(EOF_ERROR, DROP_NL);
	READ_KEYWORD("output_flag:");
	debug.output_flag = atoi(p);

	GET_NEXT_LINE(EOF_ERROR, DROP_NL);
	GET_COMMAND_STATUS(cmd);

	return 0;
}

/******************************************************************************/

static int read_describe(
	command_info_s *cmd)
{
	free_describe();

	cmd->type = DESCRIBE;

	GET_NEXT_LINE(EOF_ERROR, DROP_NL);
	READ_KEYWORD("stmt_id:");
	describe.stmt_id = atoi(p);

	GET_NEXT_LINE(EOF_ERROR, DROP_NL);
	READ_KEYWORD("data:");
	describe.data = (sqlda *)strtol(p, (char **)0, 16);
	if (describe.data)
	{
		MALLOC(describe.data, sizeof(sqlda));
		GET_DESCRIBE_SQLDA(describe.data);
	}

	GET_NEXT_LINE(EOF_ERROR, DROP_NL);
	READ_KEYWORD("in_out:");
	describe.in_out = atoi(p);

	GET_NEXT_LINE(EOF_ERROR, DROP_NL);
	GET_COMMAND_STATUS(cmd);

	return 0;
}

/******************************************************************************/

static int read_execute(
	command_info_s *cmd)
{
	free_execute();

	cmd->type = EXECUTE;

	GET_NEXT_LINE(EOF_ERROR, DROP_NL);
	READ_KEYWORD("stmt_id:");
	execute.stmt_id = atoi(p);

	GET_NEXT_LINE(EOF_ERROR, DROP_NL);
	READ_KEYWORD("in_sqlda:");
	execute.in_sqlda = (sqlda *)strtol(p, (char **)0, 16);
	if (execute.in_sqlda)
	{
		MALLOC(execute.in_sqlda,sizeof(sqlda));
		GET_INPUT_SQLDA(execute.in_sqlda);
	}

	GET_NEXT_LINE(EOF_ERROR, DROP_NL);
	READ_KEYWORD("execute_mode:");
	execute.execute_mode = atoi(p);

	GET_NEXT_LINE(EOF_ERROR, DROP_NL);
	READ_KEYWORD("clear_flag:");
	execute.clear_flag = atoi(p);

	GET_NEXT_LINE(EOF_ERROR, DROP_NL);
	READ_KEYWORD("static_flag:");
	execute.static_flag = atoi(p);

	GET_NEXT_LINE(EOF_ERROR, DROP_NL);
	READ_KEYWORD("new_stmt_id:");
	execute.new_stmt_id = atoi(p);

	GET_NEXT_LINE(EOF_ERROR, DROP_NL);
	if (IN_START_MODE_ONLY(execute.execute_mode) &&
		!strncmp(p, "async_id:", 9))
	{
		p += 9;
		execute.async_id = atoi(p);

		GET_NEXT_LINE(EOF_ERROR, DROP_NL);
	}
	else
	{
		execute.async_id = -1;
	}
	GET_COMMAND_STATUS(cmd);
	return 0;
}

/******************************************************************************/

static int read_execute_imm(
	command_info_s *cmd)
{
	free_execute_imm();

	cmd->type = EXECUTE_IMM;

	GET_NEXT_LINE(EOF_ERROR, DROP_NL);
	READ_KEYWORD("stmt_id:");
	execute_imm.stmt_id = (short *)strtol(p, (char **)0, 16);
	if (execute_imm.stmt_id)
	{
		MALLOC(execute_imm.stmt_id, sizeof(short));
		GET_NEXT_LINE(EOF_ERROR, DROP_NL);
		READ_KEYWORD("*stmt_id:");
		*execute_imm.stmt_id = atoi(p);
	}

	GET_NEXT_LINE(EOF_ERROR, DROP_NL);
	READ_KEYWORD("start query:");
	GET_STRING_DATA(execute_imm.query, "stop query:");
	if (!execute_imm.query)
	{
		error_msg(MSG(RISUTL_I_EXPECTED_QUERY), "stop query:");
		report_errors = 0;
		return 1;
	}

	GET_NEXT_LINE(EOF_ERROR, DROP_NL);
	READ_KEYWORD("in_sqlda:");
	execute_imm.in_sqlda = (sqlda *)strtol(p, (char **)0, 16);
	if (execute_imm.in_sqlda)
	{
		MALLOC(execute_imm.in_sqlda, sizeof(sqlda));
		GET_INPUT_SQLDA(execute_imm.in_sqlda);
	}

	GET_NEXT_LINE(EOF_ERROR, DROP_NL);
	READ_KEYWORD("execute_mode:");
	execute_imm.execute_mode = atoi(p);

	GET_NEXT_LINE(EOF_ERROR, DROP_NL);
	READ_KEYWORD("clear_flag:");
	execute_imm.clear_flag = atoi(p);

	GET_NEXT_LINE(EOF_ERROR, DROP_NL);
	READ_KEYWORD("static_flag:");
	execute_imm.static_flag = atoi(p);

	GET_NEXT_LINE(EOF_ERROR, DROP_NL);
	READ_KEYWORD("new_stmt_id:");
	execute_imm.new_stmt_id = atoi(p);

	GET_NEXT_LINE(EOF_ERROR, DROP_NL);
	if (IN_START_MODE_ONLY(execute_imm.execute_mode) &&
		!strncmp(p, "async_id:", 9))
	{
		p += 9;
		execute_imm.async_id = atoi(p);

		GET_NEXT_LINE(EOF_ERROR, DROP_NL);
	}
	else
	{
		execute_imm.async_id = -1;
	}
	GET_COMMAND_STATUS(cmd);
	return 0;
}

/******************************************************************************/

static int read_fetch(
	command_info_s *cmd)
{
	cmd->type = FETCH;

	GET_NEXT_LINE(EOF_ERROR, DROP_NL);
	if (strncmp(p, "DITTO", 5))
	{
		free_fetch();

		READ_KEYWORD("stmt_id:");
		fetch.stmt_id = atoi(p);

		GET_NEXT_LINE(EOF_ERROR, DROP_NL);
		READ_KEYWORD("output:");
		fetch.output = (sqlda *)strtol(p, (char **)0, 16);
		if (fetch.output)
		{
			MALLOC(fetch.output, sizeof(sqlda));
			GET_OUTPUT_SQLDA(fetch.output);
		}

		GET_NEXT_LINE(EOF_ERROR, DROP_NL);
		READ_KEYWORD("one_row_only:");
		fetch.one_row_only = atoi(p);
	}

	GET_NEXT_LINE(EOF_ERROR, DROP_NL);
	READ_KEYWORD("execute_mode:");
	fetch.execute_mode = atoi(p);

	GET_NEXT_LINE(EOF_ERROR, DROP_NL);
	if (IN_START_MODE_ONLY(fetch.execute_mode) &&
		!strncmp(p, "async_id:", 9))
	{
		p += 9;
		fetch.async_id = atoi(p);

		GET_NEXT_LINE(EOF_ERROR, DROP_NL);
	}
	else
	{
		fetch.async_id = -1;
	}
	GET_COMMAND_STATUS(cmd);

	return 0;
}

/******************************************************************************/

static int read_get_app_version(
	command_info_s *cmd)
{
	free_get_app_version();

	cmd->type = GET_DEFAULT_SCHNAME;

	GET_NEXT_LINE(EOF_ERROR, DROP_NL);
	READ_KEYWORD("maj:");
	get_app_version.maj = (int *)strtol(p, (char **)0, 16);

	GET_NEXT_LINE(EOF_ERROR, DROP_NL);
	READ_KEYWORD("min:");
	get_app_version.min = (int *)strtol(p, (char **)0, 16);

	GET_NEXT_LINE(EOF_ERROR, DROP_NL);
	READ_KEYWORD("rel:");
	get_app_version.rel = (int *)strtol(p, (char **)0, 16);

	GET_NEXT_LINE(EOF_ERROR, DROP_NL);
	GET_COMMAND_STATUS(cmd);
	return 0;
}

/******************************************************************************/

static int read_get_async_stmts(
	command_info_s *cmd)
{
	free_get_async_stmts();

	cmd->type = GET_SCHEMA_NAMES;

	GET_NEXT_LINE(EOF_ERROR, DROP_NL);
	READ_KEYWORD("buffer:");
	get_async_stmts.buffer = (int *)strtol(p, (char **)0, 16);

	GET_NEXT_LINE(EOF_ERROR, DROP_NL);
	READ_KEYWORD("countp:");
	get_async_stmts.countp = (int *)strtol(p, (char **)0, 16);
	if (get_async_stmts.countp)
	{
		MALLOC(get_async_stmts.countp, sizeof(int));
		GET_NEXT_LINE(EOF_ERROR, DROP_NL);
		READ_KEYWORD("*countp:");
		*get_async_stmts.countp = atoi(p);
	}

	if (get_async_stmts.buffer)
	{
		MALLOC(get_async_stmts.buffer, *get_async_stmts.countp*RIS_MAX_ID_SIZE);
	}

	GET_NEXT_LINE(EOF_ERROR, DROP_NL);
	GET_COMMAND_STATUS(cmd);
	return 0;
}

/******************************************************************************/

static int read_get_client_location(
	command_info_s *cmd)
{
	free_get_client_location();

	cmd->type = GET_CLIENT_LOCATION;

	GET_NEXT_LINE(EOF_ERROR, DROP_NL);
	READ_KEYWORD("parms:");
	get_client_location.parms =
		(client_parms *)strtol(p, (char **)0, 16);

	GET_NEXT_LINE(EOF_ERROR, DROP_NL);
	GET_COMMAND_STATUS(cmd);
	return 0;
}

/******************************************************************************/

static int read_get_db_info(
	command_info_s *cmd)
{
	free_get_db_info();

	cmd->type = GET_DB_INFO;

	GET_NEXT_LINE(EOF_ERROR, DROP_NL);
	READ_KEYWORD("dbid:");
	get_db_info.dbid = atoi(p);

	GET_NEXT_LINE(EOF_ERROR, DROP_NL);
	READ_KEYWORD("dbp:");
	get_db_info.dbp = (ris_db_info **)strtol(p, (char **)0, 16);

	GET_NEXT_LINE(EOF_ERROR, DROP_NL);
	GET_COMMAND_STATUS(cmd);
	return 0;
}

/******************************************************************************/

static int read_get_default_schname(
	command_info_s *cmd)
{
	free_get_default_schname();

	cmd->type = GET_DEFAULT_SCHNAME;

	GET_NEXT_LINE(EOF_ERROR, DROP_NL);
	READ_KEYWORD("buffer:");
	get_default_schname.buffer = (char *)strtol(p, (char **)0, 16);

	GET_NEXT_LINE(EOF_ERROR, DROP_NL);
	GET_COMMAND_STATUS(cmd);
	return 0;
}

/******************************************************************************/

static int read_get_flags(
	command_info_s *cmd)
{
	free_get_flags();

	cmd->type = GET_FLAGS;

	GET_NEXT_LINE(EOF_ERROR, DROP_NL);
	READ_KEYWORD("ansi_mode:");
	get_flags.ansi_mode = (int *)strtol(p, (char **)0, 16);

	GET_NEXT_LINE(EOF_ERROR, DROP_NL);
	READ_KEYWORD("enable_dbms:");
	get_flags.enable_dbms = (int *)strtol(p, (char **)0, 16);

	GET_NEXT_LINE(EOF_ERROR, DROP_NL);
	READ_KEYWORD("verify_mode:");
	get_flags.verify_mode = (int *)strtol(p, (char **)0, 16);

	GET_NEXT_LINE(EOF_ERROR, DROP_NL);
	READ_KEYWORD("blankstrip_mode:");
	get_flags.blankstrip_mode = (int *)strtol(p, (char **)0, 16);

	GET_NEXT_LINE(EOF_ERROR, DROP_NL);
	READ_KEYWORD("autocommit:");
	get_flags.autocommit = (int *)strtol(p, (char **)0, 16);

	GET_NEXT_LINE(EOF_ERROR, DROP_NL);
	READ_KEYWORD("autorename:");
	get_flags.autorename = (int *)strtol(p, (char **)0, 16);

	GET_NEXT_LINE(EOF_ERROR, DROP_NL);
	GET_COMMAND_STATUS(cmd);
	return 0;
}

/******************************************************************************/

static int read_get_language_name(
	command_info_s *cmd)
{
	free_get_language_name();

	cmd->type = GET_LANGUAGE_NAME;

	GET_NEXT_LINE(EOF_ERROR, DROP_NL);
	READ_KEYWORD("name:");
	get_language_name.name = (char *)strtol(p, (char **)0, 16);

	GET_NEXT_LINE(EOF_ERROR, DROP_NL);
	GET_COMMAND_STATUS(cmd);
	return 0;
}

/******************************************************************************/

static int read_get_parameters(
	command_info_s *cmd)
{
	free_get_parameters();

	cmd->type = GET_PARAMETERS;

	GET_NEXT_LINE(EOF_ERROR, DROP_NL);
	READ_KEYWORD("parameters:");
	get_parameters.parameters = (ris_parameters *)strtol(p, (char **)0, 16);

	GET_NEXT_LINE(EOF_ERROR, DROP_NL);
	GET_COMMAND_STATUS(cmd);
	return 0;
}

/******************************************************************************/

static int read_get_ris_type_code(
	command_info_s *cmd)
{
	int len;

	free_get_ris_type_code();

	cmd->type = GET_RIS_TYPE_CODE;

	GET_NEXT_LINE(EOF_ERROR, DROP_NL);
	READ_KEYWORD("code:");
	get_ris_type_code.code = (int *)strtol(p, (char **)0, 16);

	GET_NEXT_LINE(EOF_ERROR, DROP_NL);
	READ_KEYWORD("str:");
	get_ris_type_code.str = (char *)strtol(p, (char **)0, 16);
	if (get_ris_type_code.str)
	{
		GET_NEXT_LINE(EOF_ERROR, DROP_NL);
		READ_KEYWORD("*str:");
		len = strlen(p) + 1;
		MALLOC(get_ris_type_code.str, len);
		strcpy(get_ris_type_code.str, p);
	}

	GET_NEXT_LINE(EOF_ERROR, DROP_NL);
	GET_COMMAND_STATUS(cmd);
	return 0;
}

/******************************************************************************/

static int read_get_ris_type_string(
	command_info_s *cmd)
{
	free_get_ris_type_string();

	cmd->type = GET_RIS_TYPE_STRING;

	GET_NEXT_LINE(EOF_ERROR, DROP_NL);
	READ_KEYWORD("str:");
	get_ris_type_string.str = (char *)strtol(p, (char **)0, 16);

	GET_NEXT_LINE(EOF_ERROR, DROP_NL);
	READ_KEYWORD("code:");
	get_ris_type_string.code = atoi(p);

	GET_NEXT_LINE(EOF_ERROR, DROP_NL);
	GET_COMMAND_STATUS(cmd);
	return 0;
}

/******************************************************************************/

static int read_get_schema_file(
	command_info_s *cmd)
{
	free_get_schema_file();

	cmd->type = GET_SCHEMA_FILE;

	GET_NEXT_LINE(EOF_ERROR, DROP_NL);
	READ_KEYWORD("schema_filenamep:");
	get_schema_file.schema_filenamep = (char **)strtol(p,(char **)0, 16);

	GET_NEXT_LINE(EOF_ERROR, DROP_NL);
	READ_KEYWORD("dblistp:");
	get_schema_file.dblistp = (ris_db_info **)strtol(p, (char **)0, 16);

	GET_NEXT_LINE(EOF_ERROR, DROP_NL);
	READ_KEYWORD("schlistp:");
	get_schema_file.schlistp = (ris_schema_info **)strtol(p, (char **)0, 16);

	GET_NEXT_LINE(EOF_ERROR, DROP_NL);
	READ_KEYWORD("granteep:");
	get_schema_file.granteep = (ris_grantee_info **)strtol(p, (char **)0, 16);

	GET_NEXT_LINE(EOF_ERROR, DROP_NL);
	GET_COMMAND_STATUS(cmd);
	return 0;
}

/******************************************************************************/

static int read_get_schema_file_location(
	command_info_s *cmd)
{
	free_get_schema_file_location();

	cmd->type = GET_SCHEMA_FILE_LOCATION;

	GET_NEXT_LINE(EOF_ERROR, DROP_NL);
	READ_KEYWORD("parms:");
	get_schema_file_location.parms =
		(schema_file_parms *)strtol(p, (char **)0, 16);

	GET_NEXT_LINE(EOF_ERROR, DROP_NL);
	GET_COMMAND_STATUS(cmd);
	return 0;
}

/******************************************************************************/

static int read_get_schema_info(
	command_info_s *cmd)
{
	int len;

	free_get_schema_info();

	cmd->type = GET_SCHEMA_INFO;

	GET_NEXT_LINE(EOF_ERROR, DROP_NL);
	READ_KEYWORD("schname:");
	get_schema_info.schname = (char *)strtol(p, (char **)0, 16);
	if (get_schema_info.schname)
	{
		GET_NEXT_LINE(EOF_ERROR, DROP_NL);
		READ_KEYWORD("*schname:");
		len = strlen(p) + 1;
		MALLOC(get_schema_info.schname, len);
		memcpy(get_schema_info.schname, p, len);
	}

	GET_NEXT_LINE(EOF_ERROR, DROP_NL);
	READ_KEYWORD("schemap:");
	get_schema_info.schemap = (ris_schema_info **)strtol(p, (char **)0, 16);

	GET_NEXT_LINE(EOF_ERROR, DROP_NL);
	READ_KEYWORD("dbp:");
	get_schema_info.dbp = (ris_db_info **)strtol(p, (char **)0, 16);

	GET_NEXT_LINE(EOF_ERROR, DROP_NL);
	READ_KEYWORD("granteep:");
	get_schema_info.granteep = (ris_grantee_info **)strtol(p, (char **)0, 16);

	GET_NEXT_LINE(EOF_ERROR, DROP_NL);
	GET_COMMAND_STATUS(cmd);
	return 0;
}

/******************************************************************************/

static int read_get_schema_names(
	command_info_s *cmd)
{
	free_get_schema_names();

	cmd->type = GET_SCHEMA_NAMES;

	GET_NEXT_LINE(EOF_ERROR, DROP_NL);
	READ_KEYWORD("buffer:");
	get_schema_names.buffer =
		(char (*)[RIS_MAX_ID_SIZE])strtol(p, (char **)0, 16);

	GET_NEXT_LINE(EOF_ERROR, DROP_NL);
	READ_KEYWORD("countp:");
	get_schema_names.countp = (int *)strtol(p, (char **)0, 16);
	if (get_schema_names.countp)
	{
		MALLOC(get_schema_names.countp, sizeof(int));
		GET_NEXT_LINE(EOF_ERROR, DROP_NL);
		READ_KEYWORD("*countp:");
		*get_schema_names.countp = atoi(p);
	}

	if (get_schema_names.buffer)
	{
		MALLOC(get_schema_names.buffer,
			*get_schema_names.countp * RIS_MAX_ID_SIZE);
	}

	GET_NEXT_LINE(EOF_ERROR, DROP_NL);
	GET_COMMAND_STATUS(cmd);
	return 0;
}

/******************************************************************************/

static int read_get_schema_transactions(
	command_info_s *cmd)
{
	free_get_schema_transactions();

	cmd->type = GET_SCHEMA_NAMES;

	GET_NEXT_LINE(EOF_ERROR, DROP_NL);
	READ_KEYWORD("buffer:");
	get_schema_transactions.buffer =
		(char (*)[RIS_MAX_ID_SIZE])strtol(p, (char **)0, 16);

	GET_NEXT_LINE(EOF_ERROR, DROP_NL);
	READ_KEYWORD("countp:");
	get_schema_transactions.countp = (int *)strtol(p, (char **)0, 16);
	if (get_schema_transactions.countp)
	{
		MALLOC(get_schema_transactions.countp, sizeof(int));
		GET_NEXT_LINE(EOF_ERROR, DROP_NL);
		READ_KEYWORD("*countp:");
		*get_schema_transactions.countp = atoi(p);
	}

	if (get_schema_transactions.buffer)
	{
		MALLOC(get_schema_transactions.buffer,
			*get_schema_transactions.countp * RIS_MAX_ID_SIZE);
	}

	GET_NEXT_LINE(EOF_ERROR, DROP_NL);
	GET_COMMAND_STATUS(cmd);
	return 0;
}

/******************************************************************************/

static int read_get_ss_def(
	command_info_s *cmd)
{
	int len;

	free_get_ss_def();

	cmd->type = GET_SS_DEF;

	GET_NEXT_LINE(EOF_ERROR, DROP_NL);
	READ_KEYWORD("ss_name:");
	get_ss_def.ss_name = (char *)strtol(p, (char **)0, 16);
	if (get_ss_def.ss_name)
	{
		GET_NEXT_LINE(EOF_ERROR, DROP_NL);
		READ_KEYWORD("*ss_name:");
		len = strlen(p) + 1;
		MALLOC(get_ss_def.ss_name, len);
		strcpy(get_ss_def.ss_name, p);
	}

	GET_NEXT_LINE(EOF_ERROR, DROP_NL);
	READ_KEYWORD("buffer:");
	get_ss_def.buffer = (char (*)[RIS_MAX_ID_SIZE])strtol(p, (char **)0, 16);

	GET_NEXT_LINE(EOF_ERROR, DROP_NL);
	READ_KEYWORD("countp:");
	get_ss_def.countp = (int *)strtol(p, (char **)0, 16);
	if (get_ss_def.countp)
	{
		MALLOC(get_ss_def.countp, sizeof(int));
		GET_NEXT_LINE(EOF_ERROR, DROP_NL);
		READ_KEYWORD("*countp:");
		*get_ss_def.countp = atoi(p);
	}

	if (get_ss_def.buffer)
	{
		MALLOC(get_ss_def.buffer, *get_ss_def.countp * RIS_MAX_ID_SIZE);
	}

	GET_NEXT_LINE(EOF_ERROR, DROP_NL);
	GET_COMMAND_STATUS(cmd);
	return 0;
}

/******************************************************************************/

static int read_get_ss_names(
	command_info_s *cmd)
{
	free_get_ss_names();

	cmd->type = GET_SS_NAMES;

	GET_NEXT_LINE(EOF_ERROR, DROP_NL);
	READ_KEYWORD("buffer:");
	get_ss_names.buffer = (char (*)[RIS_MAX_ID_SIZE])strtol(p, (char **)0, 16);

	GET_NEXT_LINE(EOF_ERROR, DROP_NL);
	READ_KEYWORD("countp:");
	get_ss_names.countp = (int *)strtol(p, (char **)0, 16);
	if (get_ss_names.countp)
	{
		MALLOC(get_ss_names.countp, sizeof(int));
		GET_NEXT_LINE(EOF_ERROR, DROP_NL);
		READ_KEYWORD("*countp:");
		*get_ss_names.countp = atoi(p);
	}

	if (get_ss_names.buffer)
	{
		MALLOC(get_ss_names.buffer, *get_ss_names.countp * RIS_MAX_ID_SIZE);
	}

	GET_NEXT_LINE(EOF_ERROR, DROP_NL);
	GET_COMMAND_STATUS(cmd);
	return 0;
}

/******************************************************************************/

static int read_get_stmt_schname(
	command_info_s *cmd)
{
	free_get_stmt_schname();

	cmd->type = GET_STMT_SCHNAME;

	GET_NEXT_LINE(EOF_ERROR, DROP_NL);
	READ_KEYWORD("buffer:");
	get_stmt_schname.buffer = (char *)strtol(p, (char **)0, 16);

	GET_NEXT_LINE(EOF_ERROR, DROP_NL);
	GET_COMMAND_STATUS(cmd);
	return 0;
}

/******************************************************************************/

static int read_initialize(
	command_info_s *cmd)
{
	int len;

	free_initialize();

	cmd->type = INITIALIZE;

	GET_NEXT_LINE(EOF_ERROR, DROP_NL);
	READ_KEYWORD("language_name:");
	initialize.language_name = (char *)strtol(p, (char **)0, 16);
	if (initialize.language_name)
	{
		GET_NEXT_LINE(EOF_ERROR, DROP_NL);
		READ_KEYWORD("*language_name:");
		len = strlen(p) + 1;
		MALLOC(initialize.language_name, len);
		memcpy(initialize.language_name, p, len);
	}

	GET_NEXT_LINE(EOF_ERROR, DROP_NL);
	GET_COMMAND_STATUS(cmd);

	return 0;
}

/******************************************************************************/

static int read_locate_client(
	command_info_s *cmd)
{
	free_locate_client();

	cmd->type = LOCATE_CLIENT;

	GET_NEXT_LINE(EOF_ERROR, DROP_NL);
	READ_KEYWORD("parms:");
	locate_client.parms = (client_parms *)strtol(p, (char **)0, 16);
	if (locate_client.parms)
	{
		MALLOC(locate_client.parms, sizeof(client_parms));

		GET_NEXT_LINE(EOF_ERROR, DROP_NL);
		READ_KEYWORD("protocol:");
		locate_client.parms->protocol = *p;

		GET_NEXT_LINE(EOF_ERROR, DROP_NL);
		READ_KEYWORD("address:");
		strncpy(locate_client.parms->address, p, 28);

		GET_NEXT_LINE(EOF_ERROR, DROP_NL);
		READ_KEYWORD("username:");
		strncpy(locate_client.parms->username, p, 31);

		GET_NEXT_LINE(EOF_ERROR, DROP_NL);
		READ_KEYWORD("password:");
		strncpy(locate_client.parms->password, p, 31);
	}

	GET_NEXT_LINE(EOF_ERROR, DROP_NL);
	GET_COMMAND_STATUS(cmd);
	return 0;
}

/******************************************************************************/

static int read_locate_schema_file(
	command_info_s *cmd)
{
	free_locate_schema_file();

	cmd->type = LOCATE_SCHEMA_FILE;

	GET_NEXT_LINE(EOF_ERROR, DROP_NL);
	READ_KEYWORD("parms:");
	locate_schema_file.parms = (schema_file_parms *)strtol(p, (char **)0, 16);
	if (locate_schema_file.parms)
	{
		MALLOC(locate_schema_file.parms, sizeof(schema_file_parms));

		GET_NEXT_LINE(EOF_ERROR, DROP_NL);
		READ_KEYWORD("protocol:");
		locate_schema_file.parms->protocol = *p;

		GET_NEXT_LINE(EOF_ERROR, DROP_NL);
		READ_KEYWORD("address:");
		strncpy(locate_schema_file.parms->address, p, 28);

		GET_NEXT_LINE(EOF_ERROR, DROP_NL);
		READ_KEYWORD("username:");
		strncpy(locate_schema_file.parms->username, p, 31);

		GET_NEXT_LINE(EOF_ERROR, DROP_NL);
		READ_KEYWORD("password:");
		strncpy(locate_schema_file.parms->password, p, 31);

		GET_NEXT_LINE(EOF_ERROR, DROP_NL);
		READ_KEYWORD("filename:");
		strncpy(locate_schema_file.parms->filename, p, 240);
	}

	GET_NEXT_LINE(EOF_ERROR, DROP_NL);
	GET_COMMAND_STATUS(cmd);
	return 0;
}

/******************************************************************************/

static int read_prepare(
	command_info_s *cmd)
{
	free_prepare();

	cmd->type = PREPARE;

	GET_NEXT_LINE(EOF_ERROR, DROP_NL);
	READ_KEYWORD("stmt_id:");
	prepare.stmt_id = atoi(p);

	GET_NEXT_LINE(EOF_ERROR, DROP_NL);
	READ_KEYWORD("start query:");
	GET_STRING_DATA(prepare.query, "stop query:");
	if (!prepare.query)
	{
		error_msg(MSG(RISUTL_I_EXPECTED_QUERY), "stop query:");
		report_errors = 0;
		return 1;
	}

	GET_NEXT_LINE(EOF_ERROR, DROP_NL);
	READ_KEYWORD("clear_flag:");
	prepare.clear_flag = atoi(p);

	GET_NEXT_LINE(EOF_ERROR, DROP_NL);
	READ_KEYWORD("static_flag:");
	prepare.static_flag = atoi(p);

	GET_NEXT_LINE(EOF_ERROR, DROP_NL);
	READ_KEYWORD("new_stmt_id:");
	prepare.new_stmt_id = atoi(p);

	GET_NEXT_LINE(EOF_ERROR, DROP_NL);
	GET_COMMAND_STATUS(cmd);

	return 0;
}

/******************************************************************************/

static int read_report_error(
	command_info_s *cmd)
{
	free_report_error();

	cmd->type = REPORT_ERROR;

	GET_NEXT_LINE(EOF_ERROR, DROP_NL);
	READ_KEYWORD("async_id:");
	report_error.async_id = (int *)strtol(p, (char **)0, 16);
	if (report_error.async_id)
	{
		MALLOC(report_error.async_id, sizeof(int));
		GET_NEXT_LINE(EOF_ERROR, DROP_NL);
		READ_KEYWORD("*async_id:");
		*report_error.async_id = atoi(p);
	}

	GET_NEXT_LINE(EOF_ERROR, DROP_NL);
	READ_KEYWORD("ptrp:");
	report_error.ptrp = (char **)strtol(p, (char **)0, 16);

	GET_NEXT_LINE(EOF_ERROR, DROP_NL);
	GET_COMMAND_STATUS(cmd);

	/*
	**	RISint_report_error doesn't set sqlcode
	*/
	cmd->sqlcode = RIS_SUCCESS;

	return 0;
}

/******************************************************************************/

static int read_report_ss_error(
	command_info_s *cmd)
{
	int len;

	free_report_ss_error();

	cmd->type = REPORT_SS_ERROR;

	GET_NEXT_LINE(EOF_ERROR, DROP_NL);
	READ_KEYWORD("ss_name:");
	report_ss_error.ss_name = (char *)strtol(p, (char **)0, 16);
	if (report_ss_error.ss_name)
	{
		GET_NEXT_LINE(EOF_ERROR, DROP_NL);
		READ_KEYWORD("*ss_name:");
		len = strlen(p) + 1;
		MALLOC(report_ss_error.ss_name, len);
		strcpy(report_ss_error.ss_name, p);
	}

	GET_NEXT_LINE(EOF_ERROR, DROP_NL);
	GET_COMMAND_STATUS(cmd);
	return 0;
}

/******************************************************************************/

static int read_schema_mgr(
	command_info_s *cmd)
{
	int len;

	free_schema_mgr();

	cmd->type = SCHEMA_MGR;

	GET_NEXT_LINE(EOF_ERROR, DROP_NL);
	READ_KEYWORD("mode:");
	schema_mgr.mode = atoi(p);

	GET_NEXT_LINE(EOF_ERROR, DROP_NL);
	READ_KEYWORD("data:");
	schema_mgr.data = (char *)strtol(p, (char **)0, 16);
	if (schema_mgr.data)
	{
		GET_NEXT_LINE(EOF_ERROR, DROP_NL);
		READ_KEYWORD("*data:");
		len = strlen(p) + 1;
		MALLOC(schema_mgr.data, len);
		memcpy(schema_mgr.data, p, len);
	}

	GET_NEXT_LINE(EOF_ERROR, DROP_NL);
	READ_KEYWORD("str:");
	schema_mgr.str = (char *)strtol(p, (char **)0, 16);
	if (schema_mgr.str)
	{
		GET_NEXT_LINE(EOF_ERROR, DROP_NL);
		READ_KEYWORD("*str:");
		len = strlen(p) + 1;
		MALLOC(schema_mgr.str, len);
		memcpy(schema_mgr.str, p, len);
	}
	GET_NEXT_LINE(EOF_ERROR, DROP_NL);
	GET_COMMAND_STATUS(cmd);
	return 0;
}

/******************************************************************************/

static int read_select_into(
	command_info_s *cmd)
{
	free_select_into();

	cmd->type = SELECT_INTO;

	GET_NEXT_LINE(EOF_ERROR, DROP_NL);
	READ_KEYWORD("stmt_id:");
	select_into.stmt_id = atoi(p);

	GET_NEXT_LINE(EOF_ERROR, DROP_NL);
	READ_KEYWORD("start query:");
	GET_STRING_DATA(select_into.query, "stop query:");
	if (!select_into.query)
	{
		error_msg(MSG(RISUTL_I_EXPECTED_QUERY), "stop query:");
		report_errors = 0;
		return 1;
	}

	GET_NEXT_LINE(EOF_ERROR, DROP_NL);
	READ_KEYWORD("in_sqlda:");
	select_into.in_sqlda = (sqlda *)strtol(p, (char **)0, 16);
	if (select_into.in_sqlda)
	{
		MALLOC(select_into.in_sqlda, sizeof(sqlda));
		GET_INPUT_SQLDA(select_into.in_sqlda);
	}

	GET_NEXT_LINE(EOF_ERROR, DROP_NL);
	READ_KEYWORD("out_sqlda:");
	select_into.out_sqlda = (sqlda *)strtol(p, (char **)0, 16);
	if (select_into.out_sqlda)
	{
		MALLOC(select_into.out_sqlda, sizeof(sqlda));
		GET_OUTPUT_SQLDA(select_into.out_sqlda);
	}

	GET_NEXT_LINE(EOF_ERROR, DROP_NL);
	READ_KEYWORD("execute_mode:");
	select_into.execute_mode = atoi(p);

	GET_NEXT_LINE(EOF_ERROR, DROP_NL);
	READ_KEYWORD("new_stmt_id:");
	select_into.new_stmt_id = atoi(p);

	GET_NEXT_LINE(EOF_ERROR, DROP_NL);
	if (IN_START_MODE_ONLY(fetch.execute_mode) &&
		!strncmp(p, "async_id:", 9))
	{
		p += 9;
		fetch.async_id = atoi(p);

		GET_NEXT_LINE(EOF_ERROR, DROP_NL);
	}
	else
	{
		fetch.async_id = -1;
	}
	GET_COMMAND_STATUS(cmd);
	return 0;
}

/******************************************************************************/

static int read_start_client(
	command_info_s *cmd)
{
	cmd->type = START_CLIENT;

	GET_NEXT_LINE(EOF_ERROR, DROP_NL);
	GET_COMMAND_STATUS(cmd);

	return 0;
}

/******************************************************************************/

static int read_stop_client(
	command_info_s *cmd)
{
	cmd->type = STOP_CLIENT;

	GET_NEXT_LINE(EOF_ERROR, DROP_NL);
	GET_COMMAND_STATUS(cmd);

	return 0;
}

/******************************************************************************/

static int read_terminate(
	command_info_s *cmd)
{
	cmd->type = TERMINATE;

	GET_NEXT_LINE(EOF_ERROR, DROP_NL);
	GET_COMMAND_STATUS(cmd);

	return 0;
}

/******************************************************************************/

static int read_test_completion(
	command_info_s *cmd)
{
	free_test_completion();

	cmd->type = TEST_COMPLETION;

	GET_NEXT_LINE(EOF_ERROR, DROP_NL);
	READ_KEYWORD("desc:");
	test_completion.desc = (sqlda *)strtol(p, (char **)0, 16);
	if (test_completion.desc)
	{
		MALLOC(test_completion.desc, sizeof(sqlda));
		GET_TEST_SQLDA(test_completion.desc);
	}

	GET_NEXT_LINE(EOF_ERROR, DROP_NL);
	READ_KEYWORD("wait_flag:");
	test_completion.wait_flag = atoi(p);

	GET_NEXT_LINE(EOF_ERROR, DROP_NL);
	GET_COMMAND_STATUS(cmd);
	return 0;
}

/******************************************************************************/

extern int read_command(
	command_info_s *cmd)
{
	int sts = 0;

	GET_NEXT_LINE(EOF_ERROR, DROP_NL);

	if (!strncmp(p,"CHECKSUM SCHEMA FILE",20))
		sts = read_checksum(cmd);
	else if (!strncmp(p,"CLEAR ASYNC",11))
		sts = read_clear_async(cmd);
	else if (!strncmp(p,"CLEAR",5))
		sts = read_clear(cmd);
	else if (!strncmp(p,"CLOSE",5))
		sts = read_close(cmd);
	else if (!strncmp(p,"DEBUG",5))
		sts = read_debug(cmd);
	else if (!strncmp(p,"DESCRIBE",8))
		sts = read_describe(cmd);
	else if (!strncmp(p,"EXECUTE IMMEDIATE", 17))
		sts = read_execute_imm(cmd);
	else if (!strncmp(p,"EXECUTE",7))
		sts = read_execute(cmd);
	else if (!strncmp(p,"FETCH",5))
		sts = read_fetch(cmd);
	else if (!strncmp(p,"GET APP VERSION",15))
		sts = read_get_app_version(cmd);
	else if (!strncmp(p,"GET ASYNC STMTS",15))
		sts = read_get_async_stmts(cmd);
	else if (!strncmp(p,"GET CLIENT LOCATION",19))
		sts = read_get_client_location(cmd);
	else if (!strncmp(p,"GET DB INFO", 11))
		sts = read_get_db_info(cmd);
	else if (!strncmp(p,"GET DEFAULT SCHNAME", 19))
		sts = read_get_default_schname(cmd);
	else if (!strncmp(p,"GET FLAGS", 9))
		sts = read_get_flags(cmd);
	else if (!strncmp(p,"GET LANGUAGE NAME", 17))
		sts = read_get_language_name(cmd);
	else if (!strncmp(p,"GET PARAMETERS", 14))
		sts = read_get_parameters(cmd);
	else if (!strncmp(p,"GET RIS TYPE CODE", 17))
		sts = read_get_ris_type_code(cmd);
	else if (!strncmp(p,"GET RIS TYPE STRING", 19))
		sts = read_get_ris_type_string(cmd);
	else if (!strncmp(p,"GET SCHEMA FILE LOCATION",24))
		sts = read_get_schema_file_location(cmd);
	else if (!strncmp(p,"GET SCHEMA FILE",15))
		sts = read_get_schema_file(cmd);
	else if (!strncmp(p,"GET SCHEMA INFO",15))
		sts = read_get_schema_info(cmd);
	else if (!strncmp(p,"GET SCHEMA NAMES",16))
		sts = read_get_schema_names(cmd);
	else if (!strncmp(p,"GET SCHEMA TRANSACTIONS",23))
		sts = read_get_schema_transactions(cmd);
	else if (!strncmp(p,"GET SS NAMES",12))
		sts = read_get_ss_names(cmd);
	else if (!strncmp(p,"GET SS DEF",10))
		sts = read_get_ss_def(cmd);
	else if (!strncmp(p,"GET STMT SCHNAME", 19))
		sts = read_get_stmt_schname(cmd);
	else if (!strncmp(p,"INITIALIZE",10))
		sts = read_initialize(cmd);
	else if (!strncmp(p,"LOCATE CLIENT",13))
		sts = read_locate_client(cmd);
	else if (!strncmp(p,"LOCATE SCHEMA FILE",18))
		sts = read_locate_schema_file(cmd);
	else if (!strncmp(p,"PREPARE",7))
		sts = read_prepare(cmd);
	else if (!strncmp(p,"REPORT ERROR",12))
		sts = read_report_error(cmd);
	else if (!strncmp(p,"REPORT SS ERROR",15))
		sts = read_report_ss_error(cmd);
	else if (!strncmp(p,"SCHEMA MGR",10))
		sts = read_schema_mgr(cmd);
	else if (!strncmp(p,"SELECT INTO",11))
		sts = read_select_into(cmd);
	else if (!strncmp(p,"START CLIENT",12))
		sts = read_start_client(cmd);
	else if (!strncmp(p,"STOP CLIENT",11))
		sts = read_stop_client(cmd);
	else if (!strncmp(p,"TERMINATE",9))
		sts = read_terminate(cmd);
	else if (!strncmp(p,"TEST COMPLETION",15))
		sts = read_test_completion(cmd);
	else
	{
		error_msg(MSG(RISUTL_I_EXPECTED_CMD), p);
		report_errors = 0;
		sts = 1;
	}

	return sts;
}

/******************************************************************************/

extern int read_delay(
	delay_info_s *delay)
{
	GET_NEXT_LINE(EOF_ERROR, DROP_NL);

	READ_KEYWORD("time:");
	delay->delay_time = atoi(p);
	GET_NEXT_LINE(EOF_ERROR, DROP_NL);

	if (!strncmp(p, "elapsed time:", 13))
	{
		p += 13;
		delay->total_time = atoi(p);
		GET_NEXT_LINE(EOF_ERROR, DROP_NL);
	}
	else
	{
		delay->total_time = -1;
	}

	READ_KEYWORD("----------");
	return 0;
}

/******************************************************************************/

extern int read_system(
	system_info_s *sys)
{
	GET_NEXT_LINE(EOF_ERROR, DROP_NL);
	READ_KEYWORD("start command:");
	GET_STRING_DATA(sys->cmd, "stop command:");
	if (!sys->cmd)
	{
		error_msg(MSG(RISUTL_I_EXPECTED_SYS_CMD), "stop command:");
		report_errors = 0;
		return 1;
	}

	GET_NEXT_LINE(EOF_ERROR, DROP_NL);
	READ_KEYWORD("----------");
	return 0;
}

/******************************************************************************/

extern int read_header()
{
	int rec_maj, rec_min, rec_rel;

/*	GET_NEXT_LINE(EOF_ERROR, DROP_NL); */

	READ_KEYWORD("RIS VERSION:");
	if (sscanf(p, "%d.%d.%d", &rec_maj, &rec_min, &rec_rel) != 3)
	{
		error_msg(MSG(RISUTL_I_EXPECTED_VERSION), p);
		report_errors = 0;
		return 1;
	}
	/* We now require the major versions to match since version 5 CANNOT
	** play back record files from version 4 - Shiva 4/28/94
	*/

	if ((rec_maj != RIS_version_maj) ||
		(rec_maj == RIS_version_maj && rec_min > RIS_version_min) ||
		(rec_maj == RIS_version_maj && rec_min == RIS_version_min &&
		rec_rel > RIS_version_rel))
	{
		error_msg(MSG(RISUTL_I_VERSION_NOT_SAME), RIS_version_maj,
			RIS_version_min, RIS_version_rel, in_filename, rec_maj,
			rec_min, rec_rel);
		report_errors = 0;
		return 1;
	}
	GET_NEXT_LINE(EOF_ERROR, DROP_NL);
	READ_KEYWORD("TIMESTAMP:");

	GET_NEXT_LINE(EOF_ERROR, DROP_NL);
	READ_KEYWORD("----------");
	return 0;
}

/******************************************************************************/

extern int read_actions()
{
	int expected;
	int got;

	while (1)
	{
		GET_NEXT_LINE(EOF_OK, DROP_NL);
		if (p == NULL)
		{
			break;
		}

		if (!strncmp(p, "SUCCESS:", 8))
		{
			expected = EXPECTED_SUCCESS;		
			p += 8;
		}
		else if (!strncmp(p, "END_OF_DATA:", 12))
		{
			expected = EXPECTED_END_OF_DATA;		
			p += 12;
		}
		else if (!strncmp(p, "ERROR:", 6))
		{
			expected = EXPECTED_ERROR;		
			p += 6;
		}
		else
		{
			error_msg(MSG(RISUTL_I_EXPECTED_GOT),
				"\"SUCCESS:\", \"END_OF_DATA:\" or \"ERROR:\"", s);
			continue;
		}

		if (!strncmp(p, "SUCCESS:", 8))
		{
			got = GOT_SUCCESS;		
			p += 8;
		}
		else if (!strncmp(p, "END_OF_DATA:", 12))
		{
			got = GOT_END_OF_DATA;		
			p += 12;
		}
		else if (!strncmp(p, "ERROR:", 6))
		{
			got = GOT_ERROR;		
			p += 6;
		}
		else
		{
			error_msg(MSG(RISUTL_I_EXPECTED_GOT),
				"\"SUCCESS:\", \"END_OF_DATA:\" or \"ERROR:\"", s);
			continue;
		}

		if (!strncmp(p, "CONTINUE", 8))
		{
			action[expected][got] = CONTINUE;
			p += 8;
		}
		else if (!strncmp(p, "STOP", 4))
		{
			action[expected][got] = STOP;
			p += 4;
		}
		else if (!strncmp(p, "RETRY", 5))
		{
			action[expected][got] = RETRY;
			p += 5;
		}
		else
		{
			error_msg(MSG(RISUTL_I_EXPECTED_GOT),
				"\"CONTINUE\", \"STOP\" or \"RETRY\"", s);
			continue;
		}
	}

	return 0;
}

/******************************************************************************/
