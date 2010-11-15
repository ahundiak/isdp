/* Do not alter this SPC information: $Revision: 1.1.56.1 $ */
/*
**	NAME:							trnfrom.c
**	AUTHORS:						David Michal
**	CREATION DATE:					3/88
**	ABSTRACT:
**		This file contains the routines that handle dml from clauses.
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
#define trnfrom_c
#include "comjmp.prt"
#include "comdebug.prt"
#include "trnalias.prt"
#include "trnfrom.prt"
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
** verifys that a table is not already in the table list
** table = the table table_list = the table list
** 5.20 <from clause> syntax rule 2
*/

extern void RIStrn_check_for_dup_tables(
	int token,
	ristree * table,
	ristree * table_list)
{
	ristree * tp;

TRN_DBG(("RIStrn_check_for_dup_tables(token:%d table:0x%x table_list:0x%x\n",
	token, table, table_list));

	for(tp=table_list;tp && tp != table;tp=tp->rhs)
	{
		if (tp->lhs->info.tab == table->lhs->info.tab)
		{
			switch(token)
			{
				case RIS_TOK_SELECT:
					TRN_ERR_RETURN(RIS_E_DUP_TAB_IN_FROM,table->lhs->pos);
				break;
				case RIS_TOK_LOCK_TABLES:
					TRN_ERR_RETURN(RIS_E_DUP_TAB_IN_LOCK,table->lhs->pos);
				break;
				default:
					LONGJMP(RIS_E_INTERNAL_ERROR);
				break;
			}
		}
	}
	TRN_DBG(("RIStrn_check_for_dup_tables: complete\n"));
}

/******************************************************************************/

/*
** gets table and view info
** fromp = from parse tree update_table = insert/update/delete table
** schema = schema which must contain all the tables and views
** 5.20 <from clause> syntax rule 2 checked by RIStrn_check_for_dup_tables
** 8.5 <delete statment:searched> syntax rule 2 checked by 
**  RIStrn_check_for_common_table
** 8.7 <insert statment> syntax rule 2 checked by RIStrn_check_for_common_table
** 8.12 <update statment:searched> syntax rule 2 checked by
**  RIStrn_check_for_common_table
*/

extern int RIStrn_from(
	ristree * fromp,
	ristree * update_table,
	risschema * schema)
{
	ristree * tp;
	ristree * aliasp;
	ristree * tablep;
	int updatable = 1;

	TRN_DBG(("RIStrn_from(fromp:0x%x update_table:0x%x schema:0x%x)\n",
		fromp,update_table,schema));

	for (tp=fromp->rhs;tp;tp=tp->rhs)
	{
		if (updatable && tp->rhs)
		{
			updatable = 0;
		}
		tablep = tp->lhs;
		if (tablep->tok == RIS_TOK_AUTH_ID)
		{
			if (tablep->rhs->tok == RIS_TOK_USR_NAME)
			{
				aliasp = tablep->rhs->rhs->rhs;
			}
			else
			{
				aliasp = tablep->rhs->rhs;
			}
		}
		else
		{
			if (tablep->tok == RIS_TOK_USR_NAME)
			{
				aliasp = tablep->rhs->rhs;
			}
			else
			{
				aliasp = tablep->rhs;
			}
		}
		RIStrn_table_name(tablep,SELECT_ACCESS,schema,0);
		RIStrn_check_dict_select(tablep->info.tab->tabname, RIS_TOK_SELECT);
		RIStrn_check_for_common_table(update_table,tablep);
		if (aliasp)
		{
			RIStrn_make_alias_tree(aliasp,tablep);
		}
		RIStrn_check_for_dup_tables(RIS_TOK_SELECT,tp,fromp->rhs);
		if (!schema)
		{
			if (tablep->info.tab->tabtype == 'A')
			{
				schema = tablep->info.tab->tab->schema;
			}
			else
			{
				schema = tablep->info.tab->schema;
			}
		}
	}
	TRN_DBG(("RIStrn_from:complete\n"));
	return(updatable);
}

/******************************************************************************/

/* verifys that the two views or tables do not have any tables in common
** tp1 = view or table tp2 = view or table
** 8.5 <delete statment:searched> syntax rule 2
** 8.7 <insert statment> syntax rule 2
** 8.12 <update statment:searched> syntax rule 2
*/

static void RIStrn_check_for_common_table(
	ristree * tp1,
	ristree * tp2)
{
	ristab * tab1;
	ristab * tab2;

	TRN_DBG(("RIStrn_check_for_common_table(tp1:0x%x tp2:0x%x\n",tp1,tp2));

	if (tp1 && tp2)
	{
		switch(tp1->tok)
		{
			case RIS_TOK_TABLE:
				switch(tp2->tok)
				{
					case RIS_TOK_TABLE:
						tab1 = tp1->info.tab;
						if (tab1->tabtype == 'A')
						{
							tab1 = tab1->tab;
						}
						tab2 = tp2->info.tab;
						if (tab2->tabtype == 'A')
						{
							tab2 = tab1->tab;
						}
						if (tab1 == tab2)
						{
							TRN_ERR_RETURN(RIS_E_UPDATE_TAB_IN_SUBQUERY,
								tp2->pos);
						}
					break;
					default:
						RIStrn_check_for_common_table(tp1,tp2->lhs);
						RIStrn_check_for_common_table(tp1,tp2->rhs);
					break;
				}
			break;
			default:
				RIStrn_check_for_common_table(tp1->lhs,tp2);
				RIStrn_check_for_common_table(tp1->rhs,tp2);
			break;
		}
	}
	TRN_DBG(("RIStrn_check_for_common_table:complete\n"));
}

/******************************************************************************/
