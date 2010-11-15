/*
**	NAME:							cppslct.c
**	AUTHORS:						David Michal
**	CREATION DATE:					6/88
**	ABSTRACT:
**	The functions that translate embedded ris statements into function
**	calls.
**		
**	
**	REVISION HISTORY: Modified to incorporate 'tree to string' generation and
**				      and to 'avoid repreparing of static statements' by 
**					  Prasad Challa on 9/11/91
**
**                    10/21/91 sjb added async flag
*/
 
/*
**	INCLUDES
*/
#include "cpp.h"
#include "parser.h"

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
#define cppslct_c
#include "comdebug.prt"
#include "cppslct.prt"
#include "cpptrstr.prt"
#include "cppparm.prt"
#include "cppmisc.prt"
#include "sys.prt"
#if defined(DOS) || defined(WIN32) || defined(vms)
#include "partree.prt"
#endif

/******************************************************************************/

extern void RIScpp_select(
	ristree * tp)
{
	ristree * temp;
	int in_parm_count;
	int out_parm_count;
	parm_list_node * in_parm_list;
	parm_list_node * out_parm_list;

	CPP_DBG(("\nRIScpp_select tp = %x\n",tp));

	/* remove into clause from tree */

	temp = tp->rhs->lhs->rhs->lhs->rhs->rhs; /* LIST NODE having INTO */
	tp->rhs->lhs->rhs->lhs->rhs->rhs = tp->rhs->lhs->rhs->lhs->rhs->rhs->rhs;
	temp->rhs = 0;

    fprintf(RIScpp_temp_file,"{\n");

	in_parm_count = 0;
	RIScpp_make_parm_list(tp,&in_parm_list,&in_parm_count);
	if (in_parm_count)
	{
		RIScpp_print_decl(in_parm_list,in_parm_count,"in");
	}
	out_parm_count = 0;
	RIScpp_make_parm_list(temp,&out_parm_list,&out_parm_count);
	RIScpp_print_parm_list(out_parm_list,out_parm_count,"out");
	BEGIN_BRACE;
	if (in_parm_count)
	{
		fprintf(RIScpp_temp_file, "\tstatic short RIScpp_static_stmt = -1;\n");
		RIScpp_print_assigns(in_parm_list,in_parm_count,"in");
		if (RIScpp_async_id_name)
		{
			fprintf(RIScpp_temp_file,
				"RISint_select(&RIScpp_static_stmt,&%s,\"",
				RIScpp_async_id_name);
		}
		else
		{
			fprintf(RIScpp_temp_file,
				"RISint_select(&RIScpp_static_stmt,0,\"");
		}
		RIScpp_generate_string(tp);
		fprintf(RIScpp_temp_file,"\",&in_sqlda,&out_sqlda,%d);\n}\n",
			RIScpp_async_flag);
	}
	else
	{
		fprintf(RIScpp_temp_file, "\tstatic short RIScpp_static_stmt = -1;\n");
		if (RIScpp_async_id_name)
		{
			fprintf(RIScpp_temp_file,
				"RISint_select(&RIScpp_static_stmt,&%s,\"",
				RIScpp_async_id_name);
		}
		else
		{
			fprintf(RIScpp_temp_file,
				"RISint_select(&RIScpp_static_stmt,0,\"");
		}
		RIScpp_generate_string(tp);
		fprintf(RIScpp_temp_file,"\",0,&out_sqlda,%d);\n}\n",RIScpp_async_flag);
	}
	RIScpp_sqlerror_notfound_check();
	END_BRACE;
}

/******************************************************************************/
