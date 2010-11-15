/* Do not alter this SPC information: $Revision: 1.1.56.1 $ */
/*
**	NAME:							trnselct.c
**	AUTHORS:						David Michal
**	CREATION DATE:					3/88
**	ABSTRACT:
**		This file contains the routines that handle dml select statements.
**	
**	REVISION HISTORY:
**		add RIStrn_select_select() for the union clause by Jin Jing 8/93
*/
 
/*
**	INCLUDES
*/
#include "riscli.h"
#include "riscom.h"
#include "rismem.h"
#include "trans.h"
#include "sys.prt"

/*
**	FUNCTION PROTOTYPES
*/
#define trnselct_c
#include "comalloc.prt"
#include "comdebug.prt"
#include "comjmp.prt"
#include "comtree.prt"
#include "trnfrom.prt"
#include "trngroup.prt"
#include "trnhving.prt"
#include "trnorder.prt"
#include "trnparms.prt"
#include "trnselct.prt"
#include "trnshare.prt"
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
** given a var or an attr produce a value expression
** tp = var or attr remove_flag = indicates if vars are to be removed
*/

static ristree * RIStrn_create_value_expr(
	ristree * tp1,
	int remove_flag)
{
	ristree * tp2;

TRN_DBG(("\nRIStrn_create_value_expr tp1 = 0x%x remove_flag = %d\n",
 tp1,remove_flag));

	tp2 = ALLOCT(ristree);
	tp2->tok = RIS_TOK_LIST;
	if (tp1->tok == RIS_TOK_ATTR)
	{
		tp2->lhs = RIScom_copy_tree_node(tp1); /* Hitesh */
	}
	else if (remove_flag)
	{
		tp2->lhs = RIScom_copy_tree(tp1->rhs); /* Hitesh */
	}
	else
	{
		tp2->lhs = RIScom_copy_tree(tp1); /* Hitesh */
	}
	return(tp2);
}

/******************************************************************************/

/*
** replaces a star in the select list with the value_exprs for the view/tables
** table_list = a list of the views and tables
** remove_flag = indicates if vars are to be removed
** group_colist = grouping column list
*/

static ristree * RIStrn_replace_star(
	ristree * table_list,
	int remove_flag,
	ristree * group_colist)
{
	ristree * tp1;
	ristree * tp2;
	ristree * list = 0;
	ristree * prev = 0;

	TRN_DBG(("RIStrn_replace_star(table_list:0x%x remove_flag:%d "
 		"group_colist:0x%x)\n",table_list,remove_flag,group_colist));

	for (tp1=table_list->lhs;tp1;tp1=tp1->rhs)
	{
		for(tp2=tp1->lhs->rhs;tp2;tp2=tp2->rhs)
		{

/* verfiy that the default schema has the proper access to this column */

			RIStrn_col_name(tp2->lhs,tp1->lhs,0);

			RIStrn_is_group_col(tp2->lhs,group_colist,table_list);
			if (!prev)
			{
				list = RIStrn_create_value_expr(tp2->lhs,remove_flag);
				prev = list;
			}
			else
			{
				prev->rhs = RIStrn_create_value_expr(tp2->lhs,remove_flag);
				prev = prev->rhs;
			}
		}
	}
	TRN_DBG(("RIStrn_replace_star:returning list:0x%x\n", list));
	return(list);
}

/******************************************************************************/

/*
** transforms select parse tree into rax
** selectp = select parse tree table_list = tables from containing queries
** update_table = insert/update/delete table
** group_colist = list of grouping columns
** 8.10 <select statement> syntax rule 1 not currently supported
** 8.10 <select statement> syntax rule 2 not supported
** 8.10 <select statement> syntax rule 3 not supported
** 8.10 <select statement> syntax rule 4a not supported
** 8.10 <select statement> syntax rule 4b not supported
** 8.10 <select statement> syntax rule 4c not supported
*/

extern int RIStrn_select_select(
	ristree * selectp,
	ristree * table_list,
	ristree * update_table,
	ristree * group_colist,
	ristree * orderbyp,
	int		  select_stmt)
{
	ristree * fromp;
	ristree * wherep = 0;
	ristree * groupbyp = 0;
	ristree * havingp = 0;
	ristree * temp;
	ristree table_list_node;
	ristree group_colist_node;
	ristree attr_list_node;
	ristree dummy_attr;
	risschema * schema = 0;
	int updatable = 1;
	ristree *tp;
	ristree *tp1;
	int aggregate_function = 0;
	int in_groupby, in_orderby, col_pos;

	TRN_DBG(("RIStrn_select_select(selectp:0x%x table_list:0x%x "
		"update_table:0x%x group_colist:0x%x)\n", 
		selectp,table_list,update_table,group_colist));

	/* save ptrs to the from, where, group by, having, and order by clauses */

	fromp = selectp->rhs->rhs->lhs;
	for (temp=selectp->rhs->rhs->rhs;temp;temp=temp->rhs)
	{
		switch(temp->lhs->tok)
		{
			case RIS_TOK_WHERE:
				wherep = temp->lhs;
			break;
			case RIS_TOK_GROUP_BY:
				groupbyp = temp->lhs;
			break;
			case RIS_TOK_HAVING:
				havingp = temp->lhs;
			break;
			case RIS_TOK_ORDER_BY:
			break;
			default:
				TRN_ERR_RETURN(RIS_E_INTERNAL_ERROR,temp->lhs->pos);
			break;
		}
	}

	/* set schema to the schema of the first table or view in the list */

	if (table_list)
	{
		if (table_list->lhs->lhs->info.tab->tabtype == 'A')
		{
			schema = table_list->lhs->lhs->info.tab->tab->schema;
		}
		else
		{
			schema = table_list->lhs->lhs->info.tab->schema;
		}
	}
	else if (update_table)
	{
		schema = update_table->info.tab->schema;
	}

	/*
	** make RIS_TOK_FROM into a product list and check
	** for insert/update/delete table
	*/

	updatable &= RIStrn_from(fromp,update_table,schema);

	/* add from clause to table list */

	table_list_node.tok = RIS_TOK_LIST;
	table_list_node.lhs = fromp->rhs;
	table_list_node.rhs = table_list;
	table_list = &table_list_node;

	if (groupbyp)
	{
		updatable = 0;

		/* fix group by column spec list*/

		RIStrn_group_by(groupbyp,table_list);

		/* add group by list to group col list */

		group_colist_node.lhs = groupbyp->rhs;
	}
	else if (havingp)
	{
		/*
		** add a dummy group by list to group colist
		** to indicate a grouped table
		*/

		dummy_attr.tok = RIS_TOK_ATTR;
		dummy_attr.info.attr = 0;
		attr_list_node.tok = RIS_TOK_LIST;
		attr_list_node.lhs = &dummy_attr;
		attr_list_node.rhs = 0;
		group_colist_node.lhs = &attr_list_node;
	}
	else
	{
		/* add a list node as a place holder for non-grouped table */

		group_colist_node.lhs = 0;
	}
	group_colist_node.tok = RIS_TOK_LIST;
	group_colist_node.rhs = group_colist;
	group_colist = &group_colist_node;

	/*
	** fix select list
	*/

	updatable &= RIStrn_select_list(selectp,table_list,group_colist);


	/* if this is a select, create the output sqlda and sqlvar structures */
	if (select_stmt) 
	{
		int i;

		if (selectp->tok == RIS_TOK_SELECT_SELECT)
		{
			for (i=0,temp=selectp->rhs->rhs; temp; i++,temp=temp->rhs);
			RIStrn_parms(selectp->rhs->rhs,i,0);
		}
		else if (selectp->tok == RIS_TOK_UNION_SELECT || 
				selectp->tok == RIS_TOK_UNION_ALL_SELECT)
		{
			for (i=0,temp=selectp->rhs->rhs; temp; i++,temp=temp->rhs);
			RIStrn_parms_compatible(selectp->rhs->rhs,i,0);
		}
		else
		{
			TRN_ERR_RETURN(RIS_E_INTERNAL_ERROR,temp->pos);
		}
	}

/* create order by node if necessary */

	if (orderbyp)
	{
		RIStrn_order_by(orderbyp,selectp->rhs->rhs,table_list);
	}

	if (havingp)
	{
		updatable = 0;

		/* fix having expression */

		RIStrn_having(havingp,table_list,group_colist);
	}

	if (wherep)
	{

		/* fix RIS_TOK_WHERE */

		/*
		** set group col list for this query to zero because all columns
		** are allowed in the where clause 
		*/
		group_colist->lhs = 0;

		updatable &= RIStrn_where(wherep,table_list,(ristree *)0,group_colist);
	}

	/* connect up all of the clauses */

	if (havingp)
	{
		havingp->lhs = selectp->lhs;
		selectp->lhs = havingp;
	}
	if (groupbyp)
	{
		groupbyp->lhs = selectp->lhs;
		selectp->lhs = groupbyp;
	}
	if (wherep)
	{
		wherep->lhs = selectp->lhs;
		selectp->lhs = wherep;
	}
	fromp->lhs = selectp->lhs;
	selectp->lhs = fromp;

	/*
	** Check if there are any aggregate functions in the select list.
	** If so, verify that all colums in the select-list that are non-aggregate
	** must appear in the group-by list.
	** -Sunil 1/28/94 TR# 249305462
	*/
	for (tp=selectp->rhs->rhs;tp;tp=tp->rhs)
	{
		if (tp->lhs->tok == RIS_TOK_AVG ||
			tp->lhs->tok == RIS_TOK_MAX ||
			tp->lhs->tok == RIS_TOK_MIN ||
			tp->lhs->tok == RIS_TOK_SUM ||
			tp->lhs->tok == RIS_TOK_COUNT)
		{
			aggregate_function = 1;
			TRN_DBG(("found an aggregate function\n"));
		}
	}
	if (aggregate_function)
	{
		col_pos = 0;
		for (tp=selectp->rhs->rhs;tp;tp=tp->rhs)
		{
			col_pos++;
			if (tp->lhs->tok == RIS_TOK_ATTR)
			{
				in_groupby = 0;
				in_orderby = 0;
				for (tp1=groupbyp;tp1;tp1=tp1->rhs)
				{

/*	Added check for tp1->lhs to see if it is null. Only if it is not 
**	NULL the consequent check is performed. In the absence of this
**	check riscli is receiving an exception. This will fix TR# 249403181.
**	RAJU. 06/20/94.
*/
					if ((tp1->lhs) && (tp1->lhs->tok == RIS_TOK_ATTR &&
						strcmp(tp1->lhs->info.val, tp->lhs->info.val) == 0))
					{
						in_groupby = 1;
					}
				}
				if (orderbyp)
				{
					tp1 = orderbyp->rhs;
				}
				else
				{
					tp1 = 0;
				}
				for (;tp1;tp1=tp1->rhs)
				{
					if (tp1->lhs->tok == RIS_TOK_EXACT_NUM_LIT &&
						col_pos == atoi(tp1->lhs->info.val))
					{
						in_orderby = 1;
					}
				}
				if (!in_groupby && !in_orderby)
				{
					TRN_ERR_RETURN(RIS_E_COL_NOT_IN_GROUP_BY_LIST,tp->lhs->pos);
				}
			}
		}
	}
	TRN_DBG(("RIStrn_select_select: returning\n"));
	return(updatable);
}

/******************************************************************************/

/*
** transforms select parse tree into rax
** selectp = select parse tree table_list = tables from containing queries
** update_table = insert/update/delete table
** group_colist = list of grouping columns
** 8.10 <select statement> syntax rule 1 not currently supported
** 8.10 <select statement> syntax rule 2 not supported
** 8.10 <select statement> syntax rule 3 not supported
** 8.10 <select statement> syntax rule 4a not supported
** 8.10 <select statement> syntax rule 4b not supported
** 8.10 <select statement> syntax rule 4c not supported
*/

extern int RIStrn_select(
	ristree * selectp,
	ristree * table_list,
	ristree * update_table,
	ristree * group_colist)
{
	ristree * tablep = 0;
	ristree * orderbyp = 0;
	ristree * tp;
	ristree * last;
	ristree * left;
	risschema * schema = 0;
	risschema * union_sch = 0;
	int updatable = 1;
	int select_stmt = 0;

	TRN_DBG(("RIStrn_select(selectp:0x%x table_list:0x%x update_table:0x%x "
		"group_colist:0x%x)\n", selectp,table_list,update_table,group_colist));

	/* get orderbyp, if specified */

	if (selectp->rhs->rhs)
	{
		orderbyp = selectp->rhs->rhs->lhs;
	}

	/* transforms select_select or union_select parse trees into rax */
	for (tp=selectp->rhs->lhs->rhs;tp;tp=tp->rhs)
	{
		/* if this is a select */
		if (RIS_stmt->tree->tok == RIS_TOK_SELECT &&
			RIS_stmt->tree->rhs->lhs->rhs == tp)
		{
			select_stmt = 1;
		}
	
		switch(tp->lhs->tok)
		{
			case RIS_TOK_SELECT_SELECT:

				tablep = tp->lhs->rhs->rhs->lhs->rhs->lhs;
				updatable = RIStrn_select_select(tp->lhs, table_list, 
					update_table, group_colist, orderbyp, select_stmt);

				/* 
				**	set schema to the schema of the first table or view 
				*/
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
			break;
			case RIS_TOK_UNION_ALL_SELECT:
			case RIS_TOK_UNION_SELECT:
				if (RIS_stmt->tree->tok == RIS_TOK_INSERT ||
					RIS_stmt->tree->tok == RIS_TOK_CREATE_VIEW)
				{
					TRN_ERR_RETURN(RIS_E_UNION_CLAUSE_NOT_ALLOWED,tp->pos);
				}

				tablep = tp->lhs->rhs->rhs->lhs->rhs->lhs;
				RIStrn_select_select(tp->lhs, table_list, update_table,
					group_colist, 0, select_stmt);

				/* 
				**	set union_sch to the schema of the first table or view 
				*/
				if (tablep->info.tab->tabtype == 'A')
				{
					union_sch = tablep->info.tab->tab->schema;
				}
				else
				{
					union_sch = tablep->info.tab->schema;
				}
				TRN_DBG(("RIStrn_select: schema: 0x%x union_sch: 0x%x\n",
					schema, union_sch));
				if (union_sch != schema)
				{
					TRN_ERR_RETURN(RIS_E_MULT_SCHEMA_NOT_ALLOWED,tp->pos);
				}
			break;
			default:
				TRN_ERR_RETURN(RIS_E_INTERNAL_ERROR,tp->lhs->pos);
			break;
		}
	}

	/* connect up all of the clauses */

	last = selectp;
	for (tp=left=selectp->rhs->lhs->rhs;tp;tp=left=tp->rhs)
	{
		last->lhs = tp->lhs;
		while (left->lhs)
		{
			left = left->lhs;
		}
		last = left;
	}
	if (orderbyp)
	{
		last->lhs = orderbyp;
	}

	selectp->rhs = selectp->lhs->rhs;
	selectp->lhs = selectp->lhs->lhs;

	TRN_DBG(("RIStrn_select: returning\n"));
	return(updatable);
}

/******************************************************************************/

/*
** transform sql select list into a rax project
** selectp = select list parse tree table_list = the list of tables
** remove_flag = indicates if vars are to be removed
** group_colist = grouping column list
*/

static int RIStrn_select_list(
	ristree * selectp,
	ristree * table_list,
	ristree * group_colist)
{
	ristree * tp;
	int updatable = 1;

	TRN_DBG(("RIStrn_select_list(selectp:0x%x table_list:0x%x "
		"group_colist:0x%x)\n",selectp,table_list,group_colist));

	selectp->rhs = selectp->rhs->lhs;
	if (selectp->rhs->rhs->tok == RIS_TOK_MUL)
	{
		/*
		**	fix RIS_TOK_MUL
		*/
		selectp->rhs->rhs = RIStrn_replace_star(table_list,0,group_colist);
	}
	else
	{

/* fix RIS_TOK_VALUE_EXPRs */

		selectp->rhs->rhs = selectp->rhs->rhs->rhs;
	}

	if (selectp->rhs->tok == RIS_TOK_DISTINCT)
	{
		updatable = 0;
	}

	for (tp=selectp->rhs->rhs;tp;tp=tp->rhs)
	{
		RIStrn_search_cond(tp->lhs,table_list,(ristree *)0,1,RIS_UNKNOWN_TYPE,0,
			group_colist);
		if (updatable)
		{
			if (tp->lhs->tok == RIS_TOK_ATTR)
			{
				updatable &= RIStrn_check_for_dup_col(tp,selectp->rhs->rhs);
			}
			else
			{
				updatable = 0;
			}
		}
	}
	TRN_DBG(("RIStrn_select_list:returning %d\n", updatable));
	return(updatable);
}

/******************************************************************************/

static int RIStrn_check_for_dup_col(
	ristree * tp,
	ristree * list)
{
	for(;tp != list && list;list=list->rhs)
	{
		switch(tp->lhs->tok)
		{
			case RIS_TOK_ATTR:
				switch(list->lhs->tok)
				{
					case RIS_TOK_ATTR:
						if (tp->lhs->info.attr == list->lhs->info.attr)
						{
							return(0);
						}
					break;
					default:
						TRN_ERR_RETURN(RIS_E_INTERNAL_ERROR,list->lhs->pos);
					break;
				}
			break;
			default:
				TRN_ERR_RETURN(RIS_E_INTERNAL_ERROR,tp->lhs->pos);
			break;
		}
	}
	return(1);
}

/******************************************************************************/
