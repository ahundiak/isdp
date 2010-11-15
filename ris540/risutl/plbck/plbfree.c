/* Do not alter this SPC information: $Revision: 1.1.53.1 $ */
/*
**	NAME:							plbfree.c
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
#include "plbck.h"
#if defined(WIN32S)
#include "prog32s.h"
#endif 

/*
**	DEFINES
*/
#ifdef ZMEM
#undef ZMEM
#endif
#define ZMEM(x)	memset(&x, 0, sizeof(x));

#ifdef FREE
#undef FREE
#endif
#define FREE(x) {if (x) {free(x);}}

/*
**	TYPES
*/

/*
**	FUNCTION PROTOTYPES
*/
#define plbfree_c
#include "plbfree.prt"
#include "sys.prt"

/*
**	VARIABLES
*/

/*
**	FUNCTIONS
*/

/******************************************************************************/

static void free_sqlda(
	sqlda *desc)
{
	int i;

	if (desc)
	{
		if (desc->sqlvar)
		{
			for (i = 0; i < desc->sqld; i++)
			{
				if (desc->sqlvar[i].sqlind)
				{
					free(desc->sqlvar[i].sqlind);
				}
				if (desc->sqlvar[i].sqldata)
				{
					if (desc->sqlvar[i].sqltype == RIS_BLOB ||
						desc->sqlvar[i].sqltype == RIS_TEXT)
					{
						ris_blob *b = (ris_blob *)desc->sqlvar[i].sqldata;

						if (b->filename)
						{
							free(b->filename);
						}
						if (b->array)
						{
							free(b->array);
						}
					}
					free(desc->sqlvar[i].sqldata);
				}
			}
			free(desc->sqlvar);
		}
		free(desc);
	}
}

/******************************************************************************/

extern void free_clear()
{
	ZMEM(clear);
}

/******************************************************************************/

extern void free_clear_async()
{
	ZMEM(clear_async);
}

/******************************************************************************/

extern void free_close()
{
	ZMEM(clse);
}

/******************************************************************************/

extern void free_debug()
{
	FREE(debug.s);
	ZMEM(debug);
}

/******************************************************************************/

extern void free_describe()
{
	free_sqlda(describe.data);
	ZMEM(describe);
}

/******************************************************************************/

extern void free_execute()
{
	free_sqlda(execute.in_sqlda);
	ZMEM(execute);
}

/******************************************************************************/

extern void free_execute_imm()
{
	FREE(execute_imm.stmt_id);
	FREE(execute_imm.query);
	free_sqlda(execute_imm.in_sqlda);
	ZMEM(execute_imm);
}

/******************************************************************************/

extern void free_fetch()
{
	free_sqlda(fetch.output);
	ZMEM(fetch);
}

/******************************************************************************/

extern void free_get_async_stmts()
{
	FREE(get_async_stmts.countp);
	FREE(get_async_stmts.buffer);
	ZMEM(get_async_stmts);
}

/******************************************************************************/

extern void free_get_app_version()
{
	ZMEM(get_app_version);
}

/******************************************************************************/

extern void free_get_client_location()
{
	ZMEM(get_client_location);
}

/******************************************************************************/

extern void free_get_db_info()
{
	ZMEM(get_db_info);
}

/******************************************************************************/

extern void free_get_default_schname()
{
	ZMEM(get_default_schname);
}

/******************************************************************************/

extern void free_get_flags()
{
	ZMEM(get_flags);
}

/******************************************************************************/

extern void free_get_language_name()
{
	ZMEM(get_language_name);
}

/******************************************************************************/

extern void free_get_parameters()
{
	ZMEM(get_parameters);
}

/******************************************************************************/

extern void free_get_ris_type_code()
{
	FREE(get_ris_type_code.str);
	ZMEM(get_ris_type_code);
}

/******************************************************************************/

extern void free_get_ris_type_string()
{
	ZMEM(get_ris_type_string);
}

/******************************************************************************/

extern void free_get_schema_file()
{
	ZMEM(get_schema_file);
}

/******************************************************************************/

extern void free_get_schema_file_location()
{
	ZMEM(get_schema_file_location);
}

/******************************************************************************/

extern void free_get_schema_info()
{
	FREE(get_schema_info.schname);
	ZMEM(get_schema_info);
}

/******************************************************************************/

extern void free_get_schema_names()
{
	FREE(get_schema_names.countp);
	FREE(get_schema_names.buffer);
	ZMEM(get_schema_names);
}

/******************************************************************************/

extern void free_get_schema_transactions()
{
	FREE(get_schema_transactions.countp);
	FREE(get_schema_transactions.buffer);
	ZMEM(get_schema_transactions);
}

/******************************************************************************/

extern void free_get_ss_def()
{
	FREE(get_ss_def.ss_name);
	FREE(get_ss_def.countp);
	FREE(get_ss_def.buffer);
	ZMEM(get_ss_def);
}

/******************************************************************************/

extern void free_get_ss_names()
{
	FREE(get_ss_names.countp);
	FREE(get_ss_names.buffer);
	ZMEM(get_ss_names);
}

/******************************************************************************/

extern void free_get_stmt_schname()
{
	ZMEM(get_stmt_schname);
}

/******************************************************************************/

extern void free_initialize()
{
	FREE(initialize.language_name);
	ZMEM(initialize);
}

/******************************************************************************/

extern void free_locate_client()
{
	FREE(locate_client.parms);
	ZMEM(locate_client);
}

/******************************************************************************/

extern void free_locate_schema_file()
{
	FREE(locate_schema_file.parms);
	ZMEM(locate_schema_file);
}

/******************************************************************************/

extern void free_prepare()
{
	FREE(prepare.query);
	ZMEM(prepare);
}

/******************************************************************************/

extern void free_report_error()
{
	FREE(report_error.async_id);
	ZMEM(report_error);
}

/******************************************************************************/

extern void free_report_ss_error()
{
	FREE(report_ss_error.ss_name);
	ZMEM(report_ss_error);
}

/******************************************************************************/

extern void free_schema_mgr()
{
	FREE(schema_mgr.data);
	FREE(schema_mgr.str);
	ZMEM(schema_mgr);
}

/******************************************************************************/

extern void free_select_into()
{
	FREE(select_into.query);
	free_sqlda(select_into.in_sqlda);
	free_sqlda(select_into.out_sqlda);
	ZMEM(select_into);
}

/******************************************************************************/

extern void free_test_completion()
{
	free_sqlda(test_completion.desc);
	ZMEM(test_completion);
}

/******************************************************************************/
