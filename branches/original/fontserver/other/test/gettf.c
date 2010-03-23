/* This program exercises the FSGetTypefaces() call.  It also prints	*/
/* out the list of available typefaces on this machine.			*/


#include <stdio.h>
#include <FS.h>


main (argc, argv)
int argc;
char *argv[];
{
	int	numTF, i, j, k, numSpaces;
	char	(*tfNames)[15];

	FSEnter (0);

	tfNames = (char (*)[15]) malloc (1);
	for (i = 0; i < 100; i++)
	{
	    printf ("%3d\r", 99 - i);
	    fflush (stdout);

	    free (tfNames);
	    tfNames = NULL;
	    FSGetTypefaces (&tfNames, &numTF);
	}

	printf ("Total: %d\n", numTF);
	for (i = 0; i < numTF;)
	{
	    for (j = 0; (j < 5) && (i < numTF); j++, i++)
	    {
		printf ("%s", tfNames[i]);
		numSpaces = 16 - strlen (tfNames[i]);
		for (k = 0; k < numSpaces; k++)
			printf (" ");
	    }
	    printf ("\n");
	}

	free (tfNames);
	FSExit ();
}
