/*
**	NAME:							sqldel.c
**	AUTHORS:						Dave Beuhmann
**	CREATION DATE:					4/88
**	ABSTRACT:
**		walk a delete tree filling in interface info.
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
#define sqldel_c
#include "sqldel.prt"
#include "sqlexpr.prt"
#include "sqlmisc.prt"
#include "comdebug.prt"
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


extern void RISsql_delete(
	ristree	*delete,
	rissql	*sql)
{
	SQL_DBG(("\nin RISsql_delete\n"));

	CONSTADD("delete from ");
	RISsql_expr(delete->rhs, sql);

	/* add the where clause */
	RISsql_expr(delete->lhs, sql);
}
