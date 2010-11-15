/* Do not alter this SPC information: $Revision: 1.1.58.1 $ */
/*
**	NAME:							cppvar.c
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
#include "riscom.h"
#include "rismem.h"
#include "ris_err.h"
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
#define cppvar_c
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

extern void RIScpp_add_var(
	ristree * type,
	ristree * var,
	char * string)
{
	ENTRY * found_item;
	var_list_node * temp;
	ENTRY item;
	ristree * tp;
	int ptr = 0;
	int array = 0;
	int i;
	type_spec_list_node *p; 

CPP_DBG(("\nRIScpp_add_var type = %x var = %x string = %x\n",type,var,string));

	if (var->rhs->lhs->tok == RIS_TOK_STAR_LIST)
	{
		for (tp=var->rhs->lhs->rhs;tp;tp=tp->rhs)
		{
			ptr++;
		}
		var->rhs = var->rhs->rhs;
	}
CPP_DBG(("host ident = %s\n",var->rhs->lhs->info.val));

	item.key = var->rhs->lhs->info.val;
	if ((found_item = hsearch(item,FIND)) == 0)
	{
		temp = ALLOCTP(var_list_node);
		temp->ident = RIScpp_ident_num;
		temp->name = var->rhs->lhs->info.val;
		temp->string = string;
		temp->type=NULL;
		for(tp=type->rhs;tp;tp=tp->rhs)
		{
			p = temp->type;
			temp->type = ALLOCTP(type_spec_list_node);
			temp->type->spec_tok=tp->lhs->tok;
			temp->type->next = p;
		}
		temp->ptr = ptr;
		if (var->rhs->rhs)
		{
			for (tp=var->rhs->rhs->lhs->rhs;tp;tp=tp->rhs)
			{
				array++;
			}
		}
		temp->array = array;
		temp->sizes = ALLOCNP(int, array+1);
		temp->sizes[0] = RIScpp_size(RIScpp_list_to_type(temp->type));
		if (array)
		{
			for (tp=var->rhs->rhs->lhs->rhs,i=1;tp;tp=tp->rhs,i++)
			{
				temp->sizes[i] = atoi(tp->lhs->info.val);
			}
		}
		temp->next = RIScpp_scope_stack->var_list;
		RIScpp_scope_stack->var_list = temp;
		item.data = (char *)RIScpp_ident_num++;
		if (!hsearch(item,ENTER))
		{
			CPP_ERR_RETURN(RIS_E_VAR_IN_HASH_ERROR,var->rhs->lhs->pos);
		}
	}
	else
	{
		if (RIScpp_find_var_in_scope((int)found_item->data,RIScpp_scope_stack))
		{
			CPP_ERR_RETURN(RIS_E_VAR_ALREADY_DEFINED,var->rhs->lhs->pos);
		}
		else
		{
			temp = ALLOCTP(var_list_node);
			temp->ident = (int)found_item->data;
			temp->name = var->rhs->lhs->info.val;
			temp->string = string;
			temp->type=NULL;
			for(tp=type->rhs;tp;tp=tp->rhs)
			{
				p = temp->type;
				temp->type = ALLOCTP(type_spec_list_node);
				temp->type->spec_tok=tp->lhs->tok;
				temp->type->next = p;
			}
			temp->ptr = ptr;
			if (var->rhs->rhs)
			{
				for (tp=var->rhs->rhs->lhs->rhs;tp;tp=tp->rhs)
				{
					array++;
				}
			}
			temp->array = array;
			temp->sizes = ALLOCNP(int, array+1);
			temp->sizes[0] = RIScpp_size(RIScpp_list_to_type(temp->type));
			if (array)
			{
				for (tp=var->rhs->rhs->lhs->rhs,i=1;tp;tp=tp->rhs,i++)
				{
					temp->sizes[i] = atoi(tp->lhs->info.val);
				}
			}
			temp->next = RIScpp_scope_stack->var_list;
			RIScpp_scope_stack->var_list = temp;
		}
	}
}

/******************************************************************************/

extern var_list_node * RIScpp_find_var(
	int ident)
{
	scope_stack_node * temp;
	var_list_node * result;

CPP_DBG(("\nRIScpp_find_var ident = %d\n",ident));

	for(temp=RIScpp_scope_stack;temp;temp=temp->next)
	{
		if ((result = RIScpp_find_var_in_scope(ident,temp)) != 0)
		{
			return(result);
		}
	}
	return(0);
}

/******************************************************************************/

extern var_list_node * RIScpp_find_var_in_scope(
	int ident,
	scope_stack_node * scope)
{
	var_list_node * temp;

CPP_DBG(("\nRIScpp_find_var_in_scope ident = %d scope = %x\n",ident,scope));

	for(temp=scope->var_list;temp;temp=temp->next)
	{
		if (temp->ident == ident)
		{
			return(temp);
		}
	}
	return(0);
}

/******************************************************************************/

extern int RIScpp_size(
	int tok)
{

CPP_DBG(("\nRIScpp_size tok = %d\n",tok));

    switch(tok)
    {
		case RIS_TOK_CHAR:
			return(sizeof(char));
        case RIS_TOK_SHORT:
			return(sizeof(short));
        case RIS_TOK_INT:
			return(sizeof(int));
        case RIS_TOK_LONG:
			return(sizeof(long));
        case RIS_TOK_UNSIGNED:
			return(sizeof(unsigned));
        case RIS_TOK_FLOAT:
			return(sizeof(float));
        case RIS_TOK_DOUBLE:
			return(sizeof(double));
		case RIS_TOK_SQLDA:
			return(sizeof(sqlda));
		case RIS_TOK_DATETIME:
			return(sizeof(dtime));
		case RIS_TOK_SIGNED:
			return(sizeof(signed));
		case RIS_TOK_VOLATILE:
			return(sizeof(volatile));
		case RIS_TOK_CONST:
			return(sizeof(const));
		case RIS_TOK_RIS_BLOB:
			return(sizeof(ris_blob));
		case RIS_TOK_RIS_TEXT:
			return(sizeof(ris_text));
        default:
			CPP_ERR_RETURN(RIS_E_INTERNAL_ERROR,0);
    }

/* make the compiler happy */

	return 0;
}

/******************************************************************************/

extern void RIScpp_check_type(
	int type,
	var_list_node * var,
	int pos,
	int ptr_only)
{

CPP_DBG(("\nRIScpp_check_type type = %d var = %x pos = %d ptr_only = %d\n",
 type,var,pos,ptr_only));

	switch(type)
	{
		case RIS_TOK_CHAR:
			if (type != var->type->spec_tok || var->array+var->ptr != 1 ||
			 (ptr_only && var->array))
			{
				CPP_ERR_RETURN(RIS_E_INVALID_HOST_VAR_TYPE,pos);
			}
		break;
		case RIS_TOK_SQLDA:
			if (type != var->type->spec_tok|| var->array+var->ptr > 1)
			{
				CPP_ERR_RETURN(RIS_E_INVALID_HOST_VAR_TYPE,pos);
			}
		break;
		case RIS_TOK_LONG:
		case RIS_TOK_INT:
			if ((var->type->spec_tok != RIS_TOK_LONG && var->type->spec_tok != RIS_TOK_INT) || 
			 var->array+var->ptr != 0)
			{
				CPP_ERR_RETURN(RIS_E_INVALID_HOST_VAR_TYPE,pos);
			}
		break;
		default:
			CPP_ERR_RETURN(RIS_E_INTERNAL_ERROR,pos);
		break;
	}
}

/******************************************************************************/

extern var_list_node * RIScpp_find_var_name(
	ristree * tp,
	char ** var_name)
{
	ENTRY item;
	ENTRY * found_item;
	var_list_node * result = 0;

CPP_DBG(("\nRIScpp_find_var_name tp = %x var_name = %x\n",tp,var_name));

	item.key = tp->info.val;
	if ((found_item = hsearch(item,FIND)) != 0) 
	{
		if ((result = RIScpp_find_var((int)found_item->data)) != 0)
		{
			if (result->string)
			{
				*var_name = result->string;
			}
			else
			{
				*var_name = result->name;
			}
		}
		else
		{
			*var_name = "";
			CPP_ERR_RETURN(RIS_E_HOST_VAR_NOT_DEFINED,tp->pos);
		}
	}
	else
	{
		*var_name = "";
		CPP_ERR_RETURN(RIS_E_HOST_VAR_NOT_DEFINED,tp->pos);
	}
	return(result);
}

/******************************************************************************/
