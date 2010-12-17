/* Do not alter this SPC information: $Revision: 1.1.58.1 $ */
/*
**	NAME:							cpptrans.c
**	AUTHORS:						David Michal
**	CREATION DATE:					6/88
**	ABSTRACT:
**		
**	The functions that translate embedded ris statements into function
**	calls.
**	
**	REVISION HISTORY:
**		10/18/92 sjb added async flag and test/wait function calls
*/
 
/*
**	INCLUDES
*/
#include "risflags.h"
#include "risapp.h"
#include "risasync.h"
#include "ris_err.h"
#include "cpp.h"

/*
**	DEFINES
*/

/*
**	VARIABLES
*/
macro_list_node * ptr;
macro_list_node * pptr;

/*
**	FUNCTIONS
*/

/*
**      FUNCTION PROTOTYPES
*/
#define cpptrans_c
#include "comdebug.prt"
#include "comwrap.prt"
#include "comjmp.prt"
#include "cppmacro.prt"
#include "cppvar.prt"
#include "cppclear.prt"
#include "cppclose.prt"
#include "cppdecl.prt"
#include "cppdesc.prt"
#include "cpperror.prt"
#include "cppexec.prt"
#include "cppfetch.prt"
#include "cppmisc.prt"
#include "cpptest.prt"
#include "cpptrans.prt"
#include "cpptrstr.prt"
#include "cppopen.prt"
#include "cppprep.prt"
#include "cpprprt.prt"
#include "cppslct.prt"
#include "cppsqlst.prt"
#include "cppupdte.prt"
#include "pardrive.prt"
#include "sys.prt"

/******************************************************************************/

extern ristree * RIScpp_translate_stmt(
	int offset,
	int begin_flag,
	char * query_buf,
	int line_num,
	char * in_name)
{
	ristree * tp; 
	ristree * temp;
	ristree * temp1;
	int status;
	int typespec[40];
	int i=0;
	macro_list_node * macro_name;
	int p;
	int q;

	CPP_DBG(("RIScpp_translate_stmt(offset:%d begin_flag:%d query:<%s> line_num:%d in_name:%s\n", 
			offset,begin_flag,STRING(query_buf),line_num,STRING(in_name)));

	tp = 0;
    status = SETJMP();
    if (status)
    {
		RESETJMP();
        RIScpp_err_return(status,query_buf,RIS_ERRPOS,
        in_name,line_num);
		return(tp);
    }
	memset(query_buf,' ',offset);
	RIScpp_fix_string(query_buf);

	CPP_DBG(("Parsing sql stmt ...\n"));
	tp = RISpar_driver(query_buf,0,0,RIScpp_macro_list, 0);
	CPP_DBG(("Done parsing sql stmt.\n"));

	/*
	*  if first keyword is 'async', set flag and continue..
	*/
	if ( tp->tok == RIS_TOK_ASYNC )
	{
		var_list_node	*id;

		RIScpp_async_flag = ASYNC_START_MODE;
		id = RIScpp_find_var_name(tp->lhs, &RIScpp_async_id_name);
		RIScpp_check_type(RIS_TOK_INT, id, tp->lhs->pos, 0);

		tp = tp->rhs;
	}
	else
	{
		RIScpp_async_flag = SYNC_MODE;
		RIScpp_async_id_name = NULL;
	}

	switch(tp->tok)

	{
		case RIS_TOK_WHENEVER:
			if (tp->rhs->lhs->tok == RIS_TOK_SQLERROR)
			{
				if (tp->rhs->rhs->lhs->tok == RIS_TOK_GOTO)
				{
					RIScpp_sqlerror_targ = tp->rhs->rhs->lhs->rhs->info.val;
				}
				else
				{
					RIScpp_sqlerror_targ = 0;
				}
			}
			else
			{
				if (tp->rhs->rhs->lhs->tok == RIS_TOK_GOTO)
				{
					RIScpp_notfound_targ = tp->rhs->rhs->lhs->rhs->info.val;
				}
				else
				{
					RIScpp_notfound_targ = 0;
				}
			}
		break;
		case RIS_TOK_SELECT:
			RIScpp_select(tp);
		break;
		case RIS_TOK_DECLARE:
			RIScpp_decl(tp);
		break;
		case RIS_TOK_FETCH:
			RIScpp_fetch(tp);
		break;
		case RIS_TOK_OPEN:
			RIScpp_open(tp);
		break;
		case RIS_TOK_REPORT_ERROR:
			RIScpp_report(tp);
		break;
		case RIS_TOK_REPORT_SS_ERROR:
			RIScpp_report_superschema(tp);
		break;
		case RIS_TOK_CLEAR:
			RIScpp_clear(tp);
		break;
		case RIS_TOK_VIRTUAL:
			if (!begin_flag)
			{
				begin_flag = 1;
				RIScpp_err_return(RIS_E_MISSING_BEGIN_DECLARE,query_buf,
				 tp->pos,in_name,line_num);
			}
			RIScpp_add_var(tp->rhs->lhs,tp->rhs->rhs->lhs,
				 tp->rhs->rhs->rhs->lhs->info.val);
		break;
		case RIS_TOK_HOST_VAR_DEF:
			if(!begin_flag)
			{
				begin_flag = 1;
				RIScpp_err_return(RIS_E_MISSING_BEGIN_DECLARE,query_buf,
				 tp->pos,in_name,line_num);
			}
			/*to check if storage class is existing or not*/
			if(tp->rhs->lhs->tok==RIS_TOK_HOST_TYPE_SPEC_LIST)
			{
				temp1=tp->rhs->lhs->rhs;
			}
			else
			{
				temp1=tp->rhs->rhs->lhs->rhs;
			}
			for(;temp1;temp1=temp1->rhs)
			{
				typespec[i]=temp1->lhs->tok;
				i++;
			}

			for(p=0;p<i-1;p++)
			{
				for(q=p+1;q<i;q++)
				{	
					if (typespec[p] == typespec[q])
					{
						RIScpp_err_return(RIS_E_INV_HOST_TYPE_SPEC_LIST,query_buf,
				 		tp->pos,in_name,line_num);
					}
				    else if(typespec[p]==RIS_TOK_INT)
					{
						if( (typespec[q]==RIS_TOK_FLOAT) || 
						(typespec[q]==RIS_TOK_CHAR) || 
						(typespec[q]==RIS_TOK_DOUBLE) )
						{
							RIScpp_err_return(RIS_E_INV_HOST_TYPE_SPEC_LIST,query_buf, 
							tp->pos,in_name,line_num);
						}
					}
				    else if( (typespec[p]==RIS_TOK_CHAR))
					{
						if((typespec[q]==RIS_TOK_INT ) || 
						(typespec[q]==RIS_TOK_SHORT) || 
						(typespec[q]==RIS_TOK_FLOAT) || 
						(typespec[q]==RIS_TOK_LONG ) || 
						(typespec[q]==RIS_TOK_DOUBLE) )
						{
							RIScpp_err_return(RIS_E_INV_HOST_TYPE_SPEC_LIST,query_buf,
				 			tp->pos,in_name,line_num);
						}
					}
				    else if( (typespec[p]==RIS_TOK_SHORT))
					{
						if((typespec[q]==RIS_TOK_CHAR) || 
						(typespec[q]==RIS_TOK_FLOAT) || 
						(typespec[q]==RIS_TOK_LONG) || 
						(typespec[q]==RIS_TOK_DOUBLE) )
						{
							RIScpp_err_return(RIS_E_INV_HOST_TYPE_SPEC_LIST,query_buf,
				 			tp->pos,in_name,line_num);
						}
					}
				    else if( (typespec[p]== RIS_TOK_LONG))
					{
						if((typespec[q]==RIS_TOK_CHAR ) || 
						(typespec[q]==RIS_TOK_SHORT ) )
						{
							RIScpp_err_return(RIS_E_INV_HOST_TYPE_SPEC_LIST,query_buf,
				 			tp->pos,in_name,line_num);
						}
					}
				    else if( (typespec[p]==RIS_TOK_SIGNED ) || 
					(typespec[p]==RIS_TOK_UNSIGNED ))
					{
						if((typespec[q]== RIS_TOK_FLOAT) || 
						(typespec[q]==RIS_TOK_SIGNED) || 
						(typespec[q]==RIS_TOK_UNSIGNED) || 
						(typespec[q]==RIS_TOK_DOUBLE) )
						{
							RIScpp_err_return(RIS_E_INV_HOST_TYPE_SPEC_LIST,query_buf,
				 			tp->pos,in_name,line_num);
						}
					}
				    else if((typespec[p]==RIS_TOK_FLOAT) || 
					(typespec[p]==RIS_TOK_DOUBLE))
					{
						if((typespec[q]== RIS_TOK_FLOAT) || 
						(typespec[q]== RIS_TOK_SIGNED) || 
						(typespec[q]== RIS_TOK_UNSIGNED) || 
						(typespec[q]==RIS_TOK_SHORT) || 
						(typespec[q]== RIS_TOK_INT) || 
						(typespec[q]==RIS_TOK_CHAR) || 
						(typespec[q]== RIS_TOK_DOUBLE) )
						{
							RIScpp_err_return(RIS_E_INV_HOST_TYPE_SPEC_LIST,query_buf,
				 			tp->pos,in_name,line_num);
						}
					}
				}
			}
			fprintf(RIScpp_temp_file,"\n");
			RIScpp_generate_string(tp);
			fprintf(RIScpp_temp_file,";\n");
			/*if host storage is class is existing*/ 
			if(tp->rhs->lhs->tok!=RIS_TOK_HOST_TYPE_SPEC_LIST)
			{
				for (temp=tp->rhs->rhs->rhs->lhs->rhs;temp;temp=temp->rhs)
				{
					RIScpp_add_var(tp->rhs->rhs->lhs,temp->lhs,0);
				}
			}
			else
			{
				for (temp=tp->rhs->rhs->lhs->rhs;temp;temp=temp->rhs)
				{
					RIScpp_add_var(tp->rhs->lhs,temp->lhs,0);
				}
			}
		break;
		case RIS_TOK_END_DECLARE:
			if (!begin_flag)
			{
				RIScpp_err_return(RIS_E_MISSING_BEGIN_DECLARE,query_buf,
				 tp->pos,in_name,line_num);
			}
		break;
		case RIS_TOK_CLOSE:
			RIScpp_close(tp);
		break;
		case RIS_TOK_BEGIN_DECLARE:
		case RIS_TOK_INCLUDE:
		case RIS_TOK_IFDEF:
		case RIS_TOK_IFNDEF:
		case RIS_TOK_ELSE:
		case RIS_TOK_ENDIF:
		break;
		case RIS_TOK_DEFINE:
			RIScpp_add_macro(tp);
			RIScpp_generate_string(tp);
			RIScom_fputs("\n", RIScpp_temp_file);
		break; 
		case RIS_TOK_UNDEF:
			 if((macro_name=RIScpp_find_macro_name(tp, RIS_TOK_UNDEF)) != 0)
			 {
				for(pptr = NULL, ptr = RIScpp_macro_list; ptr != NULL; ptr=ptr->next)
				{
					if(!strcmp(ptr->name,tp->rhs->lhs->info.val))
					{
						if (pptr == NULL)
							RIScpp_macro_list = ptr->next;
						else
							pptr->next = ptr->next;
							break;
					}
					else
						pptr = ptr;
			    }
		     }
			RIScpp_generate_string(tp);
			RIScom_fputs("\n", RIScpp_temp_file);
		break; 
		case RIS_TOK_CREATE_TABLE:
		case RIS_TOK_ALTER_TABLE:
		case RIS_TOK_DROP_TABLE:
		case RIS_TOK_DECLARE_TABLE:
		case RIS_TOK_UNDECLARE_TABLE:
		case RIS_TOK_CREATE_VIEW:
		case RIS_TOK_DROP_VIEW:
		case RIS_TOK_DECLARE_VIEW:
		case RIS_TOK_UNDECLARE_VIEW:
		case RIS_TOK_CREATE_INDEX:
		case RIS_TOK_DROP_INDEX:
		case RIS_TOK_CREATE_SCHEMA:
		case RIS_TOK_ALTER_SCHEMA:
		case RIS_TOK_DROP_SCHEMA:
		case RIS_TOK_DECLARE_SUPERSCHEMA:
		case RIS_TOK_UNDECLARE_SUPERSCHEMA:
		case RIS_TOK_REDECLARE_SUPERSCHEMA:
		case RIS_TOK_GRANT_ON_TABLE:
		case RIS_TOK_REVOKE_ON_TABLE:
		case RIS_TOK_SET:
		case RIS_TOK_OPEN_SCHEMA:
		case RIS_TOK_CLOSE_SCHEMA:
		case RIS_TOK_DEBUG:
		case RIS_TOK_EXEC:
		case RIS_TOK_GRANT_SCHEMA:
		case RIS_TOK_GRANT_CONNECT:
		case RIS_TOK_GRANT_RESOURCE:
		case RIS_TOK_REVOKE_SCHEMA:
		case RIS_TOK_REVOKE_CONNECT:
		case RIS_TOK_REVOKE_RESOURCE:
		case RIS_TOK_DECLARE_SCHEMA:
			RIScpp_sql_stmt(tp,RIS_CLEAR_FLAG);
		break;
		case RIS_TOK_COMMIT:
		case RIS_TOK_ROLLBACK:
		case RIS_TOK_LOCK_TABLES:
		case RIS_TOK_DEFAULT_SCHEMA:
			RIScpp_sql_stmt(tp,RIS_DONT_CLEAR_FLAG);
		break;
		case RIS_TOK_UPDATE:
		case RIS_TOK_DELETE:
		case RIS_TOK_INSERT:
			RIScpp_update(tp);
		break;
		case RIS_TOK_EXECUTE:
			RIScpp_exec(tp);
		break;
		case RIS_TOK_EXECUTE_IMMEDIATE:
			RIScpp_exec_imm(tp);
		break;
		case RIS_TOK_DESCRIBE_INPUT:
		case RIS_TOK_DESCRIBE_OUTPUT:
			RIScpp_desc(tp);
		break;
		case RIS_TOK_PREPARE:
			RIScpp_prep(tp);
		break;
		case RIS_TOK_TEST:
		case RIS_TOK_WAIT:
			RIScpp_test_completion(tp);
		break;
		default:
			CPP_ERR_RETURN(RIS_E_INTERNAL_ERROR,tp->pos);
		break;
	}
	RESETJMP();
	return(tp);
}

/******************************************************************************/
