/*
**	rmhead.c
**	6/11/91
**	Richard Eade
**
**	Removes the first two rows (the header) from stdin.  Returns 0
**	on error and 1 on success.
*/

#include "package.h"

int	rmhead()
{
	char	row[MAX_ROW_LEN];

	/*
	**	Read and discard the first two lines.
	*/

	if (!getrow(row) || !getrow(row))
		return 0;
	return 1;
}
