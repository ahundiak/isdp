/*
**	NAME:							ccoinvid.c
**	AUTHORS:						Sunil Murthy
**	CREATION DATE:					11/92
**	ABSTRACT:
**	
**	REVISION HISTORY:
*/
 
/*
**	INCLUDES
*/
#include "clicom.h"

/*
**	DEFINES
*/

/*
**	TYPES
*/

/*
**	FUNCTION PROTOTYPES
*/
#define ccoinvid_c
#include "ccoinvid.prt"
#include "comdebug.prt"

/*
**	VARIABLES
*/

/*
**	FUNCTIONS
*/

/******************************************************************************/

extern void RIScco_invalidate_ids(
	risschema *schema,
	int clear_schema_flag)
{
	int i;

	CCO_DBG(("RIScli_invalidate_ids(schema:0x%x clear_schema_flag:%d)\n",
		schema, clear_schema_flag));

	for (i = 0;
		 i < (int)(RIS_parms.max_user_stmts + RIS_max_secondary_stmts);
		 i++)
	{
		if (RIS_stmts[i] &&
			RIS_stmts[i]->sql &&
			RIS_stmts[i]->sql->schema == schema)
		{
			RIS_stmts[i]->sql->dbms = 0;
			if (clear_schema_flag)
			{
				RIS_stmts[i]->sql->schema = 0;
			}
		}
	}

	CCO_DBG(("RIScli_invalidate_ids:complete\n"));
}

/******************************************************************************/
