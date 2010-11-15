/* Do not alter this line: $Revision: 1.2.29.1 $ */
/*
**	NAME:							getfiles.c
**	AUTHORS:						Terry McIntyre
**	CREATION DATE:					8/92
**	ABSTRACT:
**	
**	REVISION HISTORY:
*/
 
/*
**	INCLUDES
*/
#include <stdio.h>
#include <string.h>
#include <errno.h>
#include <ctype.h>

#if defined(sco)
#include <prototypes.h>
#endif

/*
**	DEFINES
*/
#define EXE			"genspc"
#define FETCH		1
#define RESERVE		2
#define UNRESERVE	3
#define REPLACE		4

#if defined(unix)
#define PATH_CHAR '/'
#endif
#if defined(WIN32) || defined(DOS)
#define PATH_CHAR '\\'
#endif

/*
**	TYPES
*/

/*
**	FUNCTION PROTOTYPES
*/
extern int	getopt();
extern void exit();

/*
**	VARIABLES
*/

#if defined(unix)
extern int	errno;
extern char *optarg;
extern int 	optind;
extern int 	opterr;
#endif

#if defined(WIN32) || defined(DOS)
char *optarg = 0;
int  optind = 1;
int  opterr = 0;
#endif

/*
**	FUNCTIONS
*/

/******************************************************************************/

#if defined(WIN32) || defined(DOS)

extern int getopt(
	int argc,
	char **argv,
	char *optstring)
{
	char *ptrstr = 0;


	optarg = 0;

	if (optind < argc)
	{
		if( *argv[optind] == '-' )
		{
			ptrstr = strchr(optstring, *(argv[optind]+1));
			if( ptrstr )
			{
				if( *(ptrstr+1) == ':' )
				{
					if( *(argv[optind]+2) )
					{ 
						optarg = argv[optind]+2;
					}
					else
					{
						optind++; /* Next */
						if( *argv[optind] == '-' )
						{
							if( opterr )
							{
								fprintf(stderr,"%s: option requires an argument -- %c\n",
									argv[0], *ptrstr);
							}
							return('?');
						}
						else
						{
							optarg = argv[optind];
						}
					}
				}
				optind++; /* Next */
				return(*ptrstr);
			}
			else
			{
				if( opterr )
				{
					fprintf(stderr,"%s: illegal option -- %c\n",
							argv[0], *(argv[optind]+1));
				}
				optind++; /* Next */
				return('?');
			}
		}
		else
		{
			/*
			**	First nonoption argument
			*/
			return(-1);
		}
	}
	return(-1);
}

#endif

/******************************************************************************/

void output_files_for_spc(
	char *project,
	char *working_set,
	char mode,
	char *dir)
{
	char *ptr;
	char *lib;
	char *file;
	char last_lib[256] = "";
	char buffer[256];

	printf("set proj %s\n", project);

	printf("set working set %s\n", working_set);

	while(gets(buffer) != NULL)
	{
		if ((ptr = strrchr(buffer, PATH_CHAR)) == NULL)
		{
			file = buffer;
			if (strcmp(".", last_lib))
			{
				if (mode == FETCH || mode == RESERVE || mode == REPLACE)
				{
					if (mode == FETCH || mode == RESERVE)
					{
						printf("!mkdir -p %s\n", dir);
					}
					printf("cd %s\n", dir);
				}
				printf("set project element .\n");
				strcpy(last_lib, ".");
			}
		}
		else
		{
			*ptr = '\0';

			lib = buffer;
			file = ptr + 1;

			if (strcmp(lib, last_lib))
			{
				if (mode == FETCH || mode == RESERVE || mode == REPLACE)
				{
					if (mode == FETCH || mode == RESERVE)
					{
						printf("!mkdir -p %s/%s\n", dir, lib);
					}
					printf("cd %s/%s\n", dir, lib);
				}
				printf("set project element %s\n", lib);
				strcpy(last_lib,lib);
			}
		}

		switch(mode)
		{
			case FETCH:
				printf("fetch %s\n", file);
				break;
			
			case RESERVE:
				printf("reserve -comment 'Reserved automatically by mergespc' %s\n", file);
				break;

			case UNRESERVE:
				printf("unreserve -comment 'Unreserved automatically by mergespc' %s\n", file);
				break;

			case REPLACE:
				printf("replace -comment 'Replaced automatically by mergespc' %s\n", file);
				printf("fetch -overwrite %s\n", file);
				break;
		}
	}

	printf("exit\n");
}

/******************************************************************************/

extern void Usage()
{
	fprintf(stderr,
		"Usage: %s -r -w working_set -p project -d directory < list\n", EXE);
	fprintf(stderr,
		"       %s -f -w working_set -p project -d directory < list\n", EXE);
	fprintf(stderr,
		"       %s -u -w working_set -p project < list\n", EXE);
	fprintf(stderr, "    -f: fetch files\n");
	fprintf(stderr, "    -r: reserve files\n");
	fprintf(stderr, "    -u: unreserve files\n");
	fprintf(stderr, "    -m: move files into spc\n");
	fprintf(stderr, "    -w: \"working_set\" in spc.\n");
	fprintf(stderr, "    -p: \"project\" in spc.\n");
	fprintf(stderr, "    -d: fetch/reserve files into \"directory\".\n");
	exit(1);
}

/******************************************************************************/

extern int main(
int		argc,
char	*argv[])
{
	int			c;
	char		*project = NULL;
	char		*working_set = NULL;
	char		*dir = NULL;
	char		mode = 0;

	while((c = getopt(argc, argv, "rfump:w:d:?")) != -1)
	{
		switch(c)
		{
			case 'r':
				if (mode) Usage();
				mode = RESERVE;
				break;

			case 'f':
				if (mode) Usage();
				mode = FETCH;
				break;

			case 'u':
				if (mode) Usage();
				mode = UNRESERVE;
				break;

			case 'm': /* move (for lack of a better option) */
				if (mode) Usage();
				mode = REPLACE;
				break;

			case 'p':
				if (project) Usage();
				project = optarg;
				break;

			case 'w':
				if (working_set) Usage();
				working_set = optarg;
				break;

			case 'd':
				if (dir) Usage();
				dir = optarg;
				break;

			case '?':
			default:
				Usage();
		}
	}

	switch(mode)
	{
		case FETCH:
		case RESERVE:
		case REPLACE:
			if (!working_set || !project || !dir)
			{
				Usage();
			}
			break;

		case UNRESERVE:
			if (!working_set || !project)
			{
				Usage();
			}
			break;

		default:
			Usage();
			break;
	}

	output_files_for_spc(project, working_set, mode, dir);

	return 0;
}

/******************************************************************************/
