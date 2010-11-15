/* Do not alter this SPC information: $Revision: 1.1.56.1 $ */
/*
**	NAME:							trninsrt.c
**	AUTHORS:						David Michal
**	CREATION DATE:					3/88
**	ABSTRACT:
**		This file contains the routines that handle dml insert statements.
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
#define trninsrt_c
#include "comjmp.prt"
#include "comdebug.prt"
#include "trncheck.prt"
#include "trninsrt.prt"
#include "trnselct.prt"
#include "trnshare.prt"
#include "trntypsz.prt"

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
** transform insert parse tree into rax
** insertp = insert parse tree
** 8.7 <insert statement> syntax rule 1 not currently supported
** 8.7 <insert statement> syntax rule 2 checked by RIStrn_select
** 8.7 <insert statement> syntax rule 3 checked by RIStrn_insert_col_list
** 8.7 <insert statement> syntax rule 4
** 8.7 <insert statement> syntax rule 5a checked by RIStrn_insert_typecheck
** 8.7 <insert statement> syntax rule 5b checked by RIStrn_insert_typecheck
** 8.7 <insert statement> syntax rule 6a checked by RIStrn_insert_typecheck
** 8.7 <insert statement> syntax rule 6b checked by RIStrn_insert_typecheck
** 8.7 <insert statement> syntax rule 6c checked by RIStrn_insert_typecheck
*/

extern void RIStrn_insert(
	ristree * insertp)
{
	ristree * tablep;
	ristree * cols = 0;
	ristree * values;

	TRN_DBG(("RIStrn_insert(insertp:0x%x)\n",insertp));

/* set up pointers */

	tablep = insertp->rhs->lhs;
	if (insertp->rhs->rhs->lhs->tok == RIS_TOK_COLUMN_LIST)
	{
		cols = insertp->rhs->rhs->lhs->rhs;
		insertp->rhs->rhs = insertp->rhs->rhs->rhs;
	}
	values = insertp->rhs->rhs->lhs;

/* replace RIS_TOK_TABLE_NAME with RIS_TOK_TABLE */

	RIStrn_table_name(tablep,INSERT_ACCESS,0,0);

	RIStrn_det_dic_tab_mod(tablep->info.tab->tabname, RIS_TOK_INSERT);
	RIStrn_check_dict_select(tablep->info.tab->tabname, RIS_TOK_INSERT);

	if (cols)
	{

/* change columns to attrs and check for dups */
   
		RIStrn_insert_col_list(tablep,cols);
	}

/* make RIS_TOK_VALUES or RIS_TOK_SELECT the lhs of RIS_TOK_INSERT */
	
	insertp->lhs = values;

/* fix RIS_TOK_SELECT */

	if (values->tok == RIS_TOK_SELECT)
	{
		RIStrn_select(values,(ristree *)0,tablep,(ristree *)0);
	}
	else
	{
		RIStrn_values(values);
	}

/* make insert cols the rhs of RIS_TOK_TABLE */

	if (cols)
	{
		tablep->rhs = cols;
	}

/* check for unsupported columns */

	RIStrn_col_unsupported(tablep->rhs);

/* make RIS_TOK_TABLE the rhs of RIS_TOK_INSERT */

	insertp->rhs = tablep;

/* 
** check that column data types and values or select list data types are
** compatible
*/

	if (values->tok == RIS_TOK_SELECT)
	{
		RIStrn_insert_typecheck(tablep->rhs,values->rhs->rhs);
	}
	else
	{
		RIStrn_insert_typecheck(tablep->rhs,values->rhs);
	}

	TRN_DBG(("RIStrn_insert:complete\n"));
}

/******************************************************************************/

/*
e* gets info for columns and checks for dups
** tablep = insert table colp = column list
** 8.7 <insert statement> syntax rule 3
*/

static void RIStrn_insert_col_list(
	ristree * tablep,
	ristree * colp)
{
	ristree * temp1;
	ristree * temp2;

	TRN_DBG(("RIStrn_insert_col_list(tablep:0x%x colp:0x%x\n",tablep,colp));

	for (temp1=colp;temp1;temp1=temp1->rhs)
	{
		RIStrn_col_name(temp1->lhs,tablep,0);
		for (temp2=colp;temp2 != temp1;temp2=temp2->rhs)
		{
			if (temp2->lhs->info.attr == temp1->lhs->info.attr)
			{
				TRN_ERR_RETURN(RIS_E_DUP_INSERT_COL,temp2->lhs->pos);
			}
		}
	}
	TRN_DBG(("RIStrn_insert_col_list:complete\n"));
}

/******************************************************************************/

/*
** verifies that number and types of cols match number and types of values
** col_list = column list val_list = value list
** 8.7 <insert statement> syntax rule 5a
** 8.7 <insert statement> syntax rule 5b
** 8.7 <insert statement> syntax rule 6a
** 8.7 <insert statement> syntax rule 6b
** 8.7 <insert statement> syntax rule 6c
*/

static void RIStrn_insert_typecheck(
	ristree * col_list,
	ristree * val_list)
{
	ristree tp;

	TRN_DBG(("RIStrn_insert_typecheck(col_list:0x%x val_list:0x%x)\n",
		col_list, val_list));

	tp.tok = RIS_TOK_ASGN;
	for(;col_list && val_list;col_list=col_list->rhs,val_list=val_list->rhs)
	{
		tp.pos = val_list->lhs->pos;
		tp.lhs = col_list->lhs;
		tp.rhs = val_list->lhs;
		RIStrn_typecheck(&tp,RIStrn_get_type(tp.lhs),RIStrn_get_size(tp.lhs));
	}
	if (col_list && !val_list)
	{
		TRN_ERR_RETURN(RIS_E_NOT_ENOUGH_VALUES,col_list->lhs->pos);
	}
	else if (!col_list && val_list)
	{
		TRN_ERR_RETURN(RIS_E_TOO_MANY_VALUES,val_list->lhs->pos);
	}

	TRN_DBG(("RIStrn_insert_typecheck:complete\n"));
}

/******************************************************************************/

/*
** replace RIS_TOK_QUESTIONs with RIS_TOK_PARAMETERs
** valuep = value list parse tree
*/

static void RIStrn_values(
	ristree * valuep)
{
	ristree * tp;

	TRN_DBG(("RIStrn_values(valuep:0x%x)\n",valuep));

	for(tp=valuep->rhs;tp;tp=tp->rhs)
	{
		if (tp->lhs->tok == RIS_TOK_QUESTION)
		{
			RIStrn_parm_quest(tp->lhs);
		}
	}
	TRN_DBG(("RIStrn_values:complete\n"));
}

/******************************************************************************/
