/* This program prints out information about the specified character	*/
/* in the specified bitmap font.					*/


#include <stdio.h>
#include "../hfiles/FS.h"
#include "../hfiles/FSBmap.h"


FontSpec fontSpec = {	"swiss742",	/* typeface	*/
			48.0,		/* bodysize	*/
			1.0,		/* arf		*/
			1.0,		/* aspect ratio	*/
			0.0,		/* rotation	*/
			0.0,		/* slant	*/
			"dec",
			FS_ALL_BITMAPS
		    };

main (argc, argv)
int argc;
char *argv[];
{
    FontId font;
    CharId ch;
    int rVal;
    double atof ();
    BmapInfo info;
    BmapCharInfo charInfo;

    if (argc <= 1)
    {
	printf ("Usage:  %s {charNum} [typeface] [size] [charMap] [flags]\n",
		argv[0]);
	exit (1);
    }

    ch = (CharId) atoi (argv[1]);

    if (argc > 2)
	fontSpec.typeface = argv[2];

    if (argc > 3)
	fontSpec.bodySize = atof (argv[3]);

    if (argc > 4)
	fontSpec.charMap = argv[4];

    if (argc > 5)
	fontSpec.flags = atof (argv[5]);
    fontSpec.flags &= ~FS_OUTLINE;
    fontSpec.flags |= (FS_NO_KERN | FS_DEMAND);

    FSEnter (0);
    if ((rVal = FSNewFont (&fontSpec, NULL, &font)) != FS_NO_ERROR)
    {
	fprintf (stderr, "Can't create font: %d\n", rVal);
	goto Done;
    }

    FSGetBmapInfo (font, &info);

    /** Get the character info */
    if ((rVal = FSGetBmapCharInfo (font, ch, &charInfo)) == FS_NO_ERROR)
    {
	/** Print the info **/
	printf ("Width:  %f\n", charInfo.setWid);
	printf ("H Offset:  %d\n", charInfo.hOff);
	printf ("V Offset:  %d\n", charInfo.vOff);
	printf ("R Width:  %d\n", charInfo.rWid);
	printf ("R Height:  %d\n", charInfo.rHgt);
	printf ("Num Bytes:  %d\n", charInfo.nMap);
	printf ("Flags:  %d\n", charInfo.flags);
    }
    else
	printf ("Error: %d\n", rVal);

Done:
    FSExit ();
}
