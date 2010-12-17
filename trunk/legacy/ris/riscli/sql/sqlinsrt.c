/*
**	NAME:							sqlinsrt.c
**	AUTHORS:						Dave  Buehmann
**	CREATION DATE:					4/88
**	ABSTRACT:
**		Walk an insert view tree filling in interface information.
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
#define sqlinsrt_c
#include "sqlexpr.prt"
#include "sqlinsrt.prt"
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


extern void RISsql_insert(
	ristree	*insert,
	rissql	*sql)
{

	SQL_DBG(("\nin RISsql_insert\n"));

	CONSTADD("insert into ");
	RISsql_expr(insert->rhs, sql);

	/* add the attr list */
	CONSTADD(" (");
	RISsql_expr(insert->rhs->rhs, sql);
	CONSTADD(") ");

	/* add values/project list */
	RISsql_expr(insert->lhs, sql);
}
