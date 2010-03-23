/* This program generates the ratio of Environ V font size (which is	*/
/* based on the maximum extent of the DEC Multinational character	*/
/* mapping) to the Font Server font size (which is based on the em	*/
/* square.								*/

#include <stdio.h>
#include <FS.h>
#include <FSTypeface.h>

main (argc, argv)
int	argc;
char	*argv[];
{
	int		stackCount, i, numChars, minExtent, maxExtent, done;
	uInt16		*record, type;
	Int32		x, y, beta;
	TFInfo		tfInfo;
	TFCharInfo	*charDir;
	TFOutlines	*outlines;

	if (argc == 1)
	{
		printf ("Usage:  decRatio typeface\n");
		exit (0);
	}

	FSEnter (0);

	/* Get the tf info */
	if (FSGetTFInfo (argv[1], &tfInfo))
	{
		printf ("Can't get info\n");
		goto Done;
	}

	/* Get the character directory */
	charDir = NULL;
	if (FSGetTFCharDir (argv[1], "dec", &charDir, &numChars))
	{
		printf ("Can't get char info\n");
		goto Done;
	}

	/* Get the outline info for all the characters */
	outlines = NULL;
	if (FSGetTFOutlines (argv[1], &outlines))
	{
		printf ("Can't get outlines\n");
		goto Done;
	}

	minExtent = 1000000;
	maxExtent = 0;
	for (i = 0; i < numChars; i++)
	{
		_FSInitRecState (0);
		record = &outlines[charDir[i].outlineOffs];
		stackCount = 0;
		done = 0;
		while (!done)
		{
			_FSGetRec (0, &record, outlines, &type, &x, &y, &beta);
			switch (type)
			{
				case 12:	/* do char code */
					stackCount++;
					break;

				case 0:		/* end code */
					if (stackCount > 0)
						stackCount--;
					else
						done = 1;
					break;

				case 10:	/* y min extent */
					if (stackCount == 0)
					{
						if (y < minExtent)
							minExtent = y;
					}
					break;

				case 11:	/* y min extent */
					if (stackCount == 0)
					{
						if (y > maxExtent)
							maxExtent = y;
					}
					break;
			}
		}
	}

	printf ("%f\n", (float) (maxExtent - minExtent) / tfInfo.reslPerEm);

	free (outlines);
	free (charDir);
Done:
	FSExit ();
}
