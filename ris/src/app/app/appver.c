/*
**	NAME:							appver.c
**	AUTHORS:						Hitesh R. Patel
**	CREATION DATE:					8/93
**	ABSTRACT:
**				Initializes ris-application global version variables
**	REVISION HISTORY:
**					
*/
 
/*
**	INCLUDES
*/
#include <stdlib.h>
#include <string.h>

#include "risapp.h"
#include "risver.h"
#include "riscom.h"
#include "rismem.h"
#include "risums.h"
#include "risdebug.h"

/******************************************************************************/

extern int RISapp_init_version()
{
	int  			status;
	static int		version_done = 0;
	char			version[12];
	char			*tokptr;

	APP_DBG(("RISapp_init_version: starting\n\tversion_done=%d\n", version_done));
	if (!version_done)
	{
		if ((status = SETJMP()) != 0)
		{
			version_done = 0;
			RESETJMP();
			return(status);
		}

		/*
		**	Get RISDP version information
		*/
		strncpy(RIS_app_version, RIS_VERSION_STR, sizeof(RIS_app_version)); /*itbokic version string */

		APP_DBG(("RISapp_init_version: RIS_app_version = %s\n", RIS_app_version));

		strncpy(version, RIS_app_version, sizeof(version)); /*itbokic version string */
		if ((tokptr = strtok(version, ".")) != (char *) NULL) /*itbokic version string */
		{
			RIS_app_version_maj = atoi(tokptr);
		}
		if ((tokptr = strtok(NULL, ".")) != (char *) NULL) /*itbokic version string */
		{
			RIS_app_version_min = atoi(tokptr);
		}
		if ((tokptr = strtok(NULL, ".")) != (char *) NULL) /*itbokic version string */
		{
			RIS_app_version_rel = atoi(tokptr);
		}

		APP_DBG(("RISapp_init_version: RIS_app_version maj=%d min=%d rel=%d\n",
			RIS_app_version_maj, RIS_app_version_min, RIS_app_version_rel));

		version_done = 1;
		RESETJMP();
	}

	APP_DBG(("RISapp_init_version: complete\n"));
	return(RIS_SUCCESS);
}

/******************************************************************************/

