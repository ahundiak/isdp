/* Sample program for parsing the outline data of a character in a	*/
/* Font Server typeface.						*/

#include <stdio.h>
#include <FS.h>
#include <FSTypeface.h>

main ()
{
	int		stackCount, i, numChars;
	uInt16		*start, *record, type;
	uInt32		x, y, beta;
	TFCharInfo	*charDir;
	TFOutlines	*outlines;

	FSEnter (0);

	/* Get the character directory */
	charDir = NULL;
	FSGetTFCharDir ("swiss742", "ascii", &charDir, &numChars);

	/* Get the outline info for all the characters */
	outlines = NULL;
	FSGetTFOutlines ("swiss742", &outlines);

	/* Find the letter 'A' in the character directory */
	for (i = 0; charDir[i].charId != 'A'; i++);

	/* Read the outline info for the character 'A' */
	_FSInitRecState (0);
	start = outlines;
	record = &outlines[charDir[i].outlineOffs];
	stackCount = 0;
	for (;;)
	{
		_FSGetRec (0, &record, start, &type, &x, &y, &beta);
		printf ("%d: %d %d %d\n", type, x, y, beta);

		if (type == 12)		/* do char code */
			stackCount++;

		if (type == 0)		/* end code */
		{
			if (stackCount > 0)
				stackCount--;
			else
				break;
		}
	}

	free (outlines);
	free (charDir);
	FSExit ();
}
