/* This program prints out information from the header of the specified	*/
/* typeface.								*/


#include <stdio.h>
#include <FS.h>
#include <FSTypeface.h>

main (argc, argv)
int argc;
char *argv[];
{
	int rval;
	FILE *f;
	TFInfo info;
	char str[100];

	if ((argc < 2) || (strcmp (argv[1], "-?") == 0))
	{
		fprintf (stderr, "Usage:  %s typeface\n", argv[0]);
		exit (-1);
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
		strncpy (str, info.outlFmtNr, 8);
		str[8] = '\0';
		printf ("Format number:  %s\n", str);
		strncpy (str, info.srcFontId, 4);
		str[4] = '\0';
		printf ("Source font id:  %s\n", str);
		printf ("Source font version:  %d\n", info.srcFontVrsn);
		printf ("Source font name:  %s\n", info.srcFontName);
		strncpy (str, info.mfgDate, 10);
		str[10] = '\0';
		printf ("Manufacturing date:  %s\n", str);
		printf ("Layout name:  %s\n", info.layoutName);
		printf ("Layout number:  %d\n", info.layoutNumber);
		printf ("Copyright notice:  %s\n", info.cpyrtNotice);
		printf ("Resolution per em:  %d\n", info.reslPerEm);
		printf ("Flag1:  0x%4x\n", info.flag1);
		printf ("Flag2:  0x%4x\n", info.flag2);
		printf ("Offset to kern pairs:  %d\n", info.offsKernPrs);
		printf ("Offset to kern tracks:  %d\n", info.offsKernTrks);
		printf ("Offset to ligature table:  %d\n", info.offsLigTable);
		printf ("Offset to char. directory:  %d\n", info.offsCharDir);
		printf ("Offset to outline data:  %d\n", info.offsOutlData);
		printf ("Layout size:  %d\n", info.layoutSize);
		printf ("Customer number:  %d\n", info.custNumber);
		printf ("Customer notice:  %s\n", info.custNotice);
		printf ("User id:  %d\n", info.userId);
		printf ("User data:  %d\n", info.userData);
	}

	FSExit ();
	exit (rval);
}
