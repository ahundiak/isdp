/* Do not alter this SPC information: $Revision: 1.1.58.1 $ */
/*
**	NAME:							cppclear.c
**	AUTHORS:						David Michal
**	CREATION DATE:					8/88
**	ABSTRACT:
**	The functions that translate embedded clear statements into function
**	calls.
**		
**	
**	REVISION HISTORY:
**
**                    10/21/91 sjb added async flag
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
#define cppclear_c
#include "cppclear.prt"
#include "cppcursr.prt"
#include "cppmisc.prt"
#include "cppstmid.prt"
#include "cppvar.prt"
#include "sys.prt"



/******************************************************************************/

extern void RIScpp_clear(
	ristree * tp)
{
	int					index;
	cursor_list_node	*cursor;
	stmt_id_list_node	*stmt_id;
	var_list_node		*async_id;

	BEGIN_BRACE;
	if (tp->rhs->lhs->tok == RIS_TOK_ASYNC_ID)
	{
		async_id = RIScpp_find_var_name(tp->rhs->lhs, &RIScpp_async_id_name);
		RIScpp_check_type(RIS_TOK_INT, async_id, tp->rhs->lhs->pos, 0);

		fprintf(RIScpp_temp_file, "RISint_clear_async(&%s);\n",
			RIScpp_async_id_name);
	}
	else
	{
		if (tp->rhs->lhs->tok == RIS_TOK_CURSOR_NAME)
		{
			cursor = RIScpp_find_cursor_name(tp->rhs->lhs);
			index = cursor->index;
		}
		else
		{
			stmt_id = RIScpp_find_stmt_id_name(tp->rhs->lhs);
			index = stmt_id->index;
		}

		if (RIScpp_async_id_name)
		{
			fprintf(RIScpp_temp_file,
				"RISint_clear(&RIScpp_stmt_id%d, &%s ,%d);\n", index,
				RIScpp_async_id_name, RIScpp_async_flag);
		}
		else
		{
			fprintf(RIScpp_temp_file,
				"RISint_clear(&RIScpp_stmt_id%d, 0, %d);\n", index,
				RIScpp_async_flag);
		}
	}
	RIScpp_sqlerror_check();
	END_BRACE;
}

/******************************************************************************/
