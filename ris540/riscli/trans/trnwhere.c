/* Do not alter this SPC information: $Revision: 1.1.56.1 $ */
/*
**	NAME:							trnwhere.c
**	AUTHORS:						David Michal
**	CREATION DATE:					3/88
**	ABSTRACT:
**		This file contains the routines that handle dml where clauses.
**	
**	REVISION HISTORY:
*/

#define TRANS_GLOBAL_DEFINE 
/*
**	INCLUDES
*/
#include "riscl_sr.h"
#include "riscli.h"
#include "ristypes.h"
#include "trans.h"

/*
**	FUNCTION PROTOTYPES
*/
#define trnwhere_c
#include "comgtnme.prt"
#include "comdebug.prt"
#include "comjmp.prt"
#include "trncheck.prt"
#include "trngroup.prt"
#include "trnselct.prt"
#include "trnshare.prt"
#include "trntypsz.prt"
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
** typechecks and transforms expressions
** tp = expression table_list = tables from from clause update_table =
** insert/update/delete table func_flag = indicates if functions are allowed
** several syntax rules (too many to list here)
*/

extern int RIStrn_search_cond(
	ristree * tp,
	ristree * table_list,
	ristree * update_table,
	int func_flag,
	int targ_type,
	int targ_size,
	ristree * group_colist)
{
	int updatable = 1;

	TRN_DBG(("RIStrn_search_cond(tp:0x%x table_list:0x%x update_table:0x%x "
		"func_flag:%d targ_type:<%s> targ_size:%d group_colist:0x%x\n",
 		tp, table_list, update_table, func_flag,
		RIS_types[ATTR_TYPE(targ_type)].string, targ_size,group_colist));

	if (tp)
	{
		TRN_DBG(("RIStrn_search_cond: tp->tok:%s\n",
			RIScom_get_token_name(tp->tok)));
		switch(tp->tok)
		{
			case RIS_TOK_OR:
			case RIS_TOK_AND:
			case RIS_TOK_NOT:
			case RIS_TOK_LIST:
				updatable &= RIStrn_search_cond(tp->lhs,table_list,update_table,
				 func_flag,targ_type,targ_size,group_colist);
				updatable &= RIStrn_search_cond(tp->rhs,table_list,update_table,
				 func_flag,targ_type,targ_size,group_colist);
			break;
			case RIS_TOK_ASGN:
				RIStrn_decimal_list = 0;
				RIStrn_search_cond(tp->lhs,table_list,update_table,func_flag,
					targ_type,targ_size,group_colist);
				targ_type = RIStrn_get_type(tp->lhs);
				targ_size = RIStrn_get_size(tp->lhs);
				RIStrn_search_cond(tp->rhs,table_list,update_table,func_flag,
					targ_type,targ_size,group_colist);
				RIStrn_typecheck(tp,targ_type,targ_size);
				if (ATTR_TYPE(targ_type) == RIS_DECIMAL)
					RIStrn_fix_decimal_size(targ_size);
			break;
			case RIS_TOK_EQ:
			case RIS_TOK_NE:
			case RIS_TOK_GT:
			case RIS_TOK_LT:
			case RIS_TOK_GE:
			case RIS_TOK_LE:
			case RIS_TOK_BETWEEN:
				RIStrn_pos_targ_type = RIS_SMALLINT;
				RIStrn_real_list = 0;
				RIStrn_int_list = 0;
				RIStrn_smallint_list = 0;
				RIStrn_between_ptr = tp;
				updatable &= RIStrn_search_cond(tp->lhs,table_list,update_table,
				 func_flag,targ_type,targ_size,group_colist);
				updatable &= RIStrn_search_cond(tp->rhs,table_list,update_table,
				 func_flag,targ_type,targ_size,group_colist);
				RIStrn_typecheck(tp,targ_type,targ_size);
			break;
			case RIS_TOK_LIKE:
			case RIS_TOK_PLUS:
			case RIS_TOK_SUB:
			case RIS_TOK_MUL:
			case RIS_TOK_DIV:
			case RIS_TOK_UNARYMINUS:
			case RIS_TOK_BETWEEN_AND:
				RIStrn_search_cond(tp->lhs,table_list,update_table,func_flag,
				 targ_type,targ_size,group_colist);
				RIStrn_search_cond(tp->rhs,table_list,update_table,func_flag,
				 targ_type,targ_size,group_colist);
				RIStrn_typecheck(tp,targ_type,targ_size);
			break;
			case RIS_TOK_IS:
				RIStrn_search_cond(tp->lhs,table_list,update_table,func_flag,
				 targ_type,targ_size,group_colist);
			break;
			case RIS_TOK_IN:
				RIStrn_pos_targ_type = RIS_SMALLINT;
				RIStrn_real_list = 0;
				RIStrn_int_list = 0;
				RIStrn_smallint_list = 0;
				updatable &= RIStrn_search_cond(tp->lhs,table_list,update_table,
				 func_flag,targ_type,targ_size,group_colist);
				updatable &= RIStrn_search_cond(tp->rhs,table_list,update_table,
				 func_flag,targ_type,targ_size,group_colist);
				RIStrn_typecheck(tp,targ_type,targ_size);
			break;
			case RIS_TOK_ALL:
			case RIS_TOK_ANY:
				updatable &= RIStrn_search_cond(tp->rhs,table_list,update_table,
				 func_flag,targ_type,targ_size,group_colist);
				RIStrn_typecheck(tp,targ_type,targ_size);
			break;
			case RIS_TOK_EXISTS:
			case RIS_TOK_VALUES:
				updatable &= RIStrn_search_cond(tp->rhs,table_list,update_table,
				 func_flag, targ_type,targ_size,group_colist);
			break;
			case RIS_TOK_SELECT:
				updatable = 0;
				RIStrn_select(tp,table_list,update_table,group_colist);
			break;
			case RIS_TOK_ATTR:
				RIStrn_check_unsupported_type(tp);
			break;
			case RIS_TOK_NULL:
			case RIS_TOK_EXACT_NUM_LIT:
			case RIS_TOK_APPROX_NUM_LIT:
			break;
			case RIS_TOK_CHAR_STR_LIT:
				RIStrn_remove_trail_blanks(tp, RIS_blankstrip_mode);
			break;
			case RIS_TOK_CURRENT_TIMESTAMP:
			case RIS_TOK_TIMESTAMP_LIT:
			break;
			case RIS_TOK_QUESTION:
				RIStrn_parm_quest(tp);
			break;
			case RIS_TOK_AUTH_ID:
			case RIS_TOK_USR_NAME:
			case RIS_TOK_TABLE_NAME:
			case RIS_TOK_COL_NAME:
				RIStrn_col_name(tp,table_list,0);
				RIStrn_is_group_col(tp,group_colist,table_list);
				RIStrn_check_unsupported_type(tp);
			break;
			case RIS_TOK_SUM:
			case RIS_TOK_AVG:
			case RIS_TOK_MAX:
			case RIS_TOK_MIN:
			case RIS_TOK_COUNT:
				if (func_flag)
				{
					if (tp->tok != RIS_TOK_COUNT || tp->rhs->tok != RIS_TOK_MUL)
					{
						RIStrn_search_cond(tp->rhs,table_list,update_table,0,
							targ_type,targ_size,(ristree *)0);
					}
					RIStrn_typecheck(tp,targ_type,targ_size);
				}
				else
				{
					TRN_ERR_RETURN(RIS_E_FUNC_NOT_ALLOWED,tp->pos);
				}
			break;
			default:
				TRN_ERR_RETURN(RIS_E_INTERNAL_ERROR,tp->pos);
			break;
		}
	}
	return(updatable);
}

/******************************************************************************/

/*
** fix where parse tree
** wherep = where parse tree table_list = tables from from clause 
** update table = insert/update/delete table
** group_colist = list of grouping columns
** 5.21 <where clause> syntax rule 1 checked by RIStrn_search_cond
** 5.21 <where clause> syntax rule 2 checked by RIStrn_search_cond
** 5.21 <where clause> syntax rule 3 checked by RIStrn_search_cond
*/

extern int RIStrn_where(
	ristree * wherep,
	ristree * table_list,
	ristree * update_table,
	ristree * group_colist)
{
	int updatable;

TRN_DBG(("\nRIStrn_where wherep = 0x%x table_list = 0x%x update_table = 0x%x\
 group_colist = 0x%x\n",
 wherep,table_list,update_table,group_colist));

	updatable = RIStrn_search_cond(wherep->rhs,table_list,update_table,0,
		RIS_UNKNOWN_TYPE,0,group_colist);

	return(updatable);
}

/******************************************************************************/
