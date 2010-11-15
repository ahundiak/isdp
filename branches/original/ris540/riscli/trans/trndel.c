/* Do not alter this SPC information: $Revision: 1.1.56.1 $ */
/*
**	NAME:							trndel.c
**	AUTHORS:						David Michal
**	CREATION DATE:					3/88
**	ABSTRACT:
**		This file contains the routines that handle dml delete statements.
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
#define trndel_c
#include "trndel.prt"
#include "trnshare.prt"
#include "trnwhere.prt"
#include "comdebug.prt"

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
** transform delete parse tree to rax
** deletep = delete parse tree
** 8.5 <delete statement:searched> syntax rule 1 not currently supported
** 8.5 <delete statement:searched> syntax rule 2 checked by RIStrn_where
** 8.5 <delete statement:searched> syntax rule 3
*/

extern void RIStrn_delete(
	ristree * deletep)
{
	ristree table_list;
	ristree table_list2;
	ristree group_colist;
	ristree * tablep;
	ristree * wherep = 0;

TRN_DBG(("RIStrn_delete(deletep:0x%x)\n",deletep));

/* set up pointers */

	tablep = deletep->rhs->lhs;
	if (deletep->rhs->rhs)
	{
		wherep = deletep->rhs->rhs->lhs;
	}

/* replace RIS_TOK_TABLE_NAME with RIS_TOK_TABLE */

	RIStrn_table_name(tablep,DELETE_ACCESS,0,0);

	RIStrn_det_dic_tab_mod(tablep->info.tab->tabname, RIS_TOK_DELETE);
	RIStrn_check_dict_select(tablep->info.tab->tabname, RIS_TOK_DELETE);

/* fix where clause */

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

/* make RIS_TOK_TABLE_NAME the rhs of RIS_TOK_DELETE */

	deletep->rhs = tablep;

/* make RIS_TOK_WHERE the lhs of RIS_TOK_DELETE */

	deletep->lhs = wherep;

	TRN_DBG(("RIStrn_delete:complete\n"));
}

/******************************************************************************/
