/* Do not alter this SPC information: $Revision: 1.1.58.1 $ */
/*
**	NAME:							cpprprt.c
**	AUTHORS:						David Michal
**	CREATION DATE:					6/88
**	ABSTRACT:
**		
**	The functions that translate embedded ris statements into function
**	calls.
**	
**	REVISION HISTORY:
*/
 
/*
**	INCLUDES
*/
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
#define cpprprt_c
#include "comdebug.prt"
#include "cpprprt.prt"
#include "cppvar.prt"
#include "sys.prt"


/******************************************************************************/

extern void RIScpp_report(
	ristree * tp)
{
	char			*str_name = NULL;
	char			*async_name = NULL;
	var_list_node	*str_var;
	var_list_node	*async_var;
	ristree			*str_tp = NULL;
	ristree			*async_tp = NULL;

	CPP_DBG(("RIScpp_report(tp:%x)\n",tp));

	/* set up pointers */

	for(;tp->rhs; tp = tp->rhs)
	{
		switch(tp->rhs->lhs->tok)
		{
			case RIS_TOK_ASYNC:
			{
				async_tp = tp->rhs->lhs->rhs;

    			async_var = RIScpp_find_var_name(async_tp, &async_name);
				RIScpp_check_type(RIS_TOK_INT, async_var, async_tp->pos, 0);
			}
			break;

			case RIS_TOK_VAR_NAME:
			{
				str_tp = tp->rhs->lhs;

    			str_var = RIScpp_find_var_name(str_tp, &str_name);
				RIScpp_check_type(RIS_TOK_CHAR, str_var, str_tp->pos, 1);
			}
			break;
		}
	}

	fprintf(RIScpp_temp_file,"RISint_report_error(");
	if (async_tp)
	{
		fprintf(RIScpp_temp_file, "&%s,", async_name);
	}
	else
	{
		fprintf(RIScpp_temp_file, "0,");
	}

	if (str_name)
	{
		fprintf(RIScpp_temp_file, "&%s);\n", str_name);
	}
	else
	{
		fprintf(RIScpp_temp_file, "0);\n");
	}

	CPP_DBG(("RIScpp_report:returning\n"));
}

/******************************************************************************/

extern void RIScpp_report_superschema(
	ristree *tp)
{
	char			*sch_name = NULL;
	var_list_node	*sch_var;
	ristree			*sch_tp = NULL;

	CPP_DBG(("RIScpp_report_superschema(tp:%x)\n",tp));

	/* set up pointers */

	sch_tp = tp->rhs->lhs;

	if (sch_tp->tok == RIS_TOK_VAR_NAME)
	{
		sch_var = RIScpp_find_var_name(sch_tp, &sch_name);
		RIScpp_check_type(RIS_TOK_CHAR, sch_var, sch_tp->pos, 0);
	}
	else
	{
		sch_name = sch_tp->info.val;
	}

	fprintf(RIScpp_temp_file,"RISint_report_superschema_error(");
	if (sch_tp->tok == RIS_TOK_VAR_NAME)
	{
		fprintf(RIScpp_temp_file, "%s);\n", sch_name);
	}
	else
	{
		fprintf(RIScpp_temp_file, "\"%s\");\n", sch_name);
	}

	CPP_DBG(("RIScpp_report_superschema:returning\n"));
}

/******************************************************************************/
