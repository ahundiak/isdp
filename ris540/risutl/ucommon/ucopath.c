/* Do not alter this SPC information: $Revision: 1.3.26.1 $ */
/*
**	NAME:							ucopath.c
**	AUTHORS:						Terrence McIntyre
**	CREATION DATE:					7/93
**	ABSTRACT:
**	
**	REVISION HISTORY:
*/
 
/*
**	INCLUDES
*/
#include <stdio.h>
#include <ctype.h>
#include "rislimit.h"
#include "rispath.h"
#include "risutl.h"
#include "ucommon.h"
#include "utl_err.h"
#include "utl_inf.h"

/*
**	DEFINES
*/

/*
**	TYPES
*/

/*
**	FUNCTION PROTOTYPES
*/
#define ucopath_c
#include "comdebug.prt"
#include "ucopath.prt"
#include "sys.prt"

/*
**	VARIABLES
*/

/*
**	FUNCTIONS
*/

/******************************************************************************/

extern void RISuco_get_full_path(
	char *path,
	char *full_path)
{
	int i;
	int index;
	char temp[RIS_MAX_PATH_SIZE];
	char *ptr;
	char *tok;
	char *toks[RIS_MAX_PATH_SIZE];

	UCO_DBG(("RISuco_get_full_path(path:<%s> full_path:0x%x)\n", STRING(path),
		full_path));

#if defined(unix)
	if (path && path[0] == PATH_CHAR)
	{
		strcpy(temp, path);
	}
#elif defined(WIN32) || defined(DOS)
	if (path && isalpha(*path) && *(path + 1) == ':')
	{
		strcpy(temp, path);
	}
	else if (path && path[0] == PATH_CHAR)
	{
		_getcwd(temp, sizeof(temp));
		strcpy(temp + 2, path);
	}
#else
ERROR -- NO CODE
#endif
	else
	{
		int len;

#if defined(unix)
		getcwd(temp, sizeof(temp));
#elif defined(WIN32) || defined(DOS)
		_getcwd(temp, sizeof(temp));
#else
ERROR -- NO CODE
#endif

		if (path)
		{
			len = strlen(temp);
			if (temp[len-1] != PATH_CHAR)
			{
				sprintf(temp + len, "%c%s", PATH_CHAR, path);
			}
			else
			{
				strcpy(temp + len, path);
			}
		}
	}

	index = 0;

#if defined(unix)
	tok = strtok(temp, PATH_CHAR_STR);
#elif defined(WIN32) || defined(DOS)
	tok = strtok(temp + 2, PATH_CHAR_STR);
#else
ERROR -- NO CODE
#endif
	while(tok != NULL)
	{
		if (!strcmp(tok, ".."))
		{
			if (index > 0) index--;
		}
		else if (strcmp(tok, "."))
		{
			toks[index++] = tok;
		}
		
		tok = strtok(NULL, PATH_CHAR_STR);
	}

	ptr = full_path;
#if defined(WIN32) || defined(DOS)
	*ptr++ = temp[0];
	*ptr++ = temp[1];
#elif defined(unix)
#else
ERROR -- NO CODE
#endif
	if (index == 0)
	{
		strcpy(ptr, PATH_CHAR_STR);
	}
	else
	{
		for (i = 0; i < index; i++)
		{
			ptr += sprintf(ptr, "%c%s", PATH_CHAR, toks[i]);
		}
	}
	UCO_DBG(("RISuco_get_full_path:returning\n"));
}
