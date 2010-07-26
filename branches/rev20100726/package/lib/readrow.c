/*
**	readrow.c
**	6/11/91
**	Richard Eade
**
**	Reads a line (row) from stdin.  Returns 0
**	on error and 1 on success.  Note:  it does
**	print error on failure to read a line.  Use
**	getrow().
*/

#include <stdio.h>
#include "package.h"

int	readrow(row)
char	row[];
{
	if (fgets(row, MAX_ROW_LEN, stdin))
	{
		if ('\n' != row[strlen(row)-1])	
		{
			fprintf(stderr, "%s: getrow: \"%s\": row too long (%d)\n", Image, row, MAX_ROW_LEN);
			return 0;
		}
		return 1;
	}
	return 0;
}
