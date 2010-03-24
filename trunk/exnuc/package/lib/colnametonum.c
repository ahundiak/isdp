/*
**	colnametonum.c
**	7/25/91
**	Richard Eade
**
**	Converts a column name to a column number.  Returns column number or
**	-1 on error.
*/

#include <stdio.h>
#include <string.h>
#include "package.h"

int	colnametonum(headercol, ncol, name)
char	*headercol[];
int	ncol;
char	*name;
{
	int	i = 0;

	for (i = 0; i < ncol; ++i)
		if (!strcmp(headercol[i], name))
			return i;

	fprintf(stderr, "colnametonum: %s: cannot find column\n", name);
	return -1;
}
