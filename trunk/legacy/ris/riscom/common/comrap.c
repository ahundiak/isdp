/*
**	NAME:							comrap.c
**	AUTHORS:						Terrence McIntyre
**	CREATION DATE:					2/93
**	ABSTRACT:
**      
**	REVISION HISTORY:
*/
 
/*
**	INCLUDES
*/
#include "risrap.h"
#include "risstjmp.h"
#if defined(WIN32)
#include <windows.h>
#include "ris.h"
#endif

/*
**	DEFINES
*/
#if defined(unix)
#define GETPID()	getpid()
#endif
#if defined(WIN32) || defined(DOS)
#define GETPID()	_getpid()
#endif

/*
**	TYPES
*/

/*
**	FUNCTION PROTOTYPES
*/
#define comrap_c
#include "comrap.prt"
#include "sys.prt"
#include "comwrap.prt"
#include "comjmp.prt"
#include "comisfn.prt"
#if defined(unix)
#include "compd.prt"
#endif
#if defined(WIN32)
#include "complat.prt"
#endif

/*
**	VARIABLES
*/

/*
**	FUNCTIONS
*/

/******************************************************************************/

/*
**	returns 1 if a valid rap file was read, otherwise returns 0.
*/
extern int RIScom_read_rap_file(
	ris_rap_options *rap_options,
	int expand_pid_flag)
{
#if defined(unix) || defined(DOS)
	char	*p;
	char	*f;
	char	s[300];
	char	filename[32];
#if defined(unix)
   uid_t   uid;
#endif
	FILE	*fp;

#if defined(unix)
	uid = getuid();
	sprintf(filename, RISRAP_FILENAME_FORMAT, uid);
#endif
#if defined(DOS)
	sprintf(filename, RISRAP_FILENAME_FORMAT);
#endif

	memset(rap_options, 0, sizeof(ris_rap_options));
	rap_options->delay_time = 1;
	rap_options->total_time = 1;
	rap_options->command_time = 1;
	rap_options->overwrite_file = 1;

	if ((fp = RIScom_fopen(filename, "r")) == NULL)
	{
		return 0;
	}

#if defined(unix)
	/*
	**	The first line must be the encrypted uid.
	*/
	if (RIScom_fgets(s, 256, fp) == NULL)
	{
		RIScom_fclose(fp);
		return 0;
	}
	if ((p = strchr(s, '\n')) != NULL)
	{
		*p = '\0';
	}
	if (SETJMP())
	{
		RESETJMP();
		rap_options->filename[0] = '\0';

		RIScom_fclose(fp);
		return 0;
	}
	RIScom_rap_depd(s,s);
	RESETJMP();
	if (uid != (uid_t)atoi(s))
	{
		rap_options->filename[0] = '\0';

		RIScom_fclose(fp);
		return 0;
	}
#endif

	while(RIScom_fgets(s, 256, fp) != NULL)
	{
		if ((p = strchr(s, '\n')) != NULL)
		{
			*p = '\0';
		}

		if (!strncmp(s, OUTPUT_COLON, (sizeof(OUTPUT_COLON) - 1)))
		{
			p = s + (sizeof(OUTPUT_COLON) - 1);
			f = rap_options->filename;
   
			while(*p && !RIScom_isspace(*p))
			{
				if (expand_pid_flag && *p == '$' && *(p+1) == '$')
				{
					f += sprintf(f, "%d", GETPID());
					p += 2;
				}
				else
				{
					*f++ = *p++;
				}
			}
			*f = '\0';
		}
		else if (!strcmp(s, NO_DELAY_TIME))
		{
			rap_options->delay_time = 0;
		}
		else if (!strcmp(s, NO_ELAPSED_TIME))
		{
			rap_options->total_time = 0;
		}
		else if (!strcmp(s, NO_COMMAND_TIME))
		{
			rap_options->command_time = 0;
		}
		else if (!strcmp(s, NO_OVERWRITE_FILE))
		{
			rap_options->overwrite_file = 0;
		}
	}
	RIScom_fclose(fp);
	return 1;
#endif
#if defined(WIN32)
	int		type;
	int		size;
	int		value;
	char	*p;
	char	*f;
	char	s[300];
	HKEY	hKey;

	memset(rap_options, 0, sizeof(ris_rap_options));
	rap_options->delay_time = 1;
	rap_options->total_time = 1;
	rap_options->command_time = 1;
	rap_options->overwrite_file = 1;

	if (RegOpenKey(HKEY_CURRENT_USER, RISRAP_KEY, &hKey) != ERROR_SUCCESS)
	{
		return 0;
	}

	size = sizeof(s);
	if ((RegQueryValueEx(hKey, OUTPUT_VALUE_NAME, 0, &type, s, &size) ==
		ERROR_SUCCESS) && (type == OUTPUT_VALUE_TYPE))
	{
		p = s;	  
		f = rap_options->filename;
		while(*p && !RIScom_isspace(*p))
		{
			if (expand_pid_flag && *p == '$' && *(p+1) == '$')
			{
				if (RIScom_get_platform() == IS_CHICAGO)
			       f += sprintf(f, "%d", abs(GETPID()));
			    else	      
			       f += sprintf(f, "%d", GETPID());
			    p += 2;
			}
			else
			{
				*f++ = *p++;
			}
		}
		*f = '\0';
	}

	size = sizeof(value);
	if ((RegQueryValueEx(hKey, DELAY_VALUE_NAME, 0, &type,
		(unsigned char *)&value, &size) == ERROR_SUCCESS) &&
		(type == DELAY_VALUE_TYPE))
	{
		rap_options->delay_time = value;
	}

	size = sizeof(value);
	if ((RegQueryValueEx(hKey, ELAPSED_VALUE_NAME, 0, &type,
		(unsigned char *)&value, &size) == ERROR_SUCCESS) &&
		(type == ELAPSED_VALUE_TYPE))
	{
		rap_options->total_time = value;
	}

	size = sizeof(value);
	if ((RegQueryValueEx(hKey, COMMAND_VALUE_NAME, 0, &type,
		(unsigned char *)&value, &size) == ERROR_SUCCESS) &&
		(type == COMMAND_VALUE_TYPE))
	{
		rap_options->command_time = value;
	}

	size = sizeof(value);
	if ((RegQueryValueEx(hKey, OVERWRITE_VALUE_NAME, 0, &type,
		(unsigned char *)&value, &size) == ERROR_SUCCESS) &&
		(type == OVERWRITE_VALUE_TYPE))
	{
		rap_options->overwrite_file = value;
	}

	RegCloseKey(hKey);
	return 1;
#endif
#if defined(vms)
	return 0;
#endif
}
