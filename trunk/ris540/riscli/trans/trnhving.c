/* Do not alter this SPC information: $Revision: 1.1.56.1 $ */
/*
**	NAME:							trnhving.c
**	AUTHORS:						David Michal
**	CREATION DATE:					10/88
**	ABSTRACT:
**		This file contains the routines that handle dml having clauses.
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
#define trnhving_c
#include "trnhving.prt"
#include "comdebug.prt"
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
** transform having parse tree into rax tree
** havingp = having parse tree table_list = tables from from clause
** group_colist = list of grouping columns
** 5.23 <having clause> syntax rule 1 checked by RIStrn_search_cond
** 5.23 <having clause> syntax rule 2 checked by RIStrn_search_cond
*/

extern void RIStrn_having(
	ristree * havingp,
	ristree * table_list,
	ristree * group_colist)
{

	TRN_DBG(("RIStrn_having(havingp:0x%x table_list:0x%x group_colist:0x%x)\n",
		havingp, table_list, group_colist));

	RIStrn_search_cond(havingp->rhs,table_list,(ristree *)0,1,RIS_UNKNOWN_TYPE,0,
		group_colist);

	TRN_DBG(("RIStrn_having:complete\n"));
}

/******************************************************************************/
