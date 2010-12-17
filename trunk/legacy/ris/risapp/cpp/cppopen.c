/* Do not alter this SPC information: $Revision: 1.1.58.1 $ */
/*
**	NAME:							USRexec.c
**	AUTHORS:						David Michal
**	CREATION DATE:					4/88
**	ABSTRACT:
**		
**	The functions that translate embedded ris statements into function
**	calls.
**	
**	REVISION HISTORY:
**
**                    10/21/91 sjb added async flag
*/
 
/*
**	INCLUDES
*/
#include "risflags.h"
#include "risapp.h"
#include "cpp.h"

/*
**	DEFINES
*/

/*
**	VARIABLES
*/
/* MSDOS tp removed */

/*
**	FUNCTIONS
*/

/*
**      FUNCTION PROTOTYPES
*/
#define cppopen_c
#include "comdebug.prt"
#include "comwrap.prt"
#include "cppopen.prt"
#include "cppcursr.prt"
#include "cppvar.prt"
#include "cppparm.prt"
#include "cppmisc.prt"
#include "sys.prt"

/******************************************************************************/

extern void RIScpp_open(
	ristree * tp)
{
	cursor_list_node * cursor;
	var_list_node * desc;
	char * desc_name;
	int in_parm_count;
	parm_list_node * in_parm_list;

CPP_DBG(("\nRIScpp_open tp = %x\n",tp));

	cursor = RIScpp_find_cursor_name(tp->rhs->lhs);
	BEGIN_BRACE;
	if (tp->rhs->rhs)
	{
		if (tp->rhs->rhs->lhs->rhs->tok == RIS_TOK_DESC_NAME)
		{
			if (RIScpp_async_id_name)
			{
				fprintf(RIScpp_temp_file,
					"RISint_execute(&RIScpp_stmt_id%d,&%s,", cursor->index,
					RIScpp_async_id_name);
			}
			else
			{
				fprintf(RIScpp_temp_file,
					"RISint_execute(&RIScpp_stmt_id%d,0,", cursor->index);
			}

			desc = RIScpp_find_var_name(tp->rhs->rhs->lhs->rhs,&desc_name);
			RIScpp_check_type(RIS_TOK_SQLDA,desc,tp->rhs->rhs->lhs->rhs->pos,0);
			if (desc->ptr+desc->array)
			{
				fprintf(RIScpp_temp_file, "%s,%d,%d,%d);\n",
					desc_name, RIScpp_async_flag, RIS_DONT_CLEAR_FLAG,
					RIS_DYNAMIC_STMT);
			}
			else
			{
				fprintf(RIScpp_temp_file,"&%s,%d,%d,%d);\n", desc_name,
					RIScpp_async_flag,RIS_DONT_CLEAR_FLAG, RIS_DYNAMIC_STMT);
			}
		}
		else
		{
			in_parm_count = 0;
			RIScpp_make_parm_list(tp,&in_parm_list,&in_parm_count);
			RIScom_fputs("{\n",RIScpp_temp_file);
			RIScpp_print_parm_list(in_parm_list,in_parm_count,"in");

			if (RIScpp_async_id_name)
			{
				fprintf(RIScpp_temp_file,
					"RISint_execute(&RIScpp_stmt_id%d,&%s,", cursor->index,
					RIScpp_async_id_name);
			}
			else
			{
				fprintf(RIScpp_temp_file,
					"RISint_execute(&RIScpp_stmt_id%d,0,", cursor->index);
			}
			fprintf(RIScpp_temp_file, "&in_sqlda,%d,%d,%d);\n}\n",
				RIScpp_async_flag, RIS_DONT_CLEAR_FLAG, RIS_DYNAMIC_STMT);
		}
	}
	else
	{
		if (cursor->in_parm_count)
		{
            RIScom_fputs("{\n",RIScpp_temp_file);
            RIScpp_print_parm_list(cursor->in_parm_list, cursor->in_parm_count,
				"in");

			if (RIScpp_async_id_name)
			{
				fprintf(RIScpp_temp_file,
					"RISint_execute(&RIScpp_stmt_id%d,&%s,", cursor->index,
					RIScpp_async_id_name);
			}
			else
			{
				fprintf(RIScpp_temp_file,
					"RISint_execute(&RIScpp_stmt_id%d,0,", cursor->index);
			}
			fprintf(RIScpp_temp_file, "&in_sqlda,%d,%d,%d);\n}\n",
				RIScpp_async_flag,RIS_DONT_CLEAR_FLAG,RIS_DYNAMIC_STMT);
		}
		else
		{
			if (RIScpp_async_id_name)
			{
				fprintf(RIScpp_temp_file,
					"RISint_execute(&RIScpp_stmt_id%d,&%s,", cursor->index,
					RIScpp_async_id_name);
			}
			else
			{
				fprintf(RIScpp_temp_file,
					"RISint_execute(&RIScpp_stmt_id%d,0,", cursor->index);
			}
			fprintf(RIScpp_temp_file, "0,%d,%d,%d);\n", RIScpp_async_flag,
				RIS_DONT_CLEAR_FLAG,RIS_DYNAMIC_STMT);
		}
	}
	RIScpp_sqlerror_check();
	END_BRACE;
}

/******************************************************************************/
