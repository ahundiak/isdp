/* Do not alter this SPC information: $Revision: 1.1.56.1 $ */
/*
**	NAME:							trnorder.c
**	AUTHORS:						David Michal
**	CREATION DATE:					7/88
**	ABSTRACT:
**		This file contains the routines that handle the order by clause.
**	
**	REVISION HISTORY:
*/
 
/*
**	INCLUDES
*/
#include "riscom.h"
#include "rismem.h"
#include "trans.h"

/*
**	FUNCTION PROTOTYPES
*/
#define trnorder_c
#include "comalloc.prt"
#include "comdebug.prt"
#include "comjmp.prt"
#include "trnorder.prt"
#include "trnshare.prt"
#include "trntypsz.prt"
#include "sys.prt"



/*
**	DEFINES
*/

/*
**	VARIABLES
*/

/*
**	FUNCTIONS
*/

/******************************************************************************/

/*
** transform sql order by list into a rax order by 
** orderbyp = order by list parse tree proj_list = project list
** table_list = the list of tables
*/

extern void RIStrn_order_by(
	ristree * orderbyp,
	ristree * proj_list,
	ristree * table_list)
{
	ristree * tp;
	int num;
	ristree * temp;
	ristree * orderby_list = 0;
	ristree * list_end = 0;
	ristree * list_node;
	risattr * attr;

	TRN_DBG(("RIStrn_order_by(orderbyp:0x%x proj_list:0x%x table_list:0x%x)\n",
 		orderbyp,proj_list,table_list));

	for (tp=orderbyp->rhs;tp;tp=tp->rhs)
	{

/* allocate node for order by list */

		list_node = ALLOCT(ristree);
		list_node->tok = RIS_TOK_LIST;
		list_node->lhs = ALLOCT(ristree);
		list_node->lhs->tok = RIS_TOK_ATTR;
		list_node->lhs->pos = tp->lhs->pos;

		if (tp->lhs->tok == RIS_TOK_EXACT_NUM_LIT)
		{

/* get number */

			num = atoi(tp->lhs->info.val);
			if (num <= 0)
			{
				TRN_ERR_RETURN(RIS_E_INVALID_COL_NUM,tp->lhs->pos);
			}

/* find expr in select list for number */

			for (temp=proj_list,num--;temp && num;temp=temp->rhs,num--);
			if (!temp)
			{
				TRN_ERR_RETURN(RIS_E_INVALID_COL_NUM,tp->lhs->pos);
			}

/* allocate an attr struct to represent this expr */

			attr = ALLOCT(risattr);
			switch(temp->lhs->tok)
			{
				case RIS_TOK_APPROX_NUM_LIT:
				case RIS_TOK_EXACT_NUM_LIT:
				case RIS_TOK_CHAR_STR_LIT:
				case RIS_TOK_TIMESTAMP_LIT:
				case RIS_TOK_CURRENT_TIMESTAMP:
					attr->atype = (unsigned char)RIStrn_get_type(temp->lhs);
					attr->asize.len = (unsigned short)RIStrn_get_size(temp->lhs);
				break;
				case RIS_TOK_ATTR:
				case RIS_TOK_PLUS:
				case RIS_TOK_SUB:
				case RIS_TOK_MUL:
				case RIS_TOK_DIV:
				case RIS_TOK_MAX:
				case RIS_TOK_MIN:
				case RIS_TOK_SUM:
				case RIS_TOK_AVG:
				case RIS_TOK_COUNT:
				case RIS_TOK_UNARYMINUS:
					attr = temp->lhs->info.attr;
				break;
				default:
					TRN_ERR_RETURN(RIS_E_INTERNAL_ERROR,temp->lhs->pos);
				break;
			}
			list_node->lhs->info.attr = attr;
		}
		else
		{

/* get column */

			temp = tp->lhs->lhs;
			RIStrn_col_name(tp->lhs,table_list,0);
			list_node->lhs->info.attr = tp->lhs->info.attr;

/* find column in select list */

			num = RIStrn_find_col(tp->lhs,proj_list);
			if (num)
			{

/* replace column with number */

				tp->lhs->tok = RIS_TOK_EXACT_NUM_LIT;
				tp->lhs->info.val = ALLOCB(11);
				sprintf(tp->lhs->info.val,"%d",num);
				tp->lhs->rhs = temp;
			}
			else
			{
				TRN_ERR_RETURN(RIS_E_COL_NOT_SELECTED,tp->lhs->pos);
			}
		}
		if (orderby_list)
		{
			list_end->rhs = list_node;
		}
		else
		{
			orderby_list = list_node;
		}
		list_end = list_node;
	}

/* Eliminate duplicate order_by columns */

	RIStrn_remove_duplicates(orderbyp);

/* check the number of cols and the row length */

    RIStrn_check_row_size(orderby_list,0,RIS_MAX_ORDER_BY_COLUMNS,
		RIS_MAX_ORDER_BY_LENGTH,RIS_E_TOO_MANY_ORDER_BY_COLS,
		RIS_E_ORDER_BY_TOO_LONG);

	TRN_DBG(("RIStrn_order_by:complete\n"));
}

/******************************************************************************/

/*
** find a attr/var in project list
** col = col tree node
** proj_list = project list
*/

static int RIStrn_find_col(
	ristree * col,
	ristree * proj_list)
{
	ristree * tp;
	int count = 1;

	TRN_DBG(("RIStrn_find_col(col:0x%x proj_list:0x%x)\n",col,proj_list));

	for(tp=proj_list;tp;tp=tp->rhs)
	{
		switch(tp->lhs->tok)
		{
			case RIS_TOK_ATTR:
				if (col->tok == RIS_TOK_ATTR && 
				 col->info.attr == tp->lhs->info.attr)
				{
					TRN_DBG(("RIStrn_order_by:returning %d\n", count));
					return(count);
				}
			break;
		}
		count++;
	}
	TRN_DBG(("RIStrn_order_by:returning 0\n"));
	return(0);
}

/******************************************************************************/

extern void RIStrn_remove_duplicates(
	ristree *tp)
{
	ristree *dupp;
	ristree *trav;
	ristree *travprev;
	char *prevval;
	unsigned int prevtok;

	TRN_DBG(("RIStrn_remove_duplicates(tp:0x%x)\n",tp));

	/* dupp points to first element of the list */
	for (dupp = tp->rhs; dupp; dupp = dupp->rhs)
	{
		prevval = dupp->lhs->info.val;
		prevtok = dupp->lhs->rhs->tok;
		if (dupp->rhs)
		{
			travprev = dupp;
			for (trav = dupp->rhs; trav; trav = trav->rhs)
			{
				if (!strcmp(prevval, trav->lhs->info.val))
				{
					if (prevtok != trav->lhs->rhs->tok)
					{
TRN_DBG(("HOW DO WE WANT TO HANDLE ONE ASC ONE DESC ?\n"));
					}
					TRN_DBG(("Duplicate found <%s>\n",trav->lhs->info.val));
					travprev->rhs = trav->rhs;
					trav = travprev;
				}
				else
				{
					travprev = trav;
				}
			}
		}
	}
	TRN_DBG(("RIStrn_remove_duplicates done...\n"));
}
/******************************************************************************/
