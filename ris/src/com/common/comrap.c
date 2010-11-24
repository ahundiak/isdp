/*
**	NAME:							comrap.c
**	AUTHORS:						Terrence McIntyre
**	CREATION DATE:					2/93
**	ABSTRACT:
**      
**	REVISION HISTORY:
*/
 
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#include "riscom.h"
#include "risrap.h"
#include "risstjmp.h"

#define GETPID()	getpid()

/******************************************************************************/

/*
**	returns 1 if a valid rap file was read, otherwise returns 0.
*/
extern int RIScom_read_rap_file(ris_rap_options *rap_options, int expand_pid_flag)
{
	char	*p;
	char	*f;
	char	s[300];
	char	filename[32];
  uid_t   uid;
	FILE	*fp;

	uid = getuid();
	sprintf(filename, RISRAP_FILENAME_FORMAT, uid);

	memset(rap_options, 0, sizeof(ris_rap_options));
	rap_options->delay_time = 1;
	rap_options->total_time = 1;
	rap_options->command_time = 1;
	rap_options->overwrite_file = 1;

	if ((fp = RIScom_fopen(filename, "r")) == NULL)
	{
		return 0;
	}

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
}
