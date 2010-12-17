/* Do not alter this SPC information: $Revision: 1.1.58.1 $ */
/*
**	NAME:							cppclose.c
**	AUTHORS:						David Michal
**	CREATION DATE:					8/88
**	ABSTRACT:
**		
**	The functions that translate embedded close statements into function
**	calls.
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
#define cppclose_c
#include "cppclose.prt"
#include "cppcursr.prt"
#include "cppmisc.prt"
#include "sys.prt"

/******************************************************************************/

extern void RIScpp_close(
	ristree * tp)
{
	cursor_list_node	*cursor;

	cursor = RIScpp_find_cursor_name(tp->rhs->lhs);
	BEGIN_BRACE;

	if (RIScpp_async_id_name)
	{
		fprintf(RIScpp_temp_file,
			"RISint_close(RIScpp_stmt_id%d, &%s, %d);\n",
	 		cursor->index, RIScpp_async_id_name, RIScpp_async_flag);
	}
	else
	{
		fprintf(RIScpp_temp_file,
			"RISint_close(RIScpp_stmt_id%d, 0, %d);\n",
	 		cursor->index, RIScpp_async_flag);
	}

	RIScpp_sqlerror_check();
	END_BRACE;
}

/******************************************************************************/
