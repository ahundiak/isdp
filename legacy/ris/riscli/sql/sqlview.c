/*
**	NAME:							sqlview.c
**	AUTHORS:						David Michal
**	CREATION DATE:					12/88
**	ABSTRACT:
**		
**	
**	REVISION HISTORY:
*/
 
/*
**	INCLUDES
*/
#include "riscom.h"
#include "rissql.h"
#include "riscli.h"

/*
**	FUNCTION PROTOTYPES
*/
#define sqlview_c
#include "sqlview.prt"
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

extern void RISsql_create_view(
	ristree	*tp,
	rissql	*sql)
{

SQL_DBG(("RISsql_create_view tp = 0x%x sql = 0x%x\n",tp,sql));

	CONSTADD("create view ");
	/*RISsql_expr(tp->rhs, sql);*/
	strcpy(sql->ris_relname, tp->rhs->info.tab->tabname);
	strcpy(sql->ext_relname, tp->rhs->info.tab->extern_tabname);

    if (sql->schema->db->dtype == '4' )
    {
        STRADD(sql->schema->db->dbname);
        CONSTADD("/");
    }

	STRADD(tp->rhs->info.tab->extern_tabname);

	/* add the var list */

	CONSTADD("(");
	RISsql_expr(tp->rhs->rhs,sql);
	CONSTADD(") as ");

	/* add the query specification */

	RISsql_expr(tp->rhs->lhs,sql);
}

/******************************************************************************/

extern void RISsql_drop_view(
	ristree	*tp,
	rissql	*sql)
{

SQL_DBG(("RISsql_drop_view tp = 0x%x sql = 0x%x\n",tp,sql));

	strcpy(sql->ris_relname, tp->rhs->info.tab->tabname);
	strcpy(sql->ext_relname, tp->rhs->info.tab->extern_tabname);
	strcpy(sql->relowner, tp->rhs->info.tab->tabowner);

	CONSTADD("drop view ");
    if (sql->schema->db->dtype == '4' )
    {
        STRADD(sql->schema->db->dbname);
        CONSTADD("/");
    }

	STRADD(tp->rhs->info.tab->extern_tabname);
	if (sql->schema->db->dtype == 'R')
	{
		CONSTADD(" cascade");
	}
}

/******************************************************************************/
