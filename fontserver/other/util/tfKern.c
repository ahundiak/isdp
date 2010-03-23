/* This program prints out the kern pairs and kern tracks for the	*/
/* specified typeface and character mapping.				*/


#include <stdio.h>
#include "../hfiles/FS.h"
#include "../hfiles/FSTypeface.h"


main (argc, argv)
int argc;
char *argv[];
{
	int numKerns, numTracks, i, rval;
	TFKernPair *kernTable;
	TFKernTrack *kernTrack;

	if ((argc < 3) || (strcmp (argv[1], "-?") == 0))
	{
		fprintf (stderr, "Usage:  %s typeface charmap\n", argv[0]);
		exit (-1);
	}

	FSEnter (0);

	rval = 0;
	kernTable = NULL;
	kernTrack = NULL;
	if (FSGetTFKernTable (argv[1], argv[2], 0, &kernTable, &numKerns) ||
	    FSGetTFKernTrack (argv[1], &kernTrack, &numTracks))
	{
		fprintf (stderr, "Can't get info!\n");
		rval = 1;
	}
	else
	{
		printf ("Kern pairs (%d):\n", numKerns);
		for (i = 0; i < numKerns; i++)
			printf ("%c (%d) %c (%d)  %d\n",
				kernTable[i].char1, kernTable[i].char1,
				kernTable[i].char2, kernTable[i].char2,
				kernTable[i].adjustment);

		printf ("\n");
		printf ("Kern tracks (%d):\n", numTracks);
		for (i = 0; i < numTracks; i++)
			printf ("%d:  %d %d %d\n",
				kernTrack[i].pointSize, kernTrack[i].trackAdj[0],
				kernTrack[i].trackAdj[1], kernTrack[i].trackAdj[2]);
	}
	
	FSExit ();
	exit (rval);
}
