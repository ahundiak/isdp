/*
**	getrow.c
**	6/11/91
**	Richard Eade
**
**	Reads a line (row) from stdin.  Returns 0
**	on error and 1 on success.
*/

#include <stdio.h>
#include "package.h"

int	getrow(row)
char	row[];
{
	if (!fgets(row, MAX_ROW_LEN, stdin))
	{
		fprintf(stderr, "%s: getrow: fgets failed\n", Image);
		return 0;
	}
	else if ('\n' != row[strlen(row)-1])	
	{
		fprintf(stderr, "%s: getrow: \"%s\": row too long (%d)\n", Image, row, MAX_ROW_LEN);
		return 0;
	}
	return 1;
}
