/* Do not alter this SPC information: $Revision: 1.1.58.1 $ */
/*
**	NAME:							cppdesc.c
**	AUTHORS:						David Michal
**	CREATION DATE:					4/88
**	ABSTRACT:
**		
**	The functions that translate embedded describe statements into
**	function calls.
**	
**	REVISION HISTORY:
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
ristree * tp;

/*
**	FUNCTIONS
*/

/*
**      FUNCTION PROTOTYPES
*/
#define cppdesc_c
#include "comdebug.prt"
#include "cppdesc.prt"
#include "cppstmid.prt"
#include "cppvar.prt"
#include "cppmisc.prt"
#include "sys.prt"


/******************************************************************************/

extern void RIScpp_desc(
	ristree * tp)
{
	stmt_id_list_node * stmt_id;
	char * desc_name;
	var_list_node * desc;
	int tok;

CPP_DBG(("\nRIScpp_desc tp = %x\n",tp));

	if (tp->tok == RIS_TOK_DESCRIBE_INPUT)
	{
		tok = RIS_INPUT_FLAG;
	}
	else
	{
		tok = RIS_OUTPUT_FLAG;
	}
	stmt_id = RIScpp_find_stmt_id_name(tp->rhs->lhs);
	desc = RIScpp_find_var_name(tp->rhs->rhs->lhs->rhs,&desc_name);
	RIScpp_check_type(RIS_TOK_SQLDA,desc,tp->rhs->rhs->lhs->rhs->pos,0);
	BEGIN_BRACE;
	if (desc->array+desc->ptr)
	{
		fprintf(RIScpp_temp_file,
		 "RISint_describe(RIScpp_stmt_id%d,%s,%d);\n",
	 	 stmt_id->index,desc_name,tok);
	}
	else
	{
		fprintf(RIScpp_temp_file,
		 "RISint_describe(RIScpp_stmt_id%d,&%s,%d);\n",
	 	 stmt_id->index,desc_name,tok);
	}
	RIScpp_sqlerror_check();
	END_BRACE;
}

/******************************************************************************/
