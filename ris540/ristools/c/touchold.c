/* Do not alter this line: $Revision: 1.2.29.1 $ */
#include <stdio.h>
#include <string.h>
#include <sys/types.h>
#if defined(unix)
#include <utime.h>
#endif
#if defined(WIN32)
#include <sys\utime.h>
#endif
#if defined(sco)
#include <prototypes.h>
#endif

#if defined(unix)
#define OLD_TIME 496299600
#endif
#if defined(WIN32)
#define OLD_TIME 496303200
#endif

extern int main(
	int		argc,
	char	*argv[])
{
	int		i;
	struct	utimbuf ut;
	
	if (argc <= 1 || !strcmp(argv[1], "-?"))
	{
		fprintf(stderr, "Usage: %s filename...\n", argv[0]);
		return 1;
	}

	ut.actime = OLD_TIME;
	ut.modtime = OLD_TIME;

	for (i = 1; i < argc; i++)
	{
		if (utime(argv[i], &ut))
		{
			perror(argv[0]);
			return 1;
		}
	}

	return 0;
}
