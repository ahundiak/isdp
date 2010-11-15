/* Do not alter this SPC information: $Revision: 1.1.58.1 $ */
/*
**	NAME:							cppfetch.c
**	AUTHORS:						David Michal
**	CREATION DATE:					4/88
**	ABSTRACT:
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
#define cppfetch_c
#include "comdebug.prt"
#include "comwrap.prt"
#include "cppfetch.prt"
#include "cppcursr.prt"
#include "cppvar.prt"
#include "cppparm.prt"
#include "cppmisc.prt"
#include "sys.prt"

/******************************************************************************/

extern void RIScpp_fetch(
	ristree * tp)
{
	int out_parm_count;
	parm_list_node * out_parm_list;
	cursor_list_node * cursor;
	char * desc_name;
	var_list_node * desc;

CPP_DBG(("\nRIScpp_fetch tp = %x\n",tp));

	cursor = RIScpp_find_cursor_name(tp->rhs->lhs);
	BEGIN_BRACE;
	if (tp->rhs->rhs->lhs->rhs->tok == RIS_TOK_DESC_NAME)
	{
		if (RIScpp_async_id_name)
		{
			fprintf(RIScpp_temp_file, "RISint_fetch(RIScpp_stmt_id%d,&%s,",
				cursor->index, RIScpp_async_id_name);
		}
		else
		{
			fprintf(RIScpp_temp_file, "RISint_fetch(RIScpp_stmt_id%d,0,",
				cursor->index);
		}

		desc = RIScpp_find_var_name(tp->rhs->rhs->lhs->rhs,&desc_name);
		RIScpp_check_type(RIS_TOK_SQLDA,desc,tp->rhs->rhs->lhs->rhs->pos,0);
		if (desc->ptr+desc->array)
		{
			fprintf(RIScpp_temp_file, "%s,0,%d);\n", desc_name,
				RIScpp_async_flag);
		}
		else
		{
			fprintf(RIScpp_temp_file,"&%s,0,%d);\n", desc_name,
				RIScpp_async_flag);
		}
	}
	else
	{
		out_parm_count = 0;
		RIScpp_make_parm_list(tp,&out_parm_list,&out_parm_count);
		RIScom_fputs("{\n",RIScpp_temp_file);
		RIScpp_print_parm_list(out_parm_list, out_parm_count, "out");

		if (RIScpp_async_id_name)
		{
			fprintf(RIScpp_temp_file, "RISint_fetch(RIScpp_stmt_id%d,&%s,",
				cursor->index, RIScpp_async_id_name);
		}
		else
		{
			fprintf(RIScpp_temp_file, "RISint_fetch(RIScpp_stmt_id%d,0,",
				cursor->index);
		}

		fprintf(RIScpp_temp_file, "&out_sqlda,0,%d);\n}\n", RIScpp_async_flag);
	}
	RIScpp_sqlerror_notfound_check();
	END_BRACE;
}

/******************************************************************************/
