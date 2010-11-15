/* Do not alter this line: $Revision: 1.2.29.1 $ */
#include <stdio.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <string.h>
#include <ftw.h>
#if defined(sco)
#include <prototypes.h>
#endif

#define OLD_TIME 496299600

/******************************************************************************/
/* add const for s and p for HPUX */
int fn(
#if defined(__Sol2__) || defined(Soli) || defined(__hpux__)
	const char		*s,
	const struct stat	*p,
	int			i)
#else
	char		*s,
	struct stat	*p,
	int		i)
#endif
{
	i = i;

	if (p->st_mtime == OLD_TIME)
	{
    	printf("%s\n",s);
	}

    return 0;
}

/******************************************************************************/

extern void main(
	int		argc,
	char 	*argv[])
{
#if defined(__hpux__)
	const char *path;
#else
	char *path;
#endif

	switch(argc)
	{
		case 1:
			path = ".";
			break;

		case 2:
			if (!strcmp(argv[1], "-?"))
			{
				fprintf(stderr, "Usage: %s [path]\n", argv[0]);
				return;
			}
			path = argv[1];
			break;

		default:
			fprintf(stderr, "Usage: %s [path]\n", argv[0]);
			return;
	}

    ftw(path, fn, 7);
}

/******************************************************************************/
