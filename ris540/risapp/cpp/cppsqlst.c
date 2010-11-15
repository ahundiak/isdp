/* Do not alter this SPC information: $Revision: 1.1.58.1 $ */
/*
**	NAME:							cppsqlst.c
**	AUTHORS:						David Michal
**	CREATION DATE:					8/88
**	ABSTRACT:
**		
**	The functions that translate embedded ris statements into function
**	calls.
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
#define cppsqlst_c
#include "comdebug.prt"
#include "cppsqlst.prt"
#include "cpptrstr.prt"
#include "cppmisc.prt"
#include "sys.prt"

/******************************************************************************/
/* riscpp generates RISint_execute_immediate n therefore static stmt */

extern void RIScpp_sql_stmt(
	ristree * tp,
	int clear_flag)
{

CPP_DBG(("\nRIScpp_sql_stmt tp = %x clear_flag = %d\n",tp,clear_flag));

	BEGIN_BRACE;
	fprintf(RIScpp_temp_file,"static short RIScpp_exec_imm_stmt = -1;\n");
	if (RIScpp_async_id_name)
	{
		fprintf(RIScpp_temp_file,
			"RISint_execute_immediate(&RIScpp_exec_imm_stmt,&%s,\"",
			RIScpp_async_id_name);
	}
	else
	{
		fprintf(RIScpp_temp_file,
			"RISint_execute_immediate(&RIScpp_exec_imm_stmt,0,\"");
	}
	RIScpp_generate_string(tp);
	fprintf(RIScpp_temp_file,"\",0,%d,%d,%d);\n", RIScpp_async_flag, clear_flag,
		RIS_STATIC_STMT);
	RIScpp_sqlerror_check();
	END_BRACE;
}

/******************************************************************************/
