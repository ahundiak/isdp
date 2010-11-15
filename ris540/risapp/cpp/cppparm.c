/* Do not alter this SPC information: $Revision: 1.1.58.1 $ */
/*
**	NAME:							cppparm.c
**	AUTHORS:						David Michal
**	CREATION DATE:					6/88
**	ABSTRACT:
**		
**	The functions that translate embedded ris statements into function
**	calls.
**	
**	REVISION HISTORY:
*/
 
/*
**	INCLUDES
*/
#include "ris_err.h"
#include "rismem.h"
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
#define cppparm_c
#include "comdebug.prt"
#include "comalloc.prt"
#include "comjmp.prt"
#if defined(WIN32)
#include "comhsrch.prt"
#endif
#include "cppparm.prt"
#include "cppvar.prt"
#include "sys.prt"


/******************************************************************************/

extern void RIScpp_make_parm_list(
	ristree * tp,
	parm_list_node ** parm_list,
	int * parm_count)
{
	ENTRY item;
	ENTRY * found_item;
	parm_list_node * temp;
	var_list_node * result;

CPP_DBG(("\nRIScpp_make_parm_list tp = %x parm_list = %x parm_count = %x\n",
 tp,parm_list,parm_count));

	if (tp)
	{
		if (tp->tok == RIS_TOK_VAR_NAME)
		{
			item.key = tp->info.val;
			if ((found_item = hsearch(item,FIND)) != 0) 
			{
				if ((result = RIScpp_find_var((int)found_item->data)) != 0)
				{
					if ((*parm_count)++)
					{
						temp = ALLOCTP(parm_list_node);
						temp->var = result;
						temp->var_pos = tp->pos;
						temp->next = *parm_list;
						*parm_list = temp;
					}
					else
					{
						*parm_list = ALLOCTP(parm_list_node);
						(*parm_list)->var = result;
						(*parm_list)->var_pos = tp->pos;
						(*parm_list)->next = 0;
					}
					if (tp->rhs)
					{
						item.key = tp->rhs->info.val;
						if ((found_item = hsearch(item,FIND)) != 0) 
						{
							if ((result = RIScpp_find_var((int)found_item->data)) != 0)
							{
								RIScpp_check_type(RIS_TOK_LONG,result,
								 tp->rhs->pos,0);
								(*parm_list)->ind_var = result;
							}
							else
							{
								CPP_ERR_RETURN(RIS_E_HOST_VAR_NOT_DEFINED,
								 tp->rhs->pos);
							}
						}
						else
						{
							CPP_ERR_RETURN(RIS_E_HOST_VAR_NOT_DEFINED,
							 tp->rhs->pos);
						}
					}
				}
				else
				{
					CPP_ERR_RETURN(RIS_E_HOST_VAR_NOT_DEFINED,tp->pos);
				}
			}
			else
			{
				CPP_ERR_RETURN(RIS_E_HOST_VAR_NOT_DEFINED,tp->pos);
			}
		}
		else
		{
			RIScpp_make_parm_list(tp->lhs,parm_list,parm_count);
			RIScpp_make_parm_list(tp->rhs,parm_list,parm_count);
		}
	}
}

/******************************************************************************/

extern void RIScpp_print_decl(
	parm_list_node * parm_list,
	int parm_count,
	char * var_name)
{

CPP_DBG(("\nRIScpp_print_decl parm_list = %x parm_count = %d var_name = %s\n",
 parm_list,parm_count,var_name));

	fprintf(RIScpp_temp_file,
	 "\tstatic sqlvar %s_sqlvar[%d] = {\n",var_name,parm_count);
	RIScpp_print_parm_list_init_rows(parm_list);
	fprintf(RIScpp_temp_file,"\t};\n");
	fprintf(RIScpp_temp_file,
	 "\tstatic sqlda %s_sqlda = {%d,%d,%s_sqlvar};\n",
	 var_name,parm_count,parm_count,var_name);
}

/******************************************************************************/

extern void RIScpp_print_assigns(
	parm_list_node * parm_list,
	int parm_count,
	char * var_name)
{
	int i;
	parm_list_node * temp;
	char * host_name;

CPP_DBG((
 "\nRIScpp_print_assigns parm_list = %x parm_count = %d var_name = %s\n",
 parm_list,parm_count,var_name));

	for (temp=parm_list,i=parm_count-1;i >= 0;i--,temp=temp->next)
	{
		if (temp->var->string)
		{
			host_name = temp->var->string;
		}
		else
		{
			host_name = temp->var->name;
		}
		if (RIScpp_list_to_type(temp->var->type) == RIS_TOK_CHAR 
		&& (temp->var->ptr || temp->var->array))
		{
			fprintf(RIScpp_temp_file,"\t%s_sqlvar[%d].sqldata = %s;\n",var_name,i,
			 host_name);
			if (temp->var->ptr)
			{
				fprintf(RIScpp_temp_file,
				 "\t%s_sqlvar[%d].sqllen = strlen(%s);\n",
				 var_name,i,host_name);
			}
		}
		else
		{
			fprintf(RIScpp_temp_file,"\t%s_sqlvar[%d].sqldata = (char *)&%s;\n",
			 var_name,i,host_name);
		}
		if (temp->ind_var)
		{
			if (temp->ind_var->string)
			{
				host_name = temp->ind_var->string;
			}
			else
			{
				host_name = temp->ind_var->name;
			}
			fprintf(RIScpp_temp_file,"\t%s_sqlvar[%d].sqlind = &%s;\n",var_name,i,
		 	 host_name);
		}
	}
}

/******************************************************************************/

extern void RIScpp_print_parm_list(
	parm_list_node * parm_list,
	int parm_count,
	char * var_name)
{

CPP_DBG((
 "\nRIScpp_print_parm_list parm_list = %x parm_count = %d var_name = %s\n",
 parm_list,parm_count,var_name));

	RIScpp_print_decl(parm_list,parm_count,var_name);
	RIScpp_print_assigns(parm_list,parm_count,var_name);
}

/******************************************************************************/

extern int RIScpp_c_to_ris_type(
	type_spec_list_node * type,
	int pos)
{

CPP_DBG(("\nRIScpp_c_to_ris_type type->spec_tok = %d pos = %d\n",type,pos));

		switch(RIScpp_list_to_type(type))
		{
			case RIS_TOK_SHORT:
				return(RIS_SMALLINT);

			case RIS_TOK_INT:
			case RIS_TOK_LONG:
				return(RIS_INTEGER);

			case RIS_TOK_FLOAT:
				return(RIS_REAL);

			case RIS_TOK_DOUBLE:
				return(RIS_DOUBLE);

			case RIS_TOK_CHAR:
				return(RIS_CHARACTER);

			case RIS_TOK_DATETIME:
				return(RIS_DATETIME);

			case RIS_TOK_RIS_TEXT:
				return(RIS_TEXT);

			case RIS_TOK_RIS_BLOB:
				return(RIS_BLOB);

			case RIS_TOK_UNSIGNED:
			case RIS_TOK_SIGNED:
			case RIS_TOK_VOLATILE:
			case RIS_TOK_CONST:
			case RIS_TOK_SQLDA:
			break;
			default:
				CPP_ERR_RETURN(RIS_E_UNSUPPORTED_TYPE,pos);
			break;
		}
	return(0);
}

/******************************************************************************/

extern int RIScpp_list_to_type(
	type_spec_list_node * type)
{
	type_spec_list_node * temp;

CPP_DBG(("\nRIScpp_list_to_type type = %x\n",type));

	for(temp=type; temp; temp=temp->next)
	{
		switch(temp->spec_tok)
		{
			case RIS_TOK_SHORT:
				return(RIS_TOK_SHORT);

			case RIS_TOK_INT:
				return(RIS_TOK_INT);

			case RIS_TOK_LONG:
				return(RIS_TOK_LONG);

			case RIS_TOK_FLOAT:
				return(RIS_TOK_FLOAT);

			case RIS_TOK_DOUBLE:
				return(RIS_TOK_DOUBLE);

			case RIS_TOK_CHAR:
				return(RIS_TOK_CHAR);

			case RIS_TOK_DATETIME:
				return(RIS_TOK_DATETIME);

			case RIS_TOK_RIS_BLOB:
				return(RIS_TOK_RIS_BLOB);

			case RIS_TOK_RIS_TEXT:
				return(RIS_TOK_RIS_TEXT);

			case RIS_TOK_UNSIGNED:
				return(RIS_TOK_UNSIGNED);

			case RIS_TOK_SIGNED:
				return(RIS_TOK_SIGNED);

			case RIS_TOK_VOLATILE:
				return(RIS_TOK_VOLATILE);

			case RIS_TOK_CONST:
				return(RIS_TOK_CONST);

			case RIS_TOK_SQLDA:
				return(RIS_TOK_SQLDA);
			default:
				CPP_ERR_RETURN(RIS_E_INTERNAL_ERROR,0);
		}
	}
	return(0);
}

/******************************************************************************/

extern void RIScpp_print_parm_list_init_rows(
	parm_list_node * temp)
{
	int indirect;
	int size;
	static int count = 0;

CPP_DBG(("\nRIScpp_print_parm_list_init_rows temp = %x\n",temp));

	if (temp)
	{
		count++;
		RIScpp_print_parm_list_init_rows(temp->next);
		count--;
		indirect = temp->var->ptr + temp->var->array;
		if ((RIScpp_list_to_type(temp->var->type) != RIS_TOK_CHAR 
		&& indirect) || (RIScpp_list_to_type(temp->var->type) == RIS_TOK_CHAR 
		&& indirect >= 2))
		{
			CPP_ERR_RETURN(RIS_E_UNSUPPORTED_PTR_ARRAY,temp->var_pos);
		}
		if (RIScpp_list_to_type(temp->var->type) == RIS_TOK_CHAR)
		{
			if (temp->var->ptr)
			{
				size = 0;
			}
			else if (temp->var->array)
			{
				size = temp->var->sizes[1];
			}
			else
			{
				size = -1;
			}
		}
		else
		{
			size = temp->var->sizes[0];
		}

		fprintf(RIScpp_temp_file,"\t\t{0,0,%d,%d,%d,0,{0,\"\"}}",
		 RIScpp_c_to_ris_type(temp->var->type,temp->var_pos),
		 temp->ind_var ? 1 : 0,size);

		if (count)
		{
			fprintf(RIScpp_temp_file,",\n");
		}
		else
		{
			fprintf(RIScpp_temp_file,"\n");
		}
	}
}

/******************************************************************************/
