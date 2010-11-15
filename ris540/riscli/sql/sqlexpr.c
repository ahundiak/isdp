/*
**	NAME:							sqlexpr.c
**	AUTHORS:						Dave Buehmann
**	CREATION DATE:					4/88
**	ABSTRACT:
**
**	
**	REVISION HISTORY:
**		10/24/94 -Radha
**			Added changes for MSSQL data server.
*/
 
/*
**	INCLUDES
*/
#include <ctype.h>
#include "riscom.h"
#include "rissttyp.h"
#include "ristoken.h"
#include "rissql.h"
/*****  BLOB ******/
#include "riscl_sr.h"
/*****  BLOB ******/
/***** RENAME ******/
#include "riscli.h"
#include "risdict.h"


/*
**	FUNCTION PROTOTYPES
*/
#define sqlexpr_c
#include "comdebug.prt"
#include "comgtnme.prt"
#include "comisfn.prt"
#include "comjmp.prt"
#include "comsqlms.prt"
#include "sqldel.prt"
#include "sqlexpr.prt"
#include "sqlindex.prt"
#include "sqlinsrt.prt"
#include "sqlmisc.prt"
#include "sqlselct.prt"
#include "sqltable.prt"
#include "sqlupdt.prt"
#include "sqlview.prt"
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

extern void RISsql_expr(
	ristree	*tp,
	rissql	*sql)
{
/*****  BLOB *****/
    static int  blob_count=0;
/*****  BLOB *****/
/***** RENAME  *****/
    int  tabid=0;

	if (!tp) return;

	SQL_DBG(("in RISsql_expr; tok: %s\n", RIScom_get_token_name(tp->tok)));

	switch(tp->tok)
	{
		case RIS_TOK_VALUES:
			if (sql->stmt_type != RIS_INSERT_STMT)
			{
				CONSTADD(" (");
			}
			else
			{
				CONSTADD("values (");
			}
			RISsql_expr(tp->rhs, sql);
			CONSTADD(")");

			break;

		case RIS_TOK_APPROX_NUM_LIT:
		case RIS_TOK_CHAR_STR_LIT:
			STRADD(tp->info.val);
			break;

		case RIS_TOK_EXACT_NUM_LIT:
			STRADD(tp->info.val);

			/* asc or desc for order by */
			RISsql_expr(tp->rhs, sql);

			break;

		case RIS_TOK_TIMESTAMP_LIT:
			RISsql_add_timestamp(sql, (dtime*)tp->info.val);
			break;

		case RIS_TOK_CURRENT_TIMESTAMP:
			switch (sql->schema->db->dtype)
			{
				case 'X':
					CONSTADD("current");
				break;
				case 'I':
					CONSTADD("date(\'now\')");
				break;
				case 'O':
					CONSTADD("sysdate");
				break;
				case 'D':
				case '4':
					CONSTADD("current timestamp");
				break;
				case 'R':
					CONSTADD("current_timestamp");
				break;
				case 'Y':
					CONSTADD("getdate()");
				break;
				case 'M':
					CONSTADD("getdate()");
				break;
				default:
					LONGJMP(RIS_E_INTERNAL_ERROR);
				break;
			}
			break;

		case RIS_TOK_ATTR:
			
			tabid = RISsql_get_tabid(sql->schema, tp->info.attr->tab);

			if (sql->stmt_type == RIS_SELECT_STMT)
			{
				RISsql_add_attr_qualification(
					sql->schema, tp->info.attr->tab, tabid);
			}

			RISsql_add_attr(sql->schema, tp->info.attr, tabid);

            /*  BLOB */
            SQL_DBG(("in RISsql_expr; tp->info.attr->atype %d\n",
                     tp->info.attr->atype));

            SQL_DBG(("in RISsql_expr; blob_count %d\n", blob_count));
            if (ATTR_TYPE(tp->info.attr->atype) == RIS_BLOB ||
                ATTR_TYPE(tp->info.attr->atype) == RIS_TEXT)
             blob_count ++;
            /*  BLOB */
			break;

		case RIS_TOK_PARAMETER:
			/*
			** Various types of place holders:   
			**
			**   INFORMIX: insert into x values (?,?,?);	(default)
			**   ORACLE  : insert into x values (:x0,:x1,:x2);
			*/
			if (sql->schema->db->dtype == 'O') 
			{
				char buf[20];

				sprintf(buf, ":x%d", RISsql_parm_num);
				SQL_DBG(("RISsql_parm_num %d, buf is <%s>\n",RISsql_parm_num, buf));
				++RISsql_parm_num;
				if (tp->info.data->sqltype == RIS_DATETIME)
				{
					CONSTADD("to_date(");
				}
				STRADD(buf);
				if (tp->info.data->sqltype == RIS_DATETIME)
				{
					CONSTADD(",'yyyy-mm-dd hh24:mi:ss')");
				}
			}
			else 
			{
				CONSTADD("?");
			}
			break;

		case RIS_TOK_TABLE:
			
			tabid = RISsql_get_tabid(sql->schema, tp->info.tab);

			RISsql_add_tab_qualification(sql->schema, tp->info.tab, tabid);
			RISsql_add_table(sql->schema, tp->info.tab, tabid);

            if (sql->stmt_type == RIS_SELECT_STMT)
			{
				if (sql->schema->db->dtype == '4')
				{
                	CONSTADD(" ");
					if (tp->info.tab->tabtype != 'A')
					{
						RISsql_add_alias_id( 
							tp->info.tab->tabowner, 
							tp->info.tab->extern_tabname);
					}
					else
					{
						RISsql_add_alias_id( 
							tp->info.tab->tabowner, 
							tp->info.tab->tabname);
					}
				}
				else if (tp->info.tab->tabtype == 'A')
				{
                	CONSTADD(" ");
                   	STRADD(tp->info.tab->tabname);
				}
			}
			break;

		case RIS_TOK_LIST:
			if (((sql->schema->db->dtype == 'Y') ||
				 (sql->schema->db->dtype == 'M')) 
			    && (RISsql_in_subquery))
			{
				/* stop expansion of * for sybase -- SRB */
				SQL_DBG(("In SUBQUERY and avoiding list\n"));
				CONSTADD(" * ");
			}
			else
			{
				RISsql_expr(tp->lhs, sql);

				if (tp->rhs)
				{
					CONSTADD(", ");
					RISsql_expr(tp->rhs, sql);
				}
			}
			break;

		case RIS_TOK_EQ:
		case RIS_TOK_ASGN:
			RISsql_expr(tp->lhs, sql);
			CONSTADD(" = ");
			RISsql_expr(tp->rhs, sql);
			break;

		case RIS_TOK_NE:
			RISsql_expr(tp->lhs, sql);
			CONSTADD(" <> ");
			RISsql_expr(tp->rhs, sql);
			break;

		case RIS_TOK_LT:
			RISsql_expr(tp->lhs, sql);
			CONSTADD(" < ");
			RISsql_expr(tp->rhs, sql);
			break;

		case RIS_TOK_GT:
			RISsql_expr(tp->lhs, sql);
			CONSTADD(" > ");
			RISsql_expr(tp->rhs, sql);
			break;

		case RIS_TOK_LE:
			RISsql_expr(tp->lhs, sql);
			CONSTADD(" <= ");
			RISsql_expr(tp->rhs, sql);
			break;

		case RIS_TOK_GE:
			RISsql_expr(tp->lhs, sql);
			CONSTADD(" >= ");
			RISsql_expr(tp->rhs, sql);
			break;

/* operators that may need parenthesis */

		case RIS_TOK_PLUS:
		case RIS_TOK_SUB:
		case RIS_TOK_MUL:
		case RIS_TOK_DIV:
		case RIS_TOK_OR:
		case RIS_TOK_AND:
		case RIS_TOK_UNARYMINUS:
		case RIS_TOK_NOT:
			if (tp->lhs)
			{
				if (RIScom_need_parens(tp->tok,tp->lhs->tok,'L'))
				{
					CONSTADD("(");
					RISsql_expr(tp->lhs, sql);
					CONSTADD(")");
				}
				else
				{
					RISsql_expr(tp->lhs, sql);
				}
			}
			switch(tp->tok)
			{
				case RIS_TOK_MUL:
					CONSTADD(" * ");
					break;

				case RIS_TOK_DIV:
					CONSTADD(" / ");
					break;

				case RIS_TOK_PLUS:
					CONSTADD(" + ");
					break;

				case RIS_TOK_SUB:
					CONSTADD(" - ");
					break;

				case RIS_TOK_AND:
				case RIS_TOK_OR:
					CONSTADD(" ");
					add_token_string(tp->tok);
					CONSTADD(" ");
					break;

				case RIS_TOK_NOT:
					add_token_string(tp->tok);
					CONSTADD(" ");
					break;

				case RIS_TOK_UNARYMINUS:
					CONSTADD("-");
					break;
			}
			if (RIScom_need_parens(tp->tok,tp->rhs->tok,'R'))
			{
				CONSTADD("(");
				RISsql_expr(tp->rhs, sql);
				CONSTADD(")");
			}
			else
			{
				RISsql_expr(tp->rhs, sql);
			}
			break;

		case RIS_TOK_AVG:
		case RIS_TOK_MAX:
		case RIS_TOK_MIN:
		case RIS_TOK_SUM:
			add_token_string(tp->tok);
			if (tp->lhs->tok == RIS_TOK_ALL)
			{
				CONSTADD("(all ");
			}
			else if (tp->lhs->tok == RIS_TOK_DISTINCT)
			{
				if (sql->schema->db->dtype == 'Y' ||
					 sql->schema->db->dtype == 'M')
				{
					/* avoid distinct for max,min for SYBASE */
					if ((tp->tok == RIS_TOK_AVG) || (tp->tok == RIS_TOK_SUM))
					{
						CONSTADD("(distinct ");
					}
					else
					{
						CONSTADD("(");
					}
				}
				else
				{
					CONSTADD("(distinct ");
				}
			}
			else
			{
				LONGJMP(RIS_E_INTERNAL_ERROR);
			}
			RISsql_expr(tp->rhs, sql);
			CONSTADD(")");
			break;

		case RIS_TOK_COUNT:
			CONSTADD("count(");
			if (tp->lhs)
			{
				if (tp->lhs->tok == RIS_TOK_DISTINCT)
				{
					CONSTADD("distinct ");
				}
				else LONGJMP(RIS_E_INTERNAL_ERROR);
			}
			if (tp->rhs->tok == RIS_TOK_MUL) 
			{
				CONSTADD("*");
			}
			else
			{
				RISsql_expr(tp->rhs, sql);
			}

			CONSTADD(")");
			break;

		case RIS_TOK_INSERT:
			RISsql_insert(tp, sql);
			break;

		case RIS_TOK_DELETE:
			RISsql_delete(tp, sql);
			break;

		case RIS_TOK_UPDATE:
			RISsql_update(tp, sql);
			break;

		case RIS_TOK_SELECT:
			RISsql_sql_select(tp, sql);
			break;

		case RIS_TOK_UNION_ALL_SELECT:
		case RIS_TOK_UNION_SELECT:
			RISsql_union_select(tp, sql);
			break;

		case RIS_TOK_CREATE_TABLE:
			RISsql_create_table(tp, sql);
			break;

		case RIS_TOK_DROP_TABLE:
			RISsql_drop_table(tp, sql);
			break;

		case RIS_TOK_CREATE_VIEW:
			RISsql_create_view(tp, sql);
			break;

		case RIS_TOK_DROP_VIEW:
			RISsql_drop_view(tp, sql);
			break;

		case RIS_TOK_ALTER_TABLE:
			RISsql_alter_table(tp, sql);
			break;

		case RIS_TOK_LOCK_TABLES:
			RISsql_lock_table(tp, sql);
			break;

		case RIS_TOK_CREATE_INDEX:
			RISsql_create_index(tp, sql);
			break;

		case RIS_TOK_DROP_INDEX:
			RISsql_drop_index(tp, sql);
			break;

		case RIS_TOK_ASC:
		case RIS_TOK_DESC:
		case RIS_TOK_NULL:
			CONSTADD(" ");
			add_token_string(tp->tok);
			break;

		case RIS_TOK_ALL:
		case RIS_TOK_ANY:
		case RIS_TOK_EXISTS:
		case RIS_TOK_DISTINCT:
			add_token_string(tp->tok);
			CONSTADD(" ");
			RISsql_expr(tp->rhs, sql);
			break;

		case RIS_TOK_IN:
		case RIS_TOK_IS:
		case RIS_TOK_LIKE:
		case RIS_TOK_BETWEEN:
			RISsql_expr(tp->lhs, sql);
			CONSTADD(" ");
			add_token_string(tp->tok);
			CONSTADD(" ");
			RISsql_expr(tp->rhs, sql);
			break;

		case RIS_TOK_BETWEEN_AND:
			RISsql_expr(tp->lhs, sql);
			CONSTADD(" and ");
			RISsql_expr(tp->rhs, sql);
			break;

		case RIS_TOK_FROM:
		{
			tablelist *tablist = 0;

			/*
			**	Process "FROM clause"
			*/
			CONSTADD(" ");
			add_token_string(tp->tok);
			CONSTADD(" ");
			RISsql_expr(tp->rhs, sql);

			/*
			**	Check for RIS dictionary tables in the FROM clause
			*/
			RISsql_search_from_list(tp, &tablist);
			if (tablist)
			{
				/*
				**	The query involves a RIS dictionary table(s).
				**	Test if there is a WHERE clause. If there is,
				**	place parentheses around the original where clause
				**	and append the new condition(s).  Otherwise,
				**	add a where clause with the new condition(s).
				*/
				if (tp->lhs && tp->lhs->tok == RIS_TOK_WHERE)
				{
					SQL_DBG(("modifying the where clause\n"));

					CONSTADD(" where (");
					RISsql_expr(tp->lhs->rhs, sql);
					CONSTADD(") and ");

					RISsql_add_dict_tab_condition(sql, tablist);

					RISsql_expr(tp->lhs->lhs, sql);
				}
				else
				{
					SQL_DBG(("adding a where clause\n"));
					CONSTADD(" where ");

					RISsql_add_dict_tab_condition(sql, tablist);

					RISsql_expr(tp->lhs, sql);
				}
			}
			else
			{
				/*
				**	The query doesn't involve any RIS dictionary tables.
				*/
				RISsql_expr(tp->lhs, sql);
			}
		}
		break;

		case RIS_TOK_WHERE:
		case RIS_TOK_GROUP_BY:
		case RIS_TOK_HAVING:
		case RIS_TOK_ORDER_BY:
			CONSTADD(" ");
			add_token_string(tp->tok);
			CONSTADD(" ");
 			/*  BLOB 
 				Initialize the blobcount for where clause 
 			*/
             		blob_count = 0;
			RISsql_expr(tp->rhs, sql);
			RISsql_expr(tp->lhs, sql);
			
			/*  BLOB 
				Make sure the blob/text column is not used
				in the where clause.
			*/
            SQL_DBG(("in RISsql_expr; blob_count %d\n", blob_count));
            if(blob_count)
            {
                blob_count = 0;
                LONGJMP(RIS_E_BAD_BLOB_COL);
            }
            break;

		case RIS_TOK_EXEC:
			STRADD(tp->info.val);
			break;

		default:
			LONGJMP(RIS_E_INTERNAL_ERROR);
			break;
	}
}

/******************************************************************************/

static void add_token_string(
	int tok)
{
	char	token_buf[100];
	char	*cp;

	strcpy(token_buf, RIScom_get_token_name(tok));
	cp = token_buf;
	for(;*cp;cp++)
	{
		if (*cp == '_')
		{
			*cp = ' ';
		}
		else
		{
			if (RIScom_isupper(*cp))
			{
				*cp = RIScom_tolower(*cp);
			}
		}
	}
	STRADD(token_buf);
}

/******************************************************************************/
