/*
**	2/4/92
**	Richard Eade
**
**	Reads a directory.itb (stdin) and writes a directory.itb (stdout).
**	Used to extend the build key field.
**
**	Default is to add "nn" to the end of each build key.
**
**	Use -k to copy other build keys.  For example:
**
**		-k 2 -k 3 -k 10
**
**	This puts the second, third, and tenth values of the build key
**	onto the end of the key.
**
**	Use -c to only change rows of particular cpio packages.  For example:
**
**		-c config -c inc
**
**	Change only rows that are in the packages config and inc.
**
**	Use -n to set a particular key to no.  For example:
**
**		-n 8
**
**	Set key eight to no.
*/

#include <stdio.h>
#include <string.h>
#include "package.h"

#define MAX_ROWS		1000

#define FLAGS			"gk:c:n:"

/******************************************************************************/

void	print_usage()
{
	ERROR((stderr, "usage: %s [-g] [-k keynumber ...] [-c cpioname ...] [-n nokey ...]\n", Image));
}/* print_usage */

/******************************************************************************/

main(argc, argv, envp)
int	argc;
char	*argv[];
char	*envp[];
{
	int	debug = 0;
	int	ncol = 0;
	int	cpioCol;
	int	buildCol;
	char	header[MAX_ROW_LEN];
	char	dashes[MAX_ROW_LEN];
	char	row[MAX_ROW_LEN];
	char	*col[MAX_NUM_COL];
	int	key[MAX_ROWS];
	int	keyCount = 0;
	int	no[MAX_ROWS];
	int	noCount = 0;
	char	*cpio[MAX_ROWS];
	int	cpioCount = 0;


	int	c;
	extern	char *optarg;
	extern	int optind, opterr;

	GET_IMAGE_NAME();

	while (EOF != (c = getopt(argc, argv, FLAGS)))
		switch (c)
		{
		case 'k':
			if (keyCount + 1 > MAX_ROWS)
				ERROR((stderr, "%s: too many -k switches\n", Image));
			key[keyCount++] = atoi(optarg);
			break;

		case 'c':
			if (cpioCount + 1 > MAX_ROWS)
				ERROR((stderr, "%s: too many -c switches\n", Image));
			cpio[cpioCount++] = (char *)strdup(optarg);
			break;

		case 'n':
			if (noCount + 1 > MAX_ROWS)
				ERROR((stderr, "%s: too many -n switches\n", Image));
			no[noCount++] = atoi(optarg);
			break;

		case 'g':
			debug = 1;
			break;

		case '?':
		default:
			print_usage();
			break;
		}/* switch on command line flag */

	/*
	**	Read the header and dashed line.
	*/

	if (!getrow(header) || !getrow(dashes))
		ERROR((stderr, "%s: unable to read itb header\n", Image));
	fprintf(stdout, header);
	fprintf(stdout, dashes);

	/*
	**	Find the column numbers for "cpio" and "build"
	*/

	ncol = rowtocol(header, col);
	cpioCol = colnametonum(col, ncol, "cpio");
	buildCol = colnametonum(col, ncol, "build");
	
	/*
	**	Read and update the "build" field for each row.
	*/

	while(readrow(row))
	{
		int	i;
		char	newbuild[MAX_ROW_LEN];
		char	tmpbuf[MAX_ROW_LEN];
		int	skip = 0;

		if (!keyCount)
		{
			/*
			**	Default is to add one new runtime and dp.
			*/
			newbuild[0] = 'n';
			newbuild[1] = 'n';
			newbuild[2] = 0;
		}
		else
		{
			for (i = 0; i < keyCount; ++i)
				newbuild[i] = 'n';
			newbuild[i] = 0;
		}

		rowtocol(row, col);
		if (cpioCount)
		{
			/*
			**	Only change rows that match the list of
			**	cpio names.  All other rows get "nn" appended.
			*/

			int	j;
			int	found = 0;

			for (j = 0; j < cpioCount; ++j)
				if (!strcmp(cpio[j], col[cpioCol]))
				{
					found = 1;
					break;
				}
			if (!found)
				skip = 1;
		}
		for (i = 0; i < ncol; ++i)
		{
			if (i == buildCol)
			{
				if (keyCount && !skip)
				{
					int	j;

					for (j = 0; j < keyCount; ++j)
					{
						newbuild[j] = col[i][key[j]];
					}
					newbuild[j] = 0;
					if (noCount)
					{
						int	j;

						for (j = 0; j < noCount; ++j)
						{
							col[i][no[j]] = 'n';
						}
					}
				}
				strcpy(tmpbuf, col[i]);
				strcat(tmpbuf, newbuild);
				col[i] = tmpbuf;
			}
			if (i != 0)
				fprintf(stdout, "\t%s", col[i]);
			else
				fprintf(stdout, "%s", col[i]);
		}
		fprintf(stdout, "\n");
	}
}
