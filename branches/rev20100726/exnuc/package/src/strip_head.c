/*
**	strip_head.c
**	6/11/91
**	Richard Eade
**
**	Reads stdin and write to stdout all lines except the
**	first two.
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

	if (rmhead())
	{
		while (readrow(row))
			printf(row);
		return 0;
	}
	return 1;
}
