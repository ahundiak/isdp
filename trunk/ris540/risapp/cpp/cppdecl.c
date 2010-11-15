/* Do not alter this SPC information: $Revision: 1.1.58.1 $ */
/*
**	NAME:							cppdecl.c
**	AUTHORS:						David Michal
**	CREATION DATE:					8/88
**	ABSTRACT:
**		
**	The functions that translate embedded declare statements into
**	function calls.
**	
**	REVISION HISTORY: Modified to avoid 'repreparing of static static stmts'
**					  by Prasad Challa on 9/16/91
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

/*
**	FUNCTIONS
*/

/*
**      FUNCTION PROTOTYPES
*/
#define cppdecl_c
#include "comdebug.prt"
#include "cppdecl.prt"
#include "cppstmid.prt"
#include "cpptrstr.prt"
#include "cppparm.prt"
#include "cppmisc.prt"
#include "cppcursr.prt"
#include "sys.prt"


/******************************************************************************/
/* Cursor stmt therefore dynamic stmt */

extern void RIScpp_decl(
	ristree * tp)
{
	int in_parm_count;
	parm_list_node * in_parm_list;
	stmt_id_list_node * stmt_id;

CPP_DBG(("\nRIScpp_decl tp = %x\n",tp));

	if (tp->rhs->rhs->lhs->tok == RIS_TOK_STMT_ID)
	{
		stmt_id = RIScpp_find_stmt_id_name(tp->rhs->rhs->lhs);
		RIScpp_add_cursor(tp,stmt_id,(parm_list_node *)0,0);
		fprintf(RIScpp_temp_file,
	"/* declare for statement id requires no work just return success */\n");
		fprintf(RIScpp_temp_file,"RISint_set_sqlcode(RIS_SUCCESS);\n");
	}
	else
	{
		in_parm_count = 0;
		RIScpp_make_parm_list(tp,&in_parm_list,&in_parm_count);

		BEGIN_BRACE;
		fprintf(RIScpp_temp_file, "RISint_prepare(&RIScpp_stmt_id%d,\"",
			RIScpp_stmt_index); 
		RIScpp_generate_string(tp);
		fprintf(RIScpp_temp_file, "\",%d,%d);\n", RIS_DONT_CLEAR_FLAG,
			RIS_DYNAMIC_STMT);
		RIScpp_add_cursor(tp,(stmt_id_list_node *)0,in_parm_list,in_parm_count);
		RIScpp_sqlerror_check();
		END_BRACE;
	}
}

/******************************************************************************/
