/*
**	NAME:							trnupdt.c
**	AUTHORS:						David Michal
**	CREATION DATE:					3/88
**	ABSTRACT:
**		This file contains the routines that handle dml update statements.
**	
**	REVISION HISTORY:
*/
 
/*
**	INCLUDES
*/
#include "riscom.h"
#include "trans.h"

/*
**	FUNCTION PROTOTYPES
*/
#define trnupdt_c
#include "comjmp.prt"
#include "comdebug.prt"
#include "trnshare.prt"
#include "trnupdt.prt"
#include "trnwhere.prt"


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
** transform update parse tree to rax
** updatep = update parse tree
** 8.12 <update statement:searched> syntax rule 1 not currently supported
** 8.12 <update statement:searched> syntax rule 2 checked by RIStrn_where
** 8.12 <update statement:searched> syntax rule 3 checked by 
**  RIStrn_update_asgn_list
** 8.12 <update statement:searched> syntax rule 4 checked by 
**  RIStrn_update_asgn_list
** 8.12 <update statement:searched> syntax rule 5
** 8.12 <update statement:searched> syntax rule 6 checked by 
**  RIStrn_update_asgn_list
*/

extern void RIStrn_update(
	ristree * updatep)
{
	ristree * asgnp;
	ristree table_list;
	ristree table_list2;
	ristree group_colist;
	ristree * tablep;
	ristree * wherep = 0;

TRN_DBG(("\nRIStrn_update updatep = 0x%x\n",updatep));

/* set up pointers */

	tablep = updatep->rhs->lhs;
	asgnp = updatep->rhs->rhs->lhs->rhs;
	if (updatep->rhs->rhs->rhs)
	{
		wherep = updatep->rhs->rhs->rhs->lhs;
	}

/* replace RIS_TOK_TABLE_NAME with RIS_TOK_TABLE */

	RIStrn_table_name(tablep,0,0,0);

    RIStrn_det_dic_tab_mod(tablep->info.tab->tabname, RIS_TOK_UPDATE);
    RIStrn_check_dict_select(tablep->info.tab->tabname, RIS_TOK_UPDATE);

/* fix assign list */

	RIStrn_update_asgn_list(tablep,asgnp);

/* fix RIS_TOK_WHERE */

	if (wherep)
	{
		table_list.tok = RIS_TOK_LIST;
		table_list.lhs = &table_list2;
		table_list.rhs = 0;
		table_list2.tok = RIS_TOK_LIST;
		table_list2.lhs = tablep;
		table_list2.rhs = 0;

/* add a list node as a place holder for non-grouped table */

		group_colist.tok = RIS_TOK_LIST;
		group_colist.lhs = 0;
		group_colist.rhs = 0;

		RIStrn_where(wherep,&table_list,tablep,&group_colist);
	}

/* make RIS_TOK_TABLE_NAME the rhs of RIS_TOK_UPDATE */

	updatep->rhs = tablep;

/* make RIS_TOK_WHERE the lhs of RIS_TOK_UPDATE */

	updatep->lhs = wherep;

/* make asgn list the rhs of RIS_TOK_TABLE */

	tablep->rhs = asgnp;
}

/******************************************************************************/

/*
** get info for cols and do typchecking
** tablep = upadte table asgnp = assignments
** 8.12 <update statement:searched> syntax rule 3 checked by RIStrn_search_cond
** 8.12 <update statement:searched> syntax rule 4
** 8.12 <update statement:searched> syntax rule 6 checked by RIStrn_search_cond
*/

extern void RIStrn_update_asgn_list(
	ristree * tablep,
	ristree * asgnp)
{
	ristree * temp1;
	ristree * temp2;

TRN_DBG(("\nRIStrn_update_asgn_list tablep = 0x%x asgnp = 0x%x\n",tablep,asgnp));

	for (temp1=asgnp;temp1;temp1=temp1->rhs)
	{
		RIStrn_search_cond(temp1->lhs,tablep,(ristree *)0,0,RIS_UNKNOWN_TYPE,0,
			(ristree *)0);

/* check column access */

		RIStrn_col_name(temp1->lhs->lhs,tablep,UPDATE_ACCESS);

/* check for duplicate assignments */

		for (temp2=asgnp;temp2 != temp1;temp2=temp2->rhs)
		{
			if (temp2->lhs->lhs->info.attr == temp1->lhs->lhs->info.attr)
			{
				TRN_ERR_RETURN(RIS_E_DUP_UPDATE_ASGN,temp2->lhs->lhs->pos);
			}
		}
	}
}

/******************************************************************************/
