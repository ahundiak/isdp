/*
**	rowtocol.c
**	6/13/91
**	Richard Eade
**
**	Converts one row of an itb into an array:  one element for each
**	column in the row.  Returns the number of columns in the row.
**	Note: row is modified and the column returned is a list of
**	pointers into the row array.
*/

#include <stdio.h>
#include <string.h>
#include "package.h"

int	rowtocol(row, col)
char	*row;
char	*col[];
{
	int	i = 0;

	if (col[i++] = strtok(row, "\t\n"))
		while (col[i++] = strtok(NULL, "\t\n"));

	return i-1;
}
