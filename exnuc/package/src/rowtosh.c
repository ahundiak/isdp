/*
**	rowtosh.c
**	6/13/91
**	Richard Eade
**
**	Reads a row and converts it into "name=value" format.  Where "name"
**	is the column name and "value" is the column value extracted from
**	the input row.  Note: this program is designed to read the output
**	of the row executable.  It expects an itb header followed by
**	a single row.
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

		if (getrow(row))
		{
			char	*col[MAX_NUM_COL];
			int	n = 0;
			int	i = 0;

			if (!(n = rowtocol(row, col)))
				return 1;
			if (n != ncol)
				ERROR((stderr, "%s: \"%s\": invalid row: header has %d columns, row has %d columns\n", Image, row, ncol, n));
			for (i = 0; i < ncol; ++i)
				if (strchr(col[i], ' '))
					printf("%s=\"%s\"\n", hdrcol[i], col[i]);
				else
					printf("%s=%s\n", hdrcol[i], col[i]);
		}
		return 0;
	}

	return 1;
}
