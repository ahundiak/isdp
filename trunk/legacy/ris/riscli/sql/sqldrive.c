/*
**	NAME:							sqldrive.c
**	AUTHORS:						Dave Buehmann
**	CREATION DATE:					4/88
**	ABSTRACT:
**		
**	
**	REVISION HISTORY:
*/
 
#define SQL_GLOBAL_DEFINE

/*
**	INCLUDES
*/
#include "riscli.h"
#include "riscom.h"
#include "rismem.h"
#include "ristoken.h"
#include "rissql.h"

/*
**	FUNCTION PROTOTYPES
*/
#define sqldrive_c
#include "ccooutpt.prt"
#include "comdebug.prt"
#include "comalloc.prt"
#include "comjmp.prt"
#include "comoutpt.prt"
#include "comsttyp.prt"
#include "diclook.prt"
#include "sqldrive.prt"
#include "sqlexpr.prt"
#include "sqlpred.prt"
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


extern void RISsql_driver()
{
	ristree	*tp;
	rissql	*sql;
	int     generate_sql = 0;
	ristree *tabtp;

	tp = RIS_stmt->tree;

	if (RISsql_debug)
	{
		SQL_DBG(("RISsql_driver()\n"));
		RIScco_output_internal_tree(RIScom_output_debug, tp);
	}

	if (!RISsql_query_buf)
	{
		RISsql_query_buf = RIScom_alloc(RISsql_query_buf_size, 0,
		 SQL_PERMANENT_MARK, PERMANENT_MEMORY);
	}
	RISsql_query_len = 0;

	sql = RIS_stmt->sql;
	switch(tp->tok)
	{
		case RIS_TOK_CREATE_SCHEMA:
		case RIS_TOK_ALTER_SCHEMA:
		case RIS_TOK_DROP_SCHEMA:
		case RIS_TOK_OPEN_SCHEMA:
		case RIS_TOK_CLOSE_SCHEMA:
		case RIS_TOK_DECLARE_SUPERSCHEMA:
		case RIS_TOK_REDECLARE_SUPERSCHEMA:
		case RIS_TOK_UNDECLARE_SUPERSCHEMA:
		case RIS_TOK_UNDECLARE_SCHEMA:
		case RIS_TOK_SET:

			/* these statements do not need to have sql generated */

			generate_sql = 0;

		    /* these statements may reference multiple schemas */

			sql->schema = 0;
		break;

		case RIS_TOK_DEFAULT_SCHEMA:
		case RIS_TOK_DECLARE_SCHEMA:

			/* these statements do not need to have sql generated */

			generate_sql = 0;

			sql->schema = RISdic_lookup_schema(tp->rhs->lhs->info.val,
			 HASH_TABLE);
		break;

		case RIS_TOK_GRANT:
		case RIS_TOK_GRANT_ON_TABLE:
		case RIS_TOK_REVOKE:
		case RIS_TOK_REVOKE_ON_TABLE:

			/* these statements do not need to have sql generated */

			generate_sql = 0;

		    /* get the schema for these statements */

			if (tp->info.access->flag == 'T')
			{
		    	sql->schema = tp->info.access->ptr.tab->schema;
			}
			else if (tp->info.access->flag == 'A')
			{
		    	sql->schema = tp->info.access->ptr.attr->tab->schema;
			}
			else
			{
				LONGJMP(RIS_E_INTERNAL_ERROR);
			}
		break;

		case RIS_TOK_GRANT_SCHEMA:
		case RIS_TOK_GRANT_CONNECT:
		case RIS_TOK_GRANT_RESOURCE:
		case RIS_TOK_REVOKE_SCHEMA:
		case RIS_TOK_REVOKE_CONNECT:
		case RIS_TOK_REVOKE_RESOURCE:
		   
		   /* these statements do not need to have sql generated */

		   generate_sql = 0;

		  /* get the schema for these statements */

		   sql->schema = RIS_default;
		break;

        case RIS_TOK_COMMIT:
        case RIS_TOK_ROLLBACK:

		   /* these statements do not need to have sql generated */

		   generate_sql = 0;

		  /* get the schema for these statements */

		   sql->schema = tp->rhs->info.schema;
		break;

		case RIS_TOK_DECLARE_TABLE:
		case RIS_TOK_DECLARE_VIEW:
		case RIS_TOK_UNDECLARE_TABLE:
		case RIS_TOK_UNDECLARE_VIEW:

		   /* these statements do not need to have sql generated */

		   generate_sql = 0;

		  /* get the schema for these statements */

		   sql->schema = tp->rhs->info.tab->schema;
		break;
		case RIS_TOK_SELECT:
			RIS_ris5dbs_flag = 0;
			RIS_ris5schemas_flag = 0;
			RIS_ris5dict_flag = 0;

			SQL_DBG(("RISsql_driver: table_name <%s.%s>\n", 
				tp->lhs->rhs->lhs->info.tab->tabowner,
				tp->lhs->rhs->lhs->info.tab->tabname));
			/* get the schema for a select statement */

			tabtp = tp->lhs->rhs->lhs;

			/* the table may be aliased */

			if (tabtp->info.tab->tabtype == 'A')
			{
				sql->schema = tabtp->info.tab->tab->schema;
			}
			else
			{
				sql->schema = tabtp->info.tab->schema;
			}
			generate_sql = 1;
		break;
		case RIS_TOK_INSERT:
		case RIS_TOK_DELETE:
		case RIS_TOK_UPDATE:

			/* get the schema for all dml statements except for select */

			if (tp->rhs->info.tab->tabtype  == 'A')
			{
				sql->schema = tp->rhs->info.tab->tab->schema;
			}
			else
			{
				sql->schema = tp->rhs->info.tab->schema;
			}
			generate_sql = 1;
		break;
		case RIS_TOK_LOCK_TABLES:

			/* OLD: tabtp = tp->rhs->lhs; */

			tabtp = tp->rhs->lhs->rhs->lhs;
			if (tabtp->info.tab->tabtype  == 'A')
				sql->schema = tabtp->info.tab->tab->schema;
			else
				sql->schema = tabtp->info.tab->schema;

			generate_sql = 1;
		break;
		case RIS_TOK_CREATE_TABLE:
		case RIS_TOK_ALTER_TABLE:
		case RIS_TOK_DROP_TABLE:
		case RIS_TOK_CREATE_VIEW:
		case RIS_TOK_DROP_VIEW:
		case RIS_TOK_CREATE_INDEX:
		case RIS_TOK_DROP_INDEX:
        case RIS_TOK_EXEC:
            /* these statements must use the default schema */

			sql->schema = RIS_default;
			generate_sql = 1;

		break;

		default:
			LONGJMP(RIS_E_INTERNAL_ERROR);
		break;
	}

	if (sql->schema)
	{
		SQL_DBG(("sql->schema = 0x%x\n",sql->schema));

		/*
		**	Save the schema name in case the schema pointer is set to
		**	zero later (i.e close schema or drop schema).
		*/
		strcpy(sql->schname, sql->schema->schname);

		SQL_DBG(("sql->schname = <%s>\n",sql->schname));
	}
	sql->stmt_type = RIScom_tok_to_stmt_type(tp->tok);

	if (!generate_sql)
	{
		RIS_stmt->write_buf_size =
			RISsql_predict_buffer_size(tp,PREDICT_WRITE_BUFFER);
		RIS_stmt->read_buf_size =
			RISsql_predict_buffer_size(tp,PREDICT_READ_BUFFER);
		RIS_stmt->fetch_buf_size =
			RISsql_predict_buffer_size(tp,PREDICT_FETCH_BUFFER);
		SQL_DBG(("RISsql_driver: complete\n"));
		return;
	}

	/*
	** in the event we are dealing with an ORACLE statement with
	** parameters, initialize the parameter counter to 1.
	*/
	RISsql_parm_num = 1;

	RISsql_alias_list = 0;

	RISsql_expr(tp, sql);

	sql->query = ALLOCB(RISsql_query_len + 1);
	memcpy(sql->query, RISsql_query_buf, RISsql_query_len);
	memset(RISsql_query_buf, 0, RISsql_query_buf_size);

	RIS_stmt->write_buf_size =
		RISsql_predict_buffer_size(tp,PREDICT_WRITE_BUFFER);
	RIS_stmt->read_buf_size =
		RISsql_predict_buffer_size(tp,PREDICT_READ_BUFFER);
	RIS_stmt->fetch_buf_size =
		RISsql_predict_buffer_size(tp,PREDICT_FETCH_BUFFER);

	if (tp->tok == RIS_TOK_SELECT)
	{
		RIS_stmt->flags.risdbs = (char)RIS_ris5dbs_flag;
		RIS_stmt->flags.risschemas = (char)RIS_ris5schemas_flag;
	}

	if (RISsql_debug || RISstmt_debug)
	{
		RIScom_output_debug("\n\nSQL Query:\n");
		RIScom_output_sql_query(RIScom_output_debug, sql, 1);
	}
	SQL_DBG(("RISsql_driver: complete\n"));
}

/******************************************************************************/
