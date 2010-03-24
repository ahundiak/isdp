/*
**	6/25/91
**	Richard Eade
**
**	Reads directory.itbs and produces the support files 
**	necessary for creating the cpio files for newprod.
*/

#include <stdio.h>
#include <string.h>
#include "package.h"

#define MAX_ROWS		1000

#define FLAGS			"qgo:n:p:"
#define ERROR(ARGS)		(fprintf ARGS, exit(1))
#define GET_IMAGE_NAME()	((Image=strrchr(argv[0],'/'))?++Image:(Image = argv[0]))

char	*Image = 0;

/******************************************************************************/

void	print_usage()
{
	ERROR((stderr, "usage: %s [-o dir] [-p prefix] [-g] [-v] -n buildName\n", Image));
}/* print_usage */


/******************************************************************************/

struct itb
{
	char	row[MAX_ROW_LEN];
	char	*col[MAX_NUM_COL];
	char	*dir;
};

struct sortitb
{
	char		cpio[MAX_ROW_LEN];
	struct itb	*row;
};

static void	dump_itb(itb, nrow, ncol)
struct itb	itb[];
int		nrow;
int		ncol;
{
	int	i;

	printf("dump_itb:\n");
	printf(itb[0].row);
	printf(itb[1].row);

	for (i = 2; i < nrow; ++i)
	{
		int	j;

		printf(itb[i].col[0]);
		for (j = 1; j < ncol; ++j)
		{
			printf("\t");
			printf(itb[i].col[j]);
		}
		printf("\n");
	}
}

static void	dump_sortitb(sortitb, itb, nrow, ncol)
struct sortitb	*sortitb;
struct itb	itb[];
int		nrow;
int		ncol;
{
	int	i;

	printf("dump_sortitb:\n");
	printf(itb[0].row);
	printf(itb[1].row);

	for (i = 2; i < nrow; ++i)
	{
		int	j;
		struct itb	*row;

		row = sortitb[i-2].row;
		printf(row->col[0]);
		for (j = 1; j < ncol; ++j)
		{
			printf("\t");
			printf(row->col[j]);
		}
		printf("\n");
	}
}

/******************************************************************************/

static int	cpioColumn = 0;	/* Column number for the cpio name. */

static struct sortitb	*sort_by_cpio(itb, nrow, ncol)
struct itb	itb[];
int		nrow;
int		ncol;
{
	struct sortitb	*sortitb = 0;
	int		i;

	if (-1 == (cpioColumn = colnametonum(itb[0].col, ncol, "cpio")))
		ERROR((stderr, "%s: colnametonum failed\n", Image));
	
	if (!(sortitb = (struct sortitb *)calloc(nrow-2, sizeof(*sortitb))))
		ERROR((stderr, "%s: sort_by_cpio: could not calloc %d bytes\n", Image, sizeof(*sortitb)*(nrow-2)));

	for (i = 2; i < nrow; ++i)
	{
		sortitb[i-2].row = &itb[i];
		strcpy(sortitb[i-2].cpio, itb[i].col[cpioColumn]);
	}

	(void)qsort((char *)sortitb, nrow-2, sizeof(*sortitb), strcmp);	

	return sortitb;
}

/******************************************************************************/

static char	*currentDir = 0;

static void	set_current_dir(filename)
char	*filename;
{
	char	*slash = 0;

	currentDir = (char *)strdup(filename);
	if (!(slash = strrchr(currentDir, '/')))
		ERROR((stderr, "%s: %s: could not get dirname\n", Image, filename));
	*slash = 0;
}

static int	read_itb(itb, header, p_nrow, p_ncol, filename)
struct itb	itb[];
char		header[];
int		*p_nrow;
int		*p_ncol;
char		*filename;
{
	if (0 == *p_nrow)
	{
		/*	
		**	Save the itb header in the first two rows.	
		*/

		if (!getrow(itb[0].row) || !getrow(itb[1].row))
			ERROR((stderr, "%s: read_itb: %s: unable to read itb header\n", Image, filename));
		strcpy(header, itb[0].row);
		rowtocol(header, itb[0].col);
		*p_nrow = 2;

		set_current_dir(filename);
	}
	while (readrow(itb[*p_nrow].row))
	{
		*p_ncol = rowtocol(itb[*p_nrow].row, itb[*p_nrow].col);
		itb[*p_nrow].dir = currentDir;

		if (itb[*p_nrow].row[0] == '-')
		{

			/*
			**	This is the header of an itb. Need to
			**	skip it.
			*/

			--(*p_nrow);

			/*
			**	Record the pathname for all rows in
			**	this itb.
			*/

			set_current_dir(filename);
		}
		else
			++(*p_nrow);
		if (*p_nrow >= MAX_ROWS)
			ERROR((stderr, "%s: read_itb: %s: %d: maximum number of rows exceeded\n", Image, filename, MAX_ROWS));
	}

	return *p_nrow;
}

/******************************************************************************/

static void	write_info(sortitb, itb, nrow, ncol, dir, buildName, quiet, prefix)
struct sortitb	*sortitb;
struct itb	itb[];
int		nrow;
int		ncol;
char		*dir;
char		*buildName;
int		quiet;
char		*prefix;
{
	int	rt = 0;		/* TRUE iff this is a runtime variant. */
	int	dp = 0;		/* TRUE iff this is development platform variant. */
	int	i;
	char	*owner = 0;	/* For chown command after installing file. */
	char	*group = 0;	/* For chgrp command after installing file. */

	int	buildColumn = 0;
	int	filenameColumn = 0;
	int	modeColumn = 0;

	if (!buildName)
		print_usage();
	else if (!translate_build(buildName, &rt, &dp, &owner, &group))
		ERROR((stderr, "%s: write_info: %s: invalid build name\n", Image, buildName));

	/* Find the columns by name. */

	if (-1 == (buildColumn = colnametonum(itb[0].col, ncol, "build")))
		ERROR((stderr, "%s: colnametonum failed\n", Image));
	if (-1 == (filenameColumn = colnametonum(itb[0].col, ncol, "filename")))
		ERROR((stderr, "%s: colnametonum failed\n", Image));
	if (rt)
	{
		if (-1 == (modeColumn = colnametonum(itb[0].col, ncol, "rtmode")))
			ERROR((stderr, "%s: colnametonum failed\n", Image));
	}
	else
	{
		if (-1 == (modeColumn = colnametonum(itb[0].col, ncol, "dpmode")))
			ERROR((stderr, "%s: colnametonum failed\n", Image));
	}

	/*
	**	Loop through all the sorted rows.  Create a file of
	**	shell variables that is used to create the cpio files.
	*/

	for (i = 0; i < nrow - 2; ++i)
	{
		char	cpioname[MAX_ROW_LEN];
		char	filename[4096];
		FILE	*stream = 0;

		strcpy(cpioname, sortitb[i].row->col[cpioColumn]);
		strcpy(filename, dir);
		strcat(filename, "/");
		if (prefix)
			strcat(filename, prefix);
		strcat(filename, cpioname);
		strcat(filename, ".env");

		stream = 0;
		while (i < nrow - 2 && !strcmp(cpioname, sortitb[i].row->col[cpioColumn]))
		{
			/*
			**	See if the current row is included in the
			**	build being packaged.
			*/

			if (is_in_build(buildName, sortitb[i].row->col[buildColumn]))
			{
				if (!stream)
				{
					char	*src = 0;

					if (!(stream = fopen(filename, "w")))
						ERROR((stderr, "%s: write_info: %s: could not open for write\n", Image, filename));
					if (!translate_cpio(cpioname, &src))
						ERROR((stderr, "%s: write_info: %s: could not translate cpio name\n", Image, cpioname));
						
					fprintf(stream, "SOURCE=%s\n", src);
					fprintf(stream, "OWNER=%s\n", owner);
					fprintf(stream, "GROUP=%s\n", group);
					fprintf(stream, "FILELIST=\"", group);
					if (!quiet)
						printf("%s\n", filename);
				}
				fprintf(stream, " %s/", sortitb[i].row->dir);
				fprintf(stream, sortitb[i].row->col[filenameColumn]);
				fprintf(stream, ":");
				fprintf(stream, sortitb[i].row->col[modeColumn]);
			}
			++i;
		}
		if (stream)
		{
			fprintf(stream, "\"\n");
			fclose(stream);
		}
		--i;
	}
}

/******************************************************************************/

main(argc, argv, envp)
int	argc;
char	*argv[];
char	*envp[];
{
	int	quiet = 0;
	char	*dir = ".";	/* output directory for itb files. */
	int	debug = 0;
	char	*prefix = 0;	/* output filename prefix. */
	int	nrow = 0;	/* total number of rows in the itb. */
	int	ncol = 0;	/* number of columns in the itb. */
	char	*buildName = 0;	/* Name of the build, EXNUC, EXNUCX, etc. */

	struct itb	itb[MAX_ROWS];
	struct sortitb	*sortitb = 0;
	char		header[MAX_ROW_LEN];

	int	c;
	extern	char *optarg;
	extern	int optind, opterr;

	GET_IMAGE_NAME();

	while (EOF != (c = getopt(argc, argv, FLAGS)))
		switch (c)
		{
		case 'q':
			quiet = 1;
			break;

		case 'n':
			buildName = optarg;
			break;

		case 'g':
			debug = 1;
			break;

		case 'o':
			dir = optarg;
			break;

		case 'p':
			prefix = optarg;
			break;

		case '?':
		default:
			print_usage();
			break;
		}/* switch on command line flag */

	for (; optind < argc; ++optind)
	{
		/*
		**	Read each itb into one large table.
		*/

		FILE	*istream = 0;

		if (!(istream = fopen(argv[optind], "r")))
			ERROR((stderr, "%s: %s: unable to open for reading\n", Image, argv[optind]));
		*stdin = *istream;
		nrow = read_itb(itb, header, &nrow, &ncol, argv[optind]);
		fclose(stdin);
	}

	/*
	**	Sort the itb by the cpio filename.
	*/

	sortitb = sort_by_cpio(itb, nrow, ncol);

	if (debug)
	{
		dump_itb(itb, nrow, ncol);
		dump_sortitb(sortitb, itb, nrow, ncol);
	}

	/*
	**	Create a support file for each cpio file name. 
	*/

	write_info(sortitb, itb, nrow, ncol, dir, buildName, quiet, prefix);
	exit(0);
}
