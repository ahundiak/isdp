/* Do not alter this SPC information: $Revision: 1.1.58.1 $ */
/*
**	NAME:							cppprep.c
**	AUTHORS:						David Michal
**	CREATION DATE:					6/88
**	ABSTRACT:
**		
**	The function that translates embedded ris prepare statments into 
**	function calls.
**	
**	REVISION HISTORY: Modified to avoid 'repreparing of static static stmts'
**                    by Prasad Challa on 9/16/91
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
#define cppprep_c
#include "comdebug.prt"
#include "cppprep.prt"
#include "cppvar.prt"
#include "cppstmid.prt"
#include "cppmisc.prt"
#include "cpptrstr.prt"
#include "sys.prt"


/******************************************************************************/

extern void RIScpp_prep(
	ristree * tp)
{
	char * str_name;
	var_list_node * str_var;

CPP_DBG(("\nRIScpp_prep tp = %x\n",tp));

	BEGIN_BRACE;
	if (tp->rhs->rhs->lhs->tok == RIS_TOK_C_CHAR_STR_LIT)
	{
		/* undo quote translation done by lex */
		tp->rhs->rhs->lhs->info.val[0] = '"';
		tp->rhs->rhs->lhs->info.val[strlen(tp->rhs->rhs->lhs->info.val)-1]='"';
		fprintf(RIScpp_temp_file, "RISint_prepare(&RIScpp_stmt_id%d,", 
			RIScpp_stmt_index);
		RIScpp_generate_string(tp->rhs->rhs->lhs);
		fprintf(RIScpp_temp_file, ",%d,%d);\n", RIS_DONT_CLEAR_FLAG,
			RIS_DYNAMIC_STMT);
	}
	else
	{
		str_var = RIScpp_find_var_name(tp->rhs->rhs->lhs,&str_name);
		RIScpp_check_type(RIS_TOK_CHAR,str_var,tp->rhs->rhs->lhs->pos,0);
		fprintf(RIScpp_temp_file,
			"RISint_prepare(&RIScpp_stmt_id%d,%s,%d,%d);\n",
			 RIScpp_stmt_index, str_name, RIS_DONT_CLEAR_FLAG, RIS_DYNAMIC_STMT);
	}
	RIScpp_sqlerror_check();
	END_BRACE;
	RIScpp_add_stmt_id(tp);
}

/******************************************************************************/
