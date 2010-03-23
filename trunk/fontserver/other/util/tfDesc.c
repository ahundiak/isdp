/* This program prints out the description of the specified typeface.	*/


#include <stdio.h>
#include "../hfiles/FS.h"
#include "../hfiles/FSTypeface.h"

main (argc, argv)
int argc;
char *argv[];
{
	int	rval;
	FILE	*f;
	TFInfo	info;

	if ((argc < 2) || (strcmp (argv[1], "-?") == 0))
	{
		fprintf (stderr, "Usage:  %s typeface\n", argv[0]);
		exit (1);
	}

	FSEnter (0);

	rval = 0;
	if (FSGetTFInfo (argv[1], &info) != FS_NO_ERROR)
	{
		fprintf (stderr, "Can't get info!\n");
		rval = 1;
	}
	else
		printf ("%s\n", info.srcFontName);

	FSExit ();
	exit (rval);
}
