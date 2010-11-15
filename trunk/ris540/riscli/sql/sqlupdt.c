/*
**	NAME:							sqlupdt.c
**	AUTHORS:						Dave Buehmann
**	CREATION DATE:					4/88
**	ABSTRACT:
**		Walk an update tree filling in interface info.
**	
**	REVISION HISTORY:
*/
 
/*
**	INCLUDES
*/
#include "riscom.h"
#include "rissql.h"

/*
**	FUNCTION PROTOTYPES
*/
#define sqlupdt_c
#include "sqlupdt.prt"
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


extern void RISsql_update(
	ristree	*update,
	rissql	*sql)
{
	SQL_DBG(("\nin RISsql_update\n"));

	CONSTADD("update ");
	RISsql_expr(update->rhs, sql);
	CONSTADD(" set ");

	/* add the assign list */
	RISsql_expr(update->rhs->rhs, sql);

	/* add the where clause */
	RISsql_expr(update->lhs, sql);
}
