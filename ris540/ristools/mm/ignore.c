/* Do not alter this SPC information: $Revision: 1.1.54.1 $ */
/*
**	NAME:							ignore.c
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
#define MAX_IGNORES	20
#define MULTI_WILDCARD_CHAR		'*'
#define SINGLE_WILDCARD_CHAR	'?'

/*
**	TYPES
*/

/*
**	FUNCTION PROTOTYPES
*/
#define ignore_c
#include "output.prt"
#include "ignore.prt"
#include "sys.prt"

/*
**	VARIABLES
*/
int		ignores_count = 0;
#if defined(__hpux__)
static char     ignores[MAX_IGNORES][PATH_MAX];
#else
char	ignores[MAX_IGNORES][PATH_MAX];
#endif

/*
**	FUNCTIONS
*/

/******************************************************************************/

extern void add_ignore(
	char *ignore)
{
	DBG(("add_ignore(ignore:<%s>)\n", ignore));

	if (ignores_count == MAX_IGNORES)
	{
		fprintf(stderr, "%s: increase MAX_IGNORES(%d) in \"%s\".\n",
			exe, MAX_IGNORES, __FILE__);
		EXIT(1);
	}
	strcpy(ignores[ignores_count++], ignore);

	DBG(("add_ignore returning\n"));
}

/******************************************************************************/

static int strcmp_wildcard(
	char *s1,	/* string with possible wild card */
	char *s2)	/* string to compare against */
{
	if (*s1 == MULTI_WILDCARD_CHAR)
	{
		while(*s1 == MULTI_WILDCARD_CHAR)
			s1++;

		while(*s2)
		{
			if(strcmp_wildcard(s1, s2) == 0)
				return 0;
			s2++;
		}

		if (*s1 == 0 && *s2 == 0)
			return 0;
	}
	else if (*s1 == SINGLE_WILDCARD_CHAR)
	{
		if (*s2)
			return strcmp_wildcard(s1+1, s2+1);
		else
			return 1;
	}
	else
	{
		int c1 = *s1;
		int c2 = *s2;

#if defined(WIN32) || defined(DOS)
		c1 = tolower(c1);
		c2 = tolower(c2);
#endif
		if (c1 == c2)
		{
			if (c1 == 0) /* which implies c2 == 0 */
			{
				return 0;
			}
			return strcmp_wildcard(s1+1, s2+1);
		}
		else
		{
			return 1;
		}
	}
	return 1;
}

/******************************************************************************/

extern int ignore(
	char *path)
{
	int i;

	DBG(("ignore(path:<%s>\n", STRING(path)));

	for (i = 0; i < ignores_count; i++)
	{
		if (!strcmp_wildcard(ignores[i], path))
		{
			DBG(("ignore returning 1\n"));
			return 1;
		}
	}

	DBG(("ignore returning 0\n"));
	return 0;
}

/******************************************************************************/
