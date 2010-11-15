/* Do not alter this SPC information: $Revision: 1.1.55.1 $ */
/*
**	NAME:							compath.c
**	AUTHORS:						Terrence McIntyre
**	CREATION DATE:					2/93
**	ABSTRACT:
**	
**	REVISION HISTORY:
*/
 
/*
**	INCLUDES
*/
#include "rispath.h"
#include "risprods.h"
#include "risdebug.h"
#include "rislimit.h"
#include <string.h>

/*
**	DEFINES
*/

/*
**	TYPES
*/

/*
**	FUNCTION PROTOTYPES
*/
#define compath_c
#include "compath.prt"
#include "comdebug.prt"
#include "comstrcp.prt"
#include "wrap.prt"
#include "sys.prt"

/*
**	VARIABLES
*/

/*
**	FUNCTIONS
*/

/******************************************************************************/

extern void RIScom_generate_local_exe_path(
	char	*path,
	char	*risdir,
	int		development,
	char	*subdir,
	char	*exe)
{
	char	*ptr = path;
	char	tmpexe[RIS_MAX_PATH_SIZE];
	char	*prodtoken;
	char	temp[30];		/* used to generate /prodname string */
	int		tokfound = 0;

	COM_DBG(("RIScom_generate_local_exe_path(path:0x%x risdir:%s development:%d subdir:<%s> exe:<%s>)\n", path, STRING(risdir), development, STRING(subdir), STRING(exe)));

	ptr += RIScom_strcpy(ptr, risdir);
	if (development)
	{
		*ptr++ = PATH_CHAR;
		ptr += RIScom_strcpy(ptr, subdir);
	}
	*ptr++ = PATH_CHAR;
	ptr += RIScom_strcpy(ptr, "bin");
	if (development)
	{
		*ptr++ = PATH_CHAR;
		ptr += RIScom_strcpy(ptr, SYSTEM_NAME);
	}
	*ptr++ = (char)PATH_CHAR;

	/*
	** Determine whether old or new server exe name exists
	*/
	*ptr = '\0';
	strcpy(temp, exe);
	for (prodtoken = strtok(temp, ":");
		 prodtoken;
		 prodtoken = strtok(0, ":"))
	{
		tokfound = 1;
		RIScom_strcpy(tmpexe, path);
		strcat(tmpexe, prodtoken);
		COM_DBG(("RIScom_generate_local_exe_path:path:<%s>\n",STRING(tmpexe)));
		if (!access(tmpexe,0))		/* file exists */
			break;
	}
	if (! tokfound)
		ptr += RIScom_strcpy(ptr, exe);
	else
		if (prodtoken)
			ptr += RIScom_strcpy(ptr, prodtoken);
		else
			ptr += RIScom_strcpy(ptr, exe);	/* bad name so access will fail */

	COM_DBG(("RIScom_generate_local_exe_path:path:<%s>\n", STRING(path)));
	COM_DBG(("RIScom_generate_local_exe_path:returning\n"));
}

/******************************************************************************/
