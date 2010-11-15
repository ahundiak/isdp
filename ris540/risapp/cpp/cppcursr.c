/* Do not alter this SPC information: $Revision: 1.1.58.1 $ */
/*
**	NAME:							cppcursr.c
**	AUTHORS:						David Michal
**	CREATION DATE:					6/88
**	ABSTRACT:
**	The functions that translate embedded ris statements into function
**	calls.
**		
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
#define cppcursr_c
#include "comalloc.prt"
#include "comdebug.prt"
#include "comjmp.prt"
#include "cppcursr.prt"
#include "comhsrch.prt"


/******************************************************************************/

extern void RIScpp_add_cursor(
	ristree * tp,
	stmt_id_list_node * stmt_id,
	parm_list_node * in_parm_list,
	int in_parm_count)
{
	ENTRY * found_item;
	cursor_list_node * temp;
	ENTRY item;

CPP_DBG((
"\nRIScpp_add_cursor tp = %x stmt_id = %x in_parm_list = %x in_parm_count = %d\n",
tp,stmt_id,in_parm_list,in_parm_count));

CPP_DBG(("cursor name = %s\n",tp->rhs->lhs->info.val));

	item.key = tp->rhs->lhs->info.val;
	if ((found_item = hsearch(item,FIND)) == 0)
	{
		temp = ALLOCTP(cursor_list_node);
		temp->ident = RIScpp_ident_num;
		temp->name = item.key;
		if (stmt_id)
		{
			temp->index = stmt_id->index;
		}
		else
		{
			temp->index = RIScpp_stmt_index++;
		}
		temp->in_parm_count = in_parm_count;
		temp->in_parm_list = in_parm_list;
		temp->next = RIScpp_cursor_list;
		RIScpp_cursor_list = temp;
		item.data = (char *)RIScpp_ident_num++;
		if (!hsearch(item,ENTER))
		{
			CPP_ERR_RETURN(RIS_E_CURSOR_IN_HASH_ERROR,tp->rhs->lhs->pos);
		}
	}
	else
	{
		if (RIScpp_find_cursor_ident((int)found_item->data))
		{
			CPP_ERR_RETURN(RIS_E_CURSOR_ALREADY_DEFINED,tp->rhs->lhs->pos);
		}
		else
		{
			temp = ALLOCTP(cursor_list_node);
			temp->ident = (int)found_item->data;
			temp->name = item.key;
			if (stmt_id)
			{
				temp->index = stmt_id->index;
			}
			else
			{
				temp->index = RIScpp_stmt_index++;
			}
			temp->in_parm_count = in_parm_count;
			temp->in_parm_list = in_parm_list;
			temp->next = RIScpp_cursor_list;
			RIScpp_cursor_list = temp;
		}
	}
}

/******************************************************************************/

extern cursor_list_node * RIScpp_find_cursor_name(
	ristree * name)
{
	ENTRY item;
	ENTRY * found_item;
	cursor_list_node * result = 0;

CPP_DBG(("\nRIScpp_find_cursor name = %x\n",name));

	item.key = name->info.val;
	if ((found_item = hsearch(item,FIND)) != 0)
	{
		if ((result=RIScpp_find_cursor_ident((int)found_item->data)) == 0)
		{
			CPP_ERR_RETURN(RIS_E_CURSOR_NOT_DEFINED,name->pos);
		}
	}
	else
	{
		CPP_ERR_RETURN(RIS_E_CURSOR_NOT_DEFINED,name->pos);
	}
	return(result);
}

/******************************************************************************/

extern cursor_list_node * RIScpp_find_cursor_ident(
	int ident)
{
	cursor_list_node * temp;

CPP_DBG(("\nRIScpp_find_cursor_ident ident = %d\n",ident));

	for(temp=RIScpp_cursor_list;temp;temp=temp->next)
	{
		if (temp->ident == ident)
		{
			return(temp);
		}
	}
	return(0);
}

/******************************************************************************/
