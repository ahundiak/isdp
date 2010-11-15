/*
**	NAME:							ccoeot.c
**	AUTHORS:						Terry McIntyre
**	CREATION DATE:					2/92
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
#define MAX_EOT_SCHNAME_COUNT	40

/*
**	TYPES
*/

/*
**	FUNCTION PROTOTYPES
*/
#define ccoeot_c
#include "ccoeot.prt"
#include "comjmp.prt"
#include "comdebug.prt"
#include "sys.prt"

/*
**	VARIABLES
*/
static int	eot_schname_count = 0;
static char	eot_schname_list[MAX_EOT_SCHNAME_COUNT][RIS_MAX_ID_SIZE];

/*
**	FUNCTIONS
*/

/******************************************************************************/

extern void RIScco_clear_eot_schname_list()
{
	CCO_DBG(("RIScco_clear_eot_schname_list()\n"));

	eot_schname_count = 0;

	CCO_DBG(("RIScco_clear_eot_schname_list:complete\n"));
}

/******************************************************************************/

extern void RIScco_add_to_eot_schname_list(
	char *schname)
{
	CCO_DBG(("RIScco_add_to_eot_schname_list(schname:<%s>)\n", schname));

	if (eot_schname_count >= MAX_EOT_SCHNAME_COUNT)
	{
		CCO_DBG(("RIScco_add_to_eot_schname_list:ERROR:exceeded "
			"MAX_EOT_SCHNAME_COUNT\n"));
		LONGJMP(RIS_E_INTERNAL_ERROR);
	}

	strcpy(eot_schname_list[eot_schname_count], schname);
	eot_schname_count++;
	
	CCO_DBG(("RIScco_add_to_eot_schname_list:complete\n"));
}

/******************************************************************************/

extern void RIScco_get_eot_schname_list(
	int		*countp,
	char 	**listp)
{
	CCO_DBG(("RIScco_get_eot_schname_list(countp:0x%x listp:0x%x)\n",
		countp, listp));

	*countp = eot_schname_count;
	*listp = (char *)eot_schname_list;

	CCO_DBG(("RIScco_get_eot_schname_list:complete\n"));
}

/******************************************************************************/
