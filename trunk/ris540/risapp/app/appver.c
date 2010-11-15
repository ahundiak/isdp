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
#include "app.h"
#include "risver.h"
#include "riscom.h"
#include "rismem.h"
#include "risums.h"

/*
**	DEFINES
*/

/*
**	TYPES
*/

/*
**	FUNCTION PROTOTYPES
*/
#define appver_c
#include "appver.prt"
#include "comdebug.prt"
#if defined(WIN32)
#include "comgtver.prt"
#endif
#include "comjmp.prt"
#include "sys.prt"

/*
**	VARIABLES
*/

/*
**	FUNCTIONS
*/


/******************************************************************************/

extern int RISapp_init_version()
{
	int  			status;
	static int		version_done = 0;
	char			version[12];
	char			*tokptr;
#if defined(WIN32)
	char			*buffer;
	char			filename[RIS_MAX_PATH_SIZE];
	char			filepath[RIS_MAX_PATH_SIZE];
#endif

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
#if defined(unix) || defined(DOS)
		/*
		** 	Use the macro
		*/
		strncpy(RIS_app_version, RIS_VERSION_STR, sizeof(RIS_app_version)); /*itbokic version string */
#endif

#if defined(WIN32)
		/*
		**	Use resource file of current dll in this application's address
		**	space
		*/
		if (ODBCDLL)
		{
			strcpy(filename,"i9odbc.dll");
		}
		else
		{
			strcpy(filename,"i9ris6.dll");
		}
		if( !RIScom_get_filepath(filename, filepath, sizeof(filepath)) )
		{
			APP_DBG(("RISapp_init_version: GetFileVersionInfoSize returned=%d\n",
				GetLastError()));
			LONGJMP(RIS_E_INTERNAL_ERROR);
		}
		APP_DBG(("RISapp_init_version: filepath:%s\n", filepath));
		if( !(buffer = RIScom_get_version_info(filepath, "040904E4", 
			"FileVersion")) )
		{
			APP_DBG(("RISapp_init_version: GetFileVersionInfoSize returned=%d\n",
				GetLastError()));
			LONGJMP(RIS_E_INTERNAL_ERROR);
		}
		strncpy(RIS_app_version,buffer,sizeof(RIS_app_version)); /*itbokic version string */
#endif	/* WIN32 */

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

