/*
**	NAME:							ccoschid.c
**	AUTHORS:						Terry McIntyre
**	CREATION DATE:					3/92
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
#define ccoschid_c
#include "ccoschid.prt"
#include "comjmp.prt"
#include "comdebug.prt"
#include "sys.prt"

/*
**	VARIABLES
*/

/*
**	FUNCTIONS
*/

/******************************************************************************/

extern short RIScco_get_schema_id(
	char *schname)
{
	short id;

	CCO_DBG(("RIScco_get_schema_id(schname:<%s>)\n", STRING(schname)));

	for (id = 0; id < RIS_MAX_OPEN_SCHEMAS; id++)
	{
		if (!strcmp(schname, RIS_schmem[id].schname))
		{
			break;
		}
	}
	if (id == RIS_MAX_OPEN_SCHEMAS)
	{
		id = -1;
	}

	CCO_DBG(("RIScco_get_schema_id:returning id:%d\n", id));

	return id;
}

/******************************************************************************/

extern short RIScco_new_schema_id(
	char *schname)
{
	short id;

	CCO_DBG(("RIScco_new_schema_id(schname:<%s>)\n", STRING(schname)));

	/*
	**	Check for existing id
	*/
	if (RIScco_get_schema_id(schname) != -1)
	{
		CCO_DBG(("RIScco_new_schema_id: schema already has an id\n"));
		LONGJMP(RIS_E_DUP_SCHNAME);
	}

	/*
	**	Find open slot
	*/
	for (id = 0; id < RIS_MAX_OPEN_SCHEMAS; id++)
	{
		if (!RIS_schmem[id].schname[0])
		{
			break;
		}
	}
	if (id == RIS_MAX_OPEN_SCHEMAS)
	{
		LONGJMP(RIS_E_MAX_OPEN_SCHEMAS_EXCEEDED);
	}

	strcpy(RIS_schmem[id].schname, schname);

	CCO_DBG(("RIScco_new_schema_id:returning id:%d\n", id));
	return id;
}

/******************************************************************************/

extern void RIScco_clear_schema_id(
	short id)
{

	CCO_DBG(("RIScco_clear_schema_id(id:%d)\n", id));

	if (id < 0 || id >= RIS_MAX_OPEN_SCHEMAS)
	{
		LONGJMP(RIS_E_INVALID_SCHEMA_ID);
	}

	memset(&RIS_schmem[id], 0, sizeof(risschmem));

	CCO_DBG(("RIScco_clear_schema_id: returning\n"));
}

/******************************************************************************/
