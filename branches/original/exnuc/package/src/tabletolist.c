/*
**	tabltolist.c
**	6/13/91
**	Richard Eade
**
**	Reads an itb from stdin.  Converts the itb to list format
**	and writes it on stdout.
*/

#include <stdio.h>
#include <string.h>
#include "package.h"

char	*Image = 0;

/******************************************************************************/

main(argc, argv, envp)
int	argc;
char	*argv[];
char	*envp[];
{
	char	hdr[MAX_ROW_LEN];

	GET_IMAGE_NAME();

	/*
	**	Save the header to output with each row.
	*/

	if (getrow(hdr))
	{
		char	row[MAX_ROW_LEN];
		char	*hdrcol[MAX_NUM_COL];
		int	ncol = 0;

		/*  Discard the row of dashes.  */

		if (!getrow(row))
			return 1;

		if (!(ncol = rowtocol(hdr, hdrcol)))
			return 1;

		while (readrow(row))
		{
			char	*col[MAX_NUM_COL];
			int	n = 0;
			int	i = 0;

			if (!(n = rowtocol(row, col)))
				return 1;
			if (n != ncol)
				ERROR((stderr, "%s: \"%s\": invalid row: header has %d columns, row has %d columns\n", Image, row, ncol, n));
			printf("\n");
			for (i = 0; i < ncol; ++i)
				printf("%s\t%s\n", hdrcol[i], col[i]);
		}
		return 0;
	}

	return 1;
}
