/* This program prints out information about the characters of the	*/
/* specified character mapping in the specified typeface.		*/


#include <stdio.h>
#include <FS.h>
#include <FSTypeface.h>


main (argc, argv)
int argc;
char *argv[];
{
	int numChars, i, rval;
	TFCharInfo *charInfo;

	if ((argc < 3) || (strcmp (argv[1], "-?") == 0))
	{
		fprintf (stderr, "Usage:  %s typeface charmap\n", argv[0]);
		exit (1);
	}

	FSEnter (0);

	rval = 0;
	charInfo = NULL;
	if (FSGetTFCharDir (argv[1], argv[2], &charInfo, &numChars))
	{
		fprintf (stderr, "Can't get char info!\n");
		rval = 1;
	}
	else
	{
		printf ("Characters (%d):\n", numChars);
		for (i = 0; i < numChars; i++)
			printf ("%d  %d  %c (%d)\n",
				charInfo[i].setWidth, charInfo[i].outlineOffs,
				charInfo[i].charId, charInfo[i].charId);
	}

	FSExit ();
	exit (rval);
}
