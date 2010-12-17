/* Do not alter this SPC information: $Revision: 1.1.54.1 $ */
/*
**	NAME:							define.c
**	AUTHORS:						Terrence McIntyre
**	CREATION DATE:					10/92
**	ABSTRACT:
**	
**	REVISION HISTORY:
*/
 
/*
**	INCLUDES
*/
#include <stdio.h>
#include "mm.h"

/*
**	DEFINES
*/
#define MAX_DEFINES		50
#define MAX_DEFINE_SIZE	40

/*
**	TYPES
*/

/*
**	FUNCTION PROTOTYPES
*/
#define define_c
#include "define.prt"
#include "output.prt"
#include "sys.prt"

/*
**	VARIABLES
*/
int		defines_count = 0;
#if defined(__hpux__)
static char     defines[MAX_DEFINES][MAX_DEFINE_SIZE];
#else
char	defines[MAX_DEFINES][MAX_DEFINE_SIZE];
#endif

/*
**	FUNCTIONS
*/

/******************************************************************************/

extern int defined(
	char *tok,
	int len)
{
	int i;

	DBG(("token_defined(tok:<%s>, len:%d)\n", tok, len));

	for (i = 0; i < defines_count; i++)
	{
		if (!strncmp(tok, defines[i], len) && defines[i][len] == '\0') 
		{
			DBG(("token_defined: returning TRUE\n"));
			return 1;
		}
	}

	DBG(("token_defined: returning FALSE\n"));
	return 0;
}

/******************************************************************************/

extern void add_define(
	char *name)
{
	int len;

	DBG(("add_define(name:<%s>)\n", name));

	if ((len = strlen(name)) > MAX_DEFINE_SIZE)
	{
		fprintf(stderr,
			"%s: increase MAX_DEFINE_SIZE(%d) in \"%s\" to at least %d.\n",
			exe, MAX_DEFINES, __FILE__, len);
		EXIT(1);
	}
	if (defines_count == MAX_DEFINES)
	{
		fprintf(stderr, "%s: increase MAX_DEFINES(%d) in \"%s\".\n",
			exe, MAX_DEFINES, __FILE__);
		EXIT(1);
	}

	strcpy(defines[defines_count++], name);

	DBG(("add_define:returning\n"));
}

/******************************************************************************/
