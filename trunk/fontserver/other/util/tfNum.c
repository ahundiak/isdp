/* This program prints out the typeface number of the specified		*/
/* typeface.  It is assigned by Bitstream.				*/


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
		fprintf (stderr, "Usage:  tfName typeface\n");
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
	{
		info.srcFontId[4] = '\0';
		printf ("%s\n", info.srcFontId);
	}

	FSExit ();
	exit (rval);
}
