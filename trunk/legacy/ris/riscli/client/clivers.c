/* Do not alter this SPC information: $Revision: 1.2.53.1 $ */
/*
**	NAME:							clivers.c
**	AUTHORS:						Terry McIntyre
**	CREATION DATE:					1/92
**	ABSTRACT:
**	
**	REVISION HISTORY:
*/
 
/*
**	INCLUDES
*/
#include "client.h"
#include "risver.h"

/*
**	DEFINES
*/

/*
**	TYPES
*/
typedef struct version_info_s
{
	unsigned char maj;
	unsigned char min;
	unsigned char rel;
} version_info;

/*
**	FUNCTION PROTOTYPES
*/
#define clivers_c
#include "clivers.prt"
#include "comdebug.prt"
#include "comjmp.prt"

/*
**	VARIABLES
*/


/*
**	FUNCTIONS
*/

extern void RIScli_check_version(
	unsigned char app_maj, 
	unsigned char app_min, 
	unsigned char app_rel)
{
	CLI_DBG(("RIScli_check_version(app_maj:%d app_min:%d app_rel:%d)\n",
		app_maj, app_min, app_rel));

	if ((int)app_maj > RIS_version_maj)
	{
		LONGJMP(RIS_E_APPCLI_INCOMPATIBLE);
	}

	return;
}
