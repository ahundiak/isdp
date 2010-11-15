/* Do not alter this SPC information: $Revision: 1.1.58.1 $ */
/*
**	NAME:							cppexec.c
**	AUTHORS:						David Michal
**	CREATION DATE:					8/88
**	ABSTRACT:
**		
**	The functions that translate embedded execute statmenets into
**	function calls.
**	
**	REVISION HISTORY: Modified to avoid 'repreparing of static static stmts'
**                    by Prasad Challa on 9/16/91
**				
**					  10/21/91 sjb added async flag
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
#define cppexec_c
#include "comdebug.prt"
#include "comwrap.prt"
#include "cppexec.prt"
#include "cppstmid.prt"
#include "cppvar.prt"
#include "cppparm.prt"
#include "cppmisc.prt"
#include "cpptrstr.prt"
#include "sys.prt"

/******************************************************************************/

extern void RIScpp_exec(
	ristree * tp)
{
	parm_list_node * in_parm_list;
	int in_parm_count;
	stmt_id_list_node * stmt_id;
	char * desc_name;
	var_list_node * desc;

CPP_DBG(("\nRIScpp_exec tp = %x\n",tp));

	stmt_id = RIScpp_find_stmt_id_name(tp->rhs->lhs);
	BEGIN_BRACE;
	if (tp->rhs->rhs)
	{
		if (tp->rhs->rhs->lhs->rhs->tok == RIS_TOK_DESC_NAME)
		{
			if (RIScpp_async_id_name)
			{
				fprintf(RIScpp_temp_file,
					"RISint_execute(&RIScpp_stmt_id%d,&%s,", stmt_id->index,
					RIScpp_async_id_name);
			}
			else
			{
				fprintf(RIScpp_temp_file,
					"RISint_execute(&RIScpp_stmt_id%d,0,", stmt_id->index);
			}

			desc = RIScpp_find_var_name(tp->rhs->rhs->lhs->rhs,&desc_name);
			RIScpp_check_type(RIS_TOK_SQLDA,desc,tp->rhs->rhs->lhs->rhs->pos,0);
			if (desc->ptr+desc->array)
			{
				fprintf(RIScpp_temp_file, "%s,%d,%d,%d);\n", desc_name,
					RIScpp_async_flag, RIS_DONT_CLEAR_FLAG, RIS_DYNAMIC_STMT);
			}
			else
			{
				fprintf(RIScpp_temp_file, "&%s,%d,%d,%d);\n", 
					desc_name, RIScpp_async_flag, RIS_DONT_CLEAR_FLAG,
					RIS_DYNAMIC_STMT);
			}
		}
		else
		{
			in_parm_count = 0;
			RIScpp_make_parm_list(tp,&in_parm_list,&in_parm_count);
			RIScom_fputs("{\n",RIScpp_temp_file);
			RIScpp_print_parm_list(in_parm_list,in_parm_count,"in");
			if (RIScpp_async_id_name)
			{
				fprintf(RIScpp_temp_file,
					"RISint_execute(&RIScpp_stmt_id%d,&%s,", stmt_id->index,
					RIScpp_async_id_name);
			}
			else
			{
				fprintf(RIScpp_temp_file,
					"RISint_execute(&RIScpp_stmt_id%d,0,", stmt_id->index);
			}
			fprintf(RIScpp_temp_file, "&in_sqlda,%d,%d,%d);\n}\n",
				RIScpp_async_flag, RIS_DONT_CLEAR_FLAG, RIS_DYNAMIC_STMT);
		}
	}
	else
	{
		if (RIScpp_async_id_name)
		{
			fprintf(RIScpp_temp_file,
				"RISint_execute(&RIScpp_stmt_id%d,&%s,", stmt_id->index,
				RIScpp_async_id_name);
		}
		else
		{
			fprintf(RIScpp_temp_file,
				"RISint_execute(&RIScpp_stmt_id%d,0,", stmt_id->index);
		}
		fprintf(RIScpp_temp_file,
			"0,%d,%d,%d);\n", RIScpp_async_flag, RIS_DONT_CLEAR_FLAG,
			RIS_DYNAMIC_STMT);
	}
	RIScpp_sqlerror_notfound_check();
	END_BRACE;
}

/******************************************************************************/

/* Called by user directly therefore dynamic stmt */
extern void RIScpp_exec_imm(
	ristree * tp)
{
	char * str_name;
	var_list_node * str_var;

CPP_DBG(("\nRIScpp_exec_imm tp = %x\n",tp));

	BEGIN_BRACE;
	fprintf(RIScpp_temp_file,"static short RIScpp_exec_imm_stmt = -1;\n");
	if (RIScpp_async_id_name)
	{
		fprintf(RIScpp_temp_file,
			"RISint_execute_immediate(&RIScpp_exec_imm_stmt,&%s,",
			RIScpp_async_id_name);
	}
	else
	{
		fprintf(RIScpp_temp_file,
			"RISint_execute_immediate(&RIScpp_exec_imm_stmt,0,");
	}
	if (tp->rhs->lhs->tok == RIS_TOK_C_CHAR_STR_LIT)
	{
        /* undo quote translation done by lex */
        tp->rhs->lhs->info.val[0] = '"';
        tp->rhs->lhs->info.val[strlen(tp->rhs->lhs->info.val)-1]='"';
		RIScpp_generate_string(tp->rhs->lhs);
		fprintf(RIScpp_temp_file,",0,%d,%d,%d);\n", RIScpp_async_flag,
			RIS_CLEAR_FLAG, RIS_DYNAMIC_STMT);
	}
	else
	{
		str_var = RIScpp_find_var_name(tp->rhs->lhs,&str_name);
		RIScpp_check_type(RIS_TOK_CHAR,str_var,tp->rhs->lhs->pos,0);
		fprintf(RIScpp_temp_file, "%s,0,%d,%d,%d);\n", str_name,
			RIScpp_async_flag, RIS_CLEAR_FLAG, RIS_DYNAMIC_STMT);
	}
	RIScpp_sqlerror_notfound_check();
	END_BRACE;
}

/******************************************************************************/
