/*
**	NAME:							ccoss_id.c
**	AUTHORS:						Hitesh R. Patel
**	CREATION DATE:					8/92
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
#define ccoss_id_c
#include "ccoss_id.prt"
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

extern short RIScco_get_sschema_id(
	char *ssname)
{
	short id;

	CCO_DBG(("RIScco_get_sschema_id(ssname:<%s>)\n", STRING(ssname)));

	for (id = 0; id < RIS_MAX_OPEN_SUPERSCHEMAS; id++)
	{
		if (RIS_ssmem[id] && !strcmp(ssname, RIS_ssmem[id]->schname))
		{
			break;
		}
	}
	if (id == RIS_MAX_OPEN_SUPERSCHEMAS)
	{
		id = -1;
	}

	CCO_DBG(("RIScco_get_sschema_id:returning id:%d\n", id));

	return id;
}

/******************************************************************************/

extern short RIScco_new_sschema_id(
	char *ssname)
{
	short id;

	CCO_DBG(("RIScco_new_sschema_id(ssname:0x%x)\n", ssname));

	/*
	**	Check for existing id
	*/
	if (RIScco_get_sschema_id(ssname) != -1)
	{
		CCO_DBG(("RIScco_new_sschema_id: schema already has an id\n"));
		LONGJMP(RIS_E_INTERNAL_ERROR);
	}

	/*
	**	Find open slot
	*/
	for (id = 0; id < RIS_MAX_OPEN_SUPERSCHEMAS; id++)
	{
		if (!RIS_ssmem[id])
		{
			break;
		}
	}
	if (id == RIS_MAX_OPEN_SUPERSCHEMAS)
	{
		LONGJMP(RIS_E_MAX_OPEN_SUPER_SCHEMAS_EXCEEDED);
	}

	CCO_DBG(("RIScco_new_schema_id:returning id:%d\n", id));
	return id;
}

/******************************************************************************/

extern void RIScco_clear_sschema_id(
	short id)
{

	CCO_DBG(("RIScco_clear_sschema_id(id:%d)\n", id));

	if (id < 0 || id >= RIS_MAX_OPEN_SUPERSCHEMAS)
	{
		LONGJMP(RIS_E_INVALID_SUPER_SCHEMA_ID);
	}

	RIS_ssmem[id] = 0;

	CCO_DBG(("RIScco_clear_sschema_id: returning\n"));
}

/******************************************************************************/
