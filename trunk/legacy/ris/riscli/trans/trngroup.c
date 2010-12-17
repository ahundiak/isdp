/* Do not alter this SPC information: $Revision: 1.1.56.1 $ */
/*
**	NAME:							trngroup.c
**	AUTHORS:						David Michal
**	CREATION DATE:					10/88
**	ABSTRACT:
**		This file contains the routines that handle dml group by clauses.
**	
**	REVISION HISTORY:
*/
 
/*
**	INCLUDES
*/
#include "trans.h"

/*
**	FUNCTION PROTOTYPES
*/
#define trngroup_c
#include "comjmp.prt"
#include "comdebug.prt"
#include "trngroup.prt"
#include "trnshare.prt"


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
** transform group by parse tree into rax tree
** groupbyp = group by parse tree table_list = tables from from clause
** 5.22 <group by clause> syntax rule 2 checked by RIStrn_col_name
*/

extern void RIStrn_group_by(
	ristree * groupbyp,
	ristree * table_list)
{
	ristree * tp;

	TRN_DBG(("RIStrn_group_by(groupbyp:0x%x table_list:0x%x\n",
 		groupbyp,table_list));

	for (tp=groupbyp->rhs;tp;tp=tp->rhs)
	{
		RIStrn_col_name(tp->lhs,table_list,0);
	}

/* check the number of cols and the row length */

    RIStrn_check_row_size(groupbyp->rhs,0,RIS_MAX_GROUP_BY_COLUMNS,
		RIS_MAX_GROUP_BY_LENGTH,RIS_E_TOO_MANY_GROUP_BY_COLS,
		RIS_E_GROUP_BY_TOO_LONG);

	TRN_DBG(("RIStrn_group_by:complete\n"));
}

/******************************************************************************/

/*
** verifys that col is a grouping column
** col = column in question
** group_colist = the list of columns specified in the group by clause
** table_list = the list of tables
*/

extern void RIStrn_is_group_col(
	ristree * col,
	ristree * group_colist,
	ristree * table_list)
{
	ristree * tp1;
	ristree * tp2;
	ristree * tp3;

TRN_DBG((
 "\nRIStrn_is_group_col col = 0x%x group_colist = 0x%x table_list = 0x%x\n",
 col,group_colist,table_list));
	 
	if (group_colist)
	{
		switch(col->tok)
		{
			case RIS_TOK_ATTR:

/* find appropriate group col list */

				for (tp1=table_list,tp2=group_colist;tp1 && tp2;tp1=tp1->rhs,
				 tp2=tp2->rhs)
				{
					for (tp3=tp1->lhs;tp3;tp3=tp3->rhs)
					{
						if (tp3->lhs->tok == RIS_TOK_TABLE && 
						 tp3->lhs->info.tab == col->info.attr->tab)
						{
							break;
						}
					}
					if (tp3)
					{
						break;
					}
				}
				if (!tp1 || !tp2)
				{
					TRN_ERR_RETURN(RIS_E_INTERNAL_ERROR,col->pos);
				}

/* if there is a group col list then make sure col is in it */

				if (tp2->lhs)
				{
					for (tp2=tp2->lhs;tp2;tp2=tp2->rhs)
					{
						if (tp2->lhs->tok == RIS_TOK_ATTR && 
						 tp2->lhs->info.attr == col->info.attr)
						{
							return;
						}
					}
					TRN_ERR_RETURN(RIS_E_NOT_GROUP_COL,col->pos);
				}
			break;
			default:
				TRN_ERR_RETURN(RIS_E_INTERNAL_ERROR,col->pos);
			break;
		}
	}
}

/******************************************************************************/
