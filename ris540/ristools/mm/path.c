/* Do not alter this SPC information: $Revision: 1.2.28.1 $ */
/*
**	NAME:							path.c
**	AUTHORS:						Terrence McIntyre
**	CREATION DATE:					10/92
**	ABSTRACT:
**	
**	REVISION HISTORY:
*/
 
/*
**	INCLUDES
*/
#include <ctype.h>
#include "mm.h"

/*
**	DEFINES
*/
#define MAX_PATHS	20

/*
**	TYPES
*/

/*
**	FUNCTION PROTOTYPES
*/
#define path_c
#include "output.prt"
#include "path.prt"
#include "sys.prt"

/*
**	VARIABLES
*/
int		paths_count = 0;
/* Add static for hpux */
#if defined(__hpux__)
static char     paths[MAX_PATHS][PATH_MAX];
#else
char	paths[MAX_PATHS][PATH_MAX];
#endif

/*
**	FUNCTIONS
*/

/******************************************************************************/

extern void expand_path(
	char *path, 
	char *ep,
	char *file, 
	int  line)
{
	int ep_index;
	int var_index;
	char *p;
	char var[256];
	char *value;

	DBG(("expand_path(path:<%s>)\n", path));

	p = path;
	ep_index = 0;

	while(*p)
	{
		if (*p == '$' && *(p+1) == '(')
		{
			p += 2;
			var_index = 0;
			while(*p != ')')
			{
				if (!*p)
				{
					ERRHEADER(line, file);
					fprintf(stderr, "Invalid path:<%s>\n", path);
					EXIT(1);
				}

				var[var_index++] = *p++;
			}
			p++;
			var[var_index] = '\0';

			if ((value = getenv(var)) == NULL)
			{
				ERRHEADER(line, file);
				fprintf(stderr, "Environment variable $(%s) undefined\n", var);
				EXIT(1);
			}

			strcpy(ep + ep_index, value);
			ep_index += strlen(value);
		}
		else
		{
			ep[ep_index++] = *p++;
		}
	}
	ep[ep_index] = '\0';

	DBG(("expand_path returning\n"));
}

/******************************************************************************/

extern void add_path(
	char *path)
{
	DBG(("add_path(path:<%s>)\n", path));

	if (paths_count == MAX_PATHS)
	{
		fprintf(stderr, "%s: increase MAX_PATHS(%d) in \"%s\".\n",
			exe, MAX_PATHS, __FILE__);
		EXIT(1);
	}
	strcpy(paths[paths_count++], path);

	DBG(("add_path returning\n"));
}

/******************************************************************************/
static int fullpathname(
	char *s)
{
	int sts = 0;
#if defined(unix)
	if (*s == '/' || *s == '.')
	{
		sts = 1;
	}
#endif
#if defined(WIN32) || defined(DOS)
	if ((isalpha(*s) && *(s+1) == ':') ||
		*s == '\\' || *s == '/' || *s == '.')
	{
		sts = 1;
	}
#endif
	return sts;
}
/******************************************************************************/

extern FILE *fopen_with_paths(
	char *filename,
	char *mode,
	char *path)
{
	int i;
	FILE *fp = NULL;

	DBG(("fopen_with_paths(filename:<%s> mode:<%s> path:0x%x)\n",
		filename, mode, path));

	if (fullpathname(filename))
	{
		strcpy(path, filename);
		fp = fopen(path, mode);
	}
	else
	{
		sprintf(path, "%s%c%s", src, PATH_CHAR, filename);
		if ((fp = fopen(path, mode)) == NULL)
		{
			for (i = 0; i < paths_count; i++)
			{
				sprintf(path, "%s%c%s", paths[i], PATH_CHAR, filename);
				if ((fp = fopen(path, mode)) != NULL)
				{
					break;
				}
			}
		}
	}

	DBG(("fopen_with_paths:returning fp:0x%x\n", fp));
	return fp;
}

/******************************************************************************/

extern void write_I_path()
{
	int i;

	output("\nIPATH=");
	output("\\\n\t-I%s", src);		
	for (i = 0; i < paths_count; i++)
	{
		output("\\\n\t-I%s", paths[i]);		
	}
	output("\n");
}

/******************************************************************************/
