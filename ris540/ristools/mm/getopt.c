/* Do not alter this SPC information: $Revision: 1.1.54.1 $ */
/*
**	NAME:		getopt.c
**	AUTHOR:		Hitesh R. Patel
**	DATE:		11/1/92
**	DESCRIPTION:	Emulates getopt(3) found on CLIX standard C.
**			Does not support:
**			-rhc xxx (where c is legal option but not r and h)
**
*/

/*
** DEFINES
*/
int getopt_debug = 0;
#define DBG(s) if(getopt_debug) printf s

/*
**	INCLUDES
*/
#include <stdio.h>

/*
**	FUNCTION PROTOTYPE
*/
#define getopt_c
#include "sys.prt"

/*
** 	VARIABLES
*/
#if defined (WIN32) || defined(DOS)
char *optarg = 0;
int  optind = 1;
int  opterr = 0;
#endif

/*****************************************************************************/

#if defined (WIN32) || defined(DOS)
extern int getopt(
	int argc,
	char **argv,
	char *optstring)
{
	char *ptrstr = 0;

	DBG(("getopt()\n"));
	DBG(("optind=%d argc=%d\n", optind, argc));

	optarg = 0;

	if (optind < argc)
	{
		DBG(("argv[%d] = <%s>\n", optind, argv[optind]));
		if( *argv[optind] == '-' )
		{
			ptrstr = strchr(optstring, *(argv[optind]+1));
			if( ptrstr )
			{
				if( *(ptrstr+1) == ':' )
				{
					DBG(("getopt:Found ':'.\n"));
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
				DBG(("getopt(): returning optarg:<%s>\n", optarg));
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
			DBG(("getopt(): returning\n"));
			return(-1);
		}
	}
	DBG(("getopt(): returning\n"));
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
		printf("argv[%d]:0x%x <%s>\n", i, argv[i], argv[i]?argv[i]:"");
	}

	while((c = getopt(argc, argv, "D:o:w")) != -1)
	{
		DBG(("c:%c\n", c));
		DBG(("optarg:0x%x <%s>\n", optarg, optarg?optarg:""));
		DBG(("optind:%d\n", optind));
	}

	DBG(("optarg:0x%x <%s>\n", optarg, optarg?optarg:""));
	DBG(("optind:%d\n", optind));
	if (optind != argc - 1)
	{
		DBG(("ERROR found.\n"));
	}
}
#endif

/*****************************************************************************/
