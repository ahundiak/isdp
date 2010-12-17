/*
**	NAME:							sqlindex.c
**	AUTHORS:						Dave Buehmann
**	CREATION DATE:					4/88
**	ABSTRACT:
**
**	
**	REVISION HISTORY:
*/
 
/*
**	INCLUDES
*/
#include "riscom.h"
#include "ristoken.h"
#include "rissql.h"
#include "riscli.h"

/*
**	FUNCTION PROTOTYPES
*/
#define sqlindex_c
#include "sqlindex.prt"
#include "comdebug.prt"
#include "sys.prt"
#include "sqlexpr.prt"
#include "sqlmisc.prt"



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

extern void RISsql_create_index(
	ristree	*tp,
	rissql	*sql)
{
	ristree *ext_index = tp->lhs;

SQL_DBG(("RISsql_create_index tp = 0x%x\n sql = 0x%x",tp,sql));
	
	/* We borrow relname fields to store index names (external and internal) */ 	
	strcpy(sql->ris_relname, tp->rhs->info.val);
	strcpy(sql->ext_relname, ext_index->info.val);
	sql->reltype = 'D';
	/* Server needs ris table name */
	strcpy(sql->relname, tp->rhs->lhs->info.tab->tabname);

	tp = tp->rhs;

	CONSTADD("create ");

	if (tp->rhs && tp->rhs->tok == RIS_TOK_UNIQUE)
	{
		CONSTADD("unique ");
		sql->reltype = 'U';
	}
	CONSTADD("index ");

	STRADD(ext_index->info.val);
	CONSTADD(" on ");

	tp = tp->lhs;

    if (sql->schema->db->dtype != 'I')
    {
    	if (sql->schema->db->dtype == 'X')
    	{
			CONSTADD("\"");
    		STRADD(tp->info.tab->tabowner);
   			CONSTADD("\"");
		}
   		else 
    	{
    		STRADD(tp->info.tab->tabowner);
    	}


		if (sql->schema->db->dtype == '4')
    	{
			CONSTADD("/");
    	}
   		else
   		{
			CONSTADD(".");
		}
	}

	STRADD(tp->info.tab->extern_tabname);

	CONSTADD("(");

	/* add the column list */
	RISsql_expr(tp->rhs, sql);

	CONSTADD(")");
}

/******************************************************************************/

extern void RISsql_drop_index(
	ristree	*tp,
	rissql	*sql)
{

SQL_DBG(("RISsql_drop_index tp = 0x%x\n sql = 0x%x",tp,sql));

	strcpy(sql->ris_relname, tp->rhs->info.val);
	CONSTADD("drop index ");
	STRADD(tp->rhs->info.val);
}

/******************************************************************************/
