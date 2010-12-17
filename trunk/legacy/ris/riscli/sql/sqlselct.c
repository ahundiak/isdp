/*
**	NAME:							sqlselct.c
**	AUTHORS:						Dave Buehmann
**	CREATION DATE:					4/88
**	ABSTRACT:
**		Translate a select statement.
**	
**	REVISION HISTORY:
**		Add RISsql_union_select() by Jin Jing 8/93
**		10/24/94 -Radha
**			Added changes for MSSQL data server.
*/
 
/*
**	INCLUDES
*/
#include "riscom.h"
#include "rissttyp.h"
#include "ristoken.h"
#include "riscli.h"
#include "rissql.h"

/*
**	FUNCTION PROTOTYPES
*/
#define sqlselct_c
#include "sqlselct.prt"
#include "sys.prt"
#include "sqlexpr.prt"
#include "sqlmisc.prt"
#include "comdebug.prt"
#include "comjmp.prt"
#include "comsttyp.prt"



/*
**	DEFINES
*/

/*
**	VARIABLES
*/

/*
**	FUNCTIONS
*/


extern void RISsql_sql_select(
	ristree *select,
	rissql	*sql)
{
	char old_stmt_type;
	char *querybuf;
	char *c1, *c2orig;
	char *c2;
	short done = 0;

	SQL_DBG(("RISsql_sql_select(select:0x%x sql:0x%x)\n", select, sql));

	querybuf = RISsql_query_buf;

	old_stmt_type = sql->stmt_type;
	sql->stmt_type = RIScom_tok_to_stmt_type(select->tok);

	if (select != RIS_stmt->tree && old_stmt_type != RIS_INSERT_STMT &&
	 old_stmt_type != RIS_CREATE_VIEW_STMT)
	{
		CONSTADD("(");
		/*
		** code that sets subquery flag only if there is a subquery of type
		** (select * or ( select *; used to stop  expansion of * for SYBASE
		*/
		if (sql->schema->db->dtype == 'Y' || sql->schema->db->dtype == 'M')
		{
			/*
			** c2 points to the beginning of the query buffer being built.
			*/
			c2 = (char *)&querybuf[0];
			/*
			** c2orig points to the beginning of the original query buffer.
			*/
			c2orig = (char *)STRING(RIS_app_read->buf.prep.data);
			while(!done)
			{
				if (c2orig[7] &&
					(c2orig[0] == 'S' || c2orig[0] == 's') &&
					(c2orig[1] == 'E' || c2orig[1] == 'e') &&
					(c2orig[2] == 'L' || c2orig[2] == 'l') &&
					(c2orig[3] == 'E' || c2orig[3] == 'e') &&
					(c2orig[4] == 'C' || c2orig[4] == 'c') &&
					(c2orig[5] == 'T' || c2orig[5] == 't'))
				{
					c1 = (char *)strstr(c2, "select"); /*itbokic 3/30  SELECT keyword*/
					if ((c1 > c2) || (c1 != NULL))
					{
						c2 = (char *)(c1 + 1);
					}
					else
					{
						done = 1;
					}
				}
				c2orig++;
			}
			if (c2orig[6] && c2orig[6] == '*')
			{
				RISsql_in_subquery = 1;
			}
		}
	}

	CONSTADD("select ");

/* add the select list */

	RISsql_expr(select->rhs, sql);

	if (RISsql_in_subquery)
	{
		SQL_DBG(("Ending SUBQUERY\n"));
		RISsql_in_subquery = 0;
	}

/* add the from, where, group by, having, and order by clauses */ 

	RISsql_expr(select->lhs, sql);

	if (select != RIS_stmt->tree && old_stmt_type != RIS_INSERT_STMT &&
	 old_stmt_type != RIS_CREATE_VIEW_STMT)
	{
		CONSTADD(")");
	}
	
	sql->stmt_type = old_stmt_type;

	SQL_DBG(("RISsql_sql_select:complete\n"));
}

/******************************************************************************/

extern void RISsql_union_select(
	ristree *select,
	rissql	*sql)
{
	SQL_DBG(("RISsql_union_select(select:0x%x sql:0x%x)\n", select, sql));

	if (select->tok == RIS_TOK_UNION_ALL_SELECT)
	{
		CONSTADD(" union all ");
	}
	else if (select->tok == RIS_TOK_UNION_SELECT)
	{
		CONSTADD(" union ");
	}
	else
	{
		LONGJMP(RIS_E_INTERNAL_ERROR);
	}

	CONSTADD("select ");

/* add the select list */

	RISsql_expr(select->rhs, sql);

/* add the from, where, group by, having, and order by clauses */ 

	RISsql_expr(select->lhs, sql);

	SQL_DBG(("RISsql_union_select:complete\n"));
}

/******************************************************************************/
