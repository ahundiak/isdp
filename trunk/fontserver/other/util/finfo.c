/* This program prints out information about the specified font.	*/


#include <stdio.h>
#include "FS.h"
#include "FSBmap.h"
#include "FSOutl.h"


FontSpec fontSpec = {	"swiss742",	/* typeface	*/
			48.0,		/* bodysize	*/
			1.0,		/* arf		*/
			1.0,		/* aspect ratio	*/
			0.0,		/* rotation	*/
			0.0,		/* slant	*/
			"ascii",
			FS_DEMAND
		    };

main (argc, argv)
int argc;
char *argv[];
{
    FontId font;
    int bmap, rval;
    double atof ();
    BmapInfo info;

    if (argc > 1)
	fontSpec.typeface = argv[1];

    if (argc > 2)
	fontSpec.bodySize = atof (argv[2]);

    if (argc > 3)
	fontSpec.charMap = argv[3];

    if (argc > 4)
	fontSpec.flags = atof (argv[4]);

    FSEnter (0);
    if ((rval = FSNewFont (&fontSpec, NULL, &font)) != FS_NO_ERROR)
    {
	fprintf (stderr, "Can't create font: %d\n", rval);
	goto Done;
    }

    /** Decide if font is bmap or outl **/
    bmap = (FSGetBmapInfo (font, &info) == FS_NO_ERROR);
    if (!bmap)
	FSGetOutlInfo (font, &info);

    /** Print the info **/
    printf ("Typeface:  %s\n", info.typeface);
    printf ("Bodysize:  %f\n", info.bodySize);
    printf ("Res Factor:  %f\n", info.resFactor);
    printf ("Aspect Ratio:  %f\n", info.aspect);
    printf ("Rotation:  %f\n", info.rotation);
    printf ("Slant:  %f\n", info.slant);
    printf ("Char Map:  %s\n", info.charMap);
    printf ("Flags:  %d\n", info.flags);
    printf ("Ascent:  %f\n", info.ascent);
    printf ("Descent:  %f\n", info.descent);
    printf ("Min Extent:  %f\n", info.minExtent);
    printf ("Max Extent:  %f\n", info.maxExtent);
    printf ("Miss Char:  %d\n", info.missingChar);

Done:
    FSExit ();
}
