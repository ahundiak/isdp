/* Do not alter this SPC information: $Revision: 1.1.58.1 $ */
/*
**	NAME:							cppupdte.c
**	AUTHORS:						David Michal
**	CREATION DATE:					8/88
**	ABSTRACT:
**		
**	The functions that translate embedded delete, insert, and update 
**	statements into function calls.
**	
**	REVISION HISTORY: Modified to incorporate 'tree to string' generation and
**                    and to 'avoid repreparing of static statements' by
**                    Prasad Challa on 9/11/91
**
**                    10/21/91 sjb added async flag
*/
 
/*
**	INCLUDES
*/
#include "risflags.h"
#include "risapp.h"
#include "ris_err.h"
#include "cpp.h"

/*
**	DEFINES
*/

/*
**	VARIABLES
*/

/*
**	FUNCTIONS
*/

/*
**      FUNCTION PROTOTYPES
*/
#define cppupdte_c
#include "comdebug.prt"
#include "comjmp.prt"
#include "cpptrstr.prt"
#include "cppparm.prt"
#include "cppmisc.prt"
#include "cppupdte.prt"
#include "sys.prt"

/******************************************************************************/
/* riscpp generates RISint_execute_immediate n therefore static stmt */

extern void RIScpp_update(
	ristree * tp)
{
	int in_parm_count;
	parm_list_node * in_parm_list;
	ristree * cursorp = 0;

CPP_DBG(("\nRIScpp_update tp = %x \n",tp));

	if (tp->tok == RIS_TOK_UPDATE && tp->rhs->rhs->rhs &&
	 tp->rhs->rhs->rhs->lhs->tok == RIS_TOK_CURSOR_NAME)
	{
		cursorp = tp->rhs->rhs->rhs->lhs;
	}
	else if (tp->tok == RIS_TOK_DELETE && tp->rhs->rhs &&
	 tp->rhs->rhs->lhs->tok == RIS_TOK_CURSOR_NAME)
	{
		cursorp = tp->rhs->rhs->lhs;
	}
	if (cursorp)
	{
		CPP_ERR_RETURN(RIS_E_NOT_IMPLEMENTED,cursorp->pos);
	}
	else
	{
		in_parm_count = 0;
		RIScpp_make_parm_list(tp,&in_parm_list,&in_parm_count);
		BEGIN_BRACE;
		if (in_parm_count)
		{
			fprintf(RIScpp_temp_file,"{\n");
			fprintf(RIScpp_temp_file,
				"\tstatic short RIScpp_static_stmt = -1;\n");
			RIScpp_print_parm_list(in_parm_list,in_parm_count,"in");
			if (RIScpp_async_id_name)
			{
				fprintf(RIScpp_temp_file,
					"RISint_execute_immediate(&RIScpp_static_stmt,&%s,\"",
					RIScpp_async_id_name);
			}
			else
			{
				fprintf(RIScpp_temp_file,
					"RISint_execute_immediate(&RIScpp_static_stmt,0,\"");
			}
			RIScpp_generate_string(tp);
		 	fprintf(RIScpp_temp_file, "\",&in_sqlda,%d,%d,%d);\n}\n",
				RIScpp_async_flag, RIS_DONT_CLEAR_FLAG, RIS_STATIC_STMT);
		}
		else
		{
			fprintf(RIScpp_temp_file,
				"\tstatic short RIScpp_static_stmt = -1;\n");
			if (RIScpp_async_id_name)
			{
				fprintf(RIScpp_temp_file,
					"RISint_execute_immediate(&RIScpp_static_stmt,&%s,\"",
					RIScpp_async_id_name);
			}
			else
			{
				fprintf(RIScpp_temp_file,
					"RISint_execute_immediate(&RIScpp_static_stmt,0,\"");
			}
			RIScpp_generate_string(tp);
		 	fprintf(RIScpp_temp_file, "\",0,%d,%d,%d);\n", RIScpp_async_flag,
				RIS_DONT_CLEAR_FLAG, RIS_STATIC_STMT);
		}
		RIScpp_sqlerror_notfound_check();
		END_BRACE;
	}
}

/******************************************************************************/
