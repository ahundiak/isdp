/* This program tests the FSGetTF* routines.  It allocates the memory	*/
/* for the data and calls the routines, which copy the data into the	*/
/* allocated memory.							*/
/* It also tests the capability of passing in the obsolete integer	*/
/* character mappings.							*/


#include <stdio.h>
#include <FS.h>
#include <FSTypeface.h>


main (argc, argv)
int argc;
char *argv[];
{
	int numKerns, numTracks, numLigs, numChars, outlinesSize, i;
	char *tf;
	CharMapId charMap;	/* obsolete char map id */
	TFInfo info;
	TFKernPair *kernTable;
	TFKernTrack *kernTrack;
	TFLigature *ligature;
	TFCharInfo *charInfo;
	TFOutlines *outlines;

	FSEnter (0);

	tf = "swiss742";
	if (argc > 1)
		tf = argv[1];

	charMap = 0;	/* 0 = ascii (obsolete) */
	if (argc > 2)
		charMap = atoi (argv[2]);

	FSGetTFInfo (tf, &info);

	FSGetTFKernTable (tf, charMap, 0, NULL, &numKerns);
	FSGetTFKernTrack (tf, NULL, &numTracks);
	FSGetTFLigTable (tf, charMap, NULL, &numLigs);
	FSGetTFCharDir (tf, charMap, NULL, &numChars);
	FSGetTFOutlines (tf, NULL, &outlinesSize);

	kernTable = (TFKernPair *) malloc (numKerns * sizeof (TFKernPair));
	kernTrack = (TFKernTrack *) malloc (numTracks * sizeof (TFKernTrack));
	ligature = (TFLigature *) malloc (numLigs * sizeof (TFLigature));
	charInfo = (TFCharInfo *) malloc (numChars * sizeof (TFCharInfo));
	outlines = (TFOutlines *) malloc (outlinesSize * sizeof (TFOutlines));

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
