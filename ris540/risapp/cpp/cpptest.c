/* Do not alter this SPC information: $Revision: 1.1.58.1 $ */
/*
**	NAME:							CPPcpp_test_completion
**	AUTHORS:						Sarah Byram
**	CREATION DATE:					10/91
**	ABSTRACT:
**		
**	The functions that translate embedded ris statements into function:
**
**	RISint_test_completion ( any or all, pointer to list of schemas, number of
**									schema, wait or test ).
**	
**	REVISION HISTORY:
**		11/22/91 sjb moved define of 'any' and 'all' to RISmacros.h
**
*/
 
/*
**	INCLUDES
*/
#include "cpp.h"
#include "ris_err.h"

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
#define cpptest_c
#include "comdebug.prt"
#include "comgtnme.prt"
#include "comjmp.prt"
#include "cppmisc.prt"
#include "cpptest.prt"
#include "cppvar.prt"
#include "sys.prt"

/******************************************************************************/

extern void RIScpp_test_completion(
	ristree	*tp)
{
	int				async_id_count;
	int				var_count;
	char			*desc_name;
	char			*var_name;
	ristree			*temp;
	var_list_node	*desc;
	var_list_node	*var;

	CPP_DBG(("RIScpp_test_completion(tp:%x)\n",tp));

	BEGIN_BRACE;

	switch(tp->rhs->tok)
	{
		case RIS_TOK_ANY:
		case RIS_TOK_ALL:
			fprintf(RIScpp_temp_file,
				"\tstatic sqlvar in_sqlvar[1];\n");
			fprintf(RIScpp_temp_file,
				"\tstatic sqlda in_sqlda = {1,1,in_sqlvar};\n");
			fprintf(RIScpp_temp_file,
				"\tin_sqlvar[0].sqldata = \"%s\";\n",
				RIScom_get_token_name(tp->rhs->tok));
			fprintf(RIScpp_temp_file,
				"\tRISint_test_completion(&in_sqlda,%d);\n",
				(int)(tp->tok == RIS_TOK_WAIT));
			break;

		case RIS_TOK_ASYNC_ID_LIST:
			for(async_id_count = 0, temp = tp->rhs->rhs;
				temp;
				temp = temp->rhs, async_id_count++)
			;

			fprintf(RIScpp_temp_file,
				"\tstatic sqlvar in_sqlvar[%d];\n", async_id_count);
			fprintf(RIScpp_temp_file,
				"\tstatic sqlda in_sqlda = {%d,%d,in_sqlvar};\n",
				async_id_count, async_id_count);

			for(async_id_count = 0, temp = tp->rhs->rhs;
				temp;
				temp = temp->rhs, async_id_count++)
			{
				fprintf(RIScpp_temp_file, "\tin_sqlvar[%d].sqltype = %d;\n",
					async_id_count, RIS_INTEGER);
				fprintf(RIScpp_temp_file,
					"\tin_sqlvar[%d].sqldata = (char *)&%s;\n",
					async_id_count, temp->lhs->info.val);
			}
			fprintf(RIScpp_temp_file,
				"\tRISint_test_completion(&in_sqlda,%d);\n",
				(int)(tp->tok == RIS_TOK_WAIT));
			break;

		case RIS_TOK_USING:	
			if (tp->rhs->rhs->tok == RIS_TOK_DESC_NAME)
			{
				desc = RIScpp_find_var_name(tp->rhs->rhs, &desc_name);
				RIScpp_check_type(RIS_TOK_SQLDA, desc, tp->rhs->rhs->pos, 0);
				if (desc->ptr + desc->array)
				{
					fprintf(RIScpp_temp_file,
						"\tRISint_test_completion(%s,%d);\n",
						desc_name, (int)(tp->tok == RIS_TOK_WAIT));
				}
				else
				{
					fprintf(RIScpp_temp_file,
						"\tRISint_test_completion(&%s,%d);\n",
						desc_name, (int)(tp->tok == RIS_TOK_WAIT));
				}
			}
			else
			{
				for(var_count = 0, temp = tp->rhs->rhs;
					temp;
					var_count++, temp = temp->rhs)
				;

				fprintf(RIScpp_temp_file,
					"\tstatic sqlvar in_sqlvar[%d];\n",
					var_count);
				fprintf(RIScpp_temp_file,
					"\tstatic sqlda in_sqlda = {%d,%d,in_sqlvar};\n",
					var_count, var_count);

				for(var_count = 0, temp = tp->rhs->rhs;
					temp;
					var_count++, temp = temp->rhs)
				{
					var = RIScpp_find_var_name(temp->lhs, &var_name);
					RIScpp_check_type(RIS_TOK_CHAR, var, temp->lhs->pos, 0);
					fprintf(RIScpp_temp_file,
						"\tin_sqlvar[%d].sqldata = %s;\n",
						var_count, var_name);
				}
				fprintf(RIScpp_temp_file,
					"\tRISint_test_completion(&in_sqlda,%d);\n",
					(int)(tp->tok == RIS_TOK_WAIT));
			}
			break;

			default:
				CPP_DBG(("RIScpp_test_completion: invalid action\n"));
				CPP_ERR_RETURN(RIS_E_INTERNAL_ERROR, tp->rhs->pos);
	}
  	RIScpp_sqlerror_check();
	END_BRACE;

	CPP_DBG(("RIScpp_test_completion: returning\n"));
}

/******************************************************************************/
