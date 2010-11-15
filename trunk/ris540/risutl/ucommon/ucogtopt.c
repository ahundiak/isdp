/* Do not alter this SPC information: $Revision: 1.1.53.1 $ */
/*
**	NAME:							ucogtopt.c
**	AUTHORS:						Hitesh R. Patel
**	CREATION DATE:					11/92
**	ABSTRACT:
**		Emulates getopt(3) found on CLIX standard C.
**		Does not support:
**		-rhc xxx (where c is legal option but not r and h)
**
**	REVISION HISTORY:
*/
 
/*
**	INCLUDES
*/
#include <stdio.h>
#include "risutl.h"
#include "ucommon.h"

/*
**	DEFINES
*/
#ifdef TEST
#undef UCO_DBG
#define UCO_DBG(s) PRINTF s
#endif

/*
**	TYPES
*/

/*
**	FUNCTION PROTOTYPES
*/
#define ucogtopt_c
#include "comdebug.prt"
#include "ucogtopt.prt"
#include "sys.prt"

/*
**	VARIABLES
*/
#if defined (WIN32) || defined(DOS)
char *optarg = 0;
int  optind = 1;
int  opterr = 0;
#endif

/*
**	FUNCTIONS
*/

/*****************************************************************************/

#if defined (WIN32) || defined(DOS)
extern int getopt(
	int argc,
	char **argv,
	char *optstring)
{
	char *ptrstr = 0;
	static  int offset = 0;

	UCO_DBG(("getopt()\n"));
	UCO_DBG(("optind=%d argc=%d\n", optind, argc));

	optarg = 0;

	if (optind < argc)
	{
		UCO_DBG(("argv[%d] = <%s>\n", optind, argv[optind]));
		if (offset == 0)
		{
			if (argv[optind][offset] != '-')
			{
				/*
				**	First nonoption argument
				*/
				UCO_DBG(("getopt: nonoption argv[%d]:<%s> :returning -1\n",
					optind, argv[optind]));
				return(-1);
			}
			offset++;
		}

		if ((ptrstr = strchr(optstring, argv[optind][offset])) == NULL)
		{
#if !defined(WIN32S)
			if (opterr)
			{
				PRINTF("%s: illegal option -- %c\n", argv[0],
					argv[optind][offset]);
			}
#endif
			offset++;
			if (argv[optind][offset] == '\0')
			{
				optind++;
				offset = 0;
			}
			UCO_DBG(("getopt: illegal option: %c: returing '?'\n",
				argv[optind][offset]));
			return('?');
		}

		if (*(ptrstr+1) == ':')
		{
			/* Expect an argument */

			UCO_DBG(("getopt:Found ':'\n"));

			offset++;
			if (!argv[optind][offset])
			{
				optind++; /* Next */
				offset = 0;

				if (optind >= argc || argv[optind][offset] == '-')
				{
#if !defined(WIN32S)
					if (opterr)
					{
						PRINTF("%s: option requires an argument -- %c\n",
							argv[0], *ptrstr);
					}
#endif
					UCO_DBG(("getopt: option requires arg %c: returning '?'\n",
						*ptrstr));
					return('?');
				}
			}
			optarg = &argv[optind][offset];

			optind++; 
			offset = 0;
		}
		else
		{
			offset++;
			if (argv[optind][offset] == '\0')
			{
				optind++;
				offset = 0;
			}
		}
		UCO_DBG(("getopt(): returning optarg:<%s>\n", optarg));
		return(*ptrstr);
	}
	UCO_DBG(("getopt(): returning -1\n"));
	return(-1);
}
#endif
/*****************************************************************************/

#ifdef TEST
main(
	int argc,
	char **argv)
{
	int c;
	int i;

	opterr = 1;
	getopt_debug = 1;
	for (i = 0; i < argc; i++)
	{
		PRINTF("argv[%d]:0x%x <%s>\n", i, argv[i], argv[i]?argv[i]:"");
	}

	while((c = getopt(argc, argv, "D:o:w")) != -1)
	{
		UCO_DBG(("c:%c\n", c));
		UCO_DBG(("optarg:0x%x <%s>\n", optarg, optarg?optarg:""));
		UCO_DBG(("optind:%d\n", optind));
	}

	UCO_DBG(("optarg:0x%x <%s>\n", optarg, optarg?optarg:""));
	UCO_DBG(("optind:%d\n", optind));
	if (optind != argc - 1)
	{
		UCO_DBG(("ERROR found.\n"));
	}
}
#endif

/*****************************************************************************/
