/* Do not alter this SPC information: $Revision: 1.1.58.1 $ */
/*
**	NAME:							cppstmid.c
**	AUTHORS:						David Michal
**	CREATION DATE:					8/88
**	ABSTRACT:
**		
**	The functions that handle statement identifiers.
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
#define cppstmid_c
#include "comdebug.prt"
#include "comalloc.prt"
#if defined(WIN32)
#include "comhsrch.prt"
#endif
#include "comjmp.prt"
#include "cppstmid.prt"
#include "sys.prt"

/******************************************************************************/

extern void RIScpp_add_stmt_id(
	ristree * tp)
{
	ENTRY * found_item;
	stmt_id_list_node * temp;
	ENTRY item;

CPP_DBG(("\nRIScpp_add_stmt_id tp = %x\n",tp));

CPP_DBG(("stmt id = %s\n",tp->rhs->lhs->info.val));

	item.key = tp->rhs->lhs->info.val;
	if ((found_item = hsearch(item,FIND)) == 0)
	{
		temp = ALLOCTP(stmt_id_list_node);
		temp->ident = RIScpp_ident_num;
		temp->name = item.key;
		temp->index = RIScpp_stmt_index++;
		temp->next = RIScpp_stmt_id_list;
		RIScpp_stmt_id_list = temp;
		item.data = (char *)RIScpp_ident_num++;
		if (!hsearch(item,ENTER))
		{
			CPP_ERR_RETURN(RIS_E_STMT_ID_IN_HASH_ERROR,tp->rhs->lhs->pos);
		}
	}
	else
	{
		if (RIScpp_find_stmt_id_ident((int)found_item->data))
		{
			CPP_ERR_RETURN(RIS_E_STMT_ID_ALREADY_DEFINED,tp->rhs->lhs->pos);
		}
		else
		{
			temp = ALLOCTP(stmt_id_list_node);
			temp->ident = (int)found_item->data;
			temp->name = item.key;
			temp->index = RIScpp_stmt_index++;
			temp->next = RIScpp_stmt_id_list;
			RIScpp_stmt_id_list = temp;
		}
	}
}

/******************************************************************************/

extern stmt_id_list_node * RIScpp_find_stmt_id_name(
	ristree * name)
{
	ENTRY item;
	ENTRY * found_item;
	stmt_id_list_node * result = 0;

CPP_DBG(("\nRIScpp_find_stmt_id name = %x\n",name));

	item.key = name->info.val;
	if ((found_item = hsearch(item,FIND)) != 0)
	{
		if ((result=RIScpp_find_stmt_id_ident((int)found_item->data)) == 0)
		{
			CPP_ERR_RETURN(RIS_E_STMT_ID_NOT_DEFINED,name->pos);
		}
	}
	else
	{
		CPP_ERR_RETURN(RIS_E_STMT_ID_NOT_DEFINED,name->pos);
	}
	return(result);
}

/******************************************************************************/

extern stmt_id_list_node * RIScpp_find_stmt_id_ident(
	int ident)
{
	stmt_id_list_node * temp;

CPP_DBG(("\nRIScpp_find_stmt_id_ident ident = %d\n",ident));

	for(temp=RIScpp_stmt_id_list;temp;temp=temp->next)
	{
		if (temp->ident == ident)
		{
			return(temp);
		}
	}
	return(0);
}

/******************************************************************************/
