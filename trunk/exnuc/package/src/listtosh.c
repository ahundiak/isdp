/*
**	listtosh.c
**	6/13/91
**	Richard Eade
**
**	Converts list format into "shellvar=value" format.
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
	char	row[MAX_ROW_LEN];

	GET_IMAGE_NAME();

	while (readrow(row))
	{
		int	ncol;
		char	*col[MAX_NUM_COL];

		if ('\n' == row[0])
			continue;
		if (!(ncol = rowtocol(row, col)) || 2 != ncol)
			ERROR((stderr, "%s: \"%s\": row not in list format\n", Image, row));
		/*
		**	Handle embedded blanks.
		*/
		if (strchr(col[1], ' '))
			printf("%s=\"%s\"\n", col[0], col[1]);
		else
			printf("%s=%s\n", col[0], col[1]);
	}

	return 0;
}
