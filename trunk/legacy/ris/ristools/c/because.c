/* Do not alter this line: $Revision: 1.3.3.1 $ */
/*
**	NAME:							because.c
**	AUTHORS:						Terrence McIntyre
**	CREATION DATE:					3/93
**	ABSTRACT:
**	
**	REVISION HISTORY:
*/
 
/*
**	INCLUDES
*/
#include <stdio.h>
#include <ctype.h>
#include <string.h>
#if defined(__clipper__) || defined(__hpux__)
#include <unistd.h>
#endif
#if defined(WIN32) || defined(DOS)
#include <stdlib.h>
#endif

/*
**	DEFINES
*/
#define EXE	"because"
#if defined(unix)
#define OPEN_TO_READ_MODE	"r"
#endif
#if defined(WIN32) || defined(DOS)
#define OPEN_TO_READ_MODE	"rt"
#endif

#define FEW		10
#define BUNCH		20
#define LARGENUMBER	40

#if defined(WIN32) || defined(DOS)
# define PATH_MAX  _MAX_PATH
#endif
#if defined(unix) && !defined(__clipper__)
# define PATH_MAX  255
#endif

/*
**	TYPES
*/

/*
**	FUNCTION PROTOTYPES
*/

/*
**	VARIABLES
*/
int depends_count = 0;
char depends[FEW-1][PATH_MAX];

/*
**	FUNCTIONS
*/

/******************************************************************************/

int add_depend(
	char *s)
{
	int sts = 0;

	depends_count++;
	if (depends_count < FEW)
	{
		strcpy(depends[depends_count-1], s);
	}
	if (depends_count >= LARGENUMBER)
	{
		sts = 1;
	}

	return sts;
}

/******************************************************************************/

int process_file(
	char *filename)
{
	int c;
	int sts = 0;
	int count;
	char name[PATH_MAX];
	FILE *fp;

	if ((fp = fopen(filename,OPEN_TO_READ_MODE)) == NULL)
	{
		fprintf(stderr, "%s: unable to open \"%s\".\n", filename);
		return 1;
	}

	while (1)
	{
		while ((c = fgetc(fp)) != EOF && isspace(c));
		if (c == EOF) break;
		
		count = 0;
		do
		{
			if (count < PATH_MAX-1)
			{
				name[count++] = (char)c;
			}
		}
		while ((c = fgetc(fp)) != EOF && !isspace(c));
		name[count] = '\0';
		if ((sts = add_depend(name)) != 0)
		{
			break;
		}
		if (c == EOF)
		{
			break;
		}
	}

	fclose (fp);

	return sts;
}

/******************************************************************************/

extern int main(
	int argc,
	char *argv[])
{
	int i;
	
	for (i = 1; i < argc; i++)
	{
		if (argv[i][0] == '@')
		{
			if (process_file(&argv[i][1]) != 0)
			{
				break;
			}
		}
		else
		{
			if (add_depend(argv[i]) != 0)
			{
				break;
			}
		}
	}
	if (depends_count == 1)
	{
		printf("\tBecause of one file:\n");
		printf("\t\t%s\n", depends[0]);
	}
	else if (depends_count < FEW)
	{
		printf("\tBecause of:\n");
		for (i = 0; i < depends_count; i++)
		{
			printf("\t\t%s\n", depends[i]);
		}
	}
	else
	{
		printf("\tBecause of:\n");
		printf("\t\t%s\n", depends[0]);
		if (depends_count < BUNCH)
			printf("\t\tand a few other files\n");
		else if (depends_count < LARGENUMBER)
			printf("\t\tand a bunch of other files\n");
		else
			printf("\t\tand a large number of other files\n");
	}
	return 0;
}

/******************************************************************************/
