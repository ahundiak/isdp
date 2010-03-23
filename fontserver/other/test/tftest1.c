/* This program tests the FSGetTF* routines.  It lets the routines	*/
/* allocate the memory for the data returned.				*/


#include <stdio.h>
#include <FS.h>
#include <FSTypeface.h>


main (argc, argv)
int argc;
char *argv[];
{
	int numKerns, numTracks, numLigs, numChars, outlinesSize, i;
	char *tf;
	char *charMap;
	TFInfo info;
	TFKernPair *kernTable = NULL;
	TFKernTrack *kernTrack = NULL;
	TFLigature *ligature = NULL;
	TFCharInfo *charInfo = NULL;
	TFOutlines *outlines = NULL;

	FSEnter (0);

	tf = "swiss742";
	if (argc > 1)
		tf = argv[1];

	charMap = "ascii";
	if (argc > 2)
		charMap = argv[2];

	FSGetTFInfo (tf, &info);

	FSGetTFKernTable (tf, charMap, 0, NULL, &numKerns);
	FSGetTFKernTrack (tf, NULL, &numTracks);
	FSGetTFLigTable (tf, charMap, NULL, &numLigs);
	FSGetTFCharDir (tf, charMap, NULL, &numChars);
	FSGetTFOutlines (tf, NULL, &outlinesSize);

	printf ("%d 0   %d 0   %d 0   %d 0   %d 0\n",
		numKerns, numTracks, numLigs, numChars, outlinesSize);

	FSGetTFKernTable (tf, charMap, 0, &kernTable, &numKerns);
	FSGetTFKernTrack (tf, &kernTrack, &numTracks);
	FSGetTFLigTable (tf, charMap, &ligature, &numLigs);
	FSGetTFCharDir (tf, charMap, &charInfo, &numChars);
	FSGetTFOutlines (tf, &outlines, &outlinesSize);

	printf ("%d %d   %d %d   %d %d   %d %d   %d %d\n\n",
		numKerns, kernTable,
		numTracks, kernTrack,
		numLigs, ligature,
		numChars, charInfo,
		outlinesSize, outlines);
	printf ("file name: %s\n", tf);
	printf ("info.layoutName: %s\n", info.layoutName);
	printf ("resolution per em: %d\n", info.reslPerEm);

	printf ("\nKern pairs:\n");
	for (i = 0; i < numKerns; i++)
		printf ("%c (%d) %c (%d)  %d\n",
			kernTable[i].char1, kernTable[i].char1,
			kernTable[i].char2, kernTable[i].char2,
			kernTable[i].adjustment);

	printf ("\nKern tracks:\n");
	for (i = 0; i < numTracks; i++)
		printf ("%d:  %d %d %d\n",
			kernTrack[i].pointSize, kernTrack[i].trackAdj[0],
			kernTrack[i].trackAdj[1], kernTrack[i].trackAdj[2]);
	
	printf ("\nChar Dirs:\n");
	for (i = 0; i < numChars; i++)
		printf ("%c (%d):  %d %d\n",
			charInfo[i].charId, charInfo[i].charId,
			charInfo[i].setWidth, charInfo[i].outlineOffs);

	free (kernTable);
	free (kernTrack);
	free (ligature);
	free (charInfo);
	free (outlines);

	FSExit ();
}
