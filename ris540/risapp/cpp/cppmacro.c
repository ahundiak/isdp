/* Do not alter this SPC information: $Revision: 1.1.58.1 $ */
/*
**	NAME:							cppmacro.c
**	AUTHORS:						Prasad Challa
**	CREATION DATE:					6/91
**	ABSTRACT:
**		
**    The functions  that handle macros.
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
#define cppmacro_c
#include "comalloc.prt"
#include "comdebug.prt"
#include "comjmp.prt"
#include "comhsrch.prt"
#include "cppmacro.prt"
#include "sys.prt"


/******************************************************************************/


extern void RIScpp_add_macro(
	ristree * tp)
{
	macro_list_node * temp;
	ENTRY * found_item;
	ENTRY item;
	int len;

CPP_DBG(("macro name = %s\n",tp->rhs->lhs->info.val));

	len = strlen (tp->rhs->lhs->info.val);

	if (len > RIS_CPP_MAX_MACRO_LEN)
	{
		CPP_ERR_RETURN(RIS_E_MACRO_NAME_TOO_LONG, tp->rhs->lhs->pos);
	}

	item.key = tp->rhs->lhs->info.val;
	if ((found_item = hsearch(item, FIND)) == 0)
	{
		temp = ALLOCTP(macro_list_node);
		temp->ident = RIScpp_ident_num;
		temp->name = item.key;
		if(tp->rhs->rhs)
			temp->value = tp->rhs->rhs->lhs->info.val;
		temp->next = RIScpp_macro_list;
		RIScpp_macro_list = temp;
		item.data = (char *)RIScpp_ident_num++;
		if (!hsearch(item,ENTER))
		{
			CPP_ERR_RETURN(RIS_E_MACRO_NAME_IN_HASH_ERROR,tp->rhs->lhs->pos);
		}
	}
	else
	{

	/* defining a macro which is already defined */

		if (RIScpp_find_macro_ident((int)found_item->data)) 
	    {
			CPP_ERR_RETURN(RIS_E_MACRO_NAME_ALREADY_DEFINED,tp->rhs->lhs->pos);
		}
		else 
		{
			temp = ALLOCTP(macro_list_node);
			temp->ident = (int)found_item->data;
			temp->name = item.key;
			if(tp->rhs->rhs)
				temp->value = tp->rhs->rhs->lhs->info.val;
			temp->next = RIScpp_macro_list;
			RIScpp_macro_list = temp;
		}
	}
}

/******************************************************************************/

extern macro_list_node * RIScpp_find_macro_name(
	ristree * tp,
	int ident)
{
	ENTRY * found_item;
	ENTRY item;
	macro_list_node * result = 0;

CPP_DBG(("\nRIScpp_find_macro macro_name = %s ident = %d\n",tp->rhs->lhs->info.val, ident));

	item.key = tp->rhs->lhs->info.val;

	if ((found_item = hsearch(item,FIND)) != 0)
	{
		result=RIScpp_find_macro_ident((int)found_item->data);
		if (((result=RIScpp_find_macro_ident((int)found_item->data)) == 0) && 
			!(ident==RIS_TOK_IFDEF) &&
			!(ident==RIS_TOK_IFNDEF)) 
		{
			CPP_ERR_RETURN(RIS_E_MACRO_NAME_NOT_DEFINED,tp->rhs->lhs->pos); 
		}

	}
	else if(!(ident==RIS_TOK_IFDEF)&&!(ident==RIS_TOK_IFNDEF))
	{
/* undefining a macro, which is not defined in the first place */
		CPP_ERR_RETURN(RIS_E_MACRO_NAME_NOT_DEFINED,tp->rhs->lhs->pos);
	}
	return(result); 

}

/******************************************************************************/

extern macro_list_node * RIScpp_find_macro_ident(
	int ident)
{
	macro_list_node * temp;

CPP_DBG(("\nRIScpp_find_macro_ident ident = %d\n",ident));

	for(temp=RIScpp_macro_list;temp;temp=temp->next)
	{
		if (temp->ident == ident)
		{
			return(temp);
		}
	}
	return(0);
}

/******************************************************************************/
